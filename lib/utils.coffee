Utils = {}

Utils.handle_error = (logger, err, reply) ->
  if err.isBoom
    logger.log(['error'], err)
    reply(err)
  else
    console.log "Unhandled Error", err, err.stack
    logger.log(['error'], {error: "#{err}", stack: err.stack})
    reply({error: "An unexpected error occurred"}).code(500)

Utils.server_method = (method, args = []) ->
  d = bb.defer()
  @_server.methods[method].apply(@, args.concat((err, result) ->
    if (err)
      d.reject(err)
    else
      d.resolve(result)
  ))
  d.promise
  
#AMD
if (typeof define != 'undefined' && define.amd)
  define([], -> return Utils)
#Node
else if (typeof module != 'undefined' && module.exports)
    module.exports = Utils;