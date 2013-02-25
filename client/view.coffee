###
###

{randomColor} = require 'client/helpers'

getPos = (e) -> {
  x: (e.pageX ? e.clientX),
  y: (e.pageY ? e.clientY)
}

@View = class View
  constructor: ({@el, @content, @padding, @width, @height, @top, @left, @border, @background}={}) ->
    # defaults
    @padding    ?= 10
    @width      ?= 320
    # @height     ?= undefined
    @top        ?= 10
    @left       ?= 10
    # @border     ?= 'none'
    @border     ?= '1px solid #ccc'
    # @background ?= randomColor(alpha:0.8)
    @background ?= 'rgba(255,255,255,0.8)'

    @el = $('<div/>') unless @el?
    @el.addClass('view_el')

    @content = $('<div/>') unless @content?
    @content.addClass('view_content')

    @el.append @content

    @makeDraggable()
    @makeResizable()

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

  makeDraggable: ->
    @el.addClass 'draggable'
    @el.css cursor:'move'

    dx = dy = undefined

    @el.bind 'mousedown', (e) =>
      {x, y} = getPos e
      @el.addClass 'dragging'
      offset = @el.offset()
      dx = x - offset.left
      dy = y - offset.top

      $(document).bind 'mousemove.dragging', (e) =>
        {x, y} = getPos e
        @el.css(left:(x-dx), top:(y-dy))

      $(document).bind 'mouseup.dragging', (e) =>
        @el.removeClass 'dragging'
        $(document).unbind '.dragging'

      return no

    @content.addClass 'dragBlock'
    @content.mousedown (e) ->
      e.stopPropagation()

  makeResizable: ->
    @el.addClass 'resizable'
    @el.append tab=$('<div/>').css(
      backgroundColor:'#AAA'
      width:    10
      height:   10
      position: 'absolute'
      right:    0
      bottom:   0
      cursor:   'se-resize'
    ).addClass('resize_tab')

    dx = dy = undefined

    tab.bind 'mousedown', (e) =>
      {x, y} = getPos e
      @el.addClass 'resizing'
      dx = x - @el.width()
      dy = y - @el.height()

      $(document).bind 'mousemove.resizing', (e) =>
        {x, y} = getPos e
        @el.width( x-dx )
        @el.height( y-dy )

      $(document).bind 'mouseup.resizing', (e) =>
        @el.removeClass 'resizing'
        $(document).unbind '.resizing'

      return no
