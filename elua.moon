
moon = require "moon"
import insert, concat from table

escape_pattern = do
  punct = "[%^$()%.%[%]*+%-?%%]"
  (str) -> (str\gsub punct, (p) -> "%"..p)

class Parser
  open_tag: "<%"
  close_tag: "%>"
  modifiers: "^[=-]"

  next_tag: =>
    start, stop = @str\find @open_tag, @pos, true

    -- no more tags, all done
    unless start
      @push_raw @pos, #@str
      return false

    -- add text before
    unless start == @pos
      @push_raw @pos, start - 1

    @pos = stop + 1
    modifier = if @str\match @modifiers, @pos
      with @str\sub @pos, @pos
        @pos += 1

    -- TODO: find the next tag or string, whichever is closer
    start, stop = @str\find @close_tag, @pos, true
    kind = modifier == "=" and "interplate" or "code"
    @push_code kind, @pos, start - 1

    @pos = stop + 1
    true

  -- closest_string: ->
  --   start = @str\find "[=*["

  push_raw: (start, stop) =>
    insert @chunks, @str\sub start, stop

  push_code: (kind, start, stop) =>
    insert @chunks, {
      kind, @str\sub start, stop
    }

  parse: (@str) =>
    assert type(@str) == "string"
    @pos = 1
    @chunks = {}

    while @next_tag!
      nil

    @compile!

  -- generates the code of the template
  compile: =>
    -- moon.p @chunks
    -- todo: find a no-conflict name for buffer
    buffer = {
      "local _b, _b_i, _tostring = {}, 0, tostring"
    }
    buffer_i = #buffer

    push = (str) ->
      buffer_i += 1
      buffer[buffer_i] = str

    for chunk in *@chunks
      t = type chunk
      t = chunk[1] if t == "table"
      switch t
        when "string"
          push "_b_i = _b_i + 1"
          push "_b[_b_i] = #{("%q")\format(chunk)}"
        when "code"
          push chunk[2]
        when "interplate"
          assign = "_b[_b_i] = _tostring(#{chunk[2]})"

          -- validate syntax
          unless loadstring assign
            error "failed to parse: #{chunk[2]}"

          push "_b_i = _b_i + 1"
          push assign
        else
          error "unknown type #{t}"

    push "return table.concat(_b)"
    concat buffer, "\n"

p = Parser!
code = p\parse [[
  This is my message to <%= "you" %>
  This is my message to <%= 4 %>
  <% if things then %>
    I love things
  <% end %>

  <% for i=1,10 do%>
    hello <%= i %>
  <% end %>

  message: <%= visitor %>

  This is my message to <%= "y%>u" %>

]]

print code
-- fn = assert loadstring code
-- setfenv fn, setmetatable {
--   visitor: "HELLO VISITOR"
--   things: true
-- }, __index: _G
-- 
-- print fn!

