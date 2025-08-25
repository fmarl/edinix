{
  description = "edinix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      extensions,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        emacsProfileDefinitions = import ./lib/emacs/profiles.nix { inherit pkgs; };
        emacs = import ./lib/emacs/editor.nix { inherit pkgs emacsProfileDefinitions; };

        vscode-marketplace = extensions.extensions.${system}.vscode-marketplace;
        codeProfileDefinitions = import ./lib/code/profiles.nix { inherit pkgs vscode-marketplace; };
        code = import ./lib/code/editor.nix { inherit pkgs codeProfileDefinitions; };

        helixProfileDefinitions = import ./lib/helix/profiles.nix { inherit pkgs; };
        helix = import ./lib/helix/editor.nix { inherit pkgs helixProfileDefinitions; };

        mkDevShell =
          editor: profileName:
          let
            editor-with-profile = editor { profiles."${profileName}".enable = true; };
          in
          pkgs.mkShell {
            nativeBuildInputs = [
              editor-with-profile.editor
              editor-with-profile.tooling
            ];
          };
      in
      {
        code = code;
        emacs = emacs;
        helix = helix;

        devShells = {
          default = mkDevShell helix "nix";

          emacs = {
            nix = mkDevShell emacs "nix";
            c = mkDevShell emacs "c";
            cpp = mkDevShell emacs "cpp";
            ats = mkDevShell emacs "ats";
          };

          code = {
            nix = mkDevShell code "nix";
            c = mkDevShell code "c";
            cpp = mkDevShell code "cpp";
            rust = mkDevShell code "rust";
            go = mkDevShell code "go";
            python = mkDevShell code "python";
            clojure = mkDevShell code "clojure";
            haskell = mkDevShell code "haskell";
            sh = mkDevShell code "sh";
          };

          helix = {
            nix = mkDevShell helix "nix";
            c = mkDevShell helix "c";
            cpp = mkDevShell helix "cpp";
            rust = mkDevShell helix "rust";
            go = mkDevShell helix "go";
            zig = mkDevShell helix "zig";
            python = mkDevShell helix "python";
            clojure = mkDevShell helix "clojure";
            haskell = mkDevShell helix "haskell";
            sh = mkDevShell helix "sh";
          };
        };
      }
    );
}
