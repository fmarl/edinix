{
  description = "code-nix";

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
        packages.default = code;

        devShells = {
          default = mkDevShell code "nix";

          emacs = {
            nix = mkDevShell emacs "nix";
            c = mkDevShell emacs "c";
            cpp = mkDevShell emacs "cpp";
          };

          code = {
            c = mkDevShell code "c";
            cpp = mkDevShell code "cpp";
            rust = mkDevShell code "rust";
            go = mkDevShell code "go";
            clojure = mkDevShell code "clojure";
            haskell = mkDevShell code "haskell";
            sh = mkDevShell code "sh";
          };
        };
      }
    );
}
