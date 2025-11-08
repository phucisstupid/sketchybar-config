local client = require("items.music.media-control")

-- Styling to match requested layout
local POPUP_HEIGHT = 120
local IMAGE_SCALE = 0.15
local Y_OFFSET = -5

-- Track current play state so we don't show stale labels
local is_playing_state = false

local music_anchor = SBAR.add("item", "music.anchor", {
  position = "right",
  update_freq = 1,
  icon = {
    string = ICONS.music.anchor,
    font = {
      size = 20,
    },
    color = COLORS.lavender,
  },
  label = {
    max_chars = MUSIC.TITLE_MAX_CHARS,
    padding_left = PADDINGS,
    color = COLORS.lavender,
  },
  popup = {
    horizontal = true,
    height = POPUP_HEIGHT,
  },
})

local music_hover = false
local schedule_hide

local function hide_music_popup()
  local query = music_anchor:query()
  if query.popup and query.popup.drawing == "on" then
    music_anchor:set({ popup = { drawing = false } })
  end
  music_hover = false
end

schedule_hide = function()
  SBAR.delay(0.2, function()
    if not music_hover then hide_music_popup() end
  end)
end

local function attach_popup_hover(item)
  item:subscribe("mouse.entered", function()
    music_hover = true
  end)
  item:subscribe("mouse.exited", function()
    music_hover = false
    schedule_hide()
  end)
  item:subscribe("mouse.exited.global", function()
    music_hover = false
    schedule_hide()
  end)
end

local albumart = SBAR.add("item", "music.cover", {
  position = "popup." .. music_anchor.name,
  label = { drawing = false },
  icon = { drawing = false },
  padding_right = 10,
  background = {
    image = {
      string = "/tmp/music_cover.jpg",
      scale = IMAGE_SCALE,
    },
  },
})
attach_popup_hover(albumart)

local track_title = SBAR.add("item", "music.title", {
  position = "popup." .. music_anchor.name,
  icon = { drawing = false },
  padding_left = 0,
  padding_right = 0,
  width = 0,
  label = {
    font = {
      size = 15,
    },
    max_chars = 18,
    color = COLORS.mauve,
  },
  y_offset = 80 + Y_OFFSET,
})
attach_popup_hover(track_title)

local track_artist = SBAR.add("item", "music.artist", {
  position = "popup." .. music_anchor.name,
  icon = { drawing = false },
  y_offset = 50 + Y_OFFSET,
  padding_left = 0,
  padding_right = 0,
  width = 0,
  align = "center",
  label = {
    max_chars = MUSIC.TITLE_MAX_CHARS,
    color = COLORS.blue,
  },
})
attach_popup_hover(track_artist)

local track_album = SBAR.add("item", "music.album", {
  position = "popup." .. music_anchor.name,
  icon = { drawing = false },
  padding_left = 0,
  padding_right = 0,
  y_offset = 25 + Y_OFFSET,
  width = 0,
  label = {
    max_chars = MUSIC.TITLE_MAX_CHARS,
    color = COLORS.lavender,
  },
})
attach_popup_hover(track_album)

-- #region Playback Controls
local CONTROLS_Y_OFFSET = -55 + Y_OFFSET

local music_shuffle = SBAR.add("item", "music.shuffle", {
  position = "popup." .. music_anchor.name,
  icon = {
    string = ICONS.music.shuffle,
    padding_left = 5,
    padding_right = 5,
    color = COLORS.overlay0,
    highlight_color = COLORS.lavender,
  },
  label = { drawing = false },
  y_offset = CONTROLS_Y_OFFSET,
})
attach_popup_hover(music_shuffle)

local music_prev = SBAR.add("item", "music.back", {
  position = "popup." .. music_anchor.name,
  icon = {
    string = ICONS.music.prev,
    padding_left = 5,
    padding_right = 5,
    color = COLORS.overlay0,
  },
  label = { drawing = false },
  y_offset = CONTROLS_Y_OFFSET,
})
attach_popup_hover(music_prev)

local music_play = SBAR.add("item", "music.play", {
  position = "popup." .. music_anchor.name,
  background = {
    height = 40,
    corner_radius = 20,
    color = COLORS.surface0,
    border_color = COLORS.surface1,
    border_width = 2,
    drawing = true,
  },
  width = 40,
  align = "center",
  icon = {
    string = ICONS.music.play,
    padding_left = 5,
    padding_right = 5,
    color = COLORS.red,
  },
  label = { drawing = false },
  y_offset = CONTROLS_Y_OFFSET,
})
attach_popup_hover(music_play)

local music_next = SBAR.add("item", "music.next", {
  position = "popup." .. music_anchor.name,
  icon = {
    string = ICONS.music.next,
    padding_left = 5,
    padding_right = 5,
    color = COLORS.overlay0,
  },
  label = { drawing = false },
  y_offset = CONTROLS_Y_OFFSET,
})
attach_popup_hover(music_next)

