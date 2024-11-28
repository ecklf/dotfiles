({
  lib,
  config,
  ...
}: let
  extraActivationScriptPath = ./extraActivation;
in {
  options.activationScriptModules = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          description = "Enable activationScriptModules";
        };
        patchScreenCaptureApprovals = lib.mkOption {
          type = lib.types.bool;
          description = "Automatically approve screen capture permissions introduced in macOS Sequoia";
        };
        patchDefaultApps = lib.mkOption {
          type = lib.types.bool;
          description = "Automatically approve screen capture permissions introduced in macOS Sequoia";
        };
      };
    };
    default = {
      enable = true;
      patchScreenCaptureApprovals = true;
      patchDefaultApps = true;
    };
  };

  config = lib.mkIf config.activationScriptModules.enable {
    system.activationScripts.extraActivation = {
      enable = true;
      text = let
        scriptFiles = lib.flatten ([]
          ++ lib.optional config.activationScriptModules.patchScreenCaptureApprovals [
            "${extraActivationScriptPath}/patch-screencapture-approvals.sh"
          ]
          ++ lib.optional config.activationScriptModules.patchDefaultApps [
            "${extraActivationScriptPath}/patch-default-apps.sh"
          ]);
      in
        builtins.concatStringsSep "\n" (map (file: builtins.readFile file) scriptFiles);
    };
  };
})
