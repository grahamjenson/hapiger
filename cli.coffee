bb = require 'bluebird'
_ = require "underscore"

program = require('commander');
chalk = require 'chalk'

HapiGER = require('./lib/hapi_server')



cli = ->

  environment = _.defaults( process.env, {
    PORT: 4567
  })


  program
    .version('0.0.2')
    .usage('[options]')
    .description('start a hapiger server')
    .option('-p, --port <port>', 'the port to start the server on', 3456)
    .option('-e, --es <esm>', 'select Event Store [memory, pg, rethinkdb, mysql]', 'memory')
    .option('-E, --esoptions <options>', 'JSON representation of Options for Event Store e.g. "{"url": "postgres://localhost/hapiger"}"
      \n\t memory -- {}
      \n\t pg -- {"url" : "postgres url"}
      \n\t rethinkdb -- {"host": "rethinkdb host", "port": "rethink port", "db": "rethink database"}
      \n\t mysql -- {"connection": {"host": "mysql host", "port": "mysql port", "user": "mysql user", "password": "mysql password"}}
      ', ((input) -> JSON.parse(input)), {})
    .option('-v, --verbose', "More Output", false)
    .option('-D --default_configuration', "Default Configuration to generate recommendations", {})
    .parse(process.argv);

  verbose = program.verbose

  bb.Promise.longStackTraces() if verbose

  hapiger = new HapiGER({
    esm: program.es
    esmoptions: program.esoptions
    port: program.port
    configuration: program.default_configuration
  })

  hapiger.initialize()
  .then( -> hapiger.start())
  .catch((e) -> console.log "ERROR"; console.log e.stack)


module.exports = cli