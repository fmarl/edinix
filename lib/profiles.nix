{ pkgs, vscode-marketplace }:
let
  profileDefinitions = {
    # The default extensions are active, unless we deactivate them explicitly.
    default = {
      enable = true;
      vscodeExtensions = [
        vscode-marketplace.mkhl.direnv
      ];
    };

    nix = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.bbenoist.nix
        vscode-marketplace.jnoortheen.nix-ide
      ];
    };

    c = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.llvm-vs-code-extensions.vscode-clangd
      ];
    };

    cpp = c;

    rust = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.rust-lang.rust-analyzer
        vscode-marketplace.tamasfe.even-better-toml
      ];
    };

    go = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.golang.go
      ];
    };

    haskell = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.haskell.haskell
      ];
    };
  };
in
{
  getEnabledExtensions = activeProfiles:
    builtins.concatLists (builtins.filter
      (x: x != null)
      (builtins.map
        (name:
          if (builtins.hasAttr name activeProfiles && activeProfiles.${name}.enable && builtins.hasAttr name profileDefinitions) || (profileDefinitions.${name}.enable)
          then profileDefinitions.${name}.vscodeExtensions
          else null)
        (builtins.attrNames profileDefinitions)
      ));
}
