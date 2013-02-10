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

  # Add custom shader
  # http://www.html5rocks.com/en/tutorials/webgl/shaders/
  vertexShader = """
    // create a shared variable for the
    // VS and FS containing the normal
    varying vec3 vNormal;

    void main() {

        // set the vNormal value with
        // the attribute value passed
        // in by Three.js
        vNormal = normal;

        gl_Position = projectionMatrix *
                      modelViewMatrix *
                      vec4(position,1.0);
    }
  """
  fragmentShader = """
    // same name and type as VS
    varying vec3 vNormal;

    void main() {

        // calc the dot product and clamp
        // 0 -> 1 rather than -1 -> 1
        vec3 light = vec3(0.5,0.2,1.0);
          
        // ensure it's normalized
        light = normalize(light);
      
        // calculate the dot product of
        // the light to the vertex normal
        float dProd = max(0.0, dot(vNormal, light));
      
        // feed into our frag colour
        gl_FragColor = vec4(dProd, dProd, dProd, 1.0);
      
    }
  """
  shaderMaterial = new THREE.ShaderMaterial({vertexShader, fragmentShader})

  # Add "Test" to scene
  geometry = new THREE.TextGeometry("test", {size:200, height:0, curveSegments:0, font:"helvetiker", weight:"bold", style:"normal"})
  # material = new THREE.MeshBasicMaterial( { color: 0x000000, wireframe: true } )
  mesh = new THREE.Mesh( geometry, shaderMaterial )
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
      {responseType: 'arraybuffer'},
      (err, data) ->
        console.log(err, data) if err?
        geometry = require('voxel-geometry').parsers.stl.parse( data )
        # material = new THREE.MeshBasicMaterial( { color: 0x000000, wireframe: true } )
        mesh = new THREE.Mesh( geometry, shaderMaterial )
        scene.add( mesh )
        render()
    ).el
  )

module.exports = ->
  # This gets called upon page load.
  # (because 'demodule' call in Cakefile says so)
  return this
