{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    withPython3 = true;
    withRuby = false;
    initLua = ''
      vim.g.mapleader = " "
    '';

    plugins = with pkgs.vimPlugins; [
      nvim-web-devicons
      {
        plugin = bufferline-nvim;
        type = "lua";
        config = ''
          require('bufferline').setup({})
        '';
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup({})
        '';
      }
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          require('which-key').setup({})
        '';
      }
      {
        plugin = nvim-treesitter.withPlugins (
          p: with p; [
            bash
            diff
            fish
            gitcommit
            gitignore
            go
            json
            kdl
            lua
            markdown
            markdown_inline
            nix
            python
            regex
            rust
            toml
            vim
            vimdoc
            xml
            yaml
          ]
        );
        type = "lua";
        config = ''
          -- nvim-treesitter main branch: highlight/indent are wired through
          -- Neovim's native treesitter APIs (same setup nixvim generated).
          require('nvim-treesitter').setup({})

          local augroup = vim.api.nvim_create_augroup('treesitter', { clear = true })
          vim.api.nvim_create_autocmd('FileType', {
            group = augroup,
            pattern = '*',
            callback = function(args)
              local filetype = vim.bo[args.buf].filetype
              local lang = vim.treesitter.language.get_lang(filetype) or filetype
              pcall(vim.treesitter.start, args.buf, lang)
              vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
          })
        '';
      }
      {
        plugin = srcery-vim;
        type = "lua";
        config = ''
          vim.cmd.colorscheme('srcery')
        '';
      }
    ];
  };
}
