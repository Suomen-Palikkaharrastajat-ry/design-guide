# elm-pages CLI packaged via Nix, using the project's own pnpm-lock.yaml
# so the version is always in sync with package.json.
#
# The derivation fetches pnpm deps in the Nix sandbox (--ignore-scripts skips
# elm-tooling and other postinstall steps that require network access) and
# wraps the resulting elm-pages binary to ensure the Nix-packaged lamdera is
# always found first on PATH.
#
# How to update pnpmDepsHash after changing pnpm-lock.yaml:
#   1. Set pnpmDepsHash = pkgs.lib.fakeHash; below
#   2. Run `devenv shell` — the build will fail with the correct sha256
#   3. Paste that sha256 here
#
# Or use the nix build command directly:
#   nix build --impure --expr \
#     'let p=(builtins.getFlake "nixpkgs").legacyPackages.x86_64-linux;
#      in p.callPackage ./elm-pages.nix {lamdera=p.elmPackages.lamdera;}' \
#     2>&1 | grep "got:"
{ pkgs, lamdera }:
let
  # Strip the postinstall script from package.json so that elm-tooling does not
  # run during the Nix pnpm-deps fetch (it needs network + elm-tooling.json).
  # elm / elm-format come from Nix packages instead.
  # lamdera stays in devDependencies so pnpm-lock.yaml remains consistent;
  # --ignore-scripts prevents its postinstall from running.
  patchedSrc = pkgs.runCommand "elm-pages-pnpm-src" { nativeBuildInputs = [ pkgs.jq ]; } ''
    mkdir $out
    jq 'del(.scripts.postinstall)' ${./package.json} > $out/package.json
    cp ${./pnpm-lock.yaml} $out/pnpm-lock.yaml
    cp ${./pnpm-workspace.yaml} $out/pnpm-workspace.yaml
  '';

  pnpmDeps = pkgs.fetchPnpmDeps {
    pname = "elm-pages";
    src = patchedSrc;
    fetcherVersion = 3;
    # Computed by building with pkgs.lib.fakeHash and reading the "got:" line.
    # To update: set back to pkgs.lib.fakeHash, run the nix build command above,
    # then replace this value with the sha256 printed in the error output.
    hash = "sha256-UwjgOJVRj9Nd9rwtVGzpUBEUDvde1oetSnbNpqyAX1U=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "elm-pages";
  version = "3.1.5";

  src = patchedSrc;

  inherit pnpmDeps;

  # Skip postinstall scripts:
  #   - elm-tooling install  (elm / elm-format come from Nix)
  #   - any native binary download steps (lamdera/esbuild ship prebuilt in npm)
  pnpmInstallFlags = "--ignore-scripts";

  nativeBuildInputs = [
    pkgs.nodejs
    pkgs.pnpm
    pkgs.pnpmConfigHook
    pkgs.makeWrapper
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp -r node_modules $out/lib/

    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/elm-pages \
      --add-flags "$out/lib/node_modules/elm-pages/generator/src/cli.js" \
      --prefix PATH : "$out/lib/node_modules/.bin" \
      --prefix PATH : ${lamdera}/bin

    runHook postInstall
  '';
}
