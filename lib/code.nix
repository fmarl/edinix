{ pkgs, profileDefinitions }:
{ profiles ? { }, extraExtensions ? [ ], userDir ? "" }:
let
  script = ''
    #!/usr/bin/env bash

    if [ -z "$USER_DIR" ]; then
        USER_DIR="/tmp/code-nix/$(uuidgen)"
    else
        USER_DIR="${userDir}"
    fi

    ${(pkgs.vscode-with-extensions.override {
      vscodeExtensions = (profileDefinitions.getEnabledExtensions profiles) ++ extraExtensions;
    })}/bin/code --user-data-dir "$USER_DIR" "$@"
  '';
in
pkgs.writeShellScriptBin "code" script
