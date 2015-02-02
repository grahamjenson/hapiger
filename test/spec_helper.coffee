process.env.NODE_ENV = 'test'
environment = require '../config/environment'

chai = require 'chai'  
should = chai.should()

global.sinon = require 'sinon'
global.bb = require 'bluebird'
bb.Promise.longStackTraces();

global.GERClient = require 'ger-client'

fs = require('fs');
path = require 'path'

HapiGER = require('../lib/hapi_server.coffee')

global.bootstrap_stream = ->
  fs.createReadStream(path.resolve('./test/test_events.csv'))

global.server = new HapiGER()

global.start_server = server.initialize()
.then( -> server.start())
.then( -> server)

global.start_server_w_client = (namespace = 'default_ns') ->
  client = null
  start_server.then( (server) ->
    client = new GERClient("#{server.info.uri}", namespace)
    client.destroy_namespace()
  )
  .then( ->
    client.create_namespace()
  )
  .then( -> 
    client
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
