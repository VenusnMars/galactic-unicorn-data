-- Video player standalone application

local video_player = require("/video/player.lua")

-- Can't have all videos at once, there's just not enough flash memory (4MB, and the 16-bit rickroll
-- is already 2.1MB)
local VIDEOS = {
  [1] = "/video/rickroll.guv",
  -- [2] = "/video/another_video.guv",
}

local current_video_idx = 1

function setup()
  local video = VIDEOS[current_video_idx]
  video_player.play(video)
end

function update(dt)
  video_player.update(dt)
end

function draw()
  video_player.draw()
end

function on_press(btn)
  if btn == "MENU" then
    -- Switch to the next video in the list, looping back to the first after the last
    current_video_idx = (current_video_idx % #VIDEOS) + 1
    local video = VIDEOS[current_video_idx]

    video_player.stop()
    video_player.play(video)
  end
end
