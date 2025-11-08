local popup_width = 150
local volume_style = MODULES.volume.style or 'both'

local volume_icon = SBAR.add('item', 'widgets.volume', {
  position = 'right',
  icon = (volume_style ~= 'text')
      and {
        string = ICONS.volume._100,
        align = 'right',
        color = COLORS.yellow, -- Yellow for audio
      }
    or { drawing = false },
  label = (volume_style ~= 'icon') and {
    align = 'right',
    string = '0%',
    color = COLORS.text,
  } or { drawing = false },
})

local volume_hover = false
local schedule_hide

local function volume_collapse_details()
  local query = volume_icon:query()
  if query.popup and query.popup.drawing == 'on' then
    volume_icon:set({ popup = { drawing = false } })
    SBAR.remove('/volume.device\\.*/')
  end
  volume_hover = false
end

schedule_hide = function()
  SBAR.delay(0.2, function()
    if not volume_hover then
      volume_collapse_details()
    end
  end)
end

local function attach_popup_hover(item)
  item:subscribe('mouse.entered', function()
    volume_hover = true
  end)
  item:subscribe('mouse.exited', function()
    volume_hover = false
    schedule_hide()
  end)
  item:subscribe('mouse.exited.global', function()
    volume_hover = false
    schedule_hide()
  end)
end

local volume_slider = SBAR.add('slider', popup_width, {
  position = 'popup.' .. volume_icon.name,
  slider = {
    highlight_color = COLORS.yellow, -- Yellow for audio slider
    background = {
      height = 6,
      corner_radius = 3,
      color = COLORS.surface1,
    },
  },
  background = { color = COLORS.base, height = 2, y_offset = -20 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})
attach_popup_hover(volume_slider)

-- Icon selection based on volume percentage
local function get_volume_icon(volume)
  if volume > 60 then
    return ICONS.volume._100
  elseif volume > 30 then
    return ICONS.volume._66
  elseif volume > 10 then
    return ICONS.volume._33
  elseif volume > 0 then
    return ICONS.volume._10
  else
    return ICONS.volume._0
  end
end

-- Update volume display based on style
local function update_volume(volume)
  if volume_style == 'icon' then
    volume_icon:set({
      icon = {
        string = get_volume_icon(volume),
        drawing = true,
      },
      label = { drawing = false },
    })
  elseif volume_style == 'text' then
    volume_icon:set({
      icon = { drawing = false },
      label = {
        string = math.floor(volume) .. '%',
        drawing = true,
        color = COLORS.yellow, -- Match icon color for consistency
      },
    })
  else -- both
    volume_icon:set({
      icon = {
        string = get_volume_icon(volume),
        drawing = true,
      },
      label = {
        string = math.floor(volume) .. '%',
        drawing = true,
        color = COLORS.yellow, -- Match icon color for consistency
      },
    })
  end
  volume_slider:set({ slider = { percentage = volume } })
end

volume_icon:subscribe('volume_change', function(env)
  local volume = tonumber(env.INFO)
  update_volume(volume)
end)

local current_audio_device = 'None'
local function volume_toggle_details(env)
  if env.BUTTON == 'right' then
    SBAR.exec('open /System/Library/PreferencePanes/Sound.prefpane')
    return
  end

  local query = volume_icon:query()
  local should_draw = not query.popup or query.popup.drawing == 'off'
  if should_draw then
    volume_icon:set({ popup = { drawing = true } })
    SBAR.exec('SwitchAudioSource -t output -c', function(result)
      current_audio_device = result:gsub('\n$', '')
      SBAR.exec('SwitchAudioSource -a -t output', function(available)
        local devices = {}
        for device in available:gmatch('[^\r\n]+') do
          table.insert(devices, device)
        end

        local counter = 0
        for _, device in ipairs(devices) do
          local is_current = device == current_audio_device
          local device_item = SBAR.add('item', 'volume.device.' .. counter, {
            position = 'popup.' .. volume_icon.name,
            width = popup_width,
            label = {
              string = device,
              color = is_current and COLORS.text or COLORS.overlay0,
            },
            click_script = string.format(
              'SwitchAudioSource -s "%s" && sketchybar --set /volume.device\\.*/ label.color=%s --set $NAME label.color=%s',
              device,
              COLORS.overlay0,
              COLORS.text
            ),
          })
          attach_popup_hover(device_item)
          counter = counter + 1
        end
      end)
    end)
  else
    volume_collapse_details()
  end
end

local function volume_scroll(env)
  local delta = env.INFO.delta
  if env.INFO.modifier ~= 'ctrl' then
    delta = delta * 10.0
  end
  SBAR.exec(
    string.format(
      'osascript -e "set volume output volume (output volume of (get volume settings) + %.1f)"',
      delta
    )
  )
end

-- Initialize volume on startup
SBAR.exec('osascript -e "output volume of (get volume settings)"', function(result)
  local volume = tonumber(result:gsub('\n$', ''))
  if volume then
    update_volume(volume)
  end
end)

volume_icon:subscribe('mouse.entered', function(env)
  volume_hover = true
  local query = volume_icon:query()
  if not query.popup or query.popup.drawing == 'off' then
    volume_toggle_details(env)
  end
end)
volume_icon:subscribe('mouse.exited', function()
  volume_hover = false
  schedule_hide()
end)
volume_icon:subscribe('mouse.exited.global', function()
  volume_hover = false
  volume_collapse_details()
end)
volume_icon:subscribe('mouse.scrolled', volume_scroll)
