bb = require 'bluebird'
_ = require "underscore"

Joi = require 'joi'
Boom = require 'boom'

# GER
g = require 'ger'

GER = g.GER

Utils = require './utils'

namespace_schema = Joi.string().regex(/^[a-zA-Z][a-zA-Z0-9_]*$/)

namespace_request_schema = Joi.object().keys({
  namespace: namespace_schema.required()
})

configuration_schema = Joi.object().keys({
  actions:                       Joi.object()
  minimum_history_required:      Joi.number().integer().min(0)
  neighbourhood_search_size:     Joi.number().integer().min(1).max(250)
  similarity_search_size:        Joi.number().integer().min(1).max(250)
  neighbourhood_size:            Joi.number().integer().min(1).max(250)
  recommendations_per_neighbour: Joi.number().integer().min(1).max(250)
  filter_previous_actions:       Joi.array().items(Joi.string())
  event_decay_rate:              Joi.number().min(1).max(10)
  time_until_expiry:             Joi.number().integer().min(0).max(2678400) #seconds in a month
  current_datetime:              Joi.date().iso()
  post_process_with:             Joi.array()
})

recommendation_request_schema = Joi.object().keys({
  count: Joi.number().integer().min(1).max(200)
  person: Joi.string()
  thing:  Joi.string()
  namespace: namespace_schema.required()
  configuration: configuration_schema
}).xor('person', 'thing')

event_schema = Joi.object().keys({
  namespace: namespace_schema.required()
  person: Joi.string().required()
  action: Joi.string().required()
  thing: Joi.string().required()
  created_at: Joi.date().iso()
  expires_at: Joi.date().iso()
  recommendable: Joi.boolean()
})

events_request_schema = Joi.object().keys({
  events: Joi.array().items(event_schema).required()
})

get_events_request_schema = event_schema = Joi.object().keys({
  namespace: namespace_schema.required()
  person: Joi.string()
  action: Joi.string()
  thing: Joi.string()
})

GERAPI =
  register: (plugin, options, next) ->
    ger = options.ger
    default_configuration = options.default_configuration || {}

    ########### NAMESPACE RESOURCE ################
    plugin.route(
      method: 'GET',
      path: '/namespaces',
      handler: (request, reply) =>
        ger.list_namespaces()
        .then( (namespaces) ->
          reply({namespaces: namespaces})
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    plugin.route(
      method: 'DELETE',
      path: '/namespaces/{namespace}',
      handler: (request, reply) =>
        namespace = request.params.namespace
        ger.destroy_namespace(namespace)
        .then( ->
          reply({namespace: namespace})
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    plugin.route(
      method: 'POST',
      path: '/namespaces',
      config:
        payload:
          parse: true
          override: 'application/json'
        validate:
          payload: namespace_request_schema

      handler: (request, reply) =>
        namespace = request.payload.namespace
        ger.initialize_namespace(namespace)
        .then( ->
          reply({namespace: namespace})
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    ########### EVENTS RESOURCE ################

    #POST create event
    plugin.route(
      method: 'POST',
      path: '/events',
      config:
        payload:
          parse: true
          override: 'application/json'
        validate:
          payload: events_request_schema
      handler: (request, reply) =>
        ger.events(request.payload.events)
        .then( (event) ->
          reply(request.payload)
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    #GET event information
    plugin.route(
      method: 'GET',
      path: '/events',
      config:
        validate:
          query: get_events_request_schema

      handler: (request, reply) =>
        query = {
          person: request.params.person,
          action: request.params.action,
          thing: request.params.thing
        }
        ger.find_events(request.params.namespace, query)
        .then( (events) ->
          reply({"_data": events})
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )


    ########### RECOMMENDATIONS RESOURCE ################
    #POST recommendations
    plugin.route(
      method: 'POST',
      path: '/recommendations',
      config:
        payload:
          parse: true
          override: 'application/json'
        validate:
          payload: recommendation_request_schema
      handler: (request, reply) =>
        #TODO if (thing,action) shows up, then return things recommendations

        person = request.payload.person
        thing = request.payload.thing
        namespace = request.payload.namespace
        configuration = _.defaults(request.payload.configuration, default_configuration)

        if thing
          promise = ger.recommendations_for_thing(namespace, thing, configuration)
        else
          promise = ger.recommendations_for_person(namespace, person, configuration)

        promise.then( (recommendations) ->
          reply(recommendations)
        )
        .catch((err) -> Utils.handle_error(request, err, reply))
    )

    #MAINTENANCE ROUTES
    plugin.route(
      method: 'POST',
      path: '/compact',
      config:
        payload:
          parse: true
          override: 'application/json'
        validate:
          payload: namespace_request_schema

      handler: (request, reply) =>
        ger.estimate_event_count()
        .then( (init_count) ->
          bb.all( [init_count, ger.compact(request.payload.namespace)] )
        )
        .spread((init_count) ->
          bb.all( [ init_count, ger.estimate_event_count()] )
        )
        .spread((init_count, end_count) ->
          reply({ init_count: init_count, end_count: end_count, compression: "#{(1 - (end_count/init_count)) * 100}%" })
        )
        .catch((err) -> Utils.handle_error(request, err, reply) )
    )

    next()


GERAPI.register.attributes =
  name: 'the_hapi_ger'
  version: '0.0.2'

module.exports = GERAPI