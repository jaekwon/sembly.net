{View} = require 'client/view'
{hasWebGL} = require 'client/helpers'

# Construct global THREE, as if three.js were included via HTML
THREE = (window.THREE ?= require('three'))
require 'client/three_trackball'

# Hook up THREE.FontUtils to *.typeface.js files
window._typeface_js =
  faces:    THREE.FontUtils.faces
  loadFace: THREE.FontUtils.loadFace

# Global variables
camera = scene = renderer = undefined
controls = undefined

init = ->

  # Renderer
  if hasWebGL()
    renderer = new THREE.WebGLRenderer()
  else
    renderer = new THREE.CanvasRenderer()
  renderer.setSize( window.innerWidth, window.innerHeight )
  document.body.appendChild( renderer.domElement )

  # Construct scene
  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )
  camera.position.z = 1000

  # Add "Test" to scene
  geometry = new THREE.TextGeometry("test", {size:200, height:0, curveSegments:0, font:"helvetiker", weight:"bold", style:"normal"})
  material = new THREE.MeshBasicMaterial( { color: 0x000000, wireframe: true } )
  mesh = new THREE.Mesh( geometry, material )
  scene.add( mesh )

  # Add grid to scene
  grid = new THREE.Mesh(
    new THREE.PlaneGeometry( 1000, 1000, 20, 20 ),
    new THREE.MeshBasicMaterial( { color: 0xAAAAEE, wireframe: true } )
  )
  #grid.rotation.z = - Math.PI / 2
  grid.kSelectable = no
  scene.add( grid )

  # Control mechanism
  controls = require('client/control').installControls({camera, elem:renderer.domElement, render})

animate = ->
  # note: three.js includes requestAnimationFrame shim
  requestAnimationFrame( animate )
  controls.update()

render = -> renderer.render( scene, camera )

$ ->
  # $(document).ready...
  init()
  animate()

  $(document.body).append(
    require('client/widgets').openLocalFileWidget(
      (err, data) ->
        console.log(err, data)
        # mesh = geom.parseSTL(e.target.result)
        # scene.add( mesh )
        render()
    ).el
  )

module.exports = ->
  # This gets called upon page load.
  # (because 'demodule' call in Cakefile says so)
  return this
