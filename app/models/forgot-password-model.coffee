_ = require 'lodash'
SecureMeshbluDb = require './secure-meshblu-db'

class ForgotPasswordModel
  constructor : (uuid, mailgunKey, dependencies) ->
    @uuid = uuid;
    @uuidGenerator = dependencies?.uuidGenerator || require 'node-uuid'
    @meshblu = dependencies?.meshblu
    Mailgun = dependencies?.Mailgun || require('mailgun').Mailgun
    @mailgun = new Mailgun mailgunKey
    @db = dependencies?.db
    @bcrypt = dependencies?.bcrypt || require 'bcrypt'
    @findSigned = SecureMeshbluDb.findSigned

  forgot :(email, callback=->) =>
    @findSigned "#{@uuid}.email" : email, (error, devices=[]) =>
      return callback new Error('Device not found for email address') if error? or !devices.length
      device = _.first devices

      resetToken = @uuidGenerator.v4()
      device[@uuid] = @sign device[@uuid]

      @bcrypt.hash resetToken + device.uuid, 10, (hash)=>
        device[@uuid].reset = hash
        @db.update(
          {uuid : device.uuid}
          _.pick(device, @uuid)
        )

        @mailgun.sendText(
          'no-reply@octoblu.com'
          email
          'Reset Password'
          "You recently made a request to reset your password, click <a href=\"https://email-password.octoblu.com/reset?token=#{resetToken}&device=#{device.uuid}\">here</a> to reset your password. If you didn't make this request please ignore this e-mail",
          callback
        )

  reset : (uuid, token, password, callback=->) => 
    @findSigned uuid: uuid, (error, devices=[]) =>
      return callback new Error('Device not found') if error? or !devices.length
      device = _.first devices
      return callback new Error('Invalid Token') unless @bcrypt.compareSync(token + uuid, device[@uuid].reset)
      @bcrypt.hash password + uuid, 10, (hash) =>
        device[@uuid].reset = null
        @sign device[@uuid]        
        @db.update( {uuid: uuid}, _.pick( @uuid, device), callback)
        

  sign : (data) =>
    delete data.signature
    data.signature = @meshblu.sign data
    data

module.exports = ForgotPasswordModel
