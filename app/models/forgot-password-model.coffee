_ = require 'lodash'
debug = require('debug')('meshblu-email-password-authenticator:forgot-password-model')
url = require 'url'

class ForgotPasswordModel
  constructor : (uuid, mailgunKey, mailgunDomain, @passwordResetUrl, dependencies) ->
    @uuid = uuid;
    @meshblu = dependencies?.meshblu
    @db = dependencies?.db

    @uuidGenerator = dependencies?.uuidGenerator || require 'node-uuid'
    Mailgun = dependencies?.Mailgun || require('./mailgun')
    @bcrypt = dependencies?.bcrypt || require 'bcrypt'

    @mailgun = new Mailgun mailgunKey, mailgunDomain

  forgot :(email, callback=->) =>
    debug "looks like #{email} forgot their password."
    @findSigned "#{@uuid}.id" : email, (error, device) =>
      return callback new Error('Device not found for email address') if error? or !device?
      debug "found device #{JSON.stringify(device)}"
      resetToken = @uuidGenerator.v4()

      @bcrypt.hash resetToken + device.uuid, 10, (error, hash)=>
        device[@uuid].reset = hash
        device[@uuid] = @sign device[@uuid]

        debug "updating device #{JSON.stringify(device, null, 2)}"

        @db.update {uuid: device.uuid}, device, (error) =>
          debug "ERROR UPDATING DEVICE #{device.uuid}: #{error.message}" if error?
          return callback error if error?
          debug "updated device"

          uriParams = url.parse @passwordResetUrl + '/reset'
          uriParams.query ?= {}
          uriParams.query.token = resetToken
          uriParams.query.device = device.uuid
          uriParams.query.email = email
          uri = url.format uriParams

          body = "You recently made a request to reset your password, click <a href=\"#{uri}\">here</a> to reset your password. If you didn't make this request please ignore this e-mail"
          debug 'email:', body

          @mailgun.sendHtml(
            'no-reply@octoblu.com'
            email
            'Reset Password'
            body
            callback
          )

  reset : (uuid, token, password, callback=->) =>
    @findSigned uuid: uuid, (error, device) =>
      return callback new Error('Device not found') if error? or !device?
      return callback new Error('Invalid Token') unless @bcrypt.compareSync(token + uuid, device[@uuid].reset)

      debug password + uuid
      @bcrypt.hash password + uuid, 10, (error, hash) =>
        delete device[@uuid].reset
        device[@uuid].secret = hash
        device[@uuid] = @sign device[@uuid]

        debug 'updating device', device

        @db.update {uuid: device.uuid}, device, callback

  findSigned: (query, callback=->) =>
    @db.find query, (error, devices) =>
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
