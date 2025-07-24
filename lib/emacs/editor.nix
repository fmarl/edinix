{ pkgs, emacsProfileDefinitions }:
{
  profiles ? { },
  extraExtensions ? [ ],
}:
let
  tooling = emacsProfileDefinitions.getTooling profiles;
  settings = emacsProfileDefinitions.getSettings profiles;
  extensions = (emacsProfileDefinitions.getEnabledExtensions profiles) ++ extraExtensions;

  emacsWithPackages = pkgs.emacs.pkgs.withPackages extensions;

  init = pkgs.writeText "init.el" settings;
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
