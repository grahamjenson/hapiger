bb = require 'bluebird'

Joi = require 'joi'
Boom = require 'boom'

# GER
g = require 'ger'

GER = g.GER

Utils = require './utils'

GERAPI =
  register: (plugin, options, next) ->
    ger = options.ger

    get_namespace_ger = (name) ->
      ger.set_namespace(name)
      ger.namespace_exists()
      .then( (exists) ->
        throw Boom.notFound('namespace not found') if not exists
        #TODO it might be possible for namespace specific options here with set_options
        ger
      )

    ########### NAMESPACE RESOURCE ################
    plugin.route(
      method: 'GET',
      path: '/namespace/{namespace}',
      handler: (request, reply) =>
        namespace = request.params.namespace
        get_namespace_ger(namespace)
        .then( ->
          reply({namespace: namespace})
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    plugin.route(
      method: 'DELETE',
      path: '/namespace/{namespace}',
      handler: (request, reply) =>
        namespace = request.params.namespace
        ger.set_namespace(namespace)
        ger.destroy_namespace()
        .then( ->
          reply({namespace: namespace}) 
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    plugin.route(
      method: 'POST',
      path: '/namespace',
      config:
        payload:
          parse: true
          override: 'application/json'
        validate:
          payload: Joi.object().keys(
              namespace: Joi.any().required()
          )

      handler: (request, reply) =>
        namespace = request.payload.namespace
        ger.set_namespace(namespace)
        ger.initialize_namespace()
        .then( ->
          reply({namespace: namespace}) 
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    ########### EVENTS RESOURCE ################
    #POST create event
    plugin.route(
      method: 'POST',
      path: '/{namespace}/events',
      config:
        payload:
          parse: true
          override: 'application/json'
        validate:
          payload: Joi.object().keys(
              person: Joi.any().required()
              action: Joi.any().required()
              thing: Joi.any().required()             
          )

      handler: (request, reply) =>
        get_namespace_ger(request.params.namespace)
        .then( (ger) ->
          ger.event(request.payload.person, request.payload.action, request.payload.thing)                       
        )
        .then( (event) ->
            reply({event: event}) 
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    #GET event information
    plugin.route(
      method: 'GET',
      path: '/{namespace}/events',
      config:
        validate:
          query:
            person: Joi.any()
            action: Joi.any()
            thing: Joi.any()
      handler: (request, reply) =>
        get_namespace_ger(request.params.namespace)
        .then( (ger) ->
          ger.find_events(request.query.person, request.query.action, request.query.thing)
        )
        .then( (events) ->
          throw Boom.notFound('event not found') if events.length == 0
          reply({"_data": events})
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    #GET event information
    plugin.route(
      method: 'GET',
      path: '/{namespace}/events/stats',
      handler: (request, reply) =>
        get_namespace_ger(request.params.namespace)
        .then( (ger) ->
          ger.count_events()
        )
        .then( (count) ->
          reply({count: count}) 
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )


    #POST bootstrap, upload csv for
    plugin.route(
      method: 'POST',
      path: '/{namespace}/events/bootstrap',
      config:
        payload:
          maxBytes: 209715200
          output:'stream'
          parse: true

      handler: (request, reply) =>
        get_namespace_ger(request.params.namespace)
        .then( (ger) ->
          stream = request.payload["events"]
          ger.bootstrap(stream)
        )
        .then((added_count) ->
          reply({added_events: added_count})
        )
        .catch((err) -> Utils.handle_error(request, err, reply))
    )

    ########### ACTIONS RESOURCE ################

    #PUT update action
    plugin.route(
      method: 'POST',
      path: '/{namespace}/actions',
      config:
        payload:
          parse: true
          override: 'application/json'
        validate:
          payload: Joi.object().keys(
              name: Joi.any().required()
              weight: Joi.any().optional()            
          )
      handler: (request, reply) =>
        action = request.payload.name
        get_namespace_ger(request.params.namespace)
        .then( (ger) ->
          ger.action(action, request.payload.weight)
        )
        .then( (action_weight) ->
          reply({action: action_weight.action, weight: action_weight.weight}) 
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    #GET update action
    plugin.route(
      method: 'GET',
      path: '/{namespace}/actions/{name}',
      handler: (request, reply) =>
        action = request.params.name
        get_namespace_ger(request.params.namespace)
        .then( (ger) ->
          ger.get_action(action)
        )
        .then( (act) ->
          throw Boom.notFound('action not found') if not act
          reply(act)
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )


    ########### RECOMMENDATIONS RESOURCE ################
    #GET recommendations
    plugin.route(
      method: 'GET',
      path: '/{namespace}/recommendations',
      config:
        validate:
          query:
            person: Joi.any().required()
            action: Joi.any().required()

      handler: (request, reply) =>
        #TODO change type of recommendation based on parameters, e.g. for person action if they are included
        
        person = request.query.person
        action = request.query.action
        explain = !!request.query.explain

        get_namespace_ger(request.params.namespace)
        .then( (ger) ->
          ger.recommendations_for_person(person, action)
        )
        .then( (recommendations) ->
          reply(recommendations)
        )
        .catch((err) -> Utils.handle_error(request, err, reply))
    )

    #MAINTENANCE ROUTES
    plugin.route(
      method: 'POST',
      path: '/{namespace}/compact_async',
      handler: (request, reply) =>
        get_namespace_ger(request.params.namespace)
        .then( (ger) ->
          ger.compact_database().then( ->
            plugin.log(['log'], {message: "COMPACT COMPLETED FOR NS #{request.params.namespace}"}) 
          )
          reply({message: "Doing"})
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    plugin.route(
      method: 'POST',
      path: '/{namespace}/compact',
      handler: (request, reply) =>
        get_namespace_ger(request.params.namespace)
        .then( (ger) ->
          ger.estimate_event_count()
          .then( (init_count) ->
            bb.all( [init_count, ger.compact_database()] )
          )
          .spread((init_count) ->
            bb.all( [ init_count, ger.estimate_event_count()] )
          )
          .spread((init_count, end_count) ->
            reply({ init_count: init_count, end_count: end_count, compression: "#{(1 - (end_count/init_count)) * 100}%" }) 
          )
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    next()


GERAPI.register.attributes =
  name: 'the_hapi_ger'
  version: '0.0.1'

#AMD
if (typeof define != 'undefined' && define.amd)
  define([], -> return GERAPI)
#Node
else if (typeof module != 'undefined' && module.exports)
    module.exports = GERAPI;