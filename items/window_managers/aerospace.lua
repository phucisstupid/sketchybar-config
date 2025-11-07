-- Aerospace window manager implementation
-- Based on working implementation from: https://github.com/falleco/dotfiles/blob/main/sketchybar
local app_icons = require("helpers.spaces_util.icon_map")

-- Prefer a plain-text, line-based format for synchronous parsing
local SYNC_WS_CMD = "aerospace list-workspaces --all --format '%{workspace}|%{monitor-appkit-nsscreen-screens-id}'"
local ASYNC_WS_CMD =
  "aerospace list-workspaces --all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"

local Window_Manager = {
  spaces = {}, -- Keyed by workspace index (e.g., "A", "1", etc.)
  events = {
    focus_change = "aerospace_workspace_change",
    focus_event = "aerospace_focus_change",
  },
}

-- Fetch workspace data and update windows
local function with_windows_data(callback)
  local open_windows = {}
  local get_windows = "aerospace list-windows --monitor all --format '%{workspace}%{app-name}' --json"
  local query_visible_workspaces =
    "aerospace list-workspaces --visible --monitor all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"
  local get_focused_workspaces = "aerospace list-workspaces --focused"

  SBAR.exec(query_visible_workspaces, function(visible_workspaces)
    SBAR.exec(get_windows, function(workspace_and_windows)
      if workspace_and_windows then
        for _, entry in ipairs(workspace_and_windows) do
          local workspace_index = entry.workspace
          local app_name = entry["app-name"]

          if open_windows[workspace_index] == nil then
            open_windows[workspace_index] = {}
          end

          table.insert(open_windows[workspace_index], app_name)
        end
      end

      SBAR.exec(get_focused_workspaces, function(focused_workspaces)
        local focused_workspace = focused_workspaces and focused_workspaces:match("^%s*(.-)%s*$")
        callback({
          open_windows = open_windows,
          focused_workspace = focused_workspace,
          visible_workspaces = visible_workspaces or {},
        })
      end)
    end)
  end)
end

--- Update a single workspace's label and visibility
--- @param workspace_index string the workspace index (e.g., "A", "1")
--- @param args table containing open_windows, focused_workspace, visible_workspaces
function Window_Manager:update_workspace(workspace_index, args)
  local workspace = self.spaces[workspace_index]
  if not workspace then
    return
  end

  local open_windows = args.open_windows[workspace_index]
  local focused_workspace = args.focused_workspace
  local visible_workspaces = args.visible_workspaces

  if open_windows == nil then
    open_windows = {}
  end

  -- Build icon line from apps
  local icon_parts = {}
  for _, app_name in ipairs(open_windows) do
    local icon = app_icons[app_name] or app_icons["default"]
    table.insert(icon_parts, " " .. icon)
  end

  local icon_line = #icon_parts > 0 and table.concat(icon_parts) or ""
  local no_app = #open_windows == 0

  -- Check if workspace is visible on any monitor
  local is_visible = false
  local monitor_id = nil
  for _, visible_ws in ipairs(visible_workspaces) do
    if workspace_index == visible_ws.workspace then
      is_visible = true
      monitor_id = math.floor(visible_ws["monitor-appkit-nsscreen-screens-id"])
      break
    end
  end

  -- Determine if this workspace is focused
  local is_focused = workspace_index == focused_workspace

  -- Update workspace display (animate only focused workspace to avoid all icons jumping)
  SBAR.animate("tanh", is_focused and 10 or 0, function()
    -- Empty workspace but visible
    if no_app and is_visible then
      icon_line = "—"
      workspace:set({
        icon = { drawing = true },
        label = {
          string = icon_line,
          drawing = true,
          font = "sketchybar-app-font:Regular:16.0",
          y_offset = -1,
        },
        background = { drawing = true, border_color = is_focused and COLORS.lavender or COLORS.surface0 },
        padding_right = 1,
        padding_left = 1,
        display = monitor_id,
      })
      return
    end

    -- Empty workspace and not focused or visible - hide label/icon but keep border
    if no_app and workspace_index ~= focused_workspace then
      workspace:set({
        icon = { drawing = false },
        label = { drawing = false },
        background = { drawing = true, border_color = COLORS.surface0 },
        padding_right = 0,
        padding_left = 0,
      })
      return
    end

    -- Empty workspace but focused
    if no_app and workspace_index == focused_workspace then
      icon_line = "—"
      workspace:set({
        icon = { drawing = true },
        label = {
          string = icon_line,
          drawing = true,
          font = "sketchybar-app-font:Regular:16.0",
          y_offset = -1,
        },
        background = { drawing = true, border_color = COLORS.lavender },
        padding_right = 1,
        padding_left = 1,
      })
      return
    end

    -- Workspace with apps
    workspace:set({
      icon = { drawing = true },
      label = {
        string = icon_line,
        drawing = true,
        font = "sketchybar-app-font:Regular:16.0",
        y_offset = -1,
      },
      background = { drawing = true, border_color = is_focused and COLORS.lavender or COLORS.surface0 },
      padding_right = 1,
      padding_left = 1,
      display = monitor_id,
    })
  end)
end

--- Update all workspace labels and visibility
function Window_Manager:update_all_workspaces()
  with_windows_data(function(args)
    for workspace_index, _ in pairs(self.spaces) do
      self:update_workspace(workspace_index, args)
    end
  end)
end

