{View} = require 'client/view'
{hasWebGL} = require 'client/helpers'
materials = require 'client/three_materials'
{createWorker} = require 'client/misc'

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
  mesh = new THREE.Mesh( geometry, materials.default )
  # mesh.castShadow = true
  # mesh.receiveShadow = true
  scene.add( mesh )

  geometry = new THREE.TextGeometry("test", {size:200, height:0, curveSegments:0, font:"helvetiker", weight:"bold", style:"normal"})
  mesh = new THREE.Mesh( geometry, materials.default )
  mesh.rotation.x = -Math.PI / 2
  # mesh.castShadow = true
  # mesh.receiveShadow = true
  scene.add( mesh )

  # Add grid to scene
  grid = new THREE.Mesh(
    new THREE.PlaneGeometry( 1000, 1000, 20, 20 ),
    new THREE.MeshBasicMaterial( { color: 0xBBBBEE, wireframe: true } )
  )
  #grid.rotation.z = - Math.PI / 2
  grid.kSelectable = no
  scene.add( grid )

  # Control mechanism
  controls = require('client/control').installControls({camera, elem:renderer.domElement, render, scene})

animate = ->
  # note: three.js includes requestAnimationFrame shim
  requestAnimationFrame( animate )
  controls.update()

render = -> renderer.render( scene, camera )

# On document ready...
$ ->
  init()
  animate()

  fileLoaderView = require('client/widgets').fileLoaderView(
    {responseType: 'arraybuffer'},
    (err, data) ->
      console.log(err, data) if err?
      geometry = require('voxel-geometry').parsers.stl.parse( data )
      # material = new THREE.MeshBasicMaterial( { color: 0x000000, wireframe: true } )
      mesh = new THREE.Mesh( geometry, materials.default )
      window.mesh = mesh # last mesh, for debugging
      scene.add( mesh )
      render()
  )

  csgEditorView = require('client/widgets').csgEditorView(
    (err, geometry) ->
      console.log(err, geometry) if err?
      # Do something with geometry
      console.log {geometry}
  )

  $(document.body).append fileLoaderView.el
  $(document.body).append csgEditorView.el

module.exports = ->
  # This gets called upon page load.
  # (because 'demodule' call in Cakefile says so)
  return this
