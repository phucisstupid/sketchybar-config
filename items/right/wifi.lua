local wifi_style = MODULES.wifi.style or "both"
local brew_enabled = MODULES.brew and MODULES.brew.enable ~= false
local battery_style = (MODULES.battery and MODULES.battery.enable ~= false) and (MODULES.battery.style or "icon") or nil
local wifi_icon_only = wifi_style == "icon"
local should_align_left = not brew_enabled and battery_style == "text" and wifi_icon_only
local popup_align = should_align_left and "right" or "center"

local wifi_item = SBAR.add("item", "wifi", {
  position = "right",
  update_freq = 5,
  icon = (wifi_style ~= "text") and {
    string = ICONS.wifi.connected,
    color = COLORS.mauve, -- Mauve for connectivity
  } or { drawing = false },
  label = (wifi_style ~= "icon") and {
    font = {
      style = FONT.style_map["Bold"],
      size = STYLE.FONT_SIZE_LABEL,
    },
    color = COLORS.mauve, -- Mauve for connectivity
    max_chars = 20,
    string = "???",
  } or { drawing = false },
  popup = {
    align = popup_align,
  },
})

local wifi_hover = false
local schedule_hide

local function attach_popup_hover(item)
  item:subscribe("mouse.entered", function()
    wifi_hover = true
  end)
  item:subscribe("mouse.exited", function()
    wifi_hover = false
    schedule_hide()
  end)
  item:subscribe("mouse.exited.global", function()
    wifi_hover = false
    schedule_hide()
  end)
end

local function update_wifi()
  -- Show explicit off icon when Wi‑Fi power is disabled
  SBAR.exec(
    "networksetup -getairportpower en0 2>/dev/null | awk '{print $NF}'",
    function(pwr)
      pwr = (pwr or ""):gsub("\n$", "")
      if pwr == "Off" then
        -- Power off: show only icon, hide text for all styles
        wifi_item:set({ icon = { string = ICONS.wifi.off, drawing = true, color = COLORS.overlay0 }, label = { drawing = false } })
        return
      end

      -- Otherwise, use SSID presence to determine connected/disconnected
  SBAR.exec(
    "networksetup -listpreferredwirelessnetworks en0 | sed -n '2p' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'",
    function(result)
      local ssid = result:gsub("\n$", "")
      local is_connected = (ssid ~= "" and ssid ~= nil)

      if not is_connected then
        ssid = "Not connected"
      end

      if wifi_style == "icon" then
        wifi_item:set({
          icon = {
            string = is_connected and ICONS.wifi.connected or ICONS.wifi.disconnected,
            color = is_connected and COLORS.mauve or COLORS.overlay0, -- Mauve for connected, muted for disconnected
            drawing = true,
          },
        })
      elseif wifi_style == "text" then
        if is_connected then
          wifi_item:set({
            icon = { drawing = false },
            label = { string = ssid, drawing = true, color = COLORS.subtext1 },
          })
        else
          -- Not connected: show only icon
          wifi_item:set({
            icon = { string = ICONS.wifi.disconnected, drawing = true, color = COLORS.overlay0 },
            label = { drawing = false },
          })
        end
      else
        if is_connected then
          wifi_item:set({
            icon = { string = ICONS.wifi.connected, color = COLORS.mauve, drawing = true },
            label = { string = ssid, drawing = true, color = COLORS.mauve },
          })
        else
          -- Not connected: show only icon
          wifi_item:set({
            icon = { string = ICONS.wifi.disconnected, color = COLORS.overlay0, drawing = true },
            label = { drawing = false },
          })
        end
      end
        end
      )
    end
  )
end

-- #region Popup
local popup_width = 250

