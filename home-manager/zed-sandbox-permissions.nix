{
  homeDirectory,
}:
{
  network_hosts = [
    "cert-manager.io"
    "cilium.io"
    "*.cilium.io"
    "docs.ansible.com"
    "docs.rs"
    "docs.terragrunt.com"
    "famedly.atlassian.net"
    "github.com"
    "*.github.com"
    "*.githubusercontent.com"
    "*.go.dev"
    "*.golang.org"
    "*.hashicorp.com"
    "*.hetzner.com"
    "kubernetes.io"
    "kubernetes-sigs.github.io"
    "*.k8s.io"
    "learn.microsoft.com"
    "litellm.ai"
    "*.litellm.ai"
    "nix-community.github.io"
    "nixos.org"
    "*.nixos.org"
    "openebs.io"
    "opentofu.org"
    "*.opentofu.org"
    "*.python.org"
    "rust-lang.org"
    "*.scaleway.com"
    "*.siderolabs.com"
    "stackoverflow.com"
    "*.stackexchange.com"
    "*.terraform.io"
    "*.wikipedia.org"
    "*.notion.com"
    "*.mozilla.org"
    "zed.dev"
  ];
  write_paths = [
    "${homeDirectory}/src"
    # Subagents persist durable findings into their skill's references/ dir.
    # write_paths are subtree grants without glob support, so each one is
    # listed. Add an entry when a new skill gets a references/ directory.
    "${homeDirectory}/.agents/skills/grafana-ansible-observability/references"
    "${homeDirectory}/.agents/skills/grafana-k8s-observability/references"
    "${homeDirectory}/.agents/skills/jira-issue-search/references"
    "${homeDirectory}/.agents/skills/notion-context-search/references"
  ];
}
