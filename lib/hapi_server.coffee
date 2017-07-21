
#PROMISES LIBRARY
bb = require 'bluebird'
_ = require "underscore"
#bb.Promise.longStackTraces();

# HAPI STACK
Hapi = require 'hapi'
Joi = require 'joi'

# GER
g = require 'ger'
knex = g.knex # postgres client


GER = g.GER

#ESMs
PsqlESM = g.PsqlESM
MemESM = g.MemESM

ret_esm = require 'ger_rethinkdb_esm'
RethinkDBESM = ret_esm.esm
r = ret_esm.r

mysql_esm = require 'ger_mysql_esm'
MysqlESM = mysql_esm.esm

class HapiGER
  constructor: (options = {}) ->
    @options = _.defaults(options, {
      esm: 'memory'
      esmoptions: {}
      port: 3456
      logging_options: {
        reporters: [{
          reporter: require('good-console'),
          events: { log: '*', response: '*' }
        }]
      }
    })

    switch @options.esm
      when 'memory'
        @_esm = new MemESM({})
        @_ger = new GER(@_esm, @options)
      when 'pg'
        throw new Error('No esm_url') if !@options.esmoptions.connection
        esm_options = _.defaults(@options.esmoptions, {
          client: 'pg'
        })
        knex = new knex(esm_options)
        @_esm = new PsqlESM({knex: knex})
        @_ger = new GER(@_esm, @options)
      when 'rethinkdb'
        rethinkcon = new r(@options.esmoptions)
        @_esm = new RethinkDBESM({r: rethinkcon}, GER.NamespaceDoestNotExist)
        @_ger = new GER(@_esm, @options)
      when 'mysql'
        esm_options = _.defaults(@options.esmoptions, {client: 'mysql'})
        esm_options.connection = _.defaults(@options.esmoptions.connection, {
          timezone: 'utc',
          charset: 'utf8'
        })
        knex = new knex(esm_options)
        @_esm = new MysqlESM({knex: knex}, GER.NamespaceDoestNotExist)
        @_ger = new GER(@_esm, @options)
      else
        throw new Error("no such esm")

  initialize: () ->
    bb.try( => @init_server())
    .then( => @setup_server())
    .then( => @add_server_routes())

  init_server: (esm = 'mem') ->
    #SETUP SERVER
    @_server = new Hapi.Server()
    @_server.connection({ port: @options.port, routes: { cors:true } });
    @info = @_server.info

  setup_server: ->
    @load_server_plugin('good', @options.logging_options)

  add_server_routes: ->
    @load_server_plugin('./the_hapi_ger', {ger : @_ger})

  server_method: (method, args = []) ->
    d = bb.defer()
    @_server.methods[method].apply(@, args.concat((err, result) ->
      if (err)
        d.reject(err)
      else
        d.resolve(result)
    ))
    d.promise


  start: ->
    console.log "Starting Server on #{@options.port}"
    @start_server()

  stop: ->
    @stop_server()

  load_server_plugin: (plugin, options = {}) ->
    d = bb.defer()
    @_server.register({register: require(plugin), options: options}, (err) ->
      if (err)
        d.reject(err)
      else
        d.resolve()
    )
    d.promise

  start_server: ->
    d = bb.defer()
    @_server.start( =>
      d.resolve(@)
    )
    d.promise

  stop_server: ->
    d = bb.defer()
    @_server.stop( ->
      d.resolve()
    )
    d.promise



module.exports = HapiGER