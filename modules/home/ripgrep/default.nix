{...}: {
  programs.ripgrep = {
    enable = true;
    arguments = [
      # Search hidden files/directories
      "--hidden"
      # Follow symbolic links
      "--follow"
      # Don't respect ignore files (.gitignore, .ignore, etc.)
      # "--no-ignore"
      # Add line numbers
      "--line-number"
      # Add column numbers
      "--column"
      # Smart case sensitivity
      "--smart-case"
      # Sort by file path
      "--sort=path"
      # Ignore common directories
      "--glob=!.git/*"
      "--glob=!node_modules/*"
      "--glob=!.next/*"
      "--glob=!target/*"
      "--glob=!dist/*"
      "--glob=!build/*"
      "--glob=!.cache/*"
      "--glob=!*.lock"
      "--glob=!package-lock.json"
      "--glob=!pnpm-lock.yaml"
      "--glob=!yarn.lock"
      "--glob=!Cargo.lock"
    ];
  };
}
