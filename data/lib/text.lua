-- Generic text renderer.
--
-- Font format:
-- {
--   width = <default glyph width in columns>,
--   height = <glyph height in rows>,
--   spacing = <optional extra pixels between glyphs, default 1>,
--   space_width = <optional width for the space character>,
--   widths = { ["A"] = <optional per-glyph width> },
--   glyphs = { ["A"] = {<column bits>, ...} }
-- }

local Text = {}

local function validate_font(font)
  if type(font) ~= "table" then
    return false
  end

  if type(font.glyphs) ~= "table" then
    return false
  end

  if type(font.width) ~= "number" or type(font.height) ~= "number" then
    return false
  end

  return true
end

function Text.new(font)
  local M = {
    scroll_speed = 10,
    scroll_delay = 1.0,
  }

  local current_font = {
    width = 0,
    height = 0,
    spacing = 1,
    space_width = 0,
    widths = {},
    glyphs = {},
  }

  local text = ""
  local text_width = 0
  local text_last_set = 0
  local scroll_offset = 0
  local font_color = rgb(255, 255, 255)

  local function glyph_width(ch, glyph)
    if current_font.widths ~= nil and current_font.widths[ch] ~= nil then
      return current_font.widths[ch]
    end

    if glyph ~= nil then
      return #glyph
    end

    return current_font.width
  end

  local function char_advance(ch)
    local spacing = current_font.spacing or 1

    if ch == " " then
      return (current_font.space_width or current_font.width) + spacing
    end

    local glyph = current_font.glyphs[ch]
    return glyph_width(ch, glyph) + spacing
  end

  local function recompute_text_width()
    text_width = 0

    for i = 1, #text do
      local ch = string.sub(text, i, i)
      text_width = text_width + char_advance(ch)
    end
  end

  function M.set_font(new_font)
    if not validate_font(new_font) then
      error("invalid font table")
    end

    current_font = new_font
    recompute_text_width()
  end

  function M.reset()
    text = ""
    text_width = 0
    scroll_offset = 0
  end

  function M.set_text(txt)
    text = txt or ""
    recompute_text_width()
    scroll_offset = 0
    text_last_set = get_time()
  end

  function M.set_color(color)
    font_color = color
  end

  function M.get_text_height()
    return current_font.height
  end

  function M.scroll(delta_time)
    if ((get_time() - text_last_set) > M.scroll_delay) then
      if text_width > 0 then
        scroll_offset = scroll_offset - (delta_time * M.scroll_speed)
        if scroll_offset <= -text_width then
          scroll_offset = SCREEN_W
        end
      end
    end
  end

  function M.draw_char(ch, x, y, color)
    if ch == " " then
      return
    end

    local glyph = current_font.glyphs[ch]
    if glyph == nil then
      return
    end

    for col = 1, #glyph do
      local bits = glyph[col]
      for row = 0, current_font.height - 1 do
        if (bits & (1 << row)) ~= 0 then
          set_pixel(x + col - 1, y + row, color)
        end
      end
    end
  end

  function M.draw(x, y)
    if text_width <= 0 then
      return
    end

    local cursor_x = x + math.floor(scroll_offset)

    for i = 1, #text do
      local ch = string.sub(text, i, i)
      M.draw_char(ch, cursor_x, y, font_color)
      cursor_x = cursor_x + char_advance(ch)

      if cursor_x > SCREEN_W and i > 1 then
        break
      end
    end
  end

  M.set_font(font)
  return M
end

return Text
