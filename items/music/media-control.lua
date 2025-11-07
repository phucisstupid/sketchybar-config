local media_control = {}

function media_control.next_track()
  SBAR.exec("media-control next-track")
end

function media_control.prev_track()
  SBAR.exec("media-control previous-track")
end

function media_control.toggle_play()
  SBAR.exec("media-control toggle-play-pause")
end

function media_control.toggle_shuffle()
  SBAR.exec("media-control toggle-shuffle")
end

function media_control.toggle_repeat()
  SBAR.exec("media-control toggle-repeat")
end

function media_control.stats(callback)
  SBAR.exec("media-control get -h", function(result)
    callback(result.playing, false, false)
  end)
end

function media_control.update_current_track(callback)
  SBAR.exec("media-control get -h", function(result)
    callback(result.title, result.artist, result.album)
  end)
end

function media_control.update_album_art(callback)
  local size = 1280
  local cmd = string.format(
    'media-control get 2>/dev/null | jq -r ".artworkData" | base64 -d > /tmp/music_cover.jpg 2>/dev/null && sips -z %d %d /tmp/music_cover.jpg >/dev/null 2>&1',
    size,
    size
  )
  SBAR.exec(cmd, function()
    callback()
  end)
end

return media_control
