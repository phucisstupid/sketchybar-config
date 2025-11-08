local widget_utils = require('helpers.widget_utils')

local ram = widget_utils.create_graph_widget('widgets.ram', {
  icon = ICONS.ram,
  icon_color = COLORS.peach, -- Peach for memory
  label = 'RAM ??%',
})
ram:set({ update_freq = 3, updates = 'when_shown' })

ram:subscribe({ 'routine', 'forced', 'system_woke' }, function()
  SBAR.exec('memory_pressure', function(output)
    local percentage = output:match('System%-wide memory free percentage: (%d+)')
    local load = 100 - tonumber(percentage)
    ram:push({ load / 100. })

    local color = widget_utils.get_load_color(load)
    ram:set({
      graph = { color = color },
      label = { string = 'RAM ' .. load .. '%' },
    })
  end)
end)
