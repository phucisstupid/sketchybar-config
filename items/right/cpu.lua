-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
SBAR.exec(
  'killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0'
)

local widget_utils = require('helpers.widget_utils')

local cpu = widget_utils.create_graph_widget('widgets.cpu', {
  icon = ICONS.cpu,
  icon_color = COLORS.yellow, -- Yellow for CPU
  label = 'CPU ??%',
})

cpu:subscribe('cpu_update', function(env)
  local load = tonumber(env.total_load)
  cpu:push({ load / 100. })

  local color = widget_utils.get_load_color(load)
  cpu:set({
    graph = { color = color },
    label = 'CPU ' .. env.total_load .. '%',
  })
end)
