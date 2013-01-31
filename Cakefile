fs = require 'fs'
{spawn, exec} = require 'child_process'
demodule = require 'demodule'
log = console.log

task 'scss', ->
  run 'sass --watch static/stylesheets/:static/stylesheets/'

task 'debug', 'Run the debug server', ->
  run 'coffee --nodejs --debug server'

task 'server', 'Run the server', ->
  run 'coffee server'

task 'browser', 'Package javascript for browser', ->
  {code,minCode} = demodule [
    {name:'client',          path:'client/**.coffee'}
    {name:'async',           path:'node_modules/async/lib/async.js'}
    {name:'three',           path:'node_modules/three/three.js'}
  ], "require('client')();"
  fs.writeFileSync 'static/javascripts/client.js', code, 'utf8'
  fs.writeFileSync 'static/javascripts/client.min.js', minCode, 'utf8'

run = (args...) ->
  for a in args
    switch typeof a
      when 'string' then command = a
      when 'object'
        if a instanceof Array then params = a
        else options = a
      when 'function' then callback = a
  
  command += ' ' + params.join ' ' if params?
  cmd = spawn '/bin/sh', ['-c', command], options
  cmd.stdout.on 'data', (data) -> process.stdout.write data
  cmd.stderr.on 'data', (data) -> process.stderr.write data
  process.on 'SIGHUP', -> cmd.kill()
  cmd.on 'exit', (code) -> callback() if callback? and code is 0
