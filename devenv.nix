{ pkgs, ... }:
let
  hsPkgs = pkgs.haskell.packages.ghc96;

  # ghcWithPackages bundles all project deps into a single consolidated
  # package-db, giving ONE bin-dir entry in PATH instead of hundreds of
  # individual Haskell derivations.  The old logoDrv.nativeBuildInputs
  # approach pulled in HLS and all its transitive deps as separate entries,
  # blowing up PATH past Linux's per-string MAX_ARG_STRLEN limit and causing
  # posix_spawnp to fail with E2BIG when cabal tried to configure the package.
  ghcWithDeps = hsPkgs.ghcWithPackages (ps: with ps; [
    # library deps (logo.cabal: library build-depends)
    text bytestring base64-bytestring
    directory filepath process xml-conduit
    aeson aeson-pretty JuicyPixels containers vector
    # test deps (logo.cabal: test-suite build-depends)
    tasty tasty-hunit tasty-quickcheck temporary
  ]);

  elm-pages = pkgs.callPackage ./elm-pages.nix {
    lamdera = pkgs.elmPackages.lamdera;
  };
in {
  profiles.shell.module = {
    languages.elm.enable = true;

    packages = [
      ghcWithDeps
      hsPkgs.cabal-install
      hsPkgs.haskell-language-server
      hsPkgs.hlint
      hsPkgs.fourmolu
      # External raster/image tools (called via System.Process)
      pkgs.librsvg       # provides rsvg-convert
      pkgs.libwebp       # provides cwebp, img2webp
      pkgs.gifski        # animated GIF
      pkgs.icoutils      # provides icotool (favicon.ico)
      pkgs.imagemagick   # fallback for animated WebP (convert)
      pkgs.git
      pkgs.treefmt
      # Elm tooling
      pkgs.nodejs
      pkgs.elmPackages.elm-format
      pkgs.elmPackages.elm-review
      pkgs.elmPackages.elm-test
      pkgs.elmPackages.elm-json
      pkgs.elmPackages.lamdera
      elm-pages
      # Other CLI tools
      pkgs.entr
    ];

    enterShell = ''
      git --version
      cabal --version
      elm-pages --version
    '';
  };
}
