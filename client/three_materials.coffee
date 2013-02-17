THREE = (window.THREE ?= require('three'))

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

# Default material
@default = new THREE.ShaderMaterial({vertexShader, fragmentShader})
