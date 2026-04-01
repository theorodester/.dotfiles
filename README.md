# Dotfiles

My computer. 

## Lockfile Inputs You Can Update

| Input | Purpose | Update command |
| --- | --- | --- |
| `codex-bin` | Codex binary release asset from GitHub | `nix flake update codex-bin` |
| `anthropic-skills` | Anthropic skills repo used for declarative agent skill installs | `nix flake update anthropic-skills` |
| `t3code-bin` | T3 Code Linux updater manifest from GitHub, which resolves the AppImage in Nix | `nix flake update t3code-bin` |
| `worktrunk-bin` | Worktrunk binary release asset from GitHub | `nix flake update worktrunk-bin` |
| `nixpkgs` | Main Nix package set | `nix flake update nixpkgs` |
| `nixpkgs-zed` | Separate nixpkgs pin used for Zed-related packages | `nix flake update nixpkgs-zed` |
| `home-manager` | Home Manager source | `nix flake update home-manager` |

## Agent Skills

Declarative agent skills are configured through `agentSkills` in `home/home.nix`, with shared install logic in `home/agent-skills.nix`.

To add another skill, pin its source repo in `flake.nix` and add one entry with the skill directory path and target agents.
To support another agent, add its skill directory once in `agentSkills.agents`.
