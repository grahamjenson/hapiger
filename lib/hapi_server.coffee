#Setup the environment variables
environment = require '../config/environment'

#PROMISES LIBRARY
bb = require 'bluebird'

# HAPI STACK
Hapi = require 'hapi'
Joi = require 'joi'

# GER
g = require 'ger'
knex = g.knex # postgres client
r = g.r #rethink client

#ESMs
PsqlESM = g.PsqlESM
MemESM = g.MemESM
RethinkDBESM = g.RethinkDBESM

Utils = {}

Utils.handle_error = (logger, err, reply) ->
  if err.isBoom
    logger.log(['error'], err)
    reply(err)
  else
    console.log "Unhandled Error", err, err.stack
    logger.log(['error'], {error: "#{err}", stack: err.stack})
    reply({error: "An unexpected error occurred"}).code(500)


class HapiGER

  initialize: () ->
    bb.try( => @init_server())
    .then( => @setup_server())
    .then( => @add_server_methods())
    .then( => @add_server_routes())

  init_server: (esm = 'mem') ->
    #SETUP SERVER
    @_server = new Hapi.Server()
    @_server.connection({ port: process.env.PORT });
    @_esm = MemESM
    @info = @_server.info
    (new @_esm('default')).initialize() #add the default namespace
  
  create_namespace: (namespace) ->
    (new @_esm(namespace)).initialize()

  destroy_namespace: (namespace) ->
    (new @_esm(namespace)).destroy()

  setup_server: ->
    @load_server_plugin('good', environment.logging_options)

  add_server_routes: ->
    @load_server_plugin('./the_hapi_ger', {ESM : @_esm, ESM_OPTIONS : {}})
    
  add_server_methods: ->


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


#AMD
if (typeof define != 'undefined' && define.amd)
  define([], -> return HapiGER)
else if (typeof module != 'undefined' && module.exports)
  module.exports = HapiGER;