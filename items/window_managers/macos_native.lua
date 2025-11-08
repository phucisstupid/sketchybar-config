-- macOS Native Spaces Window Manager
-- Uses macOS native Mission Control spaces
-- Ref: https://felixkratz.github.io/SketchyBar/config/events
local app_icons = require('helpers.spaces_util.icon_map')
local sbar_utils = require('helpers.spaces_util.sbar_util')

local Window_Manager = {
  spaces = {},
  events = {
    window_change = 'space_windows_change',
    focus_change = 'space_change',
  },
}

--- Initialize macOS space items in SketchyBar
function Window_Manager:init()
  -- Create 10 macOS spaces (standard macOS limit)
  for space_id = 1, 10 do
    local item = sbar_utils.add_space_item(space_id, space_id)
    self.spaces[space_id] = item.space

    -- Subscribe to space focus changes
    item.space:subscribe(self.events.focus_change, function(env)
      sbar_utils.highlight_focused_space(item, env.SELECTED == 'true')
    end)

    -- Subscribe to mouse clicks for space switching
    item.space:subscribe('mouse.clicked', function(env)
      self:perform_switch_space(env.BUTTON, env.SID)
    end)
  end
end

--- Start watcher for space window changes
function Window_Manager:start_watcher()
  -- Add an observer item to monitor space window changes globally.
  -- Unlike mouse.clicked and space_change which are bound to individual space items
  -- (since they relate to specific space interactions), space_windows_change is a global event
  -- that triggers whenever any space's window list changes. Using a single observer avoids
  -- redundant subscriptions and ensures efficient event handling across all spaces.
  local watcher = SBAR.add('item', {
    position = 'left',
    drawing = false,
    updates = true,
  })

  watcher:subscribe(self.events.window_change, function(env)
    self:update_space_label(env)
  end)
end

--- Switch to a macOS space
--- @param button string the mouse button clicked ("left", "right", "other")
--- @param space_id string the space ID to switch to
function Window_Manager:perform_switch_space(button, space_id)
  local key_codes = { 18, 19, 20, 21, 23, 22, 26, 28, 25, 29 }
  local space_num = tonumber(space_id)

  if button == 'left' and space_num and key_codes[space_num] then
    -- Left click: switch to space using Control + number key
    SBAR.exec(
      string.format(
        'osascript -e \'tell application "System Events" to key code %d using {control down}\'',
        key_codes[space_num]
      )
    )
  elseif button == 'right' then
    -- Right click: open Mission Control
    SBAR.exec('osascript -e \'tell application "Mission Control" to activate\'')
  elseif button == 'other' then
    -- Middle click: log for debugging
    LOG.log('[macOS Native] Middle click on space ' .. space_id)
  end
end

--- Update space label with app icons
--- @param env table containing INFO.apps and INFO.space
function Window_Manager:update_space_label(env)
  if not env.INFO or not env.INFO.space then
    return
  end

  local space_id = tonumber(env.INFO.space)
  if not space_id or not self.spaces[space_id] then
    return
  end

  local icon_parts = {}
  if env.INFO.apps then
    for app_name, _ in pairs(env.INFO.apps) do
      local icon = app_icons[app_name] or app_icons['default']
      table.insert(icon_parts, icon)
    end
  end

  local icon_line = #icon_parts > 0 and table.concat(icon_parts) or ' —'

  SBAR.animate('tanh', 10, function()
    self.spaces[space_id]:set({ label = icon_line })
  end)
end

return Window_Manager
