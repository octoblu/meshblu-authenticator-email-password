_ = require 'lodash'

class PinModel
  constructor: (uuid, dependencies) ->
    @uuid = uuid;
    @db = dependencies?.db
    @bcrypt = dependencies?.bcrypt || require 'bcrypt'

  save: (pin, attributes, callback=->)=>
    @bcrypt.hash pin, 10, (error, hash)=>
      return callback(error) if error?
      device = _.clone attributes
      device[@uuid] = hash
      @db.insert device, callback

  checkPin: (uuid, pin='', callback=->)=>
    @db.findOne { uuid: uuid }, (error, res)=>
      return callback(error) if error?
      @bcrypt.compare pin, res.pin, callback


module.exports = PinModel
