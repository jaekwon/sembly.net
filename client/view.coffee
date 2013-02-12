###
###

{randomColor} = require 'client/helpers'

@View = class View
  constructor: ({@el, @content, @padding, @width, @height, @top, @left, @border, @background}={}) ->
    # defaults
    @padding    ?= 10
    @width      ?= 320
    # @height     ?= undefined
    @top        ?= 10
    @left       ?= 10
    @border     ?= 'none'
    @background ?= randomColor(alpha:0.8)

    if not @el?
      @el = $('<div/>')
      @el.css({position:'absolute', display:'block'})
      @el.css({wordWrap:'break-word', whiteSpace:'pre-wrap'}) # word-wrapping with pre
      @el.css({borderRadius:10})
    @el.addClass('view_el')

    if not @content?
      @content = $('<div/>')
    @content.addClass('view_content')

    @el.append @content

    @repaint()

  # Resizes, reorients, draws background.
  repaint: ->
    width   = @width - @padding*2
    height  = @height - @padding*2 if @height?
    @el.css({padding:@padding})
    @el.css({width:@width, top:@top, left:@left, border:@border, background:@background})
    @el.css({height:@height}) if @height?
    @

  write: (text) ->
    @content.append($('<span/>').text(text))
    @

  append: (el) ->
    @content.append(el)
    @

  # TODO 
  splitHorizontal: -> {left, right}

  # TODO
  splitVertical: -> {top, bottom}
