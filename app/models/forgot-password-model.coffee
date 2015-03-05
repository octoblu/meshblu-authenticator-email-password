_ = require 'lodash'

class ForgotPasswordModel
  constructor : (uuid, mailgunKey, dependencies) ->
    @uuid = uuid;
    @uuidGenerator = dependencies?.uuidGenerator || require 'node-uuid'
    @meshblu = dependencies?.meshblu
    Mailgun = dependencies?.Mailgun || require('mailgun').Mailgun
    @mailgun = new Mailgun mailgunKey
    @db = dependencies?.db
    @bcrypt = dependencies?.bcrypt || require 'bcrypt'

  forgot :(email, callback=->) =>
    @findSigned "#{@uuid}.email" : email, (error, device) =>
      return callback new Error('Device not found for email address') if error? or !device?

      resetToken = @uuidGenerator.v4()

      @bcrypt.hash resetToken + device.uuid, 10, (hash)=>
        device[@uuid].reset = hash
        device[@uuid] = @sign device[@uuid]

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
    @findSigned uuid: uuid, (error, device) =>
      return callback new Error('Device not found') if error? or !device?
      return callback new Error('Invalid Token') unless @bcrypt.compareSync(token + uuid, device[@uuid].reset)

      @bcrypt.hash password + uuid, 10, (hash) =>
        delete device[@uuid].reset
        device[@uuid].secret = hash
        device[@uuid] = @sign device[@uuid]

        query = _.pick device, 'uuid', @uuid

        @db.update query, callback

  findSigned: (query, callback=->) ->
    @db.find query , (error, devices)=>
      return callback error if error?
      device = _.find devices, (device) =>
        try
          @meshblu.verify(_.omit( device[@uuid], 'signature' ), device[@uuid]?.signature)

      callback null, device


  sign : (data) =>
    data = _.cloneDeep data
    data.signature = @meshblu.sign _.omit(data, 'signature')
    data

module.exports = ForgotPasswordModel
