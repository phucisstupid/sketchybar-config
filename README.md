<h1 align="center">
  <img alt="image" src="https://github.com/user-attachments/assets/ec762bdd-e8e4-42f5-8fdf-a49ccc43ba87" width="60%"/>
  <br>
  SketchyBar Configuration
  <br>
  <i>part of my <a href="https://github.com/phucisstupid/dotfiles">dotfiles</a></i>
  <br>
</h1>

## Installation

```sh
curl -fsSL https://raw.githubusercontent.com/phucisstupid/sketchybar-config/main/install.sh | sh -s
```

---

## Configuration

The default configuration is located in **`init.lua`**. To override or disable
specific options, create a **`settings.lua`** file in the same directory. It
will be automatically loaded _after_ the defaults and merged.

<details><summary>Every configuration with their default value:
</summary>

<!-- config:start -->

```lua
return {
  -- Global bar configuration
  window_manager = "macos_native", -- Options: "macos_native" or "aerospace"
  bar_preset = "default", -- Options: "default" (larger with border) or "compact" (minimal)

  -- Font configuration
  fonts = {
    icon_font = "Maple Mono NF",
    label_font = "Maple Mono NF",
    style_map = {
      ["Regular"] = "Regular",
      ["Semibold"] = "Medium",
      ["Bold"] = "Bold",
      ["Black"] = "ExtraBold",
    },
  },

  -- Spacing configuration
  spacing = {
    item_padding = 3,
    group_padding = 5,
    menu_padding = 6,
    workspace_padding = 10,
  },

  -- Module configuration
  modules = {
    -- Left side modules
    logo = { enabled = true },
    spaces = { enabled = true },
    menus = { enabled = true },
    front_app = { enabled = true },

    -- Right side modules
    calendar = { enabled = true },
    brew = { enabled = true },
    battery = { enabled = true, style = "both" }, -- Options: "icon", "text", or "both"
    wifi = { enabled = true, style = "both" }, -- Options: "icon", "text", or "both"
    bluetooth = { enabled = true, style = "icon" }, -- Options: "icon", "text", or "both" (only shows when Bluetooth is on)
    network = { enabled = true },
    volume = { enabled = true, style = "both" }, -- Options: "icon", "text", or "both"
    toggle_stats = { enabled = true },
    cpu = { enabled = true },
    memory = { enabled = true },
    music = { enabled = true },
  },

  -- Module-specific settings
  workspace = {
    label_style = "greek_uppercase", -- Options: "greek_uppercase", "greek_lowercase", or nil for numbers
  },

  music = {
    title_max_length = 15,
    default_artist = "Various Artists",
    default_album = "No Album",
  },

  network = {
    proxy_app = "FlClash", -- VPN/Proxy app name to detect
  },
}
```

<!-- config:end -->
</details>

### Example

To change defaults, create `~/.config/sketchybar/settings.lua`:

```lua
-- example settings.lua
return {
  bar_preset = "compact",
  window_manager = "aerospace",

  modules = {
    logo = { enabled = false },
    brew = { enabled = false },
    battery = {
      style = "text",
    },
  },
}
```

That's it — no need to modify `init.lua`. Your custom settings will be merged on
load.

---

## Structure

### Left Items

| Items                                   | Details                         |
| --------------------------------------- | ------------------------------- |
| [`logo`](items/left/logo.lua)           | same as clicking the Apple icon |
| [`menus`](items/left/menus.lua)         | open macOS app menu             |
| [`workspaces`](items/left/spaces.lua)   | switch to that space            |
| [`front app`](items/left/front_app.lua) | show app titles                 |

> Supported [`Window Managers`](items/window_managers):
>
> - macOS Native (default)
> - Aerospace

### Right Items

| Items                                          | Details                                                                                                                           |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| [`music`](items/music/init.lua)                | show music controller (play/pause, next, previous, repeat/random.)                                                                |
| [`toggle stats`](items/right/toggle_stats.lua) | show/hide system monitor ([`network`](items/right/network.lua), [`cpu`](items/right/cpu.lua), [`memory`](items/right/memory.lua)) |
| [`volume`](items/right/volume.lua)             | show volume slider and output device selector                                                                                     |
| [`wifi`](items/right/wifi.lua)                 | show wifi, IP and VPN status                                                                                                      |
| [`battery`](items/right/battery.lua)           | show remaining time and percentage                                                                                                |
| [`homebrew stats`](items/right/brew.lua)       | show outdated packages                                                                                                            |
| [`cal & time`](items/right/calendar.lua)       | open Calendar.app                                                                                                                 |
