request = require 'request'

class Mailgun
  constructor: (@apiKey, @domain) ->
    @baseUrl = "https://api.mailgun.net/v2/#{@domain}"

  sendHtml : (from, to, subject, body, callback=->) =>
    request.post(
      "#{@baseUrl}/messages"
      {
        auth: { user: 'api',  pass: @apiKey }
        form : { from: from, to: to, subject: subject, html: body }
      },
      callback
    )



module.exports = Mailgun