--- Update workspace monitor assignments
function Window_Manager:update_workspace_monitors()
  SBAR.exec(ASYNC_WS_CMD, function(workspaces_and_monitors)
    if not workspaces_and_monitors then
      return
    end

    local workspace_monitor = {}
    for _, entry in ipairs(workspaces_and_monitors) do
      local workspace_index = entry.workspace
      local monitor_id = math.floor(entry["monitor-appkit-nsscreen-screens-id"])
      workspace_monitor[workspace_index] = monitor_id
    end

    for workspace_index, workspace in pairs(self.spaces) do
      if workspace_monitor[workspace_index] then
        workspace:set({
          display = workspace_monitor[workspace_index],
        })
      end
    end
  end)
end

-- Synchronous workspace fetch (line-based) to guarantee creation order
local function get_all_workspaces_sync()
  local p = io.popen(SYNC_WS_CMD)
  if not p then
    return {}
  end
  local content = p:read("*a")
  p:close()
  local result = {}
  for line in content:gmatch("([^\r\n]+)") do
    local ws, id = line:match("^([^|]+)|([%d%.%-]+)$")
    if ws then
      table.insert(result, { workspace = ws, ["monitor-appkit-nsscreen-screens-id"] = tonumber(id) })
    end
  end
  return result
end

--- Initialize workspace items in SketchyBar (synchronous create to ensure order before front_app)
function Window_Manager:init()
  local workspaces_and_monitors = get_all_workspaces_sync()

  -- Fallback to async JSON if sync returns nothing
  if not workspaces_and_monitors or #workspaces_and_monitors == 0 then
    SBAR.exec(ASYNC_WS_CMD, function(ws_async)
      workspaces_and_monitors = ws_async or {}
      -- proceed to create
      for _, entry in ipairs(workspaces_and_monitors) do
        local workspace_index = entry.workspace
        local monitor_id = math.floor(entry["monitor-appkit-nsscreen-screens-id"]) or nil

        local workspace = SBAR.add("item", "space." .. workspace_index, {
          position = "left",
          icon = {
            color = COLORS.overlay1, -- Darker for unfocused icons
            highlight_color = COLORS.mauve,
            drawing = false,
            string = workspace_index,
            padding_left = SPACE_ITEM_PADDING,
            padding_right = 5,
          },
          label = {
            padding_right = SPACE_ITEM_PADDING,
            color = COLORS.overlay0,
            highlight_color = COLORS.lavender,
            font = "sketchybar-app-font:Regular:16.0",
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
          click_script = "aerospace workspace " .. workspace_index,
          display = monitor_id,
        })
        self.spaces[workspace_index] = workspace

        workspace:subscribe(self.events.focus_change, function(env)
          local focused_workspace = env.FOCUSED_WORKSPACE
          local is_focused = focused_workspace == workspace_index
          SBAR.animate("tanh", 10, function()
            workspace:set({
              icon = { highlight = is_focused },
              label = { highlight = is_focused },
              background = { border_color = is_focused and STYLE.FOCUSED_BORDER_COLOR or STYLE.UNFOCUSED_BORDER_COLOR },
            })
          end)
        end)
      end
      self:update_all_workspaces()
      self:update_workspace_monitors()
    end)
    return
  end

  for _, entry in ipairs(workspaces_and_monitors) do
    local workspace_index = entry.workspace
    local monitor_id = math.floor(entry["monitor-appkit-nsscreen-screens-id"]) or nil

    -- Create synchronously to guarantee order before front_app
    local workspace = SBAR.add("item", "space." .. workspace_index, {
      position = "left",
      icon = {
        color = COLORS.overlay1, -- Darker for unfocused icons
        highlight_color = COLORS.mauve,
        drawing = false,
        string = workspace_index,
        padding_left = SPACE_ITEM_PADDING,
        padding_right = 5,
      },
      label = {
        padding_right = SPACE_ITEM_PADDING,
        color = COLORS.overlay0,
        highlight_color = COLORS.lavender,
        font = "sketchybar-app-font:Regular:16.0",
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
      click_script = "aerospace workspace " .. workspace_index,
      display = monitor_id,
    })

    self.spaces[workspace_index] = workspace

    workspace:subscribe(self.events.focus_change, function(env)
      local focused_workspace = env.FOCUSED_WORKSPACE
      local is_focused = focused_workspace == workspace_index

      SBAR.animate("tanh", 10, function()
        workspace:set({
          icon = { highlight = is_focused },
          label = { highlight = is_focused },
          background = { border_color = is_focused and STYLE.FOCUSED_BORDER_COLOR or STYLE.UNFOCUSED_BORDER_COLOR },
        })
      end)
    end)
  end

  -- Kick off initial updates
  self:update_all_workspaces()
  self:update_workspace_monitors()

  SBAR.exec("aerospace list-workspaces --focused", function(focused_workspace)
    if focused_workspace then
      local focused_ws = focused_workspace:match("^%s*(.-)%s*$")
      if focused_ws and self.spaces[focused_ws] then
        self.spaces[focused_ws]:set({
          icon = { highlight = true },
          label = { highlight = true },
          background = { border_color = STYLE.FOCUSED_BORDER_COLOR },
        })
      end
    end
  end)
end

--- Start watcher for workspace changes
function Window_Manager:start_watcher()
  local watcher = SBAR.add("item", {
    position = "left",
    drawing = false,
    updates = true,
  })

  -- Subscribe to aerospace focus changes
  watcher:subscribe(self.events.focus_event, function()
    self:update_all_workspaces()
  end)

  -- Subscribe to display changes (monitor changes)
  watcher:subscribe("display_change", function()
    self:update_workspace_monitors()
    self:update_all_workspaces()
  end)
end

return Window_Manager
