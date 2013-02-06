###
###

{randomColor} = require 'client/helpers'

@View = class View
  constructor: ({@el, @padding, @width, @height, @top, @left, @border, @background}={}) ->
    # defaults
    @padding    ?= 10
    @width      ?= 320
    @height     ?= 200
    @top        ?= 10
    @left       ?= 10
    @border     ?= 'none'
    @background ?= randomColor(alpha:0.8)
    @el         ?= $('<div/>')
    
    @el.addClass('borderBox')
    @el.css({position:'absolute', display:'block'})
    @el.css({wordWrap:'break-word', whiteSpace:'pre-wrap'}) # word-wrapping with pre

    @repaint()

  repaint: ->
    # Resizes, reorients, draws background.
    width   = @width - @padding*2
    height  = @height - @padding*2
    @el.css({padding:@padding})
    @el.css({width:@width, height:@height, top:@top, left:@left, border:@border, background:@background})
    @

  write: (text) ->
    @el.append($('<span/>').text(text))
    @

  append: (el) ->
    @el.append(el)
    @

  # TODO 
  splitHorizontal: -> {left, right}

  # TODO
  splitVertical: -> {top, bottom}
