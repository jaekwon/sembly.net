# global variables
dragging = dx = dy = undefined

getPos = (e) ->
  if e.pageX
    x = e.pageX
    y = e.pageY
    {x,y}
  else if e.clientX
    x = clientX
    y = clientY
    {x,y}

Drag = (e) ->
  e = window.event unless e
  {x,y} = getPos e

  src = (if (e.target) then e.target else e.srcElement)
  dragging = $(src).closest('.draggable')
  dragging.addClass('dragging')
  offset = dragging.offset()
  dx = x - offset.left
  dy = y - offset.top

Move = (e) ->
  return unless dragging
  e = window.event  unless e
  {x,y} = getPos e

  dragging.css(left:(x-dx), top:(y-dy))

Drop = (e) ->
  return unless dragging
  dragging.removeClass('dragging')
  dragging = undefined

$(document).mousemove Move
$(document).mouseup Drop

@makeDraggable = (el) ->
  el.addClass 'draggable'
  el.mousedown Drag
