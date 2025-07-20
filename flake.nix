{
  description = "code-nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      extensions,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        vscode-marketplace = extensions.extensions.${system}.vscode-marketplace;

        profileDefinitions = import ./lib/profiles.nix { inherit pkgs vscode-marketplace; };

        code = import ./lib/code.nix { inherit pkgs profileDefinitions; };
      in
      {
        packages.default = code;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            (code { profiles.nix.enable = true; }).editor
            (code { profiles.nix.enable = true; }).tooling
          ];
        };
      }
    );
}
