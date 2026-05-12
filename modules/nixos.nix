{ config, lib, ... }:

let
  # Find all home-manager users with helium enabled
  enabledUsers = lib.filterAttrs (_: user: user.programs.helium.enable or false) (
    config.home-manager.users or { }
  );

  # Write policy files per user to /etc/chromium/policies/managed/
  # Chromium reads all JSON files in this directory and merges them
  policyFiles = lib.mapAttrs' (
    name: user:
    lib.nameValuePair "chromium/policies/managed/helium-${name}.json" {
      text = user.programs.helium.finalPolicyJson;
      mode = "0644";
    }
  ) enabledUsers;

in
{
  config = lib.mkIf (enabledUsers != { }) {
    environment.etc = policyFiles;
  };
}
