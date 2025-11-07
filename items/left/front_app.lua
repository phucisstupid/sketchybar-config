local front_app = SBAR.add("item", "front_app", {
  position = "left",
  display = "active",
  updates = true,
  update_freq = 1,
  scroll_texts = false, -- Disable text scrolling, just truncate
  label = {
    color = COLORS.subtext1, -- Softer than primary text, more readable
    max_chars = 50, -- Trim long titles (no scrolling)
  },
})

local last_window_title = ""
local is_updating = false -- Prevent concurrent updates

-- Optimized function to get and update window title
local function update_window_title()
  -- Skip if already updating to prevent concurrent calls
  if is_updating then
    return
  end

  is_updating = true
  SBAR.exec(
    [[
    osascript -e 'tell application "System Events"
      try
        set frontApp to first application process whose frontmost is true
        set windowTitle to name of front window of frontApp
        return windowTitle
      on error
        return ""
      end try
    end tell'
  ]],
    function(result)
      is_updating = false

      local window_title = ""
      if result and result ~= "" then
        window_title = result:gsub("\n$", ""):gsub("^%s+", ""):gsub("%s+$", "")
      end

      -- Only update if title actually changed
      if window_title ~= last_window_title then
        last_window_title = window_title

        -- Direct update without animation for instant response
        front_app:set({
          label = {
            string = window_title,
            drawing = window_title ~= "",
          },
        })
      end
    end
  )
end

-- Update on app switch (primary trigger - instant)
front_app:subscribe("front_app_switched", function(env)
  update_window_title()
end)

-- Routine update as fallback (less frequent)
front_app:subscribe("routine", function()
  update_window_title()
end)
