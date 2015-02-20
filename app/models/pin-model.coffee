_ = require 'lodash'
class PinModel

  constructor: (dependencies) ->
    @db = dependencies?.db
    @bcrypt = dependencies?.bcrypt || require 'bcrypt'

  save: (pin, attributes, callback=->)=>
    @bcrypt.hash pin, 10, (error, hash)=>
      return callback(error) if error?
      @db.insert _.extend({pin: hash}, attributes), callback

  checkPin: (uuid, pin='', callback=->)=>
    @db.findOne { uuid: uuid }, (error, res)=>
      return callback(error) if error?
      @bcrypt.compare pin, res.pin, callback


module.exports = PinModel
