{View} = require 'client/view'
{makeDraggable} = require 'client/draggable'

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

@openLocalFileWidget = (options, fileCb) ->
  # This widget lets the user open a local shape file.
  # - options:
  #   * responseType: Read the file as 'arraybuffer' (default) or 'binarystring'.
  #   * singleUse:    If true, the widget becomes disabled after single use. False by default.
  # - fileCb: Called for each loaded file

  # Shift arguments
  [options, fileCb] = [null, options] unless fileCb?

  # Defaults
  responseType  = options?.responseType ? 'arraybuffer'
  singleUse     = options?.singleUse    ? no

  wgt = new View(background:'rgba(129, 145, 142, 0.8)', top:200, left:200)
  wgt.write('import locally\n')
  wgt.append fileInputEl (event) ->
    # After file load...
    if singleUse then $(event.target).attr('disabled', 'disabled')
    files = event.target.files
    for file in files then do (file) ->
      # 'file' is a selected file
      fr = new FileReader()
      if responseType is 'arraybuffer'
        fr.readAsArrayBuffer(file)
      else if responseType is 'binarystring'
        fr.readAsBinaryString(file)
      else
        throw new Error("Unexpected responseType: #{responseType}")
      fr.onload = (e) -> fileCb(null, e.target.result)
  wgt.write('\n--- or ---\n')
  wgt.write('import URL\n')
  wgt.append $('<input/>')

  makeDraggable wgt.el

  return wgt
