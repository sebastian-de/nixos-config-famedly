{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fzf.fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
    ];
    functions = {
      ans_env = {
        description = "Switch to Famedly ansible-environment";
        body = ''
          cd ~/src/ansible-environment/
          set -g -x ANSIBLE_CALLBACK_RESULT_FORMAT yaml
        '';
      };
      develop = {
        wraps = "nix develop";
        body = ''
          nix develop --command fish
        '';
      };
      e = {
        wraps = "$EDITOR";
        body = ''
          command $EDITOR $argv;
        '';
      };
      fish_user_key_bindings = {
        body = ''
          # https://fishshell.com/docs/current/cmds/bind.html
          bind \cy _fzf_jump_directory  # Ctrl-y
        '';
      };
      # https://github.com/PatrickF1/fzf.fish/discussions/231
      # fzf jump directory function, requires: https://github.com/jethrokuan/z
      _fzf_jump_directory = {
        body = ''
          if not type -q z
            set_color red
              echo "_fzf_jump_directory: z not found." >&2
            set_color normal
            return 1
          end

          set current_token (commandline --current-token)

          set command_z (
            z -l | sort -rn | cut -c 12- | _fzf_wrapper --query=$current_token $fzf_jump_directory_opts --preview='_fzf_preview_file {}'
          )

          if test $status -eq 0
            cd $command_z
          end

          commandline --function repaint
        '';
      };
      glagdo = {
        description = "show a nice git graph";
        wraps = "git log --all --graph --decorate --oneline";
        body = ''
          git log --all --graph --decorate --oneline $argv;
        '';
      };
      gmcb = {
        description = "Merge current branch into default branch";
        body = ''
          set source_branch (git rev-parse --abbrev-ref HEAD) || return 1
          set target_branch (git symbolic-ref refs/remotes/origin/HEAD | sed 's|^refs/remotes/origin/||') || return 1

          echo "Merge $source_branch into $target_branch"
          git switch $target_branch || return 1
          git pull || return 1
          git merge $source_branch
        '';
      };
      gscc = {
        description = "Checkout collection submodule at specified commit";
        body = ''
          set collection $argv[1] || return 1
          set commit $argv[2] || return 1

          echo "Set ansible_collections/famedly/$collection to commit $commit"
          cd ansible_collections/famedly/$collection || return 1
          git fetch || return 1
          git checkout $commit
          cd ../../..
        '';
      };
      gsdb = {
        description = "Switch collection submodule to default branch and update it";
        body = ''
          set collection $argv[1] || return 1

          echo "Set ansible_collections/famedly/$collection to branch main"
          git config -f .gitmodules submodule.ansible_collections/famedly/$collection.branch main || return 1
          git submodule update --force ansible_collections/famedly/$collection
        '';
      };
      gssb = {
        description = "Switch collection submodule to specific branch and update it";
        body = ''
          set collection $argv[1] || return 1
          set branch $argv[2] || return 1

          echo "Set ansible_collections/famedly/$collection to branch $branch"
          git config -f .gitmodules submodule.ansible_collections/famedly/$collection.branch $branch || return 1
          git submodule update --force --remote ansible_collections/famedly/$collection
        '';
      };
      ib = {
        description = "alias for ip -color=auto -brief -human";
        wraps = "ip -color=auto -brief -human";
        body = ''
          ip -color=auto -brief -human $argv;
        '';
      };
      ip = {
        wraps = "ip -color=auto -human";
        body = ''
          command ip -color=auto -human $argv;
        '';
      };
      k = {
        wraps = "kubectl";
        body = ''
          command kubectl $argv;
        '';
      };
      p = {
        description = "switch between full und simple prompt";
        body = ''
          if test -n "$STARSHIP_CONFIG"
            set -e STARSHIP_CONFIG
          else
            set -gx STARSHIP_CONFIG "$HOME/.config/starship-simple.toml"
            echo # newline after switch
          end
        '';
      };
    };
  };
}
