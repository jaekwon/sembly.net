{CSG, CAG} = require 'csg'
{View} = require 'client/view'
{blockDrag, makeDraggable} = require 'client/draggable'

require 'client/three_csg'

fileInputEl = (cb) ->
  # Creates an $(el) that calls the given callback 'cb' upon file load.

  # Check for the various File API support.
  if (window.File && window.FileReader && window.FileList && window.Blob)
    # Great success! All the File APIs are supported.
    inputEl = $('<input type="file" name="files[]" multiple />')
    inputEl.bind('change', cb)
    return inputEl
  else
    alert('The File APIs are not fully supported in this browser.')
    undefined

@fileLoaderView = (options, fileCb) ->
  # This widget lets the user open a local shape file.
  # - options:
  #   * responseType: Read the file as 'arraybuffer' (default) or 'binarystring'.
  #   * singleUse:    If true, the widget becomes disabled after single use. False by default.
  # - fileCb: Called for each loaded file

  # Shift arguments
  [options, fileCb] = [null, options] if options instanceof Function

  # Defaults
  responseType  = options?.responseType ? 'arraybuffer'
  singleUse     = options?.singleUse    ? no

  # Construct Widget View
  view = new View(top:20, left:20)
  view.write('import local file\n')
  view.append fileInputEl (event) ->
    # After file load...
    if singleUse then $(event.target).attr('disabled', 'disabled')
    files = event.target.files
    for file in files # then do (file) ->
      # 'file' is a selected file
      fr = new FileReader()
      if responseType is 'arraybuffer'
        fr.readAsArrayBuffer(file)
      else if responseType is 'binarystring'
        fr.readAsBinaryString(file)
      else
        throw new Error("Unexpected responseType: #{responseType}")
      fr.onload = (e) ->
        fileCb(null, e.target.result)
  view.write('\n\n  or, \n\n')
  view.write('import URL\n')
  view.append $('<input/>')

  makeDraggable view.el
  blockDrag view.content

  return view

@editorView = editorView = (options, saveCb, cancelCb) ->
  # This widget lets the user edit a file.
  # - options:
  #   * mode: CodeMirror mode, e.g. 'coffeescript'
  # - saveCb:
  # - cancelCb:

  # Shift arguments
  [options, saveCb, cancelCb] = [null, options, saveCb] if options instanceof Function

  # Defaults
  mode        = options?.mode     ? 'coffeescript'
  tabSize     = options?.tabSize  ? 2

  # Construct Widget View
  view = new View(top:180, left:20, width:480)
  view.content.addClass 'editor_inner'

  # Construct CodeMirror
  mirror = view.mirror = window.mirror = CodeMirror view.content[0],
    value:        '' # see mirror.setValue below.
    mode:         mode
    # theme:        'sembly'
    # keyMap:       'sembly'
    autofocus:    yes
    gutter:       yes
    fixedGutter:  yes
    lineNumbers:  yes
    tabSize:      tabSize
    onChange: (->
      view.content.height($(mirror.getWrapperElement()).height())
    )#.throttle(100) maybe causing issues.
  # Gutter
  # mirror.setMarker 0, '● ', 'cm-bracket'
  # Fix to set height of editor
  setTimeout (->mirror.setValue('')), 0

  # Add 'RUN' button
  view.append $('<hr/>')
  view.append $('<button/>').text('RUN').click (e) ->
    saveCb( mirror.getValue() )
    null

  makeDraggable view.el
  blockDrag view.content

  return view

@csgEditorView = (options, geomCb) ->

  # Shift arguments
  [options, geomCb] = [null, options] if options instanceof Function

  view = editorView options, (code) ->
    fn = new Function('CSG', 'CAG', """
      'use strict';
      #{code}
    """)
    geometry = fn(CSG, CAG)
    geomCb null, geometry
