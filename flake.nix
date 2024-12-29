{
  description = "code-nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, nixpkgs, flake-utils, extensions, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        vscode-marketplace = extensions.extensions.${system}.vscode-marketplace;

        code = { extensions ? [], userDir ? ""}: let 
          script = ''
            #!/usr/bin/env bash

            if [ -z ${userDir} ]; then
                USER_DIR="/tmp/nix-code/''$(uuidgen)/"
            else
                USER_DIR=${userDir}
            fi

            ${(pkgs.vscode-with-extensions.override { vscodeExtensions = extensions; })}/bin/code --user-data-dir ''$USER_DIR $@
            '';
          in pkgs.writeShellScriptBin "code" script;
      in
      {
        packages.default = code;
        
        vscode = code;
        
        extensions = vscode-marketplace;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.nixpkgs-fmt
            (code {
                extensions = [
                  vscode-marketplace.bbenoist.nix
                  vscode-marketplace.mkhl.direnv
                ];
            })
          ];
        };
      });
}
