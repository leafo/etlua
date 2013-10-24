
import compile, render, Parser from require "elua"

describe "elua", ->
  describe "Parser", ->
    cases = {
      {
        "hello world"
        "hello world"
      }


      {
        "one surf-zone two"
        "one <%= var %> two"
        {var: "surf-zone"}
      }

      {
        "a ((1))((2))((3)) b"
        "a <% for i=1,3 do %>((<%= i %>))<% end %> b"
      }

      {
        "y%>u"
        [[<%= "y%>u" %>]]
      }


      {
        [[
This is my message to you
This is my message to 4



  hello 1

  hello 2

  hello 3

  hello 4

  hello 5

  hello 6

  hello 7

  hello 8

  hello 9

  hello 10


message: yeah

This is my message to oh yeah  %>"]]
        [[
This is my message to <%= "you" %>
This is my message to <%= 4 %>
<% if things then %>
  I love things
<% end %>

<% for i=1,10 do%>
  hello <%= i %>
<% end %>

message: <%= visitor %>

This is my message to <%= [=[oh yeah  %>"]=] %>]]
        {
          visitor: "yeah"
        }
      }
    }

    for case in *cases
      it "should run template", ->
        assert.same case[1], render unpack case, 2

  describe "Parser.in_string", ->
    cases = {
      { "hello world", false }
      { "hello 'world", true }
      { [[hello "hello \" world]], true }
      { "hello [=[ wor'ld ]=]dad", false }
    }

    for {str, expected} in *cases
      it "should detect if in string", ->
        assert.same expected, Parser.in_string { :str }, 1
