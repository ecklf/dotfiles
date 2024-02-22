{ pkgs, lib, ... }:

# let
#   fromGitHub = ref: repo: pkgs.vimUtils.buildVimPlugin {
#     pname = "${lib.strings.sanitizeDerivationName repo}";
#     version = ref;
#     src = builtins.fetchGit {
#       url = "https://github.com/${repo}.git";
#       ref = ref;
#     };
#   };
# in

let
  # configuration = pkgs.vimUtils.buildVimPlugin {
  #   pname = "configuration";
  #   version = "1.0.0";
  #   src = ./configuration;
  # };

  iceberg = pkgs.vimUtils.buildVimPlugin {
    pname = "iceberg";
    version = "HEAD";
    src = builtins.fetchGit {
      url = "ssh://git@github.com/cocopon/iceberg.vim.git";
      # ref = "master";
      rev = "e01ac08c2202e7544531f4d806f6893539da6471";
    };
  };

  catppuccin = pkgs.vimUtils.buildVimPlugin {
    pname = "catppuccin";
    version = "HEAD";
    src = builtins.fetchGit {
      url = "ssh://git@github.com/catppuccin/nvim.git";
      ref = "main";
      rev = "bc1f2151f23227ba02ac203c2c59ad693352a741";
    };
  };
in

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraLuaConfig = ''
      ${builtins.readFile ./configuration/colorscheme.lua}
      ${builtins.readFile ./configuration/options.lua}
      ${builtins.readFile ./configuration/keymaps.lua}
      ${builtins.readFile ./configuration/autocommands.lua}
    '';
    # https://search.nixos.org/packages
    extraPackages = with pkgs; [
      # Formatters
      nodePackages_latest.prettier # webdev
      stylua # lua
      shfmt # sh
      nixpkgs-fmt # nix
      rustfmt # rust
      python310Packages.black # python
      # Linters
      statix # nix
      shellcheck # sh
      python310Packages.flake8
      # LSP
      # nodePackages_latest.eslint
      # stylelint_lsp
      nodePackages_latest.vscode-langservers-extracted # html, css, json, eslint      
      nodePackages_latest.typescript-language-server
      nodePackages_latest.stylelint
      nodePackages_latest."@tailwindcss/language-server"
      nodePackages_latest."@prisma/language-server"
      nodePackages_latest."graphql"
      nodePackages_latest.dockerfile-language-server-nodejs
      # nodePackages_latest.volar # vue
      nodePackages_latest.bash-language-server
      sumneko-lua-language-server
      gopls
      rust-analyzer
      pyright
      terraform-ls
      yaml-language-server
      # yamlls
      ripgrep
    ];
    plugins = with pkgs.vimPlugins; [
      # Core
      # use("wbthomason/packer.nvim") -- packer self-manage
      plenary-nvim # useful lua functions used ny lots of plugins - required by Telescope
      impatient-nvim # improves loading times
      # Colorschemes
      # (fromGitHub "HEAD" "cocopon/iceberg.vim")
      iceberg
      ayu-vim
      catppuccin
      nvim-web-devicons # required by nvim-tree, lualine
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile (./plugins/nvim-tree.lua);
      }
      {
        # Greeter UI
        plugin = alpha-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/alpha.lua);
      }
      {
        # Better status line
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/lualine.lua);
      }
      {
        # Tab-like buffers
        plugin = bufferline-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/bufferline.lua);
      }
      {
        # Allows to delete buffers without closing windows
        plugin = vim-bbye;
      }
      {
        # Shows indentation markss
        plugin = indent-blankline-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/indentline.lua);
      }
      {
        # Easily manage multiple terminal windows
        plugin = toggleterm-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/toggleterm.lua);
      }
      # {
      # plugin = nvim-colorizer;
      # https://github.com/windwp/nvim-ts-autotag
      # }
      {
        # Add/change/delete surrounding delimiter pairs with ease
        plugin = nvim-surround;
        type = "lua";
        config = /* lua */ ''
          require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
          })
        '';
      }
      # Detect tabstop and shiftwidth automatically
      vim-sleuth
      {
        # Add/change/delete surrounding delimiter pairs with ease
        plugin = comment-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/comment.lua);
      }

      # -- Highlight, list and search todo comments in your projects
      # -- use {
      # -- "folke/todo-comments.nvim",
      # -- requires = "nvim-lua/plenary.nvim",
      # -- config = function()
      # -- require("todo-comments").setup {
      # -- your configuration comes here
      # -- or leave it empty to use the default settings
      # -- refer to the configuration section below
      # -- }
      # -- end
      # -- }

      # -- nvim-cmp and plugins
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile (./plugins/cmp.lua);
      }

      luasnip # snippet engine
      friendly-snippets # snippet collection

      cmp-buffer # buffer completions
      cmp-path # path completions
      cmp_luasnip # snippet completions
      cmp-nvim-lsp # completion for lsp
      cmp-nvim-lua # completion for lua

      # -- Completion - Cargo.toml
      # use({
      # 	"saecki/crates.nvim",
      # 	tag = "v0.2.1",
      # 	requires = { "nvim-lua/plenary.nvim" },
      # })

      {
        # LSP
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile (./plugins/lsp.lua);
      }

      # -- Treesitter
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = builtins.readFile (./plugins/treesitter.lua);
      }
      nvim-treesitter-context # Show code context
      nvim-treesitter-textobjects # Additional textobjects for treesitter
      nvim-ts-context-commentstring # JSX commenting
      nvim-autopairs # Auto ()/{}/[] pairs - integrates with both cmp and treesitter
      nvim-ts-autotag # Auto HTML tag closing - integrates with treesitter
      # -- use { "p00f/nvim-ts-rainbows" } -- Rainbow parentheses - integrates with treesitter
      {
        # For formatters and linters
        plugin = none-ls-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/none-ls.lua);
      }
      {
        # Crates version autosuggestions 
        plugin = crates-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/crates.lua);
      }

      {
        # Highlighting other uses of the word under the cursor
        plugin = vim-illuminate;
        type = "lua";
        config = builtins.readFile (./plugins/illuminate.lua);
      }
      {
        # nvim-lsp progress
        plugin = fidget-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/fidget.lua);
      }
      {
        # nvim-lsp progress
        plugin = copilot-vim;
        type = "lua";
        config = builtins.readFile (./plugins/copilot.lua);
      }
      # -- Git
      {
        plugin =  gitsigns-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/gitsigns.lua);
      }
      # Telescope
      telescope-fzf-native-nvim # Better fuzzy finding in telescope
      {
        # Fuzzy finder 
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile (./plugins/telescope.lua);
      }
      vim-fugitive # Git commands in nvim
      vim-rhubarb # Fugitive-companion to interact with GitHub
      git-blame-nvim

      # -- Debug Adapter Protocol
      # --   use { "mfussenegger/nvim-dap" }
      # --   use { "rcarriga/nvim-dap-ui" }
      # --   use { "ravenxrz/DAPInstall.nvim" }
    ];
  };
}
