{
  description = "flake";

  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";

      # ensure nixpkgs version is consistent
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixpkgs-zed = {
      url = "nixpkgs/nixos-unstable";
    };

    codex-bin = {
      # GitHub redirects this URL to the latest tagged release asset.
      url = "https://github.com/openai/codex/releases/latest/download/codex-x86_64-unknown-linux-musl.tar.gz";
      flake = false;
    };
    gemini-cli-bin = {
      # GitHub redirects this URL to the latest tagged release asset.
      url = "https://github.com/google-gemini/gemini-cli/releases/latest/download/gemini.js";
      flake = false;
    };
    worktrunk-bin = {
      # GitHub redirects this URL to the latest tagged release asset.
      url = "https://github.com/max-sixty/worktrunk/releases/latest/download/worktrunk-x86_64-unknown-linux-musl.tar.xz";
      flake = false;
    };

    # git version of hyprland
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;

      # ---------- SYSTEM SETTINGS ---------- #
      system = "x86_64-linux";
      zedPkgs = import inputs.nixpkgs-zed { inherit system; };

      overlays = [
        (final: _prev: {
          zed-editor-unstable = zedPkgs.zed-editor;
          zed-editor = zedPkgs.zed-editor;
          zed-editor-fhs = zedPkgs.zed-editor.fhs;
          zed-editor-fhs-with-packages = zedPkgs.zed-editor.fhsWithPackages;
          gemini-cli = final.stdenvNoCC.mkDerivation {
            pname = "gemini-cli";
            version = "latest";
            src = inputs.gemini-cli-bin;
            dontUnpack = true;
            nativeBuildInputs = [ final.makeWrapper ];

            installPhase = ''
              runHook preInstall
              install -Dm644 "$src" "$out/libexec/gemini.js"
              makeWrapper ${final.nodejs}/bin/node "$out/bin/gemini" \
                --add-flags "--no-warnings=DEP0040 $out/libexec/gemini.js"
              runHook postInstall
            '';

            meta = {
              description = "An open-source AI agent that brings the power of Gemini into your terminal";
              homepage = "https://github.com/google-gemini/gemini-cli";
              license = final.lib.licenses.asl20;
              mainProgram = "gemini";
              platforms = [ "x86_64-linux" ];
            };
          };
          codex = final.stdenvNoCC.mkDerivation {
            pname = "codex";
            version = "latest";
            src = inputs.codex-bin;

            installPhase = ''
              runHook preInstall
              install -Dm755 "$src/codex-x86_64-unknown-linux-musl" "$out/bin/codex"
              runHook postInstall
            '';

            meta = {
              description = "Lightweight coding agent that runs in your terminal";
              homepage = "https://github.com/openai/codex";
              license = final.lib.licenses.asl20;
              mainProgram = "codex";
              platforms = [ "x86_64-linux" ];
            };
          };
          worktrunk = final.stdenvNoCC.mkDerivation {
            pname = "worktrunk";
            version = "latest";
            src = inputs.worktrunk-bin;

            installPhase = ''
              runHook preInstall
              if [ -d "$src/worktrunk-x86_64-unknown-linux-musl" ]; then
                bin_root="$src/worktrunk-x86_64-unknown-linux-musl"
              else
                bin_root="$src"
              fi
              install -Dm755 "$bin_root/wt" "$out/bin/wt"
              install -Dm755 "$bin_root/git-wt" "$out/bin/git-wt"
              runHook postInstall
            '';

            meta = {
              description = "CLI for Git worktree management";
              homepage = "https://worktrunk.dev";
              license = with final.lib.licenses; [ mit asl20 ];
              mainProgram = "wt";
              platforms = [ "x86_64-linux" ];
            };
          };
          blender = zedPkgs.blender;
        })
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
      };
      systemSettings = {
        timezone = "America/Los_Angeles";
      };

      # ----------- USER SETTINGS ----------- #
      userSettings = {
        username = "theo";
        name = "Theo Rode";
        codexAuthProfile = "personal";

      };

      # ----------- THEME SETTINGS ---------- #
      theme = {
        # grayscale going from dark to light
        base00 = "1d1f21";
        base01 = "282a2e";
        base02 = "373b41";
        base03 = "969896";
        base04 = "b4b7b4";
        base05 = "c5c8c6";
        base06 = "e0e0e0";
        base07 = "ffffff";

        base00_rgb = "29, 31, 33";
        base01_rgb = "40, 42, 46";
        base02_rgb = "55, 59, 65";
        base03_rgb = "150, 152, 150";
        base04_rgb = "180, 183, 180";
        base05_rgb = "197, 200, 198";
        base06_rgb = "224, 224, 224";
        base07_rgb = "255, 255, 255";

        # accent colors
        base08 = "ff6e67"; # light red
        base09 = "fea3b5"; # pink
        base0A = "f3c969"; # gold
        base0B = "6ecefe"; # "7dcef7"; # light blue
        base0C = "a8ff60"; # green
        base0D = "7aa6da"; # dark blue
        base0E = "a284dc"; # purple
        base0F = "cc6666"; # dark red

        base08_rgb = "255, 110, 103";
        base09_rgb = "254, 163, 181";
        base0A_rgb = "243, 201, 105";
        base0B_rgb = "110, 206, 254";
        base0C_rgb = "168, 255, 96";
        base0D_rgb = "122, 166, 218";
        base0E_rgb = "162, 132, 220";
        base0F_rgb = "204, 102, 102";

        # accent colors alts for kitty
        base08alt = "eb2c23";
        base09alt = "f14881";
        base0Aalt = "fab414";
        base0Balt = "0daeff";
        base0Calt = "7cfa14";
        base0Dalt = "2379de";
        base0Ealt = "5912e3";
        base0Falt = "a31414";

        base08alt_rgb = "235, 44, 35";
        base09alt_rgb = "241, 72, 128";
        base0Aalt_rgb = "250, 180, 20";
        base0Balt_rgb = "13, 174, 255";
        base0Calt_rgb = "124, 250, 20";
        base0Dalt_rgb = "35, 121, 222";
        base0Ealt_rgb = "89, 18, 227";
        base0Falt_rgb = "163, 20, 20";

        # base0Dalt gradient (main accent)
        base0Dalt2 = "1b5eab";
        base0Dalt3 = "134278";
        base0Dalt4 = "0b2645";

        base0Dalt2_rgb = "27, 94, 171";
        base0Dalt3_rgb = "19, 66, 120";
        base0Dalt4_rgb = "11, 38, 69";

        # main background options
        dark_background_primary = "120C2E";
        dark_background_primary_rgb = "18, 12, 46";
      };

    in
    {
      legacyPackages.${system} = pkgs;
      nixosConfigurations = {
        conceivably-a-shark = lib.nixosSystem {
          inherit system;
          modules = [
            (
              { ... }:
              {
                nixpkgs.overlays = overlays;
              }
            )
            ./hosts/conceivably-a-shark/configuration.nix
            ./configuration.nix
            ./hosts/conceivably-a-shark/hardware-configuration.nix
            inputs.home-manager.nixosModules.default
          ];
          specialArgs = {
            inherit inputs;
            inherit systemSettings;
            inherit userSettings;
            inherit theme;
          };
        };
        plausibly-a-shark = lib.nixosSystem {
          inherit system;
          modules = [
            (
              { ... }:
              {
                nixpkgs.overlays = overlays;
              }
            )
            ./hosts/plausibly-a-shark/configuration.nix
            ./configuration.nix
            ./hosts/plausibly-a-shark/hardware-configuration.nix
            inputs.home-manager.nixosModules.default
          ];
          specialArgs = {
            inherit inputs;
            inherit systemSettings;
            inherit userSettings;
            inherit theme;
          };
        };
      };
    };
}
