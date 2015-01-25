bb = require 'bluebird'
    
environment = {}
environment.logging_options = {
  reporters: [{
    reporter: require('good-console'),
    args: [{ log: '*', response: '*' }]
  }]
}
process.env.PORT=4567

switch process.env.NODE_ENV
  when "test"
    process.env.PORT = 3000
    bb.Promise.longStackTraces()
  when "production" 
  else
    bb.Promise.longStackTraces()


module.exports = environment
