process.env.NODE_ENV = 'test'
environment = require '../config/environment'

chai = require 'chai'  
should = chai.should()

global.sinon = require 'sinon'
global.bb = require 'bluebird'

global.GERClient = require 'ger-client'

fs = require('fs');
path = require 'path'

HapiGER = require('../index.coffee')

global.bootstrap_stream = ->
  fs.createReadStream(path.resolve('./test/test_events.csv'))

global.server = new HapiGER()

global.start_server = server.initialize()
.then( -> server.start())
.then( -> server)

global.start_server_w_client = () ->
  namespace = "tenant_#{Math.floor((1 + Math.random()) * 0x10000000)}"
  start_server.then( (server) ->
    server.create_namespace(namespace)
  )
  .then( -> 
    new GERClient("#{server.info.uri}/#{namespace}")
  )

global.requests = {}

global.requests.all_400 = (list_of_requests) ->
  bb.all(list_of_requests)
  .then( (resps) ->
    (resp[1].should.equal 400 for resp in resps)
    [..., last] = resps
    last
  )

global.requests.all_200 = (list_of_requests) ->
  bb.all(list_of_requests)
  .then( (resps) ->
    (resp[1].should.equal 200 for resp in resps)
    [..., last] = resps
    last
  )
