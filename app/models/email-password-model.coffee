_ = require 'lodash'
debug = require('debug')('meshblu-email-password:model')
validator = require 'validator'

class EmailPasswordModel
  constructor: (uuid, dependencies) ->
    @uuid = uuid;
    @db = dependencies?.db
    @bcrypt = dependencies?.bcrypt || require 'bcrypt'

  save: (email, password, attributes={}, callback=->)=>
    return callback new Error ('invalid email') unless validator.isEmail(email)

    device = _.cloneDeep attributes
    device[@uuid] = {email: email}
    @db.findOne "#{@uuid}.email": email, (error, foundDevice) =>
      return callback new Error('device already exists') if foundDevice?

      @db.insert device, (error, savedDevice) =>
        return callback error if error?
        @bcrypt.hash password, 10, (error, hash) =>        
          return callback error if error?
          savedDevice[@uuid].password = hash
          @db.update savedDevice, callback

  checkEmailPassword: (email, password='', callback=->)=>
    debug "Searching for #{@uuid}.email : #{email}"
    @db.find { "#{@uuid}.email" : email }, (error, devices=[])=>
      return callback error if error?      
      device = _.find devices, (device) =>
        @bcrypt.compareSync password, device[@uuid].password      
      callback null, device


module.exports = EmailPasswordModel
