-- Padding item required because of bracket
SBAR.add("item", { position = "left", width = GROUP_PADDINGS })

local apple = SBAR.add("item", {
  position = "left",
  icon = {
    font = {
      size = 22, -- bigger icon size
    },
    string = ICONS.apple,
    color = COLORS.lavender,
  },
  label = { drawing = false },
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

-- Padding item required because of bracket
SBAR.add("item", { position = "left", width = 7 })
