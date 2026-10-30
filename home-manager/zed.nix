{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Famedly LiteLLM gateway, as in ~/.config/opencode/opencode.jsonc. Only
  # these models are allowed for our key (GET /v1/models).
  # max_tokens: context window
  # max_output_tokens: cap per reply incl. reasoning, sent with every request.
  #   Input plus this must fit into max_tokens, so these are the gateway's
  #   output limits (GET /model_group/info).
  litellmModels =
    map
      (
        m:
        lib.recursiveUpdate {
          max_tokens = 1048576;
          capabilities = {
            tools = true;
            images = true;
            # the gateway reports no parallel tool call support for these
            parallel_tool_calls = false;
            prompt_cache_key = true;
            # thinking models want their reasoning_content back on tool calls
            interleaved_reasoning = true;
          };
        } m
      )
      [
        {
          name = "DeepSeek-V4.1-Flash";
          max_output_tokens = 262144;
          reasoning_effort = "high";
        }
        # supports only low, high and max effort
        {
          name = "GLM-5.3-Flash";
          max_output_tokens = 131072;
          reasoning_effort = "high";
        }
        # thinking is always on and the gateway rejects reasoning_effort. No
        # output limit known to the gateway, so none is sent.
        {
          name = "Kimi-K3.1-Pro";
        }
      ];
in
{
  # MCP servers as in ~/.config/opencode/opencode.jsonc. Notion and Atlassian
  # ask for an OAuth login on first use. The Grafana service account tokens are
  # read from ~/.config/mcp/<name>.token when the server starts, so they stay
  # out of the Nix store.
  programs.mcp = {
    enable = true;
    servers =
      let
        # uvx instead of pkgs.mcp-grafana, which lags far behind
        grafana = name: url: {
          command = lib.getExe' pkgs.uv "uvx";
          args = [
            "mcp-grafana"
            "--disable-write"
            "--enabled-tools"
            "alerting,annotations,asserts,dashboard,datasources,examples,incident,loki,navigation,onCall,prometheus,searchlogs"
          ];
          env = {
            GRAFANA_URL = url;
            GRAFANA_SERVICE_ACCOUNT_TOKEN.file = "${config.xdg.configHome}/mcp/${name}.token";
          };
        };
      in
      {
        notion.url = "https://mcp.notion.com/mcp";
        atlassian.url = "https://mcp.atlassian.com/v2/mcp";
        context7.url = "https://mcp.context7.com/mcp";
        siderolabs-docs.url = "https://docs.siderolabs.com/mcp";
        terragrunt-docs.url = "https://mcp.docs.terragrunt.com/mcp";
        grafana-k8s = grafana "grafana-k8s" "https://grafana.monitoring.cloud.famedly.net";
        grafana-ansible = grafana "grafana-ansible" "https://graph.famedly.de";
      };
  };

  # https://nix-community.github.io/home-manager/options/home-manager/programs/zed-editor.html
  # https://wiki.nixos.org/wiki/Zed
  programs.zed-editor = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.zed-editor;

    # keep $EDITOR pointing at nvim (see configuration.nix), `e` in fish
    defaultEditor = false;

    extensions = [
      "codebook"
      "github-actions"
      "helm"
      "nix"
      "opentofu"
    ];

    # language servers from nixpkgs, binaries downloaded by Zed often fail on NixOS
    extraPackages = with pkgs; [
      basedpyright
      bubblewrap # for sandboxing
      codebook
      gopls
      helm-ls
      ruff
      rust-analyzer
      tofu-ls
      yaml-language-server
    ];

    userSettings = {
      autosave.after_delay.milliseconds = 1000;
      buffer_font_family = "FiraCode Nerd Font";
      buffer_font_size = 15;
      collaboration_panel.dock = "left";
      format_on_save = "on";
      git_panel.dock = "left";
      languages.Nix.language_servers = [
        "nil"
        "!nixd"
      ];
      markdown_preview.font_family = "Noto Sans";
      outline_panel.dock = "left";
      project_panel.dock = "left";
      show_whitespaces = "selection";
      soft_wrap = "editor_width";
      tab_size = 2;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      theme = {
        mode = "system";
        light = "Ayu Light";
        dark = "Ayu Dark";
      };
      ui_font_family = "Noto Sans";
      ui_font_size = 16;
      vim_mode = false;

      # https://zed.dev/docs/ai/use-api-access#openai-compatible
      # The API key is entered once in the agent settings (agent: open
      # settings) and kept in the Secret Service, or taken from
      # LITELLM_API_KEY if that is set.
      language_models.openai_compatible.litellm = {
        api_url = "https://gateway.ai.famedly.dev/v1";
        available_models = litellmModels;
      };
      agent = {
        dock = "right";
        enable_feedback = false;
        thinking_display = "always_collapsed";
        threads_sidebar = {
          position = "right";
        };
        use_modifier_to_send = true;
        # inline assistant, commit messages and thread summaries fall back to
        # this, subagents and compaction to the thread's model
        default_model = {
          provider = "litellm";
          model = "GLM-5.3-Flash";
          enable_thinking = true;
          effort = "high";
        };
      };
    };
  };
}
