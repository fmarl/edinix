{ nixpkgs, extensions, profiles }:
let
  pkgs = import nixpkgs {
    config = { allowUnfree = true; };
  };
in
{ profiles ? {}, extraExtensions ? [], userDir ? "" }:
let
  selectedExtensions = builtins.concatLists ([
    (builtins.concatLists (builtins.attrValues (builtins.filterAttrs (_: v: v.vscodeExtensions) profiles)))
    extraExtensions
  ]);

  script = ''
    #!/usr/bin/env bash

    if [ -z ${userDir} ]; then
        USER_DIR="/tmp/code-nix/''$(uuidgen)/"
    else
        USER_DIR=${userDir}
    fi

    ${(pkgs.vscode-with-extensions.override { vscodeExtensions = selectedExtensions; })}/bin/code --user-data-dir ''$USER_DIR $@
    '';
in
pkgs.writeShellScriptBin "code" script
