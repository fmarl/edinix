{ pkgs, helixProfileDefinitions }:
{
  profiles ? { },
}:
let
  tooling = helixProfileDefinitions.getTooling profiles;
in
{
  editor = pkgs.helix;
  tooling = tooling;
}
