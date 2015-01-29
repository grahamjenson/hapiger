bb = require 'bluebird'

class NS
  constructor: (@name, @options = {}) ->

NS.find = (esm, name) ->
  #returns the object with GER options
  options = {}
  esm.exists(name)
  .then( (exists) ->
    return false if !exists
    return new NS(name, options)
  )

#AMD
if (typeof define != 'undefined' && define.amd)
  define([], -> return NS)
#Node
else if (typeof module != 'undefined' && module.exports)
    module.exports = NS;
