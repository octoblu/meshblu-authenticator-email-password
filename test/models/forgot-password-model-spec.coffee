ForgotPasswordModel = require '../../app/models/forgot-password-model'
_ = require 'lodash'

describe 'ForgotPasswordModel', ->
  beforeEach ->
    @meshbluHttp =
      devices: sinon.stub()
      update: sinon.stub().yields null
      sign: sinon.stub()
      verify: sinon.stub().returns true

    @Mailgun = sinon.spy()
    @Mailgun.prototype.sendHtml = sinon.spy()
    @uuidGenerator = {
      v4: sinon.stub()
    }
    @bcrypt = { hash: sinon.stub().yields( null, 'random-hash'), compareSync: sinon.spy() }
    @dependencies = Mailgun : @Mailgun, uuidGenerator: @uuidGenerator, bcrypt: @bcrypt

    @sut = new ForgotPasswordModel {uuid: 'U1', mailgunKey: 'mailgun_key', mailgunDomain: 'mailgun_domain', passwordResetUrl: 'https://email-password.octoblu.com', @meshbluHttp}, @dependencies

  describe 'constructor', ->
    it 'should instantiate a ForgotPasswordModel', ->
      expect(@sut).to.exist

    it 'should create a new mailgun', ->
      expect(@Mailgun).to.have.been.calledWithNew
      expect(@Mailgun).to.have.been.calledWith('mailgun_key')

    it 'should have a function called forgot', ->
      expect(@sut.forgot).to.exist

  describe '->forgot', ->
    describe 'when called with a@octoblu.com', ->
      beforeEach ->
        @sut.forgot 'a@octoblu.com'

      it 'should query meshblumeshbluHttp to find devices with that email', ->
        expect(@meshbluHttp.devices).to.have.been.calledWith 'U1.id' : 'a@octoblu.com'

    describe 'when called with a different email address', ->
     beforeEach ->
        @sut.forgot 'k@octoblu.com'

      it 'should query meshblumeshbluHttp to find devices with that email', ->
        expect(@meshbluHttp.devices).to.have.been.calledWith 'U1.id' : 'k@octoblu.com'

    describe 'when called with cAtS@octoblu.com', ->
      beforeEach ->
        @sut.forgot 'cAtS@octoblu.com'

      it 'should make the email case insensitive', ->
        expect(@meshbluHttp.devices).to.have.been.calledWith 'U1.id' : 'cats@octoblu.com'

    describe 'when sut is instantiated with a different uuid and forgot is called', ->
      beforeEach ->
        @sut = new ForgotPasswordModel {uuid: 'R2D2', mailgunKey: 'mailgun_key', mailgunDomain: 'mailgun_domain', passwordResetUrl: 'https://email-password.octoblu.com', @meshbluHttp}, @dependencies
        @sut.forgot 'dan@dan.com'

      it 'should call meshbluHttp.devices with that new uuid', ->
        expect(@meshbluHttp.devices).to.have.been.calledWith 'R2D2.id' : 'dan@dan.com'

    describe "when a device with the email address isn't found", ->
      beforeEach ->
        @meshbluHttp.devices.yields(null, [])
        @sut.forgot 'gza@wutang.com', (@error) =>

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when a device is found', ->
      beforeEach ->
        @meshbluHttp.devices.yields null,  [uuid: 'D1', U1: {}]
        @sut.mailgun = sendHtml: sinon.stub()
        @uuidGenerator.v4.returns '1'

        @sut.forgot 'chopped@bits.com'

      it 'should call Mailgun.sendHtml with From, To, Subject and the result of the email template in the body', ->
        expect(@sut.mailgun.sendHtml).to.have.been.calledWith(
          'no-reply@login-email.octoblu.com'
          'chopped@bits.com'
          'Reset Password'
          'You recently made a request to reset your password, click <a href="https://email-password.octoblu.com/reset?token=1&device=D1&email=chopped%40bits.com">here</a> to reset your password. If you didn\'t make this request please ignore this e-mail'
        )


    describe 'when a device is found with a different UUID', ->
      beforeEach (done)->
        @meshbluHttp.devices.yields null, [{ uuid: 'EriksDevice', U1: {} }]
        @sut.mailgun = sendHtml: sinon.stub().yields(null, true)
        @uuidGenerator.v4.returns 'c'

        @sut.forgot 'timber@waffle-iron.com', (@error, @response) => done()

      it 'should call Mailgun.sendHtml', ->
        expect(@sut.mailgun.sendHtml).to.have.been.called

      it 'should call Mailgun.sendHtml with From, To, Subject and the result of the email template in the body', ->
        expect(@sut.mailgun.sendHtml).to.have.been.calledWith(
          'no-reply@login-email.octoblu.com'
          'timber@waffle-iron.com'
          'Reset Password'
          'You recently made a request to reset your password, click <a href="https://email-password.octoblu.com/reset?token=c&device=EriksDevice&email=timber%40waffle-iron.com">here</a> to reset your password. If you didn\'t make this request please ignore this e-mail'
        )

    describe 'when the device is found and a reset UUID is generated', ->
      beforeEach ->
        @meshbluHttp.devices.yields null, [{ uuid : 'k', U1: { id: 'biofuel@used.com', secret: 'pancakes' } }]
        @meshbluHttp.update = sinon.stub()
        @sut.mailgun = sendHtml: sinon.stub()
        @meshbluHttp.sign.returns 'hello!'
        @uuidGenerator.v4.returns 'c'
        @bcrypt.hash.yields null, 'hash-of-c'
        @sut.forgot 'timber@waffle-iron.com'

      it 'should call bcrypt.hash with the generated uuid and the uuid of the device', ->
        expect(@bcrypt.hash).to.have.been.calledWith 'ck'


      it 'should update the device record with the reset UUID', ->
        expect(@meshbluHttp.update).to.have.been.calledWith(
          'k'
          {
            uuid : 'k'
            U1:
              id: 'biofuel@used.com'
              secret: 'pancakes'
              reset: 'hash-of-c'
              signature: 'hello!'
          }
        )

    describe 'when the device is found and a different reset UUID is generated', ->
      beforeEach ->
        @meshbluHttp.devices.yields null, [{ uuid : 'l', U1: { id: 'biofuel@used.com', secret: 'pancakes' } }]
        @meshbluHttp.update = sinon.stub()
        @sut.mailgun = sendHtml: sinon.stub()
        @meshbluHttp.sign.returns 'hello!'
        @uuidGenerator.v4.returns 's'
        @sut.forgot 'timber@waffle-iron.com'

      it 'should call bcrypt.hash with the generated uuid and the uuid of the device', ->
        expect(@bcrypt.hash).to.have.been.calledWith 'sl'

    describe 'when the device is found and a reset UUID is generated', ->
      beforeEach ->
        @meshbluHttp.devices.yields null, [{ uuid : 'l', U1: { id: 'slow.turning@windmill.com', secret: 'waffles' } }]
        @meshbluHttp.update = sinon.stub()
        @sut.mailgun = sendHtml: sinon.stub()
        @meshbluHttp.sign.returns 'axed!'
        @bcrypt.hash.yields null, 'hash-of-d'
        @uuidGenerator.v4.returns 'd'

        @sut.forgot 'timber@waffle-iron.com'

      it 'should update the device record with the reset UUID', ->
        expect(@meshbluHttp.update).to.have.been.calledWith(
          "l"
          {
            uuid : 'l'
            U1:
              id: 'slow.turning@windmill.com'
              secret: 'waffles'
              reset: 'hash-of-d'
              signature: 'axed!'
          }
        )

    describe 'when mailgun.sendHtml yields an error', ->
      beforeEach ->
        @meshbluHttp.devices.yields null, [{ uuid : 'l', U1: { id: 'slow.turning@windmill.com', secret: 'waffles' } }]
        @sut.mailgun = sendHtml: sinon.stub().yields(new Error('Something terrible happened'))

        @meshbluHttp.sign.returns 'axed!'
        @uuidGenerator.v4.returns 'd'

        @sut.forgot 'timber@waffle-iron.com', (@error)=>

      it 'should call the callback with the error', ->
        expect(@error.message).to.equal('Something terrible happened')

  describe '->reset', ->
    it 'should exist', ->
      expect(@sut.reset).to.exist

    describe 'when called with a uuid', ->
      beforeEach ->
        @sut.findSigned = sinon.stub()
        @sut.reset('Pilgrim')

      it 'should call findSigned with that uuid', ->
        expect(@sut.findSigned).to.have.been.calledWith uuid: 'Pilgrim'

    describe 'when called with a uuid', ->
      beforeEach ->
        @sut.findSigned = sinon.stub()
        @sut.reset('Monk')

      it 'should call findSigned with some other uuid', ->
        expect(@sut.findSigned).to.have.been.calledWith uuid: 'Monk'


    describe 'when findSigned yields some devices whose hashes don\'t match', ->
      beforeEach ->
        @sut.findSigned = sinon.stub().yields null, {uuid: 'Tuck', U1: reset: 'Piglet'}
        @sut.reset 'Tuck', 'Friar', 'password', (@error) =>

      it 'should call the callback with an error', ->
        expect(@error).to.exist

      it 'should call brypt.compareSync with the uuid and token', ->
        expect(@bcrypt.compareSync).to.have.been.calledWith 'FriarTuck', 'Piglet'

    describe 'when findSigned yields some other devices whose hashes don\'t match', ->
      beforeEach ->
        @sut.findSigned = sinon.stub().yields null, {uuid: 'Drew', U1: reset: 'Detective'}
        @sut.reset 'Drew', 'Nancy'

      it 'should call brypt.compareSync with the uuid and token', ->
        expect(@bcrypt.compareSync).to.have.been.calledWith 'NancyDrew', 'Detective'

    describe 'when sut is constructed with a different uuid and reset is called', ->
      beforeEach ->
        @sut = new ForgotPasswordModel {uuid: 'Lifehouse', mailgunKey: 'mailgun_key', mailgunDomain: 'mailgun_domain', passwordResetUrl: 'https://email-password.octoblu.com', @meshbluHttp}, @dependencies
        @sut.findSigned = sinon.stub().yields null, {uuid: 'Hood', Lifehouse: reset: 'LilJon'}
        @sut.reset 'Hood', 'Robin'

       it 'should call brypt.compareSync with the uuid and token', ->
        expect(@bcrypt.compareSync).to.have.been.calledWith 'RobinHood', 'LilJon'

    describe 'when no devices are returned', ->
      beforeEach ->
        @sut = new ForgotPasswordModel {uuid: 'Lifehouse', mailgunKey: 'mailgun_key', mailgunDomain: 'mailgun_domain', passwordResetUrl: 'https://email-password.octoblu.com', @meshbluHttp}, @dependencies
        @sut.findSigned = sinon.stub().yields null, null
        @sut.reset 'Hood', 'Robin', 'password', (@error) =>

       it 'should call the callback with an error', ->
        expect(@error).to.exist

    describe 'when the token is verified', ->
      beforeEach ->
        @sut.findSigned = sinon.stub().yields null, {uuid: 'Bunyan', U1: reset: 'Ox'}
        @bcrypt.compareSync = sinon.stub().returns true
        @sut.reset 'Bunyan', 'Paul', 'knock-knock'

      it 'should hash the new password with the uuid of the authenticator', ->
          expect(@bcrypt.hash).to.have.been.calledWith 'knock-knockBunyan'

    describe 'when the token is verified', ->
      beforeEach ->
        @device = uuid: 'Typhoid', U1: reset: 'Chef'
        @sut.findSigned = sinon.stub().yields null, @device
        @bcrypt.compareSync = sinon.stub().returns true
        @bcrypt.hash = sinon.stub().yields null, 'islandLife'
        @meshbluHttp.sign = sinon.stub().returns 'veryTasty'
        @sut.reset 'Typhoid', 'Mary', 'soupy'

      it 'should hash the new password with the uuid of the authenticator', ->
        expect(@bcrypt.hash).to.have.been.calledWith 'soupyTyphoid'

      it 'should update the database with new properties', ->
        updateDevice =
          uuid: 'Typhoid'
          U1:
            secret: 'islandLife'
            signature: 'veryTasty'
        expect(@meshbluHttp.update).to.have.been.calledWith 'Typhoid', updateDevice

    describe 'when the token is verified', ->
      beforeEach ->
        @sut.findSigned = sinon.stub().yields(null, uuid: 'Foot', U1: reset: 'Hair')
        @bcrypt.compareSync = sinon.stub().returns true
        @bcrypt.hash = sinon.stub().yields null, 'forestLife'
        @meshbluHttp.sign = sinon.stub().returns 'aliens'
        @sut.reset 'Foot', 'Big', 'Rawr'

      it 'should update the database with new properties', ->
        updateDevice =
          uuid: 'Foot'
          U1:
            secret: 'forestLife'
            signature: 'aliens'
        expect(@meshbluHttp.update).to.have.been.calledWith 'Foot', updateDevice
