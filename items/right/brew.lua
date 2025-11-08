SBAR.exec('sketchybar --add event brew_update')

local brew = SBAR.add('item', 'brew', {
  position = 'right',
  icon = {
    string = ICONS.brew,
    color = COLORS.text,
  },
  label = {
    string = '?',
  },
  update_freq = 300, -- Increased from 60 to 300 seconds (5 minutes) - brew updates rarely needed
  popup = {
    height = 20,
  },
})

-- Popup header
local brew_details = SBAR.add('item', 'brew.details', {
  position = 'popup.' .. brew.name,
  icon = { drawing = false },
  label = {
    string = 'Brew Updates',
    align = 'left',
    color = COLORS.mauve, -- Mauve for brew header
  },
  background = {
    corner_radius = 12,
    padding_left = 5,
    padding_right = 10,
  },
})

local header_count = SBAR.add('item', 'brew.count', {
  position = 'popup.' .. brew.name,
  icon = { drawing = false },
  align = 'right',
  label = {
    string = '…',
    align = 'right',
    color = COLORS.subtext1,
    padding_right = 6,
  },
})

local header_refresh = SBAR.add('item', 'brew.refresh', {
  position = 'popup.' .. brew.name,
  label = { drawing = false },
  icon = {
    string = ICONS.refresh or '↻',
    align = 'right',
    color = COLORS.blue,
    padding_right = 6,
  },
})

local header_upgrade_all = SBAR.add('item', 'brew.upgrade_all', {
  position = 'popup.' .. brew.name,
  label = { drawing = false },
  icon = {
    string = ICONS.arrow_up or '⇡',
    align = 'right',
    color = COLORS.green,
    padding_right = 6,
  },
})

-- Get brew item count
local function get_brew_count()
  local result = brew:query()
  if result and result.popup and result.popup.items then
    local count = 0
    for _, item in ipairs(result.popup.items) do
      if item:match('^brew%.package%.') then
        count = count + 1
      end
    end
    return count
  end
  return 0
end

-- Render bar item
local function render_bar_item(count)
  local color = COLORS.mauve -- Mauve when up to date
  local label = ICONS.brew_check

  if count >= 30 then
    color = COLORS.red -- Red for critical (many outdated)
    label = tostring(count)
  elseif count >= 10 then
    color = COLORS.peach -- Peach for moderate count
    label = tostring(count)
  elseif count >= 1 then
    color = COLORS.mauve -- Mauve for few outdated
    label = tostring(count)
  end

  brew:set({
    icon = { color = color },
    label = { string = label },
  })
end

local last_outdated = ''
local last_rendered_outdated = ''
local last_checked = 0
local is_open = false

local function fetch_outdated(sender, cb)
  local now = os.time()
  if sender ~= 'forced' and (now - last_checked) < 60 and last_outdated ~= nil then
    cb(last_outdated)
    return
  end
  SBAR.exec("/bin/zsh -lc 'brew outdated'", function(outdated)
    last_outdated = outdated or ''
    last_checked = os.time()
    cb(last_outdated)
  end)
end

