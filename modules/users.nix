{
  config,
  pkgs,
  lib,
  ...
}:
{
  # --- User Configuration ---
  users.users.radean = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "input"
      "realtime"
      "gamemode"
    ];
  };

  # Realtime scheduling for gaming/sim racing
  security.pam.loginLimits = [
    {
      domain = "@realtime";
      type = "-";
      item = "rtprio";
      value = 99;
    }
    {
      domain = "@realtime";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@realtime";
      type = "-";
      item = "nice";
      value = -20;
    }
  ];

  users.groups.realtime = { };
}
