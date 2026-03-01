# Dotfiles

My computer. 

## Lockfile Inputs You Can Update

| Input | Purpose | Update command |
| --- | --- | --- |
| `codex-bin` | Codex binary release asset from GitHub | `nix flake update codex-bin` |
| `gemini-cli-bin` | Gemini CLI release asset (`gemini.js`) from GitHub | `nix flake update gemini-cli-bin` |
| `worktrunk-bin` | Worktrunk binary release asset from GitHub | `nix flake update worktrunk-bin` |
| `nixpkgs` | Main Nix package set | `nix flake update nixpkgs` |
| `nixpkgs-zed` | Separate nixpkgs pin used for Zed-related packages | `nix flake update nixpkgs-zed` |
| `home-manager` | Home Manager source | `nix flake update home-manager` |
