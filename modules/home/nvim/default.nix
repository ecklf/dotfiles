{pkgs, ...}: let
  # Bundle tree-sitter grammars for native Neovim treesitter
  treesitterParsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = with pkgs.tree-sitter-grammars; [
      tree-sitter-astro
      tree-sitter-awk
      tree-sitter-bash
      tree-sitter-bibtex
      tree-sitter-c
      tree-sitter-c-sharp
      tree-sitter-cmake
      tree-sitter-comment
      tree-sitter-commonlisp
      tree-sitter-cpp
      tree-sitter-css
      tree-sitter-csv
      tree-sitter-dart
      tree-sitter-diff
      tree-sitter-dockerfile
      tree-sitter-elixir
      tree-sitter-gdscript
      tree-sitter-git-config
      tree-sitter-git-rebase
      tree-sitter-gitattributes
      tree-sitter-gitcommit
      tree-sitter-gitignore
      tree-sitter-glsl
      tree-sitter-go
      tree-sitter-gomod
      tree-sitter-gotmpl
      tree-sitter-gowork
      tree-sitter-graphql
      tree-sitter-haskell
      tree-sitter-haskell-persistent
      tree-sitter-hcl
      tree-sitter-hjson
      tree-sitter-html
      tree-sitter-http
      tree-sitter-java
      tree-sitter-javascript
      tree-sitter-jq
      tree-sitter-jsdoc
      tree-sitter-json
      tree-sitter-json5
      tree-sitter-jsonnet
      tree-sitter-latex
      tree-sitter-ledger
      tree-sitter-llvm
      tree-sitter-lua
      tree-sitter-luau
      tree-sitter-make
      tree-sitter-markdown
      tree-sitter-markdown-inline
      tree-sitter-matlab
      tree-sitter-mermaid
      tree-sitter-nginx
      tree-sitter-nix
      tree-sitter-nu
      tree-sitter-python
      tree-sitter-ql
      tree-sitter-query
      tree-sitter-r
      tree-sitter-regex
      tree-sitter-ruby
      tree-sitter-rust
      tree-sitter-scss
      tree-sitter-sql
      tree-sitter-sshclientconfig
      tree-sitter-svelte
      tree-sitter-swift
      tree-sitter-toml
      tree-sitter-tsx
      tree-sitter-typescript
      tree-sitter-typespec
      tree-sitter-vim
      tree-sitter-vue
      tree-sitter-wgsl
      tree-sitter-xml
      tree-sitter-yaml
      tree-sitter-zig
      # Not available in tree-sitter-grammars (nvim-treesitter specific):
      # asm, disassembly, gdshader, gnuplot, goctl, gosum, gpg, helm, hlsl, javadoc,
      # kcl, kconfig, luadoc, requirements, tmux, tsv, terraform, vimdoc, wgsl_bevy, xresources
    ];
  };
in let
  # configuration = pkgs.vimUtils.buildVimPlugin {
  #   pname = "configuration";
  #   version = "1.0.0";
  #   src = ./configuration;
  # };
  # iceberg = pkgs.vimUtils.buildVimPlugin {
  #   pname = "iceberg";
  #   version = "HEAD";
  #   src = builtins.fetchGit {
  #     url = "ssh://git@github.com/cocopon/iceberg.vim.git";
  #     # ref = "master";
  #     rev = "23835d5ed696436f716cbfdb56a93a7850fe3b18";
  #   };
  # };
  kanso = pkgs.vimUtils.buildVimPlugin {
    pname = "kanso";
    version = "HEAD";
    src = builtins.fetchGit {
      url = "git@github.com:webhooked/kanso.nvim.git";
      ref = "main";
      rev = "26f5c9686b17a27541c98551cf0cd2587627e387";
    };
  };

  custom-snippets = pkgs.vimUtils.buildVimPlugin {
    pname = "custom-snippets";
    version = "1.0.0";
    src = ./plugins/custom-snippets;
  };
