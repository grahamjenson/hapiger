bb = require("bluebird")
request = bb.promisify(require("request"))

class Not200Error extends Error
  constructor: (@message) ->
    @name = "Not200Error"
    Error.captureStackTrace(this, Not200Error)

process_response = (res) ->
  response = res[0]
  body = res[1]
  json = JSON.parse(body)
  status = response.statusCode
  if status != 200
    e = new Not200Error()
    e.status = status
    e.body = json
    throw e

  [json, status]

class GERClient
  constructor : (@server_uri) ->

  ########### NAMESPACE routes ################

  destroy_namespace: (namespace) ->
    req = {
      method: "DELETE",
      uri: "#{@server_uri}/namespaces/#{namespace}"
    }
    request(req)
    .then(process_response)

  show_namespaces: ->
    req = {
      method: "GET",
      uri: "#{@server_uri}/namespaces"
    }
    request(req)
    .then(process_response)

  create_namespace: (namespace)->
    req = {
      method: "POST",
      body: JSON.stringify({namespace: namespace}),
      uri: "#{@server_uri}/namespaces"
    }
    request(req)
    .then(process_response)


  ########### EVENTS routes ################

  create_events: (events) ->
    req = {
      method: "POST",
      body: JSON.stringify({events: events}),
      uri: "#{@server_uri}/events"
    }
    request(req)
    .then(process_response)

  show_events: (namespace, person, action, thing) ->
    uri = "#{@server_uri}/events?"
    params = []
    params.push "namespace=#{namespace}"
    params.push "person=#{person}" if person
    params.push "action=#{action}" if action
    params.push "thing=#{thing}" if thing
    uri += params.join('&')
    req = { method: "GET", uri: uri}
    request(req)
    .then(process_response)


  ########### RECOMMENDATIONS routes ################

  create_recommendations: (rec_body) ->
    req = {
      method: "POST",
      uri: "#{@server_uri}/recommendations"
      body: JSON.stringify(rec_body)
    }

    request(req)
    .then(process_response)


  ########### Maintenance routes ################

  create_compact: (namespace) ->
    req = {
      method: "POST",
      body: JSON.stringify({namespace: namespace}),
      uri: "#{@server_uri}/compact"
    }
    request(req)
    .then(process_response)


GERClient.Not200Error = Not200Error

module.exports = GERClient;
