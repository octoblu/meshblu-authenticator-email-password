_ = require 'lodash'
debug = require('debug')('meshblu-email-password:model')
validator = require 'validator'
SecureMeshbluDb = require './secure-meshblu-db'

class EmailPasswordModel
  constructor: (uuid, dependencies) ->
    @uuid = uuid
    @bcrypt = dependencies?.bcrypt || require 'bcrypt'
    @meshblu = dependencies?.meshblu
    @db = dependencies?.db
    @findSigned = SecureMeshbluDb.findSigned

  save: (email, password, attributes={}, callback=->) =>
    return callback new Error ('invalid email') unless validator.isEmail(email)

    device = _.cloneDeep attributes
    device[@uuid] = {email: email}
    @db.findOne "#{@uuid}.email": email, (error, foundDevice) =>
      return callback new Error('device already exists') if foundDevice?

      @db.insert device, (error, savedDevice) =>
        return callback error if error?
        @bcrypt.hash password + savedDevice.uuid, 10, (error, hash) =>
          return callback error if error?
          savedDevice[@uuid].password = hash
          savedDevice[@uuid].signature = @meshblu.sign savedDevice[@uuid]
          @db.update savedDevice, callback

  checkEmailPassword: (email, password='', callback=->)=>
    debug "Searching for #{@uuid}.email : #{email}"
    @findSigned { "#{@uuid}.email" : email }, (error, devices) =>
      return callback(error) if error?
      device = _.find devices, (device) =>
        @bcrypt.compareSync(password + device.uuid, device[@uuid]?.password)

      return callback(null, device)



module.exports = EmailPasswordModel
