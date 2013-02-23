###
###

{randomColor} = require 'client/helpers'

getPos = (e) -> {
  x: (e.pageX ? e.clientX),
  y: (e.pageY ? e.clientY)
}
dragging = dx = dy = undefined

$(document).mousemove (e) ->
  return unless dragging
  {x,y} = getPos e
  dragging.css(left:(x-dx), top:(y-dy))

$(document).mouseup (e) ->
  return unless dragging
  dragging.removeClass('dragging')
  dragging = undefined

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
    @el.mousedown (e) ->
      {x,y} = getpos e
      dragging = $(e.target).closest('.draggable')
      dragging.addclass('dragging')
      offset = dragging.offset()
      dx = x - offset.left
      dy = y - offset.top
      return no

    @content.addClass 'dragBlock'
    @content.mousedown (e) ->
      e.stopPropagation()

  makeResizable: ->
    @el.append tab=$('<div/>').css(
      backgroundColor:'#AAA'
      width:    10
      height:   10
      position: 'absolute'
      right:    0
      bottom:   0
      cursor:   'se-resize'
    )

    tab.mousedown (e) ->
      {x,y} = getpos e
      dragging = $(e.target).closest('.resizable')
      dragging.addclass('resizing')
      offset = dragging.offset()
      dx = x - offset.left
      dy = y - offset.top
      return no
