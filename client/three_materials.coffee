THREE = (window.THREE ?= require('three'))

@volumetric = new THREE.MeshPhongMaterial({
  color:        0xaaaaaa
  specular:     0x222222
  ambient:      0x000000
  shininess:    150
  morphTargets: false
  morphNormals: false
  vertexColors: THREE.FaceColors
  shading:      THREE.FlatShading
})

@volumetricHighlighted = new THREE.MeshPhongMaterial({
  color:        0xff8888
  specular:     0x222222
  ambient:      0x000000
  shininess:    150
  morphTargets: false
  morphNormals: false
  vertexColors: THREE.FaceColors
  shading:      THREE.FlatShading
})

@addLights = (scene) ->
  # Add Hemispheric Light to scene, separates the Y axis
  hemiLight = new THREE.HemisphereLight( 0xffffff, 0xffffff, 0.9 )
  hemiLight.color.setHSV( 0.6, 0.75, 1 )
  hemiLight.groundColor.setHSV( 0.095, 0.5, 1 )
  # hemiLight.position.set( 0, Number.POSITIVE_INFINITY, 0 )
  hemiLight.position.set( 0, 9999999, 0 )
  scene.add( hemiLight )

  # Add Directional Light to the scene  
  directLight = new THREE.DirectionalLight( 0xffffff, 1 )
  # directLight.position.set( 0, 0, Number.POSITIVE_INFINITY )
  directLight.position.set( 0, 0, 9999999 )
  directLight.color.setHSV( 0.0, 0.0, 0.7 )
  scene.add( directLight )

  return {hemisphere:hemiLight, directional:directLight}
