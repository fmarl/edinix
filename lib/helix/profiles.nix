{ pkgs }:
let
  profileDefinitions = {
    # The default extensions are active, unless we deactivate them explicitly.
    default = {
      enable = true;
      tooling = [ ];
      settings = {
        theme = "autumn";

        editor = {
          bufferline = "multiple";
          cursorline = true;
          rulers = [ 120 ];
          true-color = true;

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          lsp = {
            auto-signature-help = false;
            display-messages = true;
          };

          statusline = {
            left = [
              "mode"
              "spinner"
              "version-control"
              "file-name"
            ];
          };

          end-of-line-diagnostics = "hint";

          inline-diagnostics = {
            cursor-line = "error";
            other-lines = "disable";
          };
        };

      };
    };

    nix = {
      enable = false;

      tooling = with pkgs; [
        nil
        nixfmt
        nixfmt-tree
      ];

      settings = { };
    };

    c = {
      enable = false;

      tooling = with pkgs; [ clang-tools ];

      settings = { };
    };

    cpp = {
      enable = false;

      tooling = with pkgs; [ clang-tools ];

      settings = { };
    };

    rust = {
      enable = false;

      tooling = [ ];

      settings = { };
    };

    python = {
      enable = false;

      tooling = with pkgs; [
        (python3Full.withPackages (python-pkgs: [
          python-pkgs.ruff
          python-pkgs.python-lsp-ruff
        ]))
        pyright
      ];

      settings = { };
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

      settings = { };
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

      settings = { };
    };

    haskell = {
      enable = false;

      tooling = [ ];

      settings = { };
    };

    sh = {
      enable = false;

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

  getSettings = extractFromProfiles "settings" (builtins.foldl' (acc: x: acc // x) { });
}
