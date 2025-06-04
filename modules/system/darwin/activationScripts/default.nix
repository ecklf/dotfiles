({
  lib,
  config,
  pkgs,
  username,
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
    system.activationScripts.postActivation = {
      enable = true;
      text = let
        initUsername = ''
          echo "Running post activation scripts for user ${username}"
          export NIX_RUN_USER=${username}
        '';
        # Should avoid a logout/login cycle when changing settings
        respring = ''
          sudo -u ${username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '';
        patchDefaultApps = ''
          echo "Patching macOS default apps"
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.colliderli.iina .mp4 all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.colliderli.iina .mov all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.colliderli.iina .webm all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.colliderli.iina .avi all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.apple.TextEdit .txt all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .md all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .go all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .py all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .js all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .ts all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .c all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .cpp all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .h all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .hpp all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .java all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .sh all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .zsh all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .bash all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .fish all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .json all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .xml all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .css all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .scss all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .sass all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .less all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .vue all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .tsx all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .jsx all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .php all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .rb all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .rs all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .swift all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .kt all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .dart all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .sql all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .yml all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .yaml all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .toml all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .ini all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .conf all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.microsoft.VSCode .log all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.apple.iWork.Numbers .csv all
          sudo -u ${username} ${pkgs.master.duti}/bin/duti -s com.apple.iWork.Numbers .tsv all
        '';
        scriptFiles = lib.flatten ([]
          ++ lib.optional config.activationScriptModules.patches.screenCaptureApprovals [
            "${userActivationScriptsPath}/patch-screencapture-approvals.sh"
          ]);
        scriptContents =
          map (file: builtins.readFile file)
          scriptFiles;
        fullScript =
          [initUsername]
          ++ lib.flatten ([]
            ++ lib.optional config.activationScriptModules.patches.defaultApplications
            [
              patchDefaultApps
            ])
          ++ scriptContents
          ++ [respring];
      in
        builtins.concatStringsSep "\n" fullScript;
    };
  };
})
