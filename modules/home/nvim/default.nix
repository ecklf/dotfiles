{pkgs, ...}:
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
      url = "ssh://git@github.com/webhooked/kanso.nvim.git";
      ref = "main";
      rev = "7205d3902adf14c11b6aee658d6dcddd37b7ba95";
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
    extraLuaConfig = ''
      ${builtins.readFile ./configuration/colorscheme.lua}
      ${builtins.readFile ./configuration/options.lua}
      ${builtins.readFile ./configuration/keymaps.lua}
      ${builtins.readFile ./configuration/autocommands.lua}
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
      pkgs.nodePackages_latest."@tailwindcss/language-server"
      # pkgs.nodePackages_latest."graphql"
      pkgs.nodePackages_latest.bash-language-server
      pkgs.dockerfile-language-server
      pkgs.master.nodePackages_latest.eslint
      pkgs.nodePackages_latest.prettier # webdev
      pkgs.nodePackages_latest.stylelint
      pkgs.nodePackages_latest.typescript-language-server
      pkgs.nodePackages_latest.vscode-langservers-extracted # html, css, json, eslint
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
      pkgs.sumneko-lua-language-server
      pkgs.terraform-ls
      pkgs.vale
      pkgs.yaml-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      # Core
      plenary-nvim # useful lua functions used ny lots of plugins - required by Telescope
      impatient-nvim # improves loading times
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
      typescript-tools-nvim
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./plugins/lsp.lua;
      }

      # Treesitter
      {
        plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
          p.asm
          p.astro
          p.awk
          p.bash
          p.bibtex
          p.c
          p.c_sharp
          p.cmake
          p.comment
          p.commonlisp
          p.cpp
          p.css
          p.csv
          p.dart
          p.diff
          p.disassembly
          p.dockerfile
          p.elixir
          p.gdshader
          p.git_config
          p.git_rebase
          p.gitattributes
          p.gitcommit
          p.gitignore
          p.glsl
          p.gnuplot
          p.go
          p.goctl
          p.gdscript
          p.gomod
          p.gosum
          p.gotmpl
          p.gowork
          p.gpg
          p.graphql
          p.haskell
          p.haskell_persistent
          p.hcl
          p.helm
          p.hjson
          p.hlsl
          p.html
          p.http
          p.java
          p.javadoc
          p.javascript
          p.jq
          p.jsdoc
          p.json
          p.json5
          p.jsonc
          p.jsonnet
          p.kcl
          p.kconfig
          p.latex
          p.ledger
          p.llvm
          p.lua
          p.luadoc
          p.lua
          p.luau
          p.make
          p.markdown
          p.markdown_inline
          p.matlab
          p.mermaid
          p.nginx
          p.nix
          p.nu
          p.python
          p.ql
          p.tree-sitter-query
          p.r
          p.regex
          p.tree-sitter-requirements
          p.ruby
          p.rust
          p.scss
          p.sql
          p.ssh_config
          p.svelte
          p.swift
          p.terraform
          p.tmux
          p.toml
          p.tsv
          p.tsx
          p.typescript
          p.typespec
          p.vim
          p.vimdoc
          p.vue
          p.wgsl
          p.wgsl_bevy
          p.xml
          p.xresources
          p.yaml
          p.zig
        ]);
        type = "lua";
        config = builtins.readFile ./plugins/treesitter.lua;
      }
      {
        plugin = nvim-treesitter-context; # Show code context
        type = "lua";
        config =
          /*
          lua
          */
          ''
            require("treesitter-context").setup({})
          '';
      }
      nvim-treesitter-textobjects # Additional textobjects for treesitter
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
      {
        # nvim-lsp progress
        plugin = copilot-vim;
        type = "lua";
        config = builtins.readFile ./plugins/copilot.lua;
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
