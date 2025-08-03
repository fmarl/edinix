{ pkgs, helixProfileDefinitions }:
{
  profiles ? { },
  projectSettings ? { },
}:
let
  tooling = helixProfileDefinitions.getTooling profiles;
  settings = (pkgs.formats.toml { }).generate "config" ((helixProfileDefinitions.getSettings profiles) // projectSettings);
in
{
  editor =  pkgs.stdenv.mkDerivation {
    name = "custom-helix-env";
    dontUnpack = true;

    buildInputs = [
      pkgs.makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${pkgs.helix}/bin/hx $out/bin/hx \
        --add-flags "-c ${settings}"
    '';
  };
  tooling = tooling;
}
