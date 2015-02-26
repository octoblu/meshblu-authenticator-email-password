_ = require 'lodash'

class EmailPasswordModel
  constructor: (uuid, dependencies) ->
    @uuid = uuid;
    @db = dependencies?.db
    @bcrypt = dependencies?.bcrypt || require 'bcrypt'

  save: (email, password, attributes={}, callback=->)=>
    device = _.cloneDeep attributes
    device[@uuid] = {email: email}
    @db.insert device, (error, savedDevice) =>
      return callback error if error?
      @bcrypt.hash password, savedDevice.uuid, (error, hash) =>        
        return callback error if error?
        savedDevice.password = hash
        @db.update savedDevice, callback

  checkEmailPassword: (email, password='', callback=->)=>
    @db.findOne { '1234.email' : email }, (error, res)=>
      return callback error if error?
      @bcrypt.compare password, res.password, callback


module.exports = EmailPasswordModel
