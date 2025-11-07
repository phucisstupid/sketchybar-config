-- Catppuccin Mocha color palette
-- Official colors from https://github.com/catppuccin/catppuccin
return {
  -- Accent colors
  rosewater = 0xfff5e0dc,
  flamingo = 0xfff2cdcd,
  pink = 0xfff5c2e7,
  mauve = 0xffcba6f7,
  red = 0xfff38ba8,
  maroon = 0xffeba0ac,
  peach = 0xfffab387,
  yellow = 0xfff9e2af,
  green = 0xffa6e3a1,
  teal = 0xff94e2d5,
  sky = 0xff89dceb,
  sapphire = 0xff74c7ec,
  blue = 0xff89b4fa,
  lavender = 0xffb4befe,

  -- Text colors
  text = 0xffcdd6f4,        -- Primary text
  subtext1 = 0xffbac2de,    -- Secondary text
  subtext0 = 0xffa6adc8,    -- Tertiary text

  -- Overlay colors (for borders, inactive states)
  overlay2 = 0xff9399b2,
  overlay1 = 0xff7f849c,
  overlay0 = 0xff6c7086,    -- Use this instead of 'grey'

  -- Surface colors (for backgrounds)
  surface2 = 0xff585b70,
  surface1 = 0xff45475a,
  surface0 = 0xff313244,

  -- Base colors (for main backgrounds)
  base = 0xff1e1e2e,        -- Main bar background
  mantle = 0xff181825,      -- Secondary background
  crust = 0xff11111b,       -- Darkest background

  -- Utility
  transparent = 0x00000000,

  -- Helper function to apply alpha to colors
  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then
      return color
    end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
