-- Shared utilities for widget patterns
local widget_utils = {}

-- Get color based on percentage thresholds
function widget_utils.get_load_color(load, thresholds)
  thresholds = thresholds or { low = 30, medium = 60, high = 80 }
  if load > thresholds.high then
    return COLORS.red
  elseif load > thresholds.medium then
    return COLORS.peach
  elseif load > thresholds.low then
    return COLORS.yellow
  else
    return COLORS.blue
  end
end

-- Select icon based on percentage ranges
function widget_utils.select_icon(value, ranges)
  -- ranges: { {max, icon}, ... }
  for _, range in ipairs(ranges) do
    if value <= range[1] then
      return range[2]
    end
  end
  return ranges[#ranges][2] -- default to last icon
end

-- Create graph widget with common defaults
function widget_utils.create_graph_widget(name, config)
  config = config or {}
  return SBAR.add("graph", name, 42, {
    position = "right",
    updates = "when_shown", -- Only update when visible (hidden by default via toggle_stats)
    graph = { color = config.color or COLORS.blue },
    background = {
      height = 22,
      color = { alpha = 0 },
      border_color = { alpha = 0 },
      drawing = true,
    },
    icon = {
      string = config.icon or "",
      color = config.icon_color or COLORS.text,
    },
    label = {
      string = config.label or "??%",
      font = {
        style = config.font_style or FONT.style_map["Bold"],
        size = config.font_size or STYLE.FONT_SIZE_SMALL,
      },
      align = config.label_align or "right",
      padding_right = 0,
      width = 0,
      y_offset = config.y_offset or 4,
    },
  })
end

-- Safe string concatenation for loop building
function widget_utils.concat_strings(parts)
  return table.concat(parts)
end

return widget_utils
