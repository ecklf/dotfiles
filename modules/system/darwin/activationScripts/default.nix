({
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
  userActivationScriptsPath = ./userActivation;
in {
  options.activationScriptModules = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Enable activationScriptModules";
        };
        patches = lib.mkOption {
          type = lib.types.submodule {
            options = {
              screenCaptureApprovals = lib.mkOption {
                default = true;
                type = lib.types.bool;
                description = "Automatically approve screen capture permissions introduced in macOS Sequoia";
              };
              defaultApplications = lib.mkOption {
                default = true;
                type = lib.types.bool;
                description = "Automatically set default applications for common filetypes";
              };
            };
          };
          default = {};
        };
        extraPreActivationScripts = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Extra activation scripts to run";
        };
      };
    };
    default = {};
  };
  config = lib.mkIf config.activationScriptModules.enable {
    system.activationScripts.preActivation = {
      enable = true;
      text = lib.mkIf (lib.length config.activationScriptModules.extraPreActivationScripts > 0) ''
        ${
          builtins.concatStringsSep "\n" (lib.flatten (config.activationScriptModules.extraPreActivationScripts
            ++ lib.optional isDarwin [
              ''
                if [ ! -L "/usr/local/bin/gsed" ]; then
                  sudo ln -s "$(which sed)" /usr/local/bin/gsed
                  echo "Symbolic link created for gsed."
                fi
              ''
            ]))
        }
      '';
    };

    system.activationScripts.postUserActivation = {
      enable = true;
      text = let
        scriptFiles = lib.flatten ([]
          ++ lib.optional config.activationScriptModules.patches.screenCaptureApprovals [
            "${userActivationScriptsPath}/patch-screencapture-approvals.sh"
          ]
          ++ lib.optional config.activationScriptModules.patches.defaultApplications [
            "${userActivationScriptsPath}/patch-default-apps.sh"
          ]);
      in
        builtins.concatStringsSep "\n" (map (file: builtins.readFile file) scriptFiles);
    };
  };
})
