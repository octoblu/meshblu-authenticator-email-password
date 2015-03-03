class ForgotPasswordModel
  constructor : (uuid, mailgunKey, dependencies) ->
    @uuid = uuid;
    @db = dependencies?.db
    @uuidGenerator = dependencies?.uuidGenerator || require 'node-uuid'
    Mailgun = dependencies?.Mailgun || require('mailgun').Mailgun
    @mailgun = new Mailgun mailgunKey
  forgot :(email, callback=->) =>
    @db.findOne "#{@uuid}.email" : email, (error, device) =>
      return callback new Error('Device not found for email address') if error? or !device
      resetUUID = @uuidGenerator.v4()
      @mailgun.sendText(
        'no-reply@octoblu.com'
        email,
        'Reset Password'
        "You recently made a request to reset your password, click <a href=\"https://email-password.octoblu.com/reset/#{resetUUID}\">here</a> to reset your password. If you didn't make this request please ignore this e-mail"
      )

module.exports = ForgotPasswordModel
