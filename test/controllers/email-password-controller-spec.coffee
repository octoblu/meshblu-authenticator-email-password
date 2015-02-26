EmailPasswordController = require '../../app/controllers/email-password-controller'

describe 'EmailPasswordController', ->
  beforeEach ->
    @uuid = 'uuid1'
    @meshblu = {}
    @emailPasswordModel = {}
    @dependencies = meshblu : @meshblu, emailPasswordModel: @emailPasswordModel
    @sut = new EmailPasswordController @uuid, @dependencies

  describe 'constructor', ->
    it 'should instantiate a EmailPasswordController', ->
      expect(@sut).to.exist

  describe '->createDevice', ->
    describe 'when EmailPasswordController was constructed with a uuid', ->
      beforeEach ->
        @sut = new EmailPasswordController 'uuid2', @dependencies
        @emailPasswordModel.save = sinon.stub()

      describe 'when createDevice is called with some device properties', ->
        beforeEach ->
          @sut.createDevice 'email', 'password', foo: 'bar'

        it 'should call meshblu.register device properties merged in', ->
          expect(@emailPasswordModel.save).to.have.been.calledWith 'email', 'password', configureWhitelist: ['uuid2'], foo: 'bar'

      describe 'when createDevice is called with a configureWhitelist', ->
        beforeEach ->
          @sut.createDevice 'roasted', 'wow', configureWhitelist: ['73d0f6da-4b5d-4880-9f78-f48ed1b51704']

        it 'should call meshblu.register device properties merged in', ->
          expect(@emailPasswordModel.save).to.have.been.calledWith 'roasted', 'wow', configureWhitelist: ['73d0f6da-4b5d-4880-9f78-f48ed1b51704', 'uuid2']

  describe 'when register yields a new device', ->
    beforeEach ->
      @emailPasswordModel.save       = sinon.stub().yields null, { uuid: @uuid }
      @meshblu.generateAndStoreToken = sinon.stub().yields {token: 'tick-off'}
      @sut.createDevice 'rolling@pin.com', 'never', {}

    it 'it should save the uuid and pin combination', ->
      expect(@emailPasswordModel.save).to.have.been.calledWith 'rolling@pin.com', 'never', { configureWhitelist: [ 'uuid1'] }

  describe 'when register yields a different device and save yields', ->
    beforeEach (done) ->
      @callback = sinon.stub()
      @emailPasswordModel.save = sinon.stub().yields null, { uuid: 'fark' }
      @meshblu.generateAndStoreToken = sinon.stub().yields { token: 'batter up' }
      @sut.createDevice 'waffle', 'iron', null, (error, @result) => done()

    it 'it should save that uuid and pin combination', ->
      expect(@emailPasswordModel.save).to.have.been.calledWith 'waffle', 'iron', { configureWhitelist: [ 'uuid1'] }

    it 'should yield the uuid', ->
      expect(@result).to.deep.equal { uuid: 'fark', token: 'batter up' }

  describe 'when register yields a different different device', ->
    beforeEach ->
      @callback = sinon.stub()
      @emailPasswordModel.save = sinon.stub().yields null, { uuid: 'fokls' }
      @meshblu.generateAndStoreToken = sinon.stub().yields { token: 'cats'}
      @sut.createDevice 'used', 'biofuel', null, @callback

    it 'it should save that email and password combination', ->
      expect(@emailPasswordModel.save).to.have.been.calledWith 'used', 'biofuel', { configureWhitelist: [ 'uuid1'] }

    it 'should call the callback with the uuid', ->
      expect(@callback).to.have.been.calledWith null, { uuid: 'fokls', token: 'cats' }


  describe 'getToken', ->
    beforeEach ->
      @emailPasswordModel.checkEmailPassword = sinon.stub()

    it 'should exist', ->
      expect(@sut.getToken).to.exist

    describe 'when called', ->
      beforeEach ->
        @sut.getToken 'Timber', 'Wood'

      it 'should call emailPasswordModel.checkEmailPassword', ->
        expect(@emailPasswordModel.checkEmailPassword).to.have.been.calledWith 'Timber', 'Wood'

    describe 'when called and checkEmailPassword yields true', ->
      beforeEach ->
        @emailPasswordModel.checkEmailPassword.yields null, true
        @meshblu.generateAndStoreToken = sinon.stub()
        @sut.getToken 'Tray', 'Table'

      it 'it should get a session token from meshblu', ->
        expect(@meshblu.generateAndStoreToken).to.have.been.calledWith uuid: 'Tray'

    describe 'when called with a different email & password', ->
      beforeEach ->       
        @sut.getToken 'Wrong', 'Position'

      it 'should call emailPasswordModel.checkEmailPassword with those params', ->
        expect(@emailPasswordModel.checkEmailPassword).to.have.been.calledWith 'Wrong', 'Position'

    describe 'when called and checkEmailPassword yields an error', ->
      beforeEach ->
        @emailPasswordModel.checkEmailPassword.yields true
        @callback = sinon.stub()

      it 'should call the callback with an error', ->
        @sut.getToken 'Impatient', 'Vulture', @callback
        expect(@callback.args[0][0]).to.exist

    describe 'when called and checkEmailPassword yields false', ->
      beforeEach ->
        @emailPasswordModel.checkEmailPassword.yields null, false
        @callback = sinon.stub()

      it 'should call the callback with an error', ->
        @sut.getToken @uuid, @password, @callback
        expect(@callback.args[0][0]).to.exist

    describe 'when called and the checkEmailPassword yields true', ->
      beforeEach ->
        @emailPasswordModel.checkEmailPassword.yields null, true
        @meshblu.generateAndStoreToken = sinon.stub()

      it 'it should get a session token from meshblu', ->
        @sut.getToken @uuid, @password
        expect(@meshblu.generateAndStoreToken).to.have.been.calledWith uuid: @uuid

    describe 'when called, checkEmailPassword yields true, and generateAndStoreToken yields "bombastic"', ->
      beforeEach (done) ->
        @emailPasswordModel.checkEmailPassword.yields null, true
        @meshblu.generateAndStoreToken = sinon.stub().yields token: 'bombastic'
        @sut.getToken @uuid, @password, (@error, @result) => done()

      it 'should call the callback with the error', ->
        expect(@result.token).to.equal 'bombastic'

