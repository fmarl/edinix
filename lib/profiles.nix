{ extensions }:
let
  vscode-marketplace = extensions.extensions.${system}.vscode-marketplace;
in
{
  profiles = {
    nix = {
      vscodeExtensions = with vscode-marketplace; [
        bbenoist.nix
        mkhl.direnv
        jnoortheen.nix-ide
      ];

      nativeBuildInputs = with pkgs; [
        nixpkgs-fmt
      ];
    };

    rust = {
      vscodeExtensions = with vscode-marketplace; [
        mkhl.direnv
        rust-lang.rust
        matklad.rust-analyzer
      ];

      nativeBuildInputs = with pkgs; [];
    };

    haskell = {
      vscodeExtensions = with vscode-marketplace; [
        mkhl.direnv
        haskell.haskell
        justusadam.language-haskell
      ];

      nativeBuildInputs = with pkgs; [];
    };
  };
}