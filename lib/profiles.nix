{ pkgs, vscode-marketplace }:
let
  profileDefinitions = {
    # The default extensions are active, unless we deactivate them explicitly.
    default = {
      enable = true;
      vscodeExtensions = [ vscode-marketplace.mkhl.direnv ];
      tooling = [ ];
    };

    nix = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.bbenoist.nix
        vscode-marketplace.jnoortheen.nix-ide
      ];
      tooling = [ pkgs.nil pkgs.nixfmt ];
    };

    rust = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.rust-lang.rust-analyzer
        vscode-marketplace.tamasfe.even-better-toml
      ];
      tooling = [ ];
    };

    go = {
      enable = false;
      vscodeExtensions = [ vscode-marketplace.golang.go ];
      tooling = [
        pkgs.go
        pkgs.gopls
        pkgs.gotools
        pkgs.go-tools
        pkgs.gopkgs
        pkgs.golangci-lint
        pkgs.delve
        pkgs.gotests
      ];
    };

    clojure = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.betterthantomorrow.calva
        vscode-marketplace.betterthantomorrow.calva-spritz
      ];
      tooling = [
        pkgs.clojure
        pkgs.clojure-lsp
        pkgs.clj-kondo
        pkgs.cljstyle
        pkgs.leiningen
        pkgs.rlwrap
        pkgs.openjdk
      ];
    };

    haskell = {
      enable = false;
      vscodeExtensions = [ vscode-marketplace.haskell.haskell ];
      tooling = [ ];
    };
  };

  isActive = activeProfiles: name:
    ((builtins.hasAttr name activeProfiles && activeProfiles.${name}.enable
      && builtins.hasAttr name profileDefinitions)
      || (profileDefinitions.${name}.enable));
in {
  getEnabledExtensions = activeProfiles:
    builtins.concatLists (builtins.filter (x: x != null) (builtins.map (name:
      if (isActive activeProfiles name) then
        profileDefinitions.${name}.vscodeExtensions
      else
        null) (builtins.attrNames profileDefinitions)));

  getTooling = activeProfiles:
    builtins.concatLists (builtins.filter (x: x != null) (builtins.map (name:
      if (isActive activeProfiles name) then
        profileDefinitions.${name}.tooling
      else
        null) (builtins.attrNames profileDefinitions)));
}
