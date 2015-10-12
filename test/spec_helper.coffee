process.env.NODE_ENV = 'test'

chai = require 'chai'
should = chai.should()

global.bb = require 'bluebird'
global._ = require 'underscore'
global.moment = require 'moment'

bb.Promise.longStackTraces();

global.GERClient = require './client'


HapiGER = require('../lib/hapi_server.coffee')


global.server = new HapiGER()

# global.server = new HapiGER({esm:'pg', esmoptions: {"connection":"postgres://localhost/hapiger"}})
#
# global.server = new HapiGER({esm:'rethinkdb', esmoptions: {
#     "host":"127.0.0.1",
#     "port": 28015,
#     "db":"hapiger"
# }})


global.client = null


global.start_server = server.initialize()
.then( -> server.start())
.then( ->
  global.client = new GERClient("#{server.info.uri}")
  server
)

global.random_namespace = ->
  "namespace_#{_.random(0, 99999999)}"

global.tomorrow = moment().add(1, 'days').format()
global.today =  moment().format()
global.yesterday = moment().subtract(1, 'days').format()
global.tenMinutesAgo =  moment().subtract(10, 'minutes').format()