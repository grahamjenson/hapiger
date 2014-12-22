bb = require 'bluebird'

class NS
  constructor: (@name, @options = {}) ->

NS.find = (name) ->
  #returns the object with GER options
  options = {}
  bb.try( => new NS(name, options))

#AMD
if (typeof define != 'undefined' && define.amd)
  define([], -> return NS)
#Node
else if (typeof module != 'undefined' && module.exports)
    module.exports = NS;