in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = false;
    withPython3 = false;
    initLua = ''
      -- Add tree-sitter parsers to runtimepath
      vim.opt.runtimepath:prepend("${treesitterParsers}")

      ${builtins.readFile ./configuration/colorscheme.lua}
      ${builtins.readFile ./configuration/options.lua}
      ${builtins.readFile ./configuration/keymaps.lua}
      ${builtins.readFile ./configuration/autocommands.lua}
      ${builtins.readFile ./plugins/treesitter.lua}
    '';
    # https://search.nixos.org/packages
    extraPackages = [
      # nodePackages_latest.volar # vue
      # stylelint_lsp
      # yamlls
      pkgs.unstable.biome
      pkgs.gopls
      pkgs.nixd # nix lsp
      pkgs.alejandra # nix formatter
      pkgs.tailwindcss-language-server
      # pkgs.nodePackages_latest."graphql"
      pkgs.bash-language-server
      pkgs.dockerfile-language-server
      pkgs.eslint
      pkgs.prettier # webdev
      pkgs.stylelint
      pkgs.unstable.typescript-go # tsgo - Go-based TypeScript language server
      pkgs.vscode-langservers-extracted # html, css, json, eslint
      pkgs.pylint
      pkgs.pyright
      pkgs.python312Packages.black # python
      pkgs.python312Packages.flake8
      pkgs.ripgrep
      pkgs.rust-analyzer
      pkgs.rustfmt
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.stylua
      pkgs.lua-language-server
      pkgs.terraform-ls
      pkgs.vale
      pkgs.yaml-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      # Core
      plenary-nvim # useful lua functions used ny lots of plugins - required by Telescope
      impatient-nvim # improves loading times
      # AI
      {
        plugin = snacks-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/snacks.lua;
      }
      {
        plugin = opencode-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/opencode.lua;
      }
      {
        plugin = copilot-vim;
        type = "lua";
        config = builtins.readFile ./plugins/copilot.lua;
      }
      # Colorschemes
      iceberg-vim
      ayu-vim
      catppuccin-nvim
      {
        # required by nvim-tree, lualine
        plugin = nvim-web-devicons;
        type = "lua";
        config =
          /*
          lua
          */
          ''
              require("nvim-web-devicons").setup({
              override_by_extension = {
                ["rs"] = {
                 icon = "",
                 color = "#6f5242",
                 cterm_color = "95",
                 name = "Rs",
                },
                ["toml"] = {
                  icon = "",
                  color = "#333333",
                  cterm_color = "231",
                  name = "Toml",
                },
              }
            })
          '';
      }
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile ./plugins/nvim-tree.lua;
      }
      {
        # Greeter UI
        plugin = alpha-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/alpha.lua;
      }
      {
        # Better status line
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/lualine.lua;
      }
      {
        # Tab-like buffers
        plugin = bufferline-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/bufferline.lua;
      }
      {
        # Allows to delete buffers without closing windows
        plugin = vim-bbye;
      }
      {
        # Shows indentation markss
        plugin = indent-blankline-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/indentline.lua;
      }
      {
        # Easily manage multiple terminal windows
        plugin = toggleterm-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/toggleterm.lua;
      }
      # {
      # plugin = nvim-colorizer;
      # https://github.com/windwp/nvim-ts-autotag
      # }
      {
        # Add/change/delete surrounding delimiter pairs with ease
        plugin = nvim-surround;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("nvim-surround").setup({
              -- Configuration here, or leave empty to use defaults
            })
          '';
      }
      # Detect tabstop and shiftwidth automatically
      vim-sleuth
      # Seamless navigation between tmux panes and vim splits
      # Uses Ctrl+hjkl by default
      vim-tmux-navigator
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
        config = builtins.readFile ./plugins/cmp.lua;
      }

      luasnip # snippet engine
      friendly-snippets # snippet collection
      custom-snippets # custom snippets

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

      # LSP
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./plugins/lsp.lua;
      }

      {
        plugin = nvim-ts-context-commentstring;
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("ts_context_commentstring").setup({})
          '';
      }
      nvim-autopairs # Auto ()/{}/[] pairs - integrates with both cmp and treesitter
      nvim-ts-autotag # Auto HTML tag closing - integrates with treesitter
      # -- use { "p00f/nvim-ts-rainbows" } -- Rainbow parentheses - integrates with treesitter
      {
        # Colorschemes
        plugin = kanso;
        type = "lua";
        config = builtins.readFile ./plugins/kanso.lua;
      }
      {
        # Formatter
        plugin = conform-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/conform.lua;
      }
      {
        # Linters
        plugin = nvim-lint;
        type = "lua";
        config = builtins.readFile ./plugins/nvim-lint.lua;
      }
      {
        # Crates version autosuggestions
        plugin = crates-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/crates.lua;
      }
      {
        # Highlighting other uses of the word under the cursor
        plugin = vim-illuminate;
        type = "lua";
        config = builtins.readFile ./plugins/illuminate.lua;
      }
      {
        # nvim-lsp progress
        plugin = fidget-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/fidget.lua;
      }
      # Git
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/gitsigns.lua;
      }
      # Telescope
      telescope-fzf-native-nvim # Better fuzzy finding in telescope
      {
        # Fuzzy finder
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/telescope.lua;
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
