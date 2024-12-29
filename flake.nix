{
  description = "code-nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, nixpkgs, flake-utils, extensions, ... }:
    let
      inherit (import ./modules/profiles.nix { inherit extensions; }) profiles;
      code = import ./modules/code.nix {
        inherit nixpkgs extensions profiles;
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        selectedNativeBuildInputs = builtins.concatLists (builtins.attrValues (builtins.filterAttrs (_: v: v.nativeBuildInputs) profiles));
      in
      {
        packages.default = code;

        vscode = code;

        extensions = extensions.extensions.${system}.vscode-marketplace;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = builtins.concatLists [
            selectedNativeBuildInputs
            (code {
              profiles = {
                nix = true;
                rust = true;
              };
            })
          ];
        };
      });
}
