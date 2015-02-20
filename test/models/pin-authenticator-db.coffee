PinAuthenticatorDb = require '../../app/models/pin-authenticator-db'

describe 'PinAuthenticatorDb', ->
  beforeEach ->
    @meshblu = {}
    @meshblu.register = sinon.stub()
    @sut = new PinAuthenticatorDb @meshblu

  describe 'constructor', ->
    it 'should instantiate a PinAuthenticatorDb', ->
      expect(@sut).to.exist

  describe 'findOne', ->
    it 'should exist', ->
      expect(@sut.findOne).to.exist

    describe 'when called with a uuid', ->
      beforeEach ->
        @meshblu.devices = sinon.stub()
        @uuid = 'U1'
        @pin = '12345'

      it 'should call meshblu.devices', ->
        @sut.findOne uuid: @uuid
        expect(@meshblu.devices).to.have.been.calledWith uuid: @uuid

      describe 'and when devices yields a device', ->
        beforeEach ->
          @callback = sinon.stub()

        it 'it should return a record that matches the findOne query', ->
          @meshblu.devices.yields( devices: [{
            uuid: @uuid
            pin : @pin
          }])
          @sut.findOne {uuid: @uuid}, @callback
          expect(@callback).to.have.been.calledWith null, uuid: @uuid, pin: @pin

        it 'it should return a record that matches the findOne query', ->
          @uuid = '56789'
          @pin = '1337'
          @meshblu.devices.yields( devices: [{
            uuid: @uuid
            pin : @pin
          }])
          @sut.findOne {uuid: @uuid}, @callback
          expect(@callback).to.have.been.calledWith null, uuid: @uuid, pin: @pin

        describe 'when findOne is called with a query for a device that doesn\'t exist', ->
          beforeEach ->
            @meshblu.devices.yields devices: []
            @badUuid = 'Erik'
          it 'should yield an error', ->
            @sut.findOne {uuid: @badUuid}, @callback
            expect(@callback.args[0][0]).to.exist

  describe 'insert', ->
    it 'should exist',  ->
      expect(@sut.insert).to.exist

    describe 'when called', ->
      beforeEach ->
        @uuid = '84DA55'
        @pin = '80085'
        @meshblu.register = sinon.stub()
        @callback = sinon.stub()

      it 'should call meshblu.register', ->
        @sut.insert uuid: @uuid, pin: @pin
        expect(@meshblu.register).to.have.been.calledWith uuid: @uuid, pin: @pin

      describe 'and register yields a different device', ->
        beforeEach ->
          @device = uuid: 2, alarm: false
          @meshblu.register.yields @device

        it 'should call meshblu.register with the device record with a "pins" key containing the pin', ->
          @sut.insert @device
          expect(@meshblu.register).to.have.been.calledWith @device

        describe 'when meshblu.register yields the device', ->
          beforeEach ->
            @meshblu.register.yields @device
          it 'should call it\'s callback the node way', ->
            @sut.insert @rec3, @callback
            expect(@callback).to.have.been.calledWith null, @device