local music_repeat = SBAR.add("item", "music.repeat", {
  position = "popup." .. music_anchor.name,
  icon = {
    string = ICONS.music.repeat_icon,
    highlight_color = COLORS.lavender,
    padding_left = 5,
    padding_right = 5,
    color = COLORS.overlay0,
  },
  label = { drawing = false },
  y_offset = CONTROLS_Y_OFFSET,
})
attach_popup_hover(music_repeat)

SBAR.add("item", "music.spacer", {
  position = "popup." .. music_anchor.name,
  width = 5,
})

SBAR.add("bracket", "music.controls", {
  music_shuffle.name,
  music_prev.name,
  music_play.name,
  music_next.name,
  music_repeat.name,
}, {
  background = {
    color = COLORS.surface0,
  },
  y_offset = CONTROLS_Y_OFFSET,
})
-- #endregion ...

-- #region Callbacks functions for updating music info
local track_info_updater = function(title, artist, album)
  if is_playing_state then
    music_anchor:set({ label = title })
  else
    music_anchor:set({ label = "" })
  end
  track_title:set({ label = title })

  local display_artist = (artist and artist ~= "") and artist or MUSIC.DEFAULT_ARTIST
  local display_album = (album and album ~= "") and album or MUSIC.DEFAULT_ALBUM

  track_artist:set({ label = display_artist })
  track_album:set({ label = display_album })
end

local albumart_updater = function()
  albumart:set({
    background = {
      image = {
        string = "/tmp/music_cover.jpg",
        scale = IMAGE_SCALE,
      },
      drawing = true,
    },
  })
end

local icon_updater = function(is_playing, is_repeat, is_shuffle)
  is_playing_state = is_playing and true or false
  if is_playing then
    music_play:set({
      icon = { string = ICONS.music.pause, color = COLORS.green },
    })
  else
    music_play:set({
      icon = { string = ICONS.music.play, color = COLORS.red },
    })
  end

  if is_shuffle then
    music_shuffle:set({ icon = { highlight = true } })
  else
    music_shuffle:set({ icon = { highlight = false } })
  end

  if is_repeat then
    music_repeat:set({ icon = { highlight = true } })
  else
    music_repeat:set({ icon = { highlight = false } })
  end
end
-- #endregion Updaters

-- #region Event
music_anchor:subscribe("routine", function()
  -- Refresh play state first, then update track info only if playing
  client.stats(icon_updater)
  SBAR.delay(0.05, function()
    if is_playing_state then
      client.update_current_track(track_info_updater)
    else
      music_anchor:set({ label = "" })
    end
  end)
end)

music_anchor:subscribe("media_change", function(env)
  local info = env and env.INFO or {}
  local is_playing = info and (info.state == "playing") or false
  is_playing_state = is_playing
  if is_playing then
    track_title:set({ drawing = true })
    track_artist:set({ drawing = true })
    track_album:set({ drawing = true })
    albumart:set({ background = { image = { string = "/tmp/music_cover.jpg", scale = IMAGE_SCALE, drawing = true } } })
    client.update_album_art(albumart_updater)
    client.update_current_track(track_info_updater)
    client.stats(icon_updater)
  else
    -- Clear and hide when not playing
    music_anchor:set({ label = "" })
    track_title:set({ label = "", drawing = false })
    track_artist:set({ label = "", drawing = false })
    track_album:set({ label = "", drawing = false })
    albumart:set({ background = { image = { string = "", drawing = false } } })
    music_anchor:set({ popup = { drawing = false } })
    icon_updater(false, false, false)
  end
end)

music_anchor:subscribe("mouse.entered", function()
  music_hover = true
  local query = music_anchor:query()
  if not query.popup or query.popup.drawing == "off" then
    music_anchor:set({ popup = { drawing = true } })
    client.update_album_art(albumart_updater)
    client.stats(icon_updater)
  end
end)
music_anchor:subscribe("mouse.exited", function()
  music_hover = false
  schedule_hide()
end)
music_anchor:subscribe("mouse.exited.global", function()
  music_hover = false
  hide_music_popup()
end)
music_anchor:subscribe("mouse.clicked", function()
  music_anchor:set({ popup = { drawing = "toggle" } })
  client.update_album_art(albumart_updater)
  client.stats(icon_updater)
end)

music_play:subscribe("mouse.clicked", function()
  client.toggle_play()
  SBAR.delay(0.1, function()
    client.stats(icon_updater)
  end)
end)

music_shuffle:subscribe("mouse.clicked", function()
  client.toggle_shuffle()
  SBAR.delay(0.1, function()
    client.stats(icon_updater)
  end)
end)

music_repeat:subscribe("mouse.clicked", function()
  client.toggle_repeat()
  SBAR.delay(0.1, function()
    client.stats(icon_updater)
  end)
end)

music_prev:subscribe("mouse.clicked", function()
  client.prev_track()
  SBAR.delay(0.1, function()
    client.update_album_art(albumart_updater)
    client.update_current_track(track_info_updater)
    client.stats(icon_updater)
  end)
end)

music_next:subscribe("mouse.clicked", function()
  client.next_track()
  SBAR.delay(0.1, function()
    client.update_album_art(albumart_updater)
    client.update_current_track(track_info_updater)
    client.stats(icon_updater)
  end)
end)
-- #endregion Event
