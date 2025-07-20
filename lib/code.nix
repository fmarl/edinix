{ pkgs, profileDefinitions }:
{
  profiles ? { },
  extraExtensions ? [ ],
  userDir ? "",
}:
let
  tooling = profileDefinitions.getTooling profiles;
  settings = profileDefinitions.getSettings profiles;

  script = ''
    #!/usr/bin/env bash

    if [ -z "$USER_DIR" ]; then
        USER_DIR="/tmp/code-nix/$(uuidgen)"
    else
        USER_DIR="${userDir}"
    fi

    mkdir -p "$USER_DIR/User"

    echo '${builtins.toJSON settings}' > "$USER_DIR/User/settings.json"

    ${
      (pkgs.vscode-with-extensions.override {
        vscodeExtensions = (profileDefinitions.getEnabledExtensions profiles) ++ extraExtensions;
      })
    }/bin/code --user-data-dir "$USER_DIR" "$@"
  '';
in
{
  editor = pkgs.writeShellScriptBin "code" script;
  tooling = tooling;
}