local ssid_popup = SBAR.add("item", {
  position = "popup." .. wifi_item.name,
  icon = {
    font = {
      style = FONT.style_map["Bold"],
    },
    string = ICONS.wifi.router,
  },
  width = popup_width,
  align = "center",
  label = {
    font = {
      size = STYLE.FONT_SIZE_LABEL_LARGE,
      style = FONT.style_map["Bold"],
    },
    max_chars = 18,
    string = "????????????",
  },
  background = {
    height = 2,
    color = COLORS.overlay0,
    y_offset = -15,
  },
})

attach_popup_hover(ssid_popup)

local hostname = SBAR.add("item", {
  position = "popup." .. wifi_item.name,
  icon = {
    align = "left",
    string = "Hostname:",
    width = popup_width / 2,
  },
  label = {
    max_chars = 20,
    string = "????????????",
    width = popup_width / 2,
    align = "right",
  },
})
attach_popup_hover(hostname)

local ip = SBAR.add("item", {
  position = "popup." .. wifi_item.name,
  icon = {
    align = "left",
    string = "IP:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})
attach_popup_hover(ip)

local mask = SBAR.add("item", {
  position = "popup." .. wifi_item.name,
  icon = {
    align = "left",
    string = "Subnet mask:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})
attach_popup_hover(mask)

local router = SBAR.add("item", {
  position = "popup." .. wifi_item.name,
  icon = {
    align = "left",
    string = "Router:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})
attach_popup_hover(router)

local vpn = SBAR.add("item", {
  position = "popup." .. wifi_item.name,
  icon = {
    align = "left",
    string = "VPN:",
    width = popup_width / 2,
  },
  label = {
    string = "Not connected",
    width = popup_width / 2,
    align = "right",
  },
  click_script = "open -a " .. WIFI.PROXY_APP,
})
attach_popup_hover(vpn)

-- #endregion Popup

local function hide_details()
  wifi_item:set({ popup = { drawing = false } })
  wifi_hover = false
end

schedule_hide = function()
  SBAR.delay(0.2, function()
    if not wifi_hover then hide_details() end
  end)
end

local function update_popup_info()
  SBAR.exec(
    "networksetup -listpreferredwirelessnetworks en0 | sed -n '2p' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'",
    function(result)
      ssid_popup:set({ label = result:gsub("\n$", "") })
    end
  )
  SBAR.exec("networksetup -getcomputername", function(result)
    hostname:set({ label = result:gsub("\n$", "") })
  end)
  SBAR.exec("ipconfig getifaddr en0", function(result)
    ip:set({ label = result:gsub("\n$", "") })
  end)
  SBAR.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
    mask:set({ label = result:gsub("\n$", "") })
  end)
  SBAR.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
    router:set({ label = result:gsub("\n$", "") })
  end)
  SBAR.exec("pgrep -x " .. WIFI.PROXY_APP, function(result)
    vpn:set({ label = (result ~= "" and result:gsub("\n$", "") ~= "") and WIFI.PROXY_APP or "Not connected" })
  end)
end

local function toggle_details()
  local query = wifi_item:query()
  local should_draw = not query.popup or query.popup.drawing == "off"

  if should_draw then
    wifi_item:set({ popup = { drawing = true } })
    update_popup_info()
  else
    hide_details()
  end
end

wifi_item:subscribe({ "routine", "forced", "system_woke", "wifi_change" }, update_wifi)
wifi_item:subscribe("mouse.entered", function()
  wifi_hover = true
  local query = wifi_item:query()
  if not query.popup or query.popup.drawing == "off" then
    wifi_item:set({ popup = { drawing = true } })
    update_popup_info()
  end
end)
wifi_item:subscribe("mouse.exited", function()
  wifi_hover = false
  schedule_hide()
end)
wifi_item:subscribe("mouse.exited.global", function()
  wifi_hover = false
  hide_details()
end)

local function copy_label_to_clipboard(env)
  local label = SBAR.query(env.NAME).label.value
  SBAR.exec('echo "' .. label .. '" | pbcopy')
  SBAR.set(env.NAME, { label = { string = ICONS.clipboard, align = "center" } })
  SBAR.delay(1, function()
    SBAR.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

ssid_popup:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
