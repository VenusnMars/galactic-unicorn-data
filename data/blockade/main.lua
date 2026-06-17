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
  p1.next_dir = DIR.DOWN
  grid[p1.x][p1.y] = "p1"

  p2.x = SCREEN_W - 4
  p2.y = 7
  p2.dir = DIR.UP
  p2.next_dir = DIR.UP
  grid[p2.x][p2.y] = "p2"
end

function reset_game()
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

    p1.dir = p1.next_dir
    p2.dir = p2.next_dir

    p1_next_X = p1.x + p1.dir.x
    p1_next_Y = p1.y + p1.dir.y
    p2_next_X = p2.x + p2.dir.x
    p2_next_Y = p2.y + p2.dir.y

    p1_crash = false
    p2_crash = false

    if p1_next_X < 0 or p1_next_X >= SCREEN_W or p1_next_Y < 0 or p1_next_Y >= SCREEN_H or grid[p1_next_X][p1_next_Y] then
      p1_crash = true
    end

    if p2_next_X < 0 or p2_next_X >= SCREEN_W or p2_next_Y < 0 or p2_next_Y >= SCREEN_H or grid[p2_next_X][p2_next_Y] then
      p2_crash = true
    end

    if p1_next_X == p2_next_X and p1_next_Y == p2_next_Y then
      p1_crash = true
      p2_crash = true
    end

    if p1_crash or p2_crash then
      buzz(300, 150)

      if p1_crash and p2_crash then
        p1.score = p1.score + 1
        p2.score = p2.score + 1
      elseif p1_crash then 
        p2.score = p2.score + 1
      elseif p2_crash then 
        p1.score = p1.score + 1
      end

      if p1.score >= target_score and p1.score > p2.score then
        game_over = true
        winner = 1
      elseif p2.score >= target_score and p2.score > p1.score then
        game_over = true
        winner = 2
      elseif p1.score >= target_score and p2.score >= target_score then
        game_over = true
        winner = 0
      else
        setup()
      end
      return
    end

    p1.x = p1_next_X
    p1.y = p1_next_Y
    grid[p1.x][p1.y] = "p1"

    p2.x = p2_next_X
    p2.y = p2_next_Y
    grid[p2.x][p2.y] = "p2"
  end
end

function on_press(button_name)
  if button_name == "MENU" then
    reset_game()
    return
  elseif button_name == "ESC" then
    game_over = true
    return
  end

  if game_over then return end

  if     button_name == "L_UP"    and p1.dir ~= DIR.DOWN  then p1.next_dir = DIR.UP
  elseif button_name == "L_DOWN"  and p1.dir ~= DIR.UP    then p1.next_dir = DIR.DOWN
  elseif button_name == "L_LEFT"  and p1.dir ~= DIR.RIGHT then p1.next_dir = DIR.LEFT
  elseif button_name == "L_RIGHT" and p1.dir ~= DIR.LEFT  then p1.next_dir = DIR.RIGHT
  end

  if     button_name == "R_UP"    and p2.dir ~= DIR.DOWN  then p2.next_dir = DIR.UP
  elseif button_name == "R_DOWN"  and p2.dir ~= DIR.UP    then p2.next_dir = DIR.DOWN
  elseif button_name == "R_LEFT"  and p2.dir ~= DIR.RIGHT then p2.next_dir = DIR.LEFT
  elseif button_name == "R_RIGHT" and p2.dir ~= DIR.LEFT  then p2.next_dir = DIR.RIGHT
  end
end

function draw()
  clear()

  p1_color = rgb(0, 255, 100)
  p2_color = rgb(0, 255, 100) 

  if game_over then
    if winner == 1 then
      rect_f(0, 0, SCREEN_W/2, SCREEN_H, p1_color)
    elseif winner == 2 then
      rect_f(SCREEN_W/2, 0, SCREEN_W/2, SCREEN_H, p2_color)
    else
     
      rect_f(0, 0, SCREEN_W/2, SCREEN_H, p1_color)
      rect_f(SCREEN_W/2, 0, SCREEN_W/2, SCREEN_H, p2_color)
    end
    return
  end

  for x = 0, SCREEN_W - 1 do
    for y = 0, SCREEN_H - 1 do
      if grid[x][y] == "p1" then
        set_pixel(x, y, p1_color)
      elseif grid[x][y] == "p2" then
        set_pixel(x, y, p2_color)
      end
    end
  end

  set_pixel(p1.x, p1.y, p1_color)
  set_pixel(p2.x, p2.y, p2_color)
end
