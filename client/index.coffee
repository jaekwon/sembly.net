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
shaderMaterial = undefined
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

  # Add Light to scene
  hemiLight = new THREE.HemisphereLight( 0xffffff, 0xffffff, 0.9 )
  hemiLight.color.setHSV( 0.6, 0.75, 1 )
  hemiLight.groundColor.setHSV( 0.095, 0.5, 1 )
  hemiLight.position.set( 0, 500, 0 )
  scene.add( hemiLight )

  # Make default 'volumetric' shader
  shaderMaterial = new THREE.MeshPhongMaterial( { color: 0xffffff, specular: 0xffffff, ambient: 0xffffff, shininess: 20, morphTargets: false, morphNormals: false, vertexColors: THREE.FaceColors, shading: THREE.FlatShading } )

  # Add "Test" to scene
  geometry = new THREE.TextGeometry("test", {size:200, height:0, curveSegments:0, font:"helvetiker", weight:"bold", style:"normal"})
  mesh = new THREE.Mesh( geometry, shaderMaterial )
  mesh.castShadow = true
  mesh.receiveShadow = true
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
  controls = require('client/control').installControls({camera, elem:renderer.domElement, render})

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
      mesh = new THREE.Mesh( geometry, shaderMaterial )
      window.mesh = mesh # last mesh, for debugging
      scene.add( mesh )
      render()
  )

  editorView = require('client/widgets').editorView(
    (err, text) ->
      console.log(err, text) if err?
      console.log "yay"
  )

  $(document.body).append fileLoaderView.el
  $(document.body).append editorView.el

module.exports = ->
  # This gets called upon page load.
  # (because 'demodule' call in Cakefile says so)
  return this
