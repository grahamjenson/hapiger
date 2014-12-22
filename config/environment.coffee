bb = require 'bluebird'
    
environment = {}
environment.logging_options = {
  reporters: [{
    reporter: require('good-console'),
    args: [{ log: '*', response: '*' }]
  }]
}
process.env.PORT=4567

console.log "ENV", process.env.NODE_ENV
switch process.env.NODE_ENV
  when "test"
    
    process.env.PORT = 3000
    bb.Promise.longStackTraces()
  when "production" 
  else
    console.log "ENV", "forcing development"
    bb.Promise.longStackTraces()
#AMD
if (typeof define != 'undefined' && define.amd)
  define([], -> return environment)
#Node
else if (typeof module != 'undefined' && module.exports)
    module.exports = environment;
