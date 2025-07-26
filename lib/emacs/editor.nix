{ pkgs, emacsProfileDefinitions }:
{
  profiles ? { },
  extraExtensions ? [ ],
  projectSettings ? [ ],
}:
let
  tooling = emacsProfileDefinitions.getTooling profiles;

  emacsWithPackages = pkgs.emacs.pkgs.withPackages (
    (emacsProfileDefinitions.getEnabledExtensions profiles) ++ extraExtensions
  );

  init = pkgs.writeText "init.el" (
    pkgs.lib.concatMapStringsSep "\n" builtins.readFile (
      (emacsProfileDefinitions.getSettings profiles) ++ projectSettings
    )
  );
in
{
  tooling = tooling;

  editor = pkgs.stdenv.mkDerivation {
    name = "custom-emacs-env";
    dontUnpack = true;

    buildInputs = [
      emacsWithPackages
      pkgs.makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${emacsWithPackages}/bin/emacs $out/bin/emacs \
        --add-flags "-Q --load ${init}"
    '';
  };
}
