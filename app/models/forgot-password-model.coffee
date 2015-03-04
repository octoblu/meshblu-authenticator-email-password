_ = require 'lodash'
class ForgotPasswordModel
  constructor : (uuid, mailgunKey, dependencies) ->
    @uuid = uuid;
    @db = dependencies?.db
    @uuidGenerator = dependencies?.uuidGenerator || require 'node-uuid'
    @meshblu = dependencies?.meshblu
    Mailgun = dependencies?.Mailgun || require('mailgun').Mailgun
    @mailgun = new Mailgun mailgunKey

  forgot :(email, callback=->) =>
    @db.findOne "#{@uuid}.email" : email, (error, device) =>
      return callback new Error('Device not found for email address') if error? or !device

      device[@uuid].reset = @uuidGenerator.v4()
      device[@uuid] = @sign device[@uuid]

      @db.update(
        {uuid : device.uuid}
        _.pick(device, @uuid)
      )

      @mailgun.sendText(
        'no-reply@octoblu.com'
        email
        'Reset Password'
        "You recently made a request to reset your password, click <a href=\"https://email-password.octoblu.com/reset/#{device[@uuid].reset}\">here</a> to reset your password. If you didn't make this request please ignore this e-mail"
      )

  sign : (data) =>
    delete data.signature
    data.signature = @meshblu.sign data
    data

module.exports = ForgotPasswordModel
