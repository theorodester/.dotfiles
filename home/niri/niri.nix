{ lib, nixosSystemMonitors, theme, ... }:
let
  wallpaper = "~/.dotfiles/wallpapers/shark_coral_background_1_upscale.jpg";
  screenshotPath = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

  mkOutput =
    monitor:
    let
      coords =
        if monitor.position == "auto" then
          [ ]
        else
          lib.splitString "x" monitor.position;
      positionLine =
        if monitor.position == "auto" then
          ""
        else
          "    position x=${builtins.elemAt coords 0} y=${builtins.elemAt coords 1}\n";
      modeLine =
        if monitor.enabled then
          "    mode \"${toString monitor.width}x${toString monitor.height}\"\n"
        else
          "";
      scaleLine =
        if monitor.enabled then
          "    scale ${monitor.scale}\n"
        else
          "";
    in
    ''
      output "${monitor.name}" {
      ${if monitor.enabled then "" else "    off\n"}${modeLine}${scaleLine}${positionLine}      }
    '';

  mkWorkspaceBinds =
    key: workspace:
    let
      workspaceId = toString workspace;
    in
    ''
      Mod+${key} { focus-workspace ${workspaceId}; }
      Mod+Shift+${key} { move-column-to-workspace ${workspaceId} focus=false; }
    '';

  outputsConfig = lib.concatStringsSep "\n" (map mkOutput nixosSystemMonitors);

  workspaceBindings = lib.concatStringsSep "\n" [
    (mkWorkspaceBinds "1" 1)
    (mkWorkspaceBinds "2" 2)
    (mkWorkspaceBinds "3" 3)
    (mkWorkspaceBinds "4" 4)
    (mkWorkspaceBinds "5" 5)
    (mkWorkspaceBinds "6" 6)
    (mkWorkspaceBinds "7" 7)
    (mkWorkspaceBinds "8" 8)
    (mkWorkspaceBinds "9" 9)
    (mkWorkspaceBinds "0" 10)
  ];
in
{
  xdg.configFile."niri/config.kdl".text = ''
    // Shared desktop defaults live in Home Manager. This file only carries
    // niri-specific behavior so Hyprland and niri can coexist cleanly.

    ${outputsConfig}

    prefer-no-csd
    screenshot-path "${screenshotPath}"

    environment {
        ELECTRON_OZONE_PLATFORM_HINT "wayland"
        GDK_SCALE "2"
        XCURSOR_SIZE "12"
        XCURSOR_THEME "GoogleDot-Black"
    }

    spawn-at-startup "~/.dotfiles/home/wayland/scripts/start-session.sh"

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }

        touchpad {
            natural-scroll false
        }

        mouse {
            accel-speed -0.5
        }

        focus-follows-mouse max-scroll-amount="20%"
    }

    layout {
        gaps 10
        center-focused-column "never"
        always-center-single-column
        background-color "#${theme.dark_background_primary}"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        preset-window-heights {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        focus-ring {
            on
            width 2
            active-gradient from="#${theme.base0B}ee" to="#${theme.base09}ee" angle=45 relative-to="workspace-view"
            inactive-color "#${theme.dark_background_primary}aa"
            urgent-color "#${theme.base08}ee"
        }

        border {
            off
        }

        shadow {
            off
        }

        tab-indicator {
            hide-when-single-tab
        }
    }

    hotkey-overlay {
        skip-at-startup
    }

    binds {
        Mod+Space repeat=false { spawn "wofi"; }
        Mod+S repeat=false { screenshot write-to-disk=false show-pointer=false; }
        Mod+W repeat=false { close-window; }
        Mod+M repeat=false { quit skip-confirmation=true; }
        Mod+V repeat=false { toggle-window-floating; }

        Mod+Ctrl+Shift+W repeat=false { spawn "sh" "-lc" "swww img ${wallpaper}"; }

        Mod+Q repeat=false { spawn "kitty"; }
        Mod+F repeat=false { spawn "firefox"; }
        Mod+O repeat=false { spawn "obsidian" "--ozone-platform=wayland" "--enable-features=UseOzonePlatform"; }

        Mod+Ctrl+Shift+Alt+H repeat=false { spawn "systemctl" "hibernate"; }
        Mod+Ctrl+Shift+S repeat=false { spawn "systemctl" "suspend"; }

        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }
        Mod+K { focus-window-up; }
        Mod+J { focus-window-down; }

        Mod+Shift+L { set-column-width "+10%"; }
        Mod+Shift+H { set-column-width "-10%"; }
        Mod+Shift+K { set-window-height "-10%"; }
        Mod+Shift+J { set-window-height "+10%"; }

        Mod+Ctrl+H { move-column-left; }
        Mod+Ctrl+L { move-column-right; }
        Mod+Ctrl+K { move-window-up; }
        Mod+Ctrl+J { move-window-down; }

    ${workspaceBindings}

        XF86AudioRaiseVolume allow-when-locked=true { spawn "pamixer" "-i" "5"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "pamixer" "-d" "5"; }
        XF86AudioMute allow-when-locked=true { spawn "pamixer" "-t"; }

        XF86KbdBrightnessDown allow-when-locked=true { spawn "brightnessctl" "-d" "dell::kbd_backlight" "set" "33%-"; }
        XF86KbdBrightnessUp allow-when-locked=true { spawn "brightnessctl" "-d" "dell::kbd_backlight" "set" "33%+"; }

        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "10%-"; }
        XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "10%+"; }
    }

    window-rule {
        geometry-corner-radius 10
        clip-to-geometry true
    }

    window-rule {
        match app-id="kitty$"
        opacity 0.6
    }

    window-rule {
        match app-id="Code$"
        opacity 0.8
    }

    window-rule {
        match app-id="obsidian$"
        opacity 0.7
        open-floating false
    }

    window-rule {
        match app-id="dev\\.zed\\.Zed$"
        opacity 0.85
    }

    window-rule {
        match app-id="discord$"
        opacity 0.7
    }

    window-rule {
        match app-id="spotify$"
        opacity 0.5
    }

    window-rule {
        match app-id="firefox$" title="Gradescope"
        opacity 0.8
    }

    window-rule {
        match app-id="firefox$" title="Google Calendar"
        opacity 0.7
    }

    window-rule {
        match app-id="firefox$" title="Wikipedia"
        opacity 0.8
    }

    window-rule {
        match app-id="firefox$" title="RapidIdentity"
        opacity 0.7
    }

    window-rule {
        match app-id="firefox$" title="Online LaTeX Editor Overleaf"
        opacity 0.7
    }

    window-rule {
        match app-id="firefox$" title="Harvey Mudd College Mail"
        opacity 0.7
    }

    window-rule {
        match app-id="firefox$" title="Inbox .*theorodester@gmail\\.com"
        opacity 0.7
    }

    window-rule {
        match app-id="rstudio$"
        opacity 0.7
    }
  '';
}
