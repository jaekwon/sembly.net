@createWorker = ( script, callback ) ->
  createObjectURL = window.URL.createObjectURL ? window.webkitURL.createObjectURL
  blob = new Blob [script]
  worker = new Worker createObjectURL new Blob [script]
  worker.onmessage = callback
  return worker

# Below are not not used ATM

# jquery extensions
jQuery.fn.extend(

  # https://github.com/padolsey/jQuery-Plugins/blob/master/sortElements/jquery.sortElements.js
  sortElements: (->
    sort = [].sort
    (comparator, getSortable) ->
      getSortable ||= -> @
      placements = @map ->
        sortElement = getSortable.call @
        parentNode = sortElement.parentNode
        nextSibling = parentNode.insertBefore(
          document.createTextNode(''),
          sortElement.nextSibling
        )
        return ->
          if this is parentNode
            throw new Error "You can't sort elements if any one is a descendant of another."
          parentNode.insertBefore @, nextSibling
          parentNode.removeChild nextSibling

      return sort.call(@, comparator).each (i) ->
        placements[i].call(getSortable.call(@))
  )()

  # scroll element down
  scrollDown: ->
    this.each ->
      elem = $(this)
      height = elem.prop('scrollHeight')
      elem.scrollTop(height)

)
