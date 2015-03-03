ForgotPasswordModel = require '../../app/models/forgot-password-model'

describe 'ForgotPasswordModel', ->
  beforeEach ->
    @db = findOne: sinon.stub()
    @Mailgun = sinon.spy()
    @Mailgun.prototype.sendText = sinon.spy()
    @uuidGenerator = {
      v4: sinon.stub()
    }
    @dependencies = db: @db, Mailgun : @Mailgun, uuidGenerator: @uuidGenerator
    @sut = new ForgotPasswordModel 'U1', 'mailgun_key', @dependencies

  describe 'constructor', ->
    it 'should instantiate a ForgotPasswordModel', ->
      expect(@sut).to.exist

    it 'should create a new mailgun', ->
      expect(@Mailgun).to.have.been.calledWithNew
      expect(@Mailgun).to.have.been.calledWith('mailgun_key')

    it 'should have a function called forgot', ->
      expect(@sut.forgot).to.exist

  describe 'forgot', ->
    describe 'when called with a@octoblu.com', ->
      beforeEach ->
        @sut.forgot 'a@octoblu.com'
      it 'should query meshbludb to find devices with that email', ->
        expect(@db.findOne).to.have.been.calledWith 'U1.email' : 'a@octoblu.com'

    describe 'when called with a different email address', ->
     beforeEach ->
        @sut.forgot 'k@octoblu.com'
      it 'should query meshbludb to find devices with that email', ->
        expect(@db.findOne).to.have.been.calledWith 'U1.email' : 'k@octoblu.com'

    describe 'when sut is instantiated with a different uuid and forgot is called', ->
      beforeEach ->
        @sut = new ForgotPasswordModel 'R2D2', 'mailgun_key', @dependencies
        @sut.forgot 'dan@dan.com'

      it 'should call db.findOne with that new uuid', ->
        expect(@db.findOne).to.have.been.calledWith 'R2D2.email' : 'dan@dan.com'

    describe "when a device with the email address isn't found", ->
      beforeEach ->
        @db.findOne.yields(null, null)
        @sut.forgot 'gza@wutang.com', (@error) =>

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when a device is found', ->
      beforeEach ->
        @db.findOne.yields null,  uuid: 1
        @sut.mailgun = sendText: sinon.stub()
        @uuidGenerator.v4.returns '1'

        @sut.forgot 'chopped@bits.com'

      it 'should call Mailgun.sendText with From, To, Subject and the result of the email template in the body', ->
        expect(@sut.mailgun.sendText).to.have.been.calledWith(
          'no-reply@octoblu.com'
          'chopped@bits.com'
          'Reset Password'
          'You recently made a request to reset your password, click <a href="https://email-password.octoblu.com/reset/1">here</a> to reset your password. If you didn\'t make this request please ignore this e-mail'
        )


    describe 'when a device is found with a different UUID', ->
      beforeEach ->
        @db.findOne.yields null, {}
        @sut.mailgun = sendText: sinon.stub()
        @uuidGenerator.v4.returns 'c'

        @sut.forgot 'timber@waffle-iron.com'

      it 'should call Mailgun.sendText', ->
        expect(@sut.mailgun.sendText).to.have.been.called

      it 'should call Mailgun.sendText with From, To, Subject and the result of the email template in the body', ->
        expect(@sut.mailgun.sendText).to.have.been.calledWith(
          'no-reply@octoblu.com'
          'timber@waffle-iron.com'
          'Reset Password'
          'You recently made a request to reset your password, click <a href="https://email-password.octoblu.com/reset/c">here</a> to reset your password. If you didn\'t make this request please ignore this e-mail'
        )






