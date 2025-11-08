local function safe_require(path)
  local ok, err = pcall(require, path)
  if not ok then
    print('[Right Items] ⚠️ Failed to load ' .. path .. ': ' .. tostring(err))
  end
end

local function is_enabled(name)
  return MODULES[name] and MODULES[name].enable ~= false
end

if is_enabled('calendar') then
  safe_require('items.right.calendar')
end
if is_enabled('battery') then
  safe_require('items.right.battery')
end
if is_enabled('wifi') then
  safe_require('items.right.wifi')
end
if is_enabled('volume') then
  safe_require('items.right.volume')
end
if is_enabled('brew') then
  safe_require('items.right.brew')
end
if is_enabled('toggle_stats') then
  safe_require('items.right.toggle_stats')
end
if is_enabled('memory') then
  safe_require('items.right.memory')
end
if is_enabled('cpu') then
  safe_require('items.right.cpu')
end
if is_enabled('network') then
  safe_require('items.right.network')
end
if is_enabled('music') then
  safe_require('items.music')
end

-- Create bracket for wifi, volume, battery, and brew items
-- Order: brew -> volume -> battery (left to right)
local bracket_items = {}
if is_enabled('wifi') then
  table.insert(bracket_items, 'wifi')
end
if is_enabled('volume') then
  table.insert(bracket_items, 'widgets.volume')
end
if is_enabled('battery') then
  table.insert(bracket_items, 'battery')
end
if is_enabled('brew') then
  table.insert(bracket_items, 'brew')
end

-- Always show bracket for all enabled items, regardless of battery style
if #bracket_items > 0 then
  SBAR.add('bracket', 'stats_bracket', bracket_items, {
    background = {
      color = COLORS.base,
      border_color = COLORS.surface0,
      border_width = STYLE.BORDER_WIDTH,
    },
  })
end
