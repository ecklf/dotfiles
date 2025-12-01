{...}: {
  programs.git = {
    enable = true;
    userName = "Florentin Eckl";
    userEmail = "ecklf@icloud.com";

    lfs = {
      enable = true;
      skipSmudge = false; # Skip automatic downloading of objects. Requires a manual `git lfs pull`
    };

    ignores = [
      ".DS_Store"
      ".idea"
      ".scratch"
      "__scratch"
    ];

    delta = {
      enable = true;
      options = {
        syntax-theme = "TwoDark";
        side-by-side = true;
      };
    };

    # signing = {
    #   signByDefault = true;
    #   signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY2vg6JN45hpcl9HH279/ityPEGGOrDjY3KdyulOUmX";
    # };

    aliases = {
      open = "!f() { open \"$(git config --get remote.origin.url | sed -E \"s/\\.git$//;s/git@github\\.com:/https:\\/\\/github.com\\//\")\"; }; f";
    };

    extraConfig = {
      commit.gpgsign = true; # Sign all commits using ssh key
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      url."ssh://git@github.com:".insteadOf = "https://github.com";
      # ssh.program = "/usr/local/bin/op-ssh-sign";
      github = {
        user = "ecklf";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = false;
      };
      push = {
        autoSetupRemote = true;
      };
      # branch = {
      #   "main".pushRemote = "no_push";
      #   "master".pushRemote = "no_push";
      # };
      core = {
        editor = "nvim";
        fileMode = false;
        ignorecase = false;
      };
    };
  };
}
