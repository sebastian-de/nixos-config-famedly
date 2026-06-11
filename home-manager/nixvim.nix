{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";

    plugins.bufferline.enable = true;
    plugins.lualine.enable = true;
    plugins.web-devicons.enable = true;

    plugins.fzf-lua = {
      enable = true;
      keymaps = {
        # buffers
        "<leader>bb" = {
          action = "buffers";
          options = {
            silent = true;
            desc = "open buffers";
          };
        };
        "<leader>bf" = {
          action = "files";
          options = {
            silent = true;
            desc = "files";
          };
        };
        "<leader>bh" = {
          action = "history";
          options = {
            silent = true;
            desc = "history";
          };
        };
        # git
        "<leader>gb" = {
          action = "git_branches";
          options = {
            silent = true;
            desc = "Git branches";
          };
        };
        "<leader>gc" = {
          action = "git_commits";
          options = {
            silent = true;
            desc = "Git commits";
          };
        };
        "<leader>gg" = {
          action = "git_status";
          options = {
            silent = true;
            desc = "Git status";
          };
        };
        "<leader>gs" = {
          action = "git_stash";
          options = {
            silent = true;
            desc = "Git stash";
          };
        };
        "<leader>gt" = {
          action = "git_tags";
          options = {
            silent = true;
            desc = "Git tags";
          };
        };
        # search
        "<leader>sg" = {
          action = "grep";
          options = {
            silent = true;
            desc = "grep";
          };
        };
        "<leader>sw" = {
          action = "grep_cword";
          options = {
            silent = true;
            desc = "grep word under cursor";
          };
        };
        "<leader>sp" = {
          action = "grep_project";
          options = {
            silent = true;
            desc = "grep all project lines";
          };
        };
        "<leader>si" = {
          action = "live_grep";
          options = {
            silent = true;
            desc = "live grep current project";
          };
        };
        "<leader>sr" = {
          action = "live_grep_resume";
          options = {
            silent = true;
            desc = "live grep continue last search";
          };
        };
      };
    };

    plugins.treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
    };

    plugins.which-key = {
      enable = true;
      settings = {
        preset = "helix";
        spec = [
          {
            __unkeyed-1 = "<leader>b";
            group = "buffer";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "git";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "search";
          }
          {
            __unkeyed-1 = "<leader>w";
            group = "windows";
            proxy = "<C-w>";
          }
        ];
      };
    };

    extraPlugins = [ pkgs.vimPlugins.srcery-vim ];
    colorscheme = "srcery";
  };
}
