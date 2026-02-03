{...}: {
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      syntax-theme = "TwoDark";
      side-by-side = true;
    };
  };

  programs.git = {
    enable = true;

    settings = {
      user.name = "Florentin Eckl";
      user.email = "ecklf@icloud.com";
      alias = {
        open = "!f() { open \"$(git config --get remote.origin.url | sed -E \"s/\\.git$//;s/git@github\\.com:/https:\\/\\/github.com\\//\")\"; }; f";
      };

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
      rerere = {
        enabled = true; # Remember conflict resolutions
      };
      fetch = {
        prune = true; # Auto-remove deleted remote branches
      };
      diff = {
        algorithm = "histogram"; # Better diff algorithm
      };
      merge = {
        conflictStyle = "zdiff3"; # Better conflict markers
      };
      rebase = {
        autoStash = true; # Auto-stash before rebase
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

    # signing = {
    #   signByDefault = true;
    #   signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY2vg6JN45hpcl9HH279/ityPEGGOrDjY3KdyulOUmX";
    # };
  };
}