local function render_popup(outdated)
  SBAR.remove('/brew.package\\..*/')

  if outdated and outdated ~= '' then
    local packages = {}
    for package in outdated:gmatch('[^\r\n]+') do
      if package ~= '' then
        table.insert(packages, package)
      end
    end

    header_count:set({ label = { string = tostring(#packages) } })

    for counter, package in ipairs(packages) do
      local pkg_item = SBAR.add('item', 'brew.package.' .. (counter - 1), {
        position = 'popup.' .. brew.name,
        icon = { drawing = false },
        label = {
          string = package,
          align = 'right',
          padding_left = 20,
          color = COLORS.subtext1, -- Neutral for package list (readable)
        },
      })
      pkg_item:subscribe('mouse.clicked', function(env)
        local name = package:match('^(%S+)') or package
        SBAR.exec(
          string.format("/bin/zsh -lc 'brew upgrade %s; sketchybar --trigger brew_update'", name)
        )
      end)
      pkg_item:subscribe('mouse.entered', function()
        brew_hover = true
      end)
      pkg_item:subscribe('mouse.exited', function()
        brew_hover = false
        SBAR.delay(0.2, function()
          if not brew_hover then
            toggle_popup('off')
          end
        end)
      end)
    end
  else
    header_count:set({ label = { string = '0' } })
    -- Show a friendly empty state
    SBAR.add('item', 'brew.package.0', {
      position = 'popup.' .. brew.name,
      icon = { drawing = false },
      label = {
        string = 'All up to date',
        align = 'right',
        padding_left = 20,
        color = COLORS.overlay0,
      },
    })
  end
  last_rendered_outdated = outdated or ''
end

local function update(sender)
  local prev_count = get_brew_count()
  fetch_outdated(sender, function(outdated)
    local count = 0
    if outdated and outdated ~= '' then
      for _ in outdated:gmatch('[^\r\n]+') do
        count = count + 1
      end
    end

    render_bar_item(count)
    local popup_state = brew:query().popup and brew:query().popup.drawing == 'on'
    if sender == 'forced' or (popup_state and outdated ~= last_rendered_outdated) then
      render_popup(outdated)
    end

    if (not is_open) and (count ~= prev_count or sender == 'forced') then
      SBAR.animate('tanh', 15, function()
        brew:set({ label = { y_offset = 5 } })
        brew:set({ label = { y_offset = 0 } })
      end)
    end
  end)
end

-- Toggle popup
local function toggle_popup(should_draw)
  local count = get_brew_count()
  if count > 0 then
    brew:set({ popup = { drawing = should_draw } })
  else
    brew:set({ popup = { drawing = false } })
  end
end

-- Subscribe to events
brew:subscribe('routine', function()
  update('routine')
end)

brew:subscribe('forced', function()
  update('forced')
end)

brew:subscribe('brew_update', function()
  update('forced')
end)

local brew_hover = false
brew:subscribe('mouse.entered', function()
  brew_hover = true
  is_open = true
  toggle_popup('on')
end)

brew:subscribe('mouse.exited', function()
  brew_hover = false
  SBAR.delay(0.2, function()
    if not brew_hover then
      toggle_popup('off')
      is_open = false
    end
  end)
end)

brew:subscribe('mouse.exited.global', function()
  brew_hover = false
  SBAR.delay(0.2, function()
    if not brew_hover then
      toggle_popup('off')
      is_open = false
    end
  end)
end)

brew:subscribe('mouse.clicked', function()
  toggle_popup('toggle')
end)

brew_details:subscribe('mouse.entered', function()
  brew_hover = true
end)
brew_details:subscribe('mouse.exited', function()
  brew_hover = false
  SBAR.delay(0.2, function()
    if not brew_hover then
      toggle_popup('off')
    end
  end)
end)
brew_details:subscribe('mouse.clicked', function()
  brew:set({ popup = { drawing = false } })
end)

header_refresh:subscribe('mouse.clicked', function()
  update('forced')
end)

header_refresh:subscribe('mouse.entered', function()
  brew_hover = true
end)
header_refresh:subscribe('mouse.exited', function()
  brew_hover = false
  SBAR.delay(0.2, function()
    if not brew_hover then
      toggle_popup('off')
    end
  end)
end)

header_upgrade_all:subscribe('mouse.clicked', function()
  SBAR.exec("/bin/zsh -lc 'brew upgrade; sketchybar --trigger brew_update'")
end)
header_upgrade_all:subscribe('mouse.entered', function()
  brew_hover = true
end)
header_upgrade_all:subscribe('mouse.exited', function()
  brew_hover = false
  SBAR.delay(0.2, function()
    if not brew_hover then
      toggle_popup('off')
    end
  end)
end)
