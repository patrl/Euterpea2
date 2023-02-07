{
  description = "A basic flake for euterpea";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          # This overlay adds our project to pkgs
          euterpea =
            final.haskell-nix.project' {
              src = ./.;
              compiler-nix-name = "ghc924";
              # This is used by `nix develop .` to open a shell for use with
              # `cabal`, `hlint` and `haskell-language-server`
              # shell = {
            #     withHoogle = true;
            #     tools = {
            #       ghcid = {};
            #       hlint = {};
            #       ormolu = {}; 
            #       cabal-install = {};
            #       # haskell-language-server = {}; # FIXME this isn't hitting the binary cache for some reason
            #     };
            #   };
            # };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.euterpea.flake {};
    in flake // {
      # Built by `nix build .`
      packages.default = flake.packages."haskell-flake:exe:haskell-flake";
    });
}
