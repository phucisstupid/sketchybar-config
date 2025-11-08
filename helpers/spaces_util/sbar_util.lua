-- Space utilities for macOS native spaces only
-- Note: Aerospace uses different implementation and doesn't use these utilities

local greek_uppercase = {
  'Α',
  'B',
  'Γ',
  'Δ',
  'E',
  'Z',
  'H',
  'Θ',
  'I',
  'K',
  'Λ',
  'M',
  'N',
  'Ξ',
  'O',
  'Π',
  'P',
  'Σ',
  'T',
  'Y',
  'Φ',
  'X',
  'Ψ',
  'Ω',
}

local greek_lowercase = {
  'α',
  'β',
  'γ',
  'δ',
  'ε',
  'ζ',
  'η',
  'θ',
  'ι',
  'κ',
  'λ',
  'μ',
  'ν',
  'ξ',
  'ο',
  'π',
  'ρ',
  'σ',
  'τ',
  'υ',
  'φ',
  'χ',
  'ψ',
  'ω',
}

local space_api = {
  created_spaces = {},
}

--- Create a macOS space item with proper label formatting
--- @param space_id number The macOS space ID (1-10)
--- @param idx number The sequential index (1-10)
--- @return table {space: space_item}
function space_api.add_space_item(space_id, idx)
  local space_label = tostring(space_id)

  -- Apply Greek labels only for macOS spaces if configured
  if SPACE_LABEL == 'greek_uppercase' and greek_uppercase[idx] then
    space_label = greek_uppercase[idx]
  elseif SPACE_LABEL == 'greek_lowercase' and greek_lowercase[idx] then
    space_label = greek_lowercase[idx]
  end

  local space = SBAR.add('space', 'space.' .. space_id, {
    space = space_id,
    icon = {
      string = space_label,
      padding_left = SPACE_ITEM_PADDING,
      padding_right = SPACE_ITEM_PADDING,
      color = COLORS.overlay1, -- Darker for unfocused icons
      highlight_color = COLORS.mauve,
    },
    label = {
      padding_right = SPACE_ITEM_PADDING,
      color = COLORS.overlay0,
      highlight_color = COLORS.lavender,
      font = 'sketchybar-app-font:Regular:16.0',
      y_offset = -1,
    },
    padding_right = PADDINGS,
    padding_left = PADDINGS,
    background = {
      color = COLORS.base,
      border_width = STYLE.BORDER_WIDTH,
      height = STYLE.ITEM_HEIGHT,
      border_color = STYLE.UNFOCUSED_BORDER_COLOR,
      corner_radius = STYLE.CORNER_RADIUS,
      drawing = true,
    },
  })

  space_api.created_spaces[space_id] = space

  -- Padding space
  SBAR.add('space', 'space.padding.' .. idx, {
    space = idx,
    script = '',
    width = GROUP_PADDINGS,
  })

  return { space = space }
end

--- Highlight or unhighlight a space item based on focus
--- @param sbar_item table containing space item
--- @param is_selected boolean whether the space is focused
function space_api.highlight_focused_space(sbar_item, is_selected)
  sbar_item.space:set({
    icon = { highlight = is_selected },
    label = { highlight = is_selected },
    background = {
      border_color = is_selected and STYLE.FOCUSED_BORDER_COLOR or STYLE.UNFOCUSED_BORDER_COLOR,
    },
  })
end

return space_api
