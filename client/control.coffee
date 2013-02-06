
# Installs control onto a DOM element.
# camera: THREE camera
# elem:   The THREE.WebGLRenderer/CanvasRenderer dom element
# render: Callback to be called, whenever scene changes due to control actions
@installControls = ({camera, elem, render}) ->

  # Trackball control
  controls = new THREE.TrackballControls camera, elem
  controls.rotateSpeed = 1.0
  controls.zoomSpeed = 10
  controls.panSpeed = 0.8
  controls.noZoom = false
  controls.noPan = false
  controls.staticMoving = true
  controls.dynamicDampingFactor = 0.3
  controls.keys = [65, 83, 68]
  controls.addEventListener 'change', render

  # Click & select control
  selected = undefined
  isDrag = no
  $(elem).mousemove (event) ->
    isDrag = yes if event.which is 1 # mouse is down
  $(elem).mousedown (event) ->
    isDrag = no
  $(elem).mouseup (event) ->
    return true if isDrag
    intersects = geom.pickObjects( event, scene, camera ).unique( ({object}) -> object.id )
    iObjects = intersects.map( ({object}) -> object ).filter( (object) -> object.kSelectable isnt no )
    return unless iObjects.length > 0
    selectedIndex = iObjects.indexOf selected if selected?
    if selectedIndex?
      newSelected = iObjects[ (selectedIndex+1) % iObjects.length ]
    else
      newSelected = iObjects[0]
    selected.material.color.setHex 0x000000 if selected?
    newSelected.material.color.setHex 0xFF0000
    selected = newSelected
    render()
    return true

  return controls
