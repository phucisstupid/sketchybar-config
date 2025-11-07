local defaults = {
  -- Global bar configuration
  window_manager = "macos_native",
  bar_preset = "default",

  bar_presets = {
    default = {
      border_width = 3,
      height = 32,
      y_offset = 1,
      margin = 5,
      corner_radius = 10,
    },
    compact = {
      border_width = 0,
      height = 26,
      y_offset = 0,
      margin = 0,
      corner_radius = 0,
    },
  },

  -- Font configuration
  fonts = {
    nerd_font = "Maple Mono NF",
    numbers_font = "Maple Mono NF",
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
    logo = { enabled = true },
    spaces = { enabled = true },
    menus = { enabled = true },
    front_app = { enabled = true },
    calendar = { enabled = true },
    brew = { enabled = true },
    battery = { enabled = true, style = "both" }, -- Options: "icon", "text", or "both"
    wifi = { enabled = true, style = "both" }, -- Options: "icon", "text", or "both"
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
    title_max_length = 20,
    default_artist = "Various Artists",
    default_album = "No Album",
  },

  network = {
    proxy_app = "FlClash",
  },
}

local function deep_merge(base, user)
  for key, value in pairs(user) do
    if type(value) == "table" and type(base[key]) == "table" then
      deep_merge(base[key], value)
    else
      base[key] = value
    end
  end
end

local user_settings = {}
local loaded, result = pcall(require, "settings")
if loaded and type(result) == "table" then
  user_settings = result
end

local config = {}
for k, v in pairs(defaults) do
  config[k] = v
end
deep_merge(config, user_settings)

-- Normalize modules
if config.modules then
  for name, module in pairs(config.modules) do
    if type(module) == "boolean" then
      config.modules[name] = { enabled = module }
    elseif type(module) == "table" and module.enabled == nil then
      module.enabled = true
    end
  end
end

WINDOW_MANAGER = config.window_manager
PRESET = config.bar_preset
PRESET_OPTIONS = config.bar_presets
FONT = {
  nerd_font = config.fonts.nerd_font,
  numbers = config.fonts.numbers_font,
  style_map = config.fonts.style_map,
}
MODULES = {}
for k, v in pairs(config.modules) do
  MODULES[k] = { enable = v.enabled }
  if v.style then
    MODULES[k].style = v.style
  end
end
SPACE_LABEL = config.workspace.label_style
SPACE_ITEM_PADDING = config.spacing.workspace_padding
MUSIC = {
  TITLE_MAX_CHARS = config.music.title_max_length,
  DEFAULT_ARTIST = config.music.default_artist,
  DEFAULT_ALBUM = config.music.default_album,
}
WIFI = { PROXY_APP = config.network.proxy_app }
PADDINGS = config.spacing.item_padding
GROUP_PADDINGS = config.spacing.group_padding
MENU_ITEM_PADDINGS = config.spacing.menu_padding

SBAR = require("sketchybar")
COLORS = require("colors")
ICONS = require("icons")

SBAR.begin_config()

local preset = PRESET_OPTIONS[PRESET] or PRESET_OPTIONS["default"]

-- Global style constants
STYLE = {
  -- Dimensions
  CORNER_RADIUS = 8,
  ITEM_HEIGHT = 24,
  BORDER_WIDTH = 1,
  POPUP_CORNER_RADIUS = 8,

  -- Colors (using Catppuccin palette)
  UNFOCUSED_BORDER_COLOR = COLORS.surface0,
  FOCUSED_BORDER_COLOR = COLORS.lavender,
  BACKGROUND_COLOR = COLORS.base,
  POPUP_BACKGROUND = COLORS.mantle, -- Slightly darker for popups
  POPUP_BORDER = COLORS.surface0,

  -- Semantic colors for better theming
  TEXT_PRIMARY = COLORS.text,
  TEXT_SECONDARY = COLORS.subtext1,
  TEXT_TERTIARY = COLORS.overlay0,
  ACCENT_PRIMARY = COLORS.lavender,
  ACCENT_SECONDARY = COLORS.mauve,

  -- Typography
  FONT_SIZE_ICON = 16.0,
  FONT_SIZE_LABEL = 13.0,
  FONT_SIZE_LABEL_LARGE = 15.0,
  FONT_SIZE_SMALL = 9.0, -- For graph widgets and small text
}

local bar_config = {
  font_smoothing = true,
  color = COLORS.base,
  height = preset.height,
  padding_right = PADDINGS,
  padding_left = PADDINGS,
  y_offset = preset.y_offset,
  margin = preset.margin,
  corner_radius = preset.corner_radius,
}

if preset.border_width > 0 then
  bar_config.border_width = preset.border_width
  bar_config.border_color = STYLE.UNFOCUSED_BORDER_COLOR
end

SBAR.bar(bar_config)

SBAR.default({
  padding_left = PADDINGS,
  padding_right = PADDINGS,
  icon = {
    font = { family = FONT.nerd_font, style = FONT.style_map["Bold"], size = STYLE.FONT_SIZE_ICON },
    color = COLORS.text,
    padding_left = PADDINGS,
    padding_right = PADDINGS,
  },
  label = {
    font = { family = FONT.nerd_font, style = FONT.style_map["Bold"], size = STYLE.FONT_SIZE_LABEL },
    color = COLORS.text,
    padding_left = PADDINGS,
    padding_right = PADDINGS,
  },
  background = {
    height = STYLE.ITEM_HEIGHT,
    corner_radius = STYLE.CORNER_RADIUS,
    border_width = STYLE.BORDER_WIDTH,
    border_color = COLORS.surface1,
  },
  popup = {
    align = "center",
    background = {
      border_width = STYLE.BORDER_WIDTH,
      corner_radius = STYLE.POPUP_CORNER_RADIUS,
      border_color = STYLE.POPUP_BORDER,
      color = STYLE.POPUP_BACKGROUND,
    },
  },
  scroll_texts = true,
})

require("items")

SBAR.end_config()
SBAR.event_loop()
