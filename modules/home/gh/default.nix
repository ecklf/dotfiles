{...}: {
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      editor = "nvim";
      pager = "less";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
        pc = "pr create";
        pl = "pr list";
        pm = "pr merge";
        prd = "pr diff";
        rv = "repo view";
        rc = "repo clone";
        il = "issue list";
        iv = "issue view";
        ic = "issue create";
      };
    };
    extensions = [];
  };

  programs.gh-dash = {
    enable = true;
    settings = {
      prSections = [
        {
          title = "My PRs";
          filters = "is:open author:@me";
        }
        {
          title = "Review Requested";
          filters = "is:open review-requested:@me";
        }
        {
          title = "Involved";
          filters = "is:open involves:@me -author:@me";
        }
      ];
      issuesSections = [
        {
          title = "Assigned";
          filters = "is:open assignee:@me";
        }
        {
          title = "Created";
          filters = "is:open author:@me";
        }
      ];
      defaults = {
        preview = {
          open = true;
          width = 50;
        };
        prsLimit = 20;
        issuesLimit = 20;
      };
    };
  };
}
