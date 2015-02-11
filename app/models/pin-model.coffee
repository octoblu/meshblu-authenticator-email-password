class PinModel

  constructor: (dependencies) ->
    @db = dependencies?.db || {}
    @bcrypt = dependencies?.bcrypt || require 'bcrypt'

  save: (uuid, pin, callback=->)=>
    @bcrypt.hash pin, null, (error, hash)=>
      return callback(error) if error?
      @db.insert { uuid: uuid, pin: hash }, callback

  checkPin: (uuid, pin, callback=->)=>
    @db.findOne { uuid: uuid }, (error, res)=>
      return callback(error) if error?
      @bcrypt.compare pin, res.pin, callback


module.exports = PinModel
