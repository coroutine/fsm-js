fs = require 'fs'

{print} = require 'sys'
{spawn} = require 'child_process'

build = (src, dest) ->
  coffee = spawn 'coffee', ['-b', '-c', '-o', dest, src]
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task 'build', 'Builds lib/js/ from src/', ->
  build('src', 'lib/js')
  
task 'build-spec', 'Builds spec/ from spec/src/', ->
  build('spec/src', 'spec')
  
task 'run-spec', 'Builds and tests src/ files', ->
  invoke 'build'
  invoke 'build-spec'
  spawn 'open', ['spec_runner.html']