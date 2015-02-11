PinController = require '../../app/controllers/pin-controller'

describe 'PinController', ->
  beforeEach ->
    @uuid = 'uuid1'
    @meshblu = {}
    @db = {}
    @dependencies = meshblu : @meshblu, db: @db
    @sut = new PinController @uuid, @dependencies

  describe 'constructor', ->
    it 'should instantiate a PinController', ->
      expect(@sut).to.exist

  describe 'create device', ->
    it 'should should exist', ->
      expect(@sut.createDevice).to.exist

    describe 'when called', ->
      beforeEach ->
        @meshblu.register = sinon.stub()
        @sut.createDevice()

      it 'should call register on meshblu', ->
        expect(@meshblu.register).to.have.been.called;

      it 'should add its uuid to a configure whitelist', ->
        expect(@meshblu.register.args[0][0].configureWhitelist).to.deep.equal [@uuid]

    describe 'when PinController was constructed with a different uuid and createDevice is called', ->
      beforeEach ->
        @uuid2 = 'uuid2'
        @sut = new PinController @uuid2, @dependencies
        @meshblu.register = sinon.stub()
        @sut.createDevice()

      it 'should call meshblu.register with the different uuid in the whitelist', ->
        expect(@meshblu.register.args[0][0].configureWhitelist).to.deep.equal [@uuid2]

  describe 'when register yields a new device', ->
    beforeEach ->
        @uuid = 'ferk'
        @pin = 'werms'
        @meshblu.register = sinon.stub().yields { uuid: @uuid }
        @db.save = sinon.stub()
        @sut.createDevice @pin

    it 'it should save the uuid and pin combination', ->
      expect(@db.save).to.have.been.calledWith { pin: @pin, uuid: @uuid }

  describe 'when register yields a different device', ->
    beforeEach ->
        @callback = sinon.stub()
        @uuid = 'fark'
        @pin = 'warms'
        @meshblu.register = sinon.stub().yields { uuid: @uuid }
        @db.save = sinon.stub()
        @sut.createDevice @pin, @callback

    it 'it should save that uuid and pin combination', ->
      expect(@db.save).to.have.been.calledWith { pin: @pin, uuid: @uuid }

    it 'should call the callback with the uuid', ->
      expect(@callback).to.have.been.calledWith null, @uuid

  describe 'when register yields a different different device', ->
    beforeEach ->
        @callback = sinon.stub()
        @uuid = 'fork'
        @pin = 'worms'
        @meshblu.register = sinon.stub().yields { uuid: @uuid }
        @db.save = sinon.stub()
        @sut.createDevice @pin, @callback

    it 'it should save that uuid and pin combination', ->
      expect(@db.save).to.have.been.calledWith { pin: @pin, uuid: @uuid }

    it 'should call the callback with the uuid', ->
      expect(@callback).to.have.been.calledWith null, @uuid


  describe 'getToken', ->
    beforeEach ->
      @db.checkPin = sinon.stub()

    it 'should exist', ->
      expect(@sut.getToken).to.exist

    describe 'when called', ->
      beforeEach ->
        @uuid = 'banana'
        @pin = 'split'
      it 'should call db.checkPin', ->
        @sut.getToken @uuid, @pin
        expect(@db.checkPin).to.have.been.calledWith @uuid, @pin

    describe 'when called with a different uuid & pin', ->
      beforeEach ->
        @uuid = 'ice cream'
        @pin = 'sundae'

      it 'should call db.checkPin with those params', ->
        @sut.getToken @uuid, @pin
        expect(@db.checkPin).to.have.been.calledWith @uuid, @pin

      describe 'when called with an invalid pin yields an error', ->
        beforeEach ->
          @db.checkPin.yields true
          @callback = sinon.stub()

        it 'should call the callback with an error', ->
          @sut.getToken @uuid, @pin, @callback
          expect(@callback.args[0][0]).to.exist 