-- Batch event creation for better performance
SBAR.exec('sketchybar --add event hide_stats --add event show_stats --add event toggle_stats')

-- Items to control show/hide
local stats_items = {
  'widgets.cpu',
  'netspeed_upload',
  'netspeed_download',
  'widgets.ram',
}

-- Create separator_right item
local separator = SBAR.add('item', 'separator_right', {
  position = 'right',
  icon = {
    string = ICONS.stats_toggle.show,
    color = COLORS.lavender, -- Lavender for toggle button
  },
  label = { drawing = false },
  background = {
    padding_left = PADDINGS,
    padding_right = 10,
  },
})

-- Create hidden animator item for event handling
local animator = SBAR.add('item', 'animator', {
  position = 'right',
  drawing = false,
  updates = true,
})

-- Hide stats
local function hide_stats()
  for _, item_name in ipairs(stats_items) do
    SBAR.set(item_name, { drawing = false })
  end
  separator:set({ icon = { string = ICONS.stats_toggle.hide } })
end

-- Show stats
local function show_stats()
  for _, item_name in ipairs(stats_items) do
    SBAR.set(item_name, { drawing = true })
  end
  separator:set({ icon = { string = ICONS.stats_toggle.show } })
end

-- Toggle stats
local function toggle_stats()
  local current_icon = separator:query().icon.value

  if current_icon == ICONS.stats_toggle.hide then
    show_stats()
  else
    hide_stats()
  end
end

-- Separator click event
separator:subscribe('mouse.clicked', function()
  SBAR.trigger('toggle_stats')
end)

-- Animator subscribe to events
animator:subscribe('hide_stats', hide_stats)
animator:subscribe('show_stats', show_stats)
animator:subscribe('toggle_stats', toggle_stats)
