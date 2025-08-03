{ pkgs }:
let
  profileDefinitions = {
    # The default extensions are active, unless we deactivate them explicitly.
    default = {
      enable = true;
      tooling = [ ];
    };

    nix = {
      enable = false;

      tooling = with pkgs; [
        nil
        nixfmt
        nixfmt-tree
      ];
    };

    c = {
      enable = false;

      tooling = with pkgs; [ clang-tools ];
    };

    cpp = {
      enable = false;

      tooling = with pkgs; [ clang-tools ];
    };

    rust = {
      enable = false;

      tooling = [ ];
    };

    go = {
      enable = false;

      tooling = with pkgs; [
        go
        gopls
        gotools
        go-tools
        gopkgs
        golangci-lint
        delve
        gotests
      ];
    };

    clojure = {
      enable = false;

      tooling = with pkgs; [
        clojure
        clojure-lsp
        clj-kondo
        cljstyle
        leiningen
        rlwrap
        openjdk
      ];
    };

    haskell = {
      enable = false;

      tooling = [ ];
    };

    sh = {
      enable = false;

      tooling = with pkgs; [
        bash-language-server
        shfmt
        shellcheck
      ];
    };
  };

  isActive =
    activeProfiles: name:
    (
      (
        builtins.hasAttr name activeProfiles
        && activeProfiles.${name}.enable
        && builtins.hasAttr name profileDefinitions
      )
      || (profileDefinitions.${name}.enable)
    );

  extractFromProfiles =
    fieldName: combineFn: activeProfiles:
    combineFn (
      builtins.filter (x: x != null) (
        builtins.map (
          name: if isActive activeProfiles name then profileDefinitions.${name}.${fieldName} else null
        ) (builtins.attrNames profileDefinitions)
      )
    );
in
{
  getTooling = extractFromProfiles "tooling" builtins.concatLists;
}
