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

        vscode-marketplace = extensions.extensions.${system}.vscode-marketplace;

        profileDefinitions = import ./lib/profiles.nix { inherit pkgs vscode-marketplace; };

        code = import ./lib/code.nix { inherit pkgs profileDefinitions; };

        mkDevShell =
          profileName:
          let
            code-with-profile = code { profiles."${profileName}".enable = true; };
          in
          pkgs.mkShell {
            nativeBuildInputs = [
              code-with-profile.editor
              code-with-profile.tooling
            ];
          };
      in
      {
        packages.default = code;

        devShells = {
          default = mkDevShell "nix";
          c = mkDevShell "c";
          cpp = mkDevShell "cpp";
          rust = mkDevShell "rust";
          go = mkDevShell "go";
          clojure = mkDevShell "clojure";
          haskell = mkDevShell "haskell";
          sh = mkDevShell "sh";
        };
      }
    );
}
