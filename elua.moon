
import insert, concat from table

setfenv = setfenv or (fn, env) ->
  local name
  i = 1
  while true
    name = debug.getupvalue fn, i
    break if not name or name == "_ENV"
    i += 1

  if name
    debug.upvaluejoin fn, i, (-> env), 1

  fn

html_escape_entities = {
  ['&']: '&amp;'
  ['<']: '&lt;'
  ['>']: '&gt;'
  ['"']: '&quot;'
  ["'"]: '&#039;'
}

html_escape = (str) ->
  (str\gsub [=[["><'&]]=], html_escape_entities)

class Parser
  open_tag: "<%"
  close_tag: "%>"
  modifiers: "^[=-]"
  html_escape: true

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

    close_start, close_stop = @str\find @close_tag, @pos, true
    error "failed to find closing tag" unless close_start

    while @in_string @pos, close_start
      close_start, close_stop = @str\find @close_tag, close_stop, true

    trim_newline = if "-" == @str\sub close_start - 1, close_start - 1
      close_start -= 1
      true

    @push_code modifier or "code", @pos, close_start - 1

    @pos = close_stop + 1

    if trim_newline
      if match = @str\match "^\n", @pos
        @pos += #match

    true

  -- see if stop leaves us in the middle of a string
  in_string: (start, stop) =>
    in_string = false
    end_delim = nil
    escape = false

    pos = 0
    skip_until = nil

    chunk = @str\sub start, stop
    for char in chunk\gmatch "."
      pos += 1

      if skip_until
        continue if pos <= skip_until
        skip_until = nil

      if end_delim
        if end_delim == char and not escape
          in_string = false
          end_delim = nil
      else
        if char == "'" or char == '"'
          end_delim = char
          in_string = true

        if char == "["
          if lstring = chunk\match "^%[=*%[", pos
            lstring_end = lstring\gsub "%[", "]"
            lstring_p1, lstring_p2 = chunk\find lstring_end, pos, true
            -- no closing lstring, must be inside string
            return true unless lstring_p1
            skip_until = lstring_p2

      escape = char == "\\"

    in_string

  push_raw: (start, stop) =>
    insert @chunks, @str\sub start, stop

  push_code: (kind, start, stop) =>
    insert @chunks, {
      kind, @str\sub start, stop
    }

  compile: (str) =>
    @parse str
    @load @chunks_to_lua!

  parse: (@str) =>
    assert type(@str) == "string", "expecting string for parse"
    @pos = 1
    @chunks = {}

    while @next_tag!
      nil

  load: (code, name="elua") =>
    code_fn = coroutine.wrap ->
      coroutine.yield code

    fn = assert load(code_fn, name)
    (env={}) ->
      setfenv fn, env
      fn tostring, concat, html_escape

  -- generates the code of the template
  chunks_to_lua: =>
    -- todo: find a no-conflict name for buffer
    buffer = {
      "local _b, _b_i, _tostring, _concat, _escape = {}, 0, ..."
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
        when "=", "-"
          assign = "_tostring(#{chunk[2]})"

          if t == "=" and @html_escape
            assign = "_escape(" .. assign .. ")"

          assign = "_b[_b_i] = " .. assign

          -- validate syntax
          unless loadstring assign
            error "failed to parse as expression: #{chunk[2]}"

          push "_b_i = _b_i + 1"
          push assign
        else
          error "unknown type #{t}"

    push "return _concat(_b)"
    concat buffer, "\n"

compile = Parser!\compile
render = (str, env) -> compile(str) env

{ :compile, :render, :Parser }

