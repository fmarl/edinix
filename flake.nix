{
  description = "nix-code";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, nixpkgs, flake-utils, nix-vscode-extensions, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        vscode-marketplace = nix-vscode-extensions.extensions.${system}.vscode-marketplace;

        code = { extensions ? [], userDir }: let 
          script = ''
            #!/usr/bin/env bash

            ${(pkgs.vscode-with-extensions.override { vscodeExtensions = extensions; })}/bin/code --user-data-dir ${userDir} $@
            '';
          in pkgs.writeShellScriptBin "code" script;
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.nixpkgs-fmt
            (code {
                extensions = [
                  vscode-marketplace.bbenoist.nix
                  vscode-marketplace.mkhl.direnv
                ];

                userDir = "$HOME/.vscode/${self}";
            })
          ];
        };
      });
}
