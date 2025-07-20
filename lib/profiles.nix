{ pkgs, vscode-marketplace }:
let
  profileDefinitions = {
    # The default extensions are active, unless we deactivate them explicitly.
    default = {
      enable = true;
      vscodeExtensions = [ vscode-marketplace.mkhl.direnv ];
      tooling = [ ];
      settings = { };
    };

    nix = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.bbenoist.nix
        vscode-marketplace.jnoortheen.nix-ide
      ];
      tooling = [
        pkgs.nil
        pkgs.nixfmt
        pkgs.nixfmt-tree
      ];
      settings = {
        nix.enableLanguageServer = true;
        nix.formatterPath = "nixfmt";
      };
    };

    c = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.llvm-vs-code-extensions.vscode-clangd
      ];
      tooling = [ ];
      settings = { };
    };

    cpp = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.llvm-vs-code-extensions.vscode-clangd
      ];
      tooling = [ ];
      settings = { };
    };

    rust = {
      enable = false;
      vscodeExtensions = [
        vscode-marketplace.rust-lang.rust-analyzer
        vscode-marketplace.tamasfe.even-better-toml
      ];
      tooling = [ ];
      settings = { };
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
      settings = { };
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
      settings = {
        calva.clojureLspPath = "clojure-lsp";
        clojure-lsp.trace.server = "verbose";
      };
    };

    haskell = {
      enable = false;
      vscodeExtensions = [ vscode-marketplace.haskell.haskell ];
      tooling = [ ];
      settings = { };
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

  flattenAttrs =
    prefix: attrs:
    builtins.foldl' (
      acc: key:
      let
        val = attrs.${key};
        fullKey = if prefix == "" then key else "${prefix}.${key}";
      in
      if builtins.isAttrs val then acc // (flattenAttrs fullKey val) else acc // { "${fullKey}" = val; }
    ) { } (builtins.attrNames attrs);

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
  getEnabledExtensions = extractFromProfiles "vscodeExtensions" builtins.concatLists;

  getTooling = extractFromProfiles "tooling" builtins.concatLists;

  getSettings =
    activeProfiles:
    flattenAttrs "" (
      extractFromProfiles "settings" (builtins.foldl' (acc: x: acc // x) { }) activeProfiles
    );
}
