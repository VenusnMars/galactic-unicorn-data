tick_rate = 0.4
target_score = 6
game_over = false
winner = nil
tick_timer = 0

DIR = {
  UP    = {x = 0,  y = -1},
  DOWN  = {x = 0,  y = 1},
  LEFT  = {x = -1, y = 0},
  RIGHT = {x = 1,  y = 0}
}

grid = {}
p1 = { score = 0 }
p2 = { score = 0 }

function setup()
  for x = 0, SCREEN_W - 1 do
    grid[x] = {}
    for y = 0, SCREEN_H - 1 do 
      grid[x][y] = false
    end
  end

  p1.x = 3
  p1.y = 2
  p1.dir = DIR.DOWN
  p1.nextDir = DIR.DOWN
  grid[p1.x][p1.y] = "p1"

  p2.x = SCREEN_W - 4
  p2.y = 7
  p2.dir = DIR.UP
  p2.nextDir = DIR.UP
  grid[p2.x][p2.y] = "p2"
end

function resetGame()
  p1.score = 0
  p2.score = 0
  game_over = false
  winner = nil
  setup()
end

function update(dt)
  if game_over then return end

  tick_timer = tick_timer + dt
  if tick_timer >= tick_rate then
    tick_timer = tick_timer - tick_rate

    p1.dir = p1.nextDir
    p2.dir = p2.nextDir

    p1NextX = p1.x + p1.dir.x
    p1NextY = p1.y + p1.dir.y
    p2NextX = p2.x + p2.dir.x
    p2NextY = p2.y + p2.dir.y

    p1Crash = false
    p2Crash = false

    if p1NextX < 0 or p1NextX >= SCREEN_W or p1NextY < 0 or p1NextY >= SCREEN_H or grid[p1NextX][p1NextY] then
      p1Crash = true
    end

    if p2NextX < 0 or p2NextX >= SCREEN_W or p2NextY < 0 or p2NextY >= SCREEN_H or grid[p2NextX][p2NextY] then
      p2Crash = true
    end

    if p1NextX == p2NextX and p1NextY == p2NextY then
      p1Crash = true
      p2Crash = true
    end

    if p1Crash or p2Crash then
      buzz(300, 150)

      if p1Crash and p2Crash then
        p1.score = p1.score + 1
        p2.score = p2.score + 1
      elseif p1Crash then 
        p2.score = p2.score + 1
      elseif p2Crash then 
        p1.score = p1.score + 1
      end

      if p1.score >= target_score and p1.score > p2.score then
        game_over = true
        winner = 1
      elseif p2.score >= target_score and p2.score > p1.score then
        game_over = true
        winner = 2
      else
        setup()
      end
      return
    end

    p1.x = p1NextX
    p1.y = p1NextY
    grid[p1.x][p1.y] = "p1"

    p2.x = p2NextX
    p2.y = p2NextY
    grid[p2.x][p2.y] = "p2"
  end
end

function on_press(button_name)
  if button_name == "MENU" then
    resetGame()
    return
  elseif button_name == "ESC" then
    game_over = true
    return
  end

  if game_over then return end

  if     button_name == "L_UP"    and p1.dir ~= DIR.DOWN  then p1.nextDir = DIR.UP
  elseif button_name == "L_DOWN"  and p1.dir ~= DIR.UP    then p1.nextDir = DIR.DOWN
  elseif button_name == "L_LEFT"  and p1.dir ~= DIR.RIGHT then p1.nextDir = DIR.LEFT
  elseif button_name == "L_RIGHT" and p1.dir ~= DIR.LEFT  then p1.nextDir = DIR.RIGHT
  end

  if     button_name == "R_UP"    and p2.dir ~= DIR.DOWN  then p2.nextDir = DIR.UP
  elseif button_name == "R_DOWN"  and p2.dir ~= DIR.UP    then p2.nextDir = DIR.DOWN
  elseif button_name == "R_LEFT"  and p2.dir ~= DIR.RIGHT then p2.nextDir = DIR.LEFT
  elseif button_name == "R_RIGHT" and p2.dir ~= DIR.LEFT  then p2.nextDir = DIR.RIGHT
  end
end

function draw()
  clear()

  p1Color = rgb(0, 255, 100)
  p2Color = rgb(0, 255, 100)

  if game_over then
    if winner == 1 then
      rect_f(0, 0, SCREEN_W/2, SCREEN_H, p1Color)
    else
      rect_f(SCREEN_W/2, 0, SCREEN_W/2, SCREEN_H, p2Color)
    end
    return
  end

  for x = 0, SCREEN_W - 1 do
    for y = 0, SCREEN_H - 1 do
      if grid[x][y] == "p1" then
        set_pixel(x, y, p1Color)
      elseif grid[x][y] == "p2" then
        set_pixel(x, y, p2Color)
      end
    end
  end

  set_pixel(p1.x, p1.y, p1Color)
  set_pixel(p2.x, p2.y, p2Color)
end
