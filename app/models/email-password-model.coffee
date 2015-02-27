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
        savedDevice[@uuid].password = hash
        @db.update savedDevice, callback

  checkEmailPassword: (email, password='', callback=->)=>
    @db.find { "#{@uuid}.email" : email }, (error, devices=[])=>
      return callback error if error?      
      device = _.any devices, (device)=>        
        @bcrypt.compareSync password, device[@uuid].password      
      callback null, device


module.exports = EmailPasswordModel
