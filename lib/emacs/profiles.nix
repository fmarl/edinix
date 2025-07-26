{ pkgs }:
let
  epkgs = pkgs.emacsPackages;

  profileDefinitions = {
    # The default extensions are active, unless we deactivate them explicitly.
    default = {
      enable = true;
      emacsPackages =
        (with epkgs; [
          use-package
        ])
        ++ (with epkgs.melpaPackages; [
          monokai-pro-theme
        ])
        ++ (with epkgs.melpaStablePackages; [
          smart-mode-line
          smart-mode-line-powerline-theme
          smex
          markdown-mode
          ace-window
          ace-jump-mode
          yasnippet
          which-key
          direnv
          beacon
          projectile
          ivy
          posframe
          treemacs
          treemacs-projectile
          lsp-mode
          lsp-ui
          lsp-ivy
          magit
        ]);
      tooling = [ ];
      settings = [
        ./elisp/init.el
        ./elisp/ide.el
      ];
    };

    nix = {
      enable = false;

      emacsPackages = with epkgs.melpaStablePackages; [
        nix-mode
      ];

      tooling = with pkgs; [
        nil
        nixfmt
        nixfmt-tree
      ];

      settings = [ ./elisp/nix.el ];
    };

    c = {
      enable = false;

      emacsPackages =
        with epkgs;
        (with melpaPackages; [
          clang-format
          google-c-style
        ])
        ++ (with epkgs.melpaStablePackages; [
          cmake-mode
        ]);

      tooling = with pkgs; [ clang-tools ];

      settings = [ ./elisp/cc.el ];
    };

    cpp = {
      enable = false;

      emacsPackages =
        with epkgs;
        (with melpaPackages; [
          clang-format
          google-c-style
        ])
        ++ (with epkgs.melpaStablePackages; [
          cmake-mode
        ]);

      tooling = with pkgs; [ clang-tools ];

      settings = [ ./elisp/cc.el ];
    };

    rust = {
      enable = false;

      emacsPackages = with epkgs.melpaStablePackages; [
        rust-mode
        rustic
        flycheck-rust
        cargo
      ];

      tooling = [ ];

      settings = [ ./elisp/rust.el ];
    };

    clojure = {
      enable = false;

      emacsPackages = with epkgs.melpaStablePackages; [
        cider
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

      settings = [ ./elisp/clojure.el ];
    };

    haskell = {
      enable = false;

      emacsPackages = with epkgs.melpaStablePackages; [
        haskell-mode
        lsp-haskell
      ];

      tooling = [ ];

      settings = [ ./elisp/haskell.el ];
    };

    ats = {
      enable = false;

      emacsPackages = [ ];

      tooling = [ pkgs.ats2 ];

      settings = [ ./elisp/ats2.el ];
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
  getEnabledExtensions = extractFromProfiles "emacsPackages" builtins.concatLists;

  getTooling = extractFromProfiles "tooling" builtins.concatLists;

  getSettings =
    profiles:
    pkgs.lib.concatMapStringsSep "\n" builtins.readFile (
      extractFromProfiles "settings" builtins.concatLists profiles
    );
}
