{unique} = require 'client/helpers'
materials = require 'client/three_materials'

DRAG_THRESHOLD = 5.0

# Given screen coordinates 'start' and current coordinates 'current',
# return the floatingpoint distance between the two.
# start: {offsetX, offsetY}
# end:   {offsetX, offsetY}
screenDistance = (start, current) ->
  xSq = Math.pow (start.offsetX - current.offsetX), 2.0
  ySq = Math.pow (start.offsetY - current.offsetY), 2.0
  return Math.pow (xSq + ySq), 0.5

# Installs control onto a DOM element.
# camera: THREE camera
# elem:   The THREE.WebGLRenderer/CanvasRenderer dom element
# scene:  The THREE.Scene which contains selectable objects
# render: Callback to be called, whenever scene changes due to control actions
@installControls = ({camera, elem, scene, render}) ->

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
  mouseDownEvent = undefined
  isDrag = no
  $(elem).mousedown (event) ->
    mouseDownEvent = event
    isDrag = no
  $(elem).mousemove (event) ->
    return unless event.which is 1 # mouse is down
    # detect "dragging", which is sure to be happening
    # when moveDistance is above some threshold
    moveDistance = screenDistance mouseDownEvent, event if mouseDownEvent?
    isDrag = yes if moveDistance > DRAG_THRESHOLD
  $(elem).mouseup (event) ->
    return true if isDrag
    intersects = unique( pickObjects( event, scene, camera ), (({object}) -> object.id) )
    iObjects = intersects.map( ({object}) -> object ).filter( (object) -> object.kSelectable isnt no )
    return unless iObjects.length > 0
    selectedIndex = iObjects.indexOf selected if selected?
    if selectedIndex?
      newSelected = iObjects[ (selectedIndex+1) % iObjects.length ]
    else
      newSelected = iObjects[0]
    # materials.volumetric.color.setHex 0x666666
    # selected.material    = materials.volumetric if selected?
    # newSelected.material = materials.volumetricHighlighted
    selected.material     = materials.default if selected?
    newSelected.material  = materials.highlighted
    selected = newSelected
    render()
    return true

  return controls

@pickObjects = pickObjects = (event, scene, camera) ->
  {target, offsetX, offsetY} = event
  projector = new THREE.Projector()
  # map 0.0~1.0 to -1.0~1.0
  vector_x = offsetX / target.width * 2.0 - 1.0
  vector_y = offsetY / target.height * 2.0 - 1.0
  vector = new THREE.Vector3( vector_x, -vector_y, 0.5 )
  projector.unprojectVector( vector, camera )
  # Comments below for debugging the raycaster
  # vcopy = vector.clone().sub( camera.position ).normalize().multiplyScalar(1000).add( camera.position )
  raycaster = new THREE.Raycaster( camera.position, vector.sub( camera.position ).normalize() )
  # raygeom = new THREE.Geometry()
  # raygeom.vertices.push camera.position
  # raygeom.vertices.push vcopy2
  # rayline = new THREE.Line( raygeom, new THREE.LineBasicMaterial( {color: 0x0} ) )
  # scene.add rayline
  return raycaster.intersectObjects( scene.children )
