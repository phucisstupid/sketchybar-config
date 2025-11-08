-- Add an indicator to switch between menus and spaces (placed next to logo)
local spaces_indicator = SBAR.add('item', {
  position = 'left',
  padding_left = -3,
  padding_right = 0,
  icon = {
    padding_left = 8,
    padding_right = 9,
    color = COLORS.lavender, -- Better visibility with accent color
    string = ICONS.switch.on,
  },
  label = {
    drawing = false,
  },
  background = {
    drawing = false,
  },
})

spaces_indicator:subscribe('swap_menus_and_spaces', function(env)
  local currently_on = spaces_indicator:query().icon.value == ICONS.switch.on
  spaces_indicator:set({
    icon = currently_on and ICONS.switch.off or ICONS.switch.on,
  })
end)

spaces_indicator:subscribe('mouse.clicked', function(env)
  SBAR.trigger('swap_menus_and_spaces')
end)

local window_manager
if WINDOW_MANAGER == 'aerospace' then
  window_manager = require('items.window_managers.aerospace')
else
  window_manager = require('items.window_managers.macos_native')
end

window_manager:init()
window_manager:start_watcher()
