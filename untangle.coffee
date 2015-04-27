async = require 'async'
_     = require 'underscore'

cont = (failPath, prereq) ->
  (happyPath) ->
    async.apply prereq, failPath, happyPath

untangle =
  cont : (failPath) ->
    cont failPath, (failPath, happyPath, err, results...) ->
      if err? and err != false
        failPath(err)
      else
        happyPath(results...)

  dont : (failPath) ->
    untangle.cont failPath, (failPath, happyPath, err, results...) ->
      if err? and err != false
        happyPath(err)
      else
        failPath(results...)

  contin : (fn) -> do (fn) ->
    (args...) ->
      cb =  args.pop()
      cont = untangle.cont cb
      ret = async.apply cb, null
      fn cont, ret, args...

module.exports = (fn) ->
  do (fn) ->
    (args...) ->
      cb =  args.pop()
      prom =
        CONT : untangle.cont cb
        RET  : async.apply cb, null
        DONT : untangle.dont cb
        ERR  : cb
        PASS : cb
        ASSERTNULL: (nullval, msg) -> if not nullval? then cb msg
      fn.apply prom, args
