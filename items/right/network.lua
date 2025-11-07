-- Execute the event provider binary which provides the event "network_update"
-- for the network interface "en0", which is fired every 2.0 seconds.
SBAR.exec(
  "killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0"
)

local netspeed_upload = SBAR.add("item", "netspeed_upload", {
  position = "right",
  padding_left = 2,
  width = 0,
  updates = "when_shown", -- Only update when visible (hidden by default via toggle_stats)
  icon = {
    padding_right = 0,
    font = {
      style = FONT.style_map["Bold"],
      size = STYLE.FONT_SIZE_SMALL,
    },
    string = ICONS.wifi.upload,
  },
  label = {
    font = {
      style = FONT.style_map["Bold"],
      size = STYLE.FONT_SIZE_SMALL,
    },
    color = COLORS.red, -- Red for upload
    string = "??? Bps",
  },
  y_offset = 4,
})

local netspeed_download = SBAR.add("item", "netspeed_download", {
  position = "right",
  padding_left = 2,
  updates = "when_shown", -- Only update when visible (hidden by default via toggle_stats)
  icon = {
    padding_right = 0,
    font = {
      style = FONT.style_map["Bold"],
      size = STYLE.FONT_SIZE_SMALL,
    },
    string = ICONS.wifi.download,
  },
  label = {
    font = {
      style = FONT.style_map["Bold"],
      size = STYLE.FONT_SIZE_SMALL,
    },
    color = COLORS.mauve, -- Mauve for download
    string = "??? Bps",
  },
  y_offset = -4,
})

local function get_network_color(speed)
  return (speed == "000 Bps") and COLORS.overlay0 or nil
end

netspeed_upload:subscribe("network_update", function(env)
  local up_color = get_network_color(env.upload) or COLORS.red -- Red for upload
  local down_color = get_network_color(env.download) or COLORS.mauve -- Mauve for download

  netspeed_upload:set({
    icon = { color = up_color },
    label = { string = env.upload, color = up_color },
  })
  netspeed_download:set({
    icon = { color = down_color },
    label = { string = env.download, color = down_color },
  })
end)
