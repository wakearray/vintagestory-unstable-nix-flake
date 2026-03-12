{
  description = "A flake to provide support for running the most recent unstable version of Vintagestory.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages.${system} = {
      vintagestory-unstable = pkgs.callPackage ./package.nix { };

      default = self.packages.${system}.vintagestory-unstable;
    };
  };
}
