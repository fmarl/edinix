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

      vscodeExtensions = with vscode-marketplace; [
        jnoortheen.nix-ide
      ];

      tooling = with pkgs; [
        nil
        nixfmt
        nixfmt-tree
      ];

      settings = {
        nix.enableLanguageServer = true;
        nix.formatterPath = "nixfmt";
      };
    };

    c = {
      enable = false;

      vscodeExtensions = with vscode-marketplace; [
        llvm-vs-code-extensions.vscode-clangd
      ];

      tooling = with pkgs; [ clang-tools ];

      settings = { };
    };

    cpp = {
      enable = false;

      vscodeExtensions = with vscode-marketplace; [
        llvm-vs-code-extensions.vscode-clangd
      ];

      tooling = with pkgs; [ clang-tools ];

      settings = { };
    };

    rust = {
      enable = false;

      vscodeExtensions = with vscode-marketplace; [
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
      ];

      tooling = [ ];

      settings = { 
        rust-analyzer.server.path = "rust-analyzer";
      };
    };

    go = {
      enable = false;

      vscodeExtensions = with vscode-marketplace; [ golang.go ];

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

      settings = { };
    };

    clojure = {
      enable = false;

      vscodeExtensions = with vscode-marketplace; [
        betterthantomorrow.calva
        betterthantomorrow.calva-spritz
      ];

      tooling = with pkgs; [
        clojure
        clojure-lsp
        clj-kondo
        cljstyle
        leiningen
        rlwrap
        openjdk
      ];

      settings = {
        calva.clojureLspPath = "clojure-lsp";
        clojure-lsp.trace.server = "verbose";
      };
    };

    haskell = {
      enable = false;

      vscodeExtensions = with vscode-marketplace; [ haskell.haskell ];

      tooling = [ ];

      settings = { };
    };

    sh = {
      enable = false;

      vscodeExtensions = with vscode-marketplace; [
        mads-hartmann.bash-ide-vscode
        mkhl.shfmt
        timonwong.shellcheck
        editorconfig.editorconfig
      ];

      tooling = with pkgs; [
        bash-language-server
        shfmt
        shellcheck
      ];

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
