
HapiGER = require('./lib/hapi_server.coffee')

hapiger = new HapiGER()
hapiger.initialize()
.then( -> hapiger.start())
.catch((e) -> console.log "ERROR"; console.log e.stack)