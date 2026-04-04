{ pkgs, ... }:
let
  hsPkgs = pkgs.haskell.packages.ghc96;
  shell =
    { pkgs, ... }:
    {
      languages.elm.enable = true;
      languages.haskell.enable = true;
      languages.haskell.package = pkgs.haskell.packages.ghc96.ghcWithPackages (
        ps: with ps; [
          aeson
          aeson-pretty
          toml-parser
          temporary
          tasty
          tasty-hunit
          tasty-quickcheck
        ]
      );

      packages = [
        hsPkgs.hlint
        hsPkgs.fourmolu
        pkgs.git
        pkgs.treefmt
        pkgs.elmPackages.elm-format
        pkgs.elmPackages.elm-review
      ];

      enterShell = ''
        echo ""
        echo "── design-tokens dev environment ─────────────────────"
        echo "  GHC:   $(ghc --version)"
        echo "  Cabal: $(cabal --version | head -1)"
        echo ""
        echo "  make build  — compile Haskell"
        echo "  make gen    — generate dist/ artifacts"
        echo "  make test   — run tests + hlint"
        echo ""
      '';
    };
in
{
  profiles.shell.module = {
    imports = [ shell ];
  };

  dotenv.disableHint = true;
}
