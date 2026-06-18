-- Tweening library
-- Ported to Lua from https://github.com/rakkarage/Ease

local math_lib = require("lib.math")
local clamp01 = math_lib.clamp01
local lerp = math_lib.lerp

local Tween = {}

local PI = math.pi
local HALF_PI = PI * .5
local DOUBLE_PI = PI * 2

function Tween.linear(from, to, time)
  return lerp(from, to, time)
end
function Tween.sine_in(from, to, time)
  return lerp(from, to, 1 - math.cos(time * HALF_PI));
end
function Tween.sine_out(from, to, time)
  return lerp(from, to, math.sin(time * HALF_PI))
end
function Tween.sine_in_out(from, to, time)
  return lerp(from, to, .5 * (1 - math.cos(PI * time)))
end
function Tween.quad_in(from, to, time)
  return lerp(from, to, time * time)
end
function Tween.quad_out(from, to, time)
  return lerp(from, to, -time * (time - 2))
end
function Tween.quad_in_out(from, to, time)
  time = time / .5
  if time < 1 then
    return lerp(from, to, .5 * time * time)
  end
  time = time - 1
  return lerp(from, to, -.5 * (time * (time - 2) - 1))
end
function Tween.cubic_in(from, to, time)
  return lerp(from, to, time * time * time)
end
function Tween.cubic_out(from, to, time)
  time = time - 1
  return lerp(from, to, time * time * time + 1)
end
function Tween.cubic_in_out(from, to, time)
  time = time / .5
  if time < 1 then
    return lerp(from, to, .5 * time * time * time)
  end
  time = time - 2
  return lerp(from, to, .5 * (time * time * time + 2))
end
function Tween.quart_in(from, to, time)
  return lerp(from, to, time * time * time * time)
end
function Tween.quart_out(from, to, time)
  time = time - 1
  return lerp(from, to, -(time * time * time * time - 1))
end
function Tween.quart_in_out(from, to, time)
  time = time / .5
  if time < 1 then
    return lerp(from, to, .5 * time * time * time * time)
  end
  time = time - 2
  return lerp(from, to, -.5 * (time * time * time * time - 2))
end
function Tween.quint_in(from, to, time)
  return lerp(from, to, time * time * time * time * time)
end
function Tween.quint_out(from, to, time)
  time = time - 1
  return lerp(from, to, time * time * time * time * time + 1)
end
function Tween.quint_in_out(from, to, time)
  time = time / .5
  if time < 1 then
    return lerp(from, to, .5 * time * time * time * time * time)
  end
  time = time - 2
  return lerp(from, to, .5 * (time * time * time * time * time + 2))
end
function Tween.expo_in(from, to, time)
  return lerp(from, to, 2^(10 * (time - 1)))
end
function Tween.expo_out(from, to, time)
  return lerp(from, to, -2^(-10 * time) + 1)
end
function Tween.expo_in_out(from, to, time)
  time = time / .5
  if time < 1 then
    return lerp(from, to, .5 * 2^(10 * (time - 1)))
  end
  return lerp(from, to, .5 * (-2^(-10 * (time - 1)) + 2))
end
function Tween.circ_in(from, to, time)
  return lerp(from, to, -(math.sqrt(1 - time * time) - 1))
end
function Tween.circ_out(from, to, time)
  time = time - 1
  return lerp(from, to, math.sqrt(1 - time * time))
end
function Tween.circ_in_out(from, to, time)
  time = time / .5
  if time < 1 then
    return lerp(from, to, .5 * -(math.sqrt(1 - time * time) - 1))
  end
  time = time - 2
  return lerp(from, to, .5 * (math.sqrt(1 - time * time) + 1))
end
function Tween.back_in(from, to, time)
  local s = 1.70158
  to = to - from
  return to * time * time * ((s + 1) * time - s) + from
end
function Tween.back_out(from, to, time)
  local s = 1.70158
  to = to - from
  return to * ((time - 1) * time * ((s + 1) * time + s) + 1) + from
end
function Tween.back_in_out(from, to, time)
  local s = 1.70158 * 1.525
  to = to - from
  time = time / .5
  if time < 1 then
    return to * .5 * (time * time * ((s + 1) * time - s)) + from
  end
  time = time - 2
  return to * .5 * (time * time * ((s + 1) * time + s) + 2) + from
end
function Tween.elastic_in(from, to, time)
  if time == 1 then
    return to
  end
  local p = .3
  local s = p / 4
  to = to - from
  time = time - 1
  return -to * (2^(10 * time) * math.sin((time - s) * DOUBLE_PI / p)) + from
end
function Tween.elastic_out(from, to, time)
  if time == 1 then
    return to
  end
  local p = .3
  local s = p / 4
  to = to - from
  return to * (2^(-10 * time) * math.sin((time - s) * DOUBLE_PI / p) + 1) + from
end
function Tween.elastic_in_out(from, to, time)
  if time == 1 then
    return to
  end
  local p = .3 * 1.5
  local s = p / 4
  to = to - from
  time = time / .5
  if time < 1 then
    time = time - 1
    return -.5 * (to * (2^(10 * time) * math.sin((time - s) * DOUBLE_PI / p))) + from
  end
  time = time - 1
  return to * (2^(-10 * time) * math.sin((time - s) * DOUBLE_PI / p)) * .5 + to + from
end
function Tween.bounce_in(from, to, time)
  to = to - from
  return to - Tween.bounce_out(0, to, 1 - time) + from
end
function Tween.bounce_out(from, to, time)
  to = to - from
  if time < (1 / 2.75) then
    return to * (7.5625 * time * time) + from
  end
  if time < (2 / 2.75) then
    time = time - (1.5 / 2.75)
    return to * (7.5625 * time * time + .75) + from
  end
  if time < (2.5 / 2.75) then
    time = time - (2.25 / 2.75)
    return to * (7.5625 * time * time + .9375) + from
  end
  time = time - (2.625 / 2.75)
  return to * (7.5625 * time * time + .984375) + from
end
function Tween.bounce_in_out(from, to, time)
  to = to - from
  if time < .5 then
    return Tween.bounce_in(0, to, time * 2) * .5 + from
  end
  return Tween.bounce_out(0, to, time * 2 - 1) * .5 + to * .5 + from
end
function Tween.spring(from, to, time)
  time = clamp01(time)
  time = (math.sin(time * PI * (.2 + 2.5 * time * time * time)) * (1 - time)^2.2 + time) * (1 + (1.2 * (1 - time)))
  return from + (to - from) * time
end

if (...) == nil then
  local tweening_functions = {
    Tween.linear,
    Tween.quad_in,
    Tween.cubic_in,
    Tween.quart_in,
    Tween.quint_in,
    Tween.expo_in,
    Tween.circ_in,
    Tween.back_in,
    Tween.elastic_in,
    Tween.bounce_in
  }

  local function triangle(t)
    -- see https://en.wikipedia.org/wiki/Triangle_wave#Definition
    local p = 2
    return 2 * math.abs(t/p - math.floor(t/p + 1/2))
  end

  function draw()
    clear()

    local t = triangle(get_time())
    for i = 1, SCREEN_H do
      local tween_function = tweening_functions[i]
      local tweened_value = tween_function(0, SCREEN_W - 1, t)
      local color = hsl(360 * (i / SCREEN_H), 1, 0.5)

      set_pixel_f(tweened_value, i - 1, color)
    end
  end
end

return Tween
