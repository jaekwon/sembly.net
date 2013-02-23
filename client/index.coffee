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
  geom = new THREE.TextGeometry("test", {size:200, height:0, curveSegments:0, font:"helvetiker", weight:"bold", style:"normal"})
  mesh = new THREE.Mesh( geom, materials.default )
  # mesh.castShadow = true
  # mesh.receiveShadow = true
  scene.add( mesh )

  geom = new THREE.TextGeometry("test", {size:200, height:0, curveSegments:0, font:"helvetiker", weight:"bold", style:"normal"})
  mesh = new THREE.Mesh( geom, materials.default )
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

      geom = require('voxel-geometry').parsers.stl.parse( data )
      # material = new THREE.MeshBasicMaterial( { color: 0x000000, wireframe: true } )
      mesh = new THREE.Mesh( geom, materials.default )
      window.mesh = mesh # last mesh, for debugging
      scene.add( mesh )
      render()
  )

  ###
  # DEMO
  var resolution = 24; // increase to get smoother corners (will get slow!)
  var cube1 = CSG.roundedCube({center: [0,0,0], radius: [10,10,10], roundradius: 2, resolution: resolution});
  var sphere1 = CSG.sphere({center: [5, 5, 5], radius: 10, resolution: resolution });
  var sphere2 = sphere1.translate([12, 5, 0]);
  var sphere3 = CSG.sphere({center: [20, 0, 0], radius: 30, resolution: resolution });
  var result = cube1;
  result = result.union(sphere1);
  result = result.subtract(sphere2);
  result = result.intersect(sphere3);
  return result;
  ###
  csgEditorView = require('client/widgets').csgEditorView(
    (err, csgObject) ->
      console.log( err ) if err?
      
      geom = THREE.CSG.fromCSG csgObject
      mesh = new THREE.Mesh( geom, materials.default )
      window.mesh = mesh # last mesh, for debugging
      scene.add( mesh )
      render()
      # console.log {geom}
  )
  setTimeout ->
    csgEditorView.mirror.setValue """
      var resolution = 24; // increase to get smoother corners (will get slow!)
      var cube1 = CSG.roundedCube({center: [0,0,0], radius: [10,10,10], roundradius: 2, resolution: resolution});
      var sphere1 = CSG.sphere({center: [5, 5, 5], radius: 10, resolution: resolution });
      var sphere2 = sphere1.translate([12, 5, 0]);
      var sphere3 = CSG.sphere({center: [20, 0, 0], radius: 30, resolution: resolution });
      var result = cube1;
      result = result.union(sphere1);
      result = result.subtract(sphere2);
      result = result.intersect(sphere3);
      return result;
    """
  , 0

  $(document.body).append fileLoaderView.el
  $(document.body).append csgEditorView.el

module.exports = ->
  # This gets called upon page load.
  # (because 'demodule' call in Cakefile says so)
  return this
