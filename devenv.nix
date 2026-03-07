{ pkgs, inputs, ... }:
let
  stable = import inputs.nixpkgs-stable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
    };
  };
in {
  profiles.shell.module = {
    languages.haskell = {
      enable = true;
      package = pkgs.haskell.packages.ghc96.ghc;
      stack.enable = true;
    };
    packages = [
      pkgs.claude-code
      # Haskell tooling (from stable channel for reproducibility)
      stable.haskell.packages.ghc96.cabal-install
      stable.haskell.packages.ghc96.fourmolu
      stable.haskell.packages.ghc96.hlint
      stable.haskell.packages.ghc96.haskell-language-server
      # External raster/image tools (called via System.Process)
      pkgs.librsvg       # provides rsvg-convert
      pkgs.libwebp       # provides cwebp, img2webp
      pkgs.gifski        # animated GIF
      pkgs.icoutils      # provides icotool (favicon.ico)
      pkgs.imagemagick   # fallback for animated WebP (convert)
      pkgs.git
      pkgs.treefmt
      # tmp
      (pkgs.python3.withPackages(ps: [ ps.cairosvg ]))
    ];
    enterShell = ''
      git --version
      cabal --version
    '';
  };
}
