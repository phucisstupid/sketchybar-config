if not (MODULES.battery and MODULES.battery.enable) then
  return
end

local style = MODULES.battery.style or "icon"

local battery = SBAR.add("item", "battery", {
  position = "right",
  update_freq = 180,
  icon = (style ~= "text") and {
    font = { style = FONT.style_map["Regular"], size = STYLE.FONT_SIZE_ICON },
  } or { drawing = false },
  label = (style ~= "icon") and {
    color = COLORS.text,
  } or { drawing = false },
  popup = {
    align = "right",
  },
})

-- Get battery icon based on charge level
local function get_icon_level(charge)
  if charge >= 95 then
    return "100"
  elseif charge >= 85 then
    return "90"
  elseif charge >= 75 then
    return "80"
  elseif charge >= 65 then
    return "70"
  elseif charge >= 55 then
    return "60"
  elseif charge >= 45 then
    return "50"
  elseif charge >= 35 then
    return "40"
  elseif charge >= 25 then
    return "30"
  elseif charge >= 15 then
    return "20"
  else
    return "10"
  end
end

local function get_battery_icon(charge, is_charging)
  local lvl = get_icon_level(charge)
  if is_charging then
    return ICONS.battery["charging_" .. lvl], COLORS.green
  else
    return ICONS.battery["_" .. lvl], COLORS.green
  end
end

-- Get battery color for text display
local function get_battery_color(charge)
  if charge <= 20 then
    return COLORS.red
  elseif charge <= 40 then
    return COLORS.peach
  else
    return COLORS.green
  end
end

-- Update battery display based on style
local function update_battery(charge, is_charging)
  if style == "icon" then
    -- icon mode: use battery icon normally (including charging variant if you have one)
    local icon, color = get_battery_icon(charge, is_charging)
    battery:set({
      icon = { string = icon, color = color, drawing = true },
      label = { drawing = false },
    })
  elseif style == "text" then
    -- text mode: use lightning TEXT symbol when charging
    local color = get_battery_color(charge)
    local symbol = is_charging and ICONS.battery.charging_symbol or "%"
    battery:set({
      icon = { drawing = false },
      label = {
        string = charge .. symbol,
        color = color,
        drawing = true,
      },
    })
  else -- both
    -- BOTH MODE: show icon + text, but NEVER show the "󱐋"
    local icon, icon_color = get_battery_icon(charge, is_charging)
    local label_color = get_battery_color(charge)

    battery:set({
      icon = { string = icon, color = icon_color, drawing = true },
      label = {
        string = charge .. "%",
        color = label_color,
        drawing = true,
      },
    })
  end
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
  SBAR.exec("pmset -g batt", function(batt_info)
    local charge_match = batt_info:match("(%d+)%%")
    local charge = charge_match and tonumber(charge_match) or nil
    local is_charging = batt_info:find("AC Power") ~= nil

    if charge then
      update_battery(charge, is_charging)
    else
      battery:set({
        icon = { drawing = style ~= "text" },
        label = { string = "N/A", color = COLORS.red, drawing = style ~= "icon" },
      })
    end
  end)
end)

-- Popup only for icon and both styles
if style ~= "text" then
  local battery_percent = SBAR.add("item", {
    position = "popup." .. battery.name,
    icon = { string = "Percentage:", width = 100, align = "left" },
    label = { string = "??%", width = 100, align = "right" },
  })
  battery_percent:subscribe("mouse.entered", function()
    battery_hover = true
  end)
  battery_percent:subscribe("mouse.exited", function()
    battery_hover = false
    SBAR.delay(0.2, function()
      if not battery_hover then battery:set({ popup = { drawing = false } }) end
    end)
  end)

  local remaining_time = SBAR.add("item", {
    position = "popup." .. battery.name,
    icon = { string = "Time remaining:", width = 100, align = "left" },
    label = { string = "??:??h", width = 100, align = "right" },
  })
  remaining_time:subscribe("mouse.entered", function()
    battery_hover = true
  end)
  remaining_time:subscribe("mouse.exited", function()
    battery_hover = false
    SBAR.delay(0.2, function()
      if not battery_hover then battery:set({ popup = { drawing = false } }) end
    end)
  end)

  local battery_hover = false
  battery:subscribe("mouse.entered", function()
    battery_hover = true
    local query = battery:query()
    local should_draw = not query.popup or query.popup.drawing == "off"

    if should_draw then
      battery:set({ popup = { drawing = true } })
      SBAR.exec("pmset -g batt", function(batt_info)
        local charge_match = batt_info:match("(%d+)%%")
        local remaining_match = batt_info:match(" (%d+:%d+) remaining")

        if charge_match then
          battery_percent:set({ label = { string = charge_match .. "%" } })
        end

        local time_label = remaining_match and (remaining_match .. "h") or "No estimate"
        remaining_time:set({ label = { string = time_label } })
      end)
    else
      battery:set({ popup = { drawing = false } })
    end
  end)

  battery:subscribe("mouse.exited", function()
    battery_hover = false
    SBAR.delay(0.2, function()
      if not battery_hover then battery:set({ popup = { drawing = false } }) end
    end)
  end)
  battery:subscribe("mouse.exited.global", function()
    battery_hover = false
    battery:set({ popup = { drawing = false } })
  end)
end
