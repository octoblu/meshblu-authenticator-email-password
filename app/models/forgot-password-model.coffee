_ = require 'lodash'
debug = require('debug')('meshblu-email-password-authenticator:forgot-password-model')
class ForgotPasswordModel
  constructor : (uuid, mailgunKey, @password_reset_url, dependencies) ->
    @uuid = uuid;
    @meshblu = dependencies?.meshblu
    @db = dependencies?.db

    @uuidGenerator = dependencies?.uuidGenerator || require 'node-uuid'
    Mailgun = dependencies?.Mailgun || require('mailgun').Mailgun
    @bcrypt = dependencies?.bcrypt || require 'bcrypt'

    @mailgun = new Mailgun mailgunKey

  forgot :(email, callback=->) =>
    debug "looks like #{email} forgot their password."
    @findSigned "#{@uuid}.id" : email, (error, device) =>
      return callback new Error('Device not found for email address') if error? or !device?
      debug "found device #{JSON.stringify(device)}"
      resetToken = @uuidGenerator.v4()

      @bcrypt.hash resetToken + device.uuid, 10, (hash)=>
        device[@uuid].reset = hash
        device[@uuid] = @sign device[@uuid]

        debug "updating device #{JSON.stringify(device)}"

        @db.update(device)

        @mailgun.sendText(
          'no-reply@octoblu.com'
          email
          'Reset Password'
          "You recently made a request to reset your password, click <a href=\"#{@password_reset_url}/reset?token=#{resetToken}&device=#{device.uuid}\">here</a> to reset your password. If you didn't make this request please ignore this e-mail",
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
      debug "found error: #{error?.message} devices: #{JSON.stringify(devices)}"
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
