MeshbluDb = require '../../app/models/meshblu-db'

describe 'MeshbluDb', ->
  beforeEach ->
    @meshblu = {}
    @meshblu.update = sinon.stub()
    @sut = new MeshbluDb @meshblu

  describe 'constructor', ->
    it 'should instantiate a MeshbluDb', ->
      expect(@sut).to.exist

  describe 'findOne', ->
    it 'should exist', ->
      expect(@sut.findOne).to.exist

    describe 'when called with a uuid', ->
      beforeEach ->
        @meshblu.whoami = sinon.stub()
        @pins = [
              {uuid: 'george', pin: 'gallaganifus' }
              {uuid: 'bill', pin: 'bob'}
            ]
        @uuid = @pins[1].uuid
        @uuid2 = @pins[0].uuid

      it 'should call meshblu.whoami', ->
        @sut.findOne uuid: @uuid
        expect(@meshblu.whoami).to.have.been.calledWith null

      describe 'and when whoami yields a device', ->
        beforeEach ->
          @callback = sinon.stub()
          @meshblu.whoami.yields({
            pins: @pins
          })

        it 'it should return a record that matches the findOne query', ->
          @sut.findOne {uuid: @uuid}, @callback
          expect(@callback).to.have.been.calledWith null, @pins[1]

        it 'it should return a record that matches the findOne query', ->
          @sut.findOne {uuid: @uuid2}, @callback
          expect(@callback).to.have.been.calledWith null, @pins[0]

  describe 'insert', ->
    it 'should exist',  ->
      expect(@sut.insert).to.exist

    describe 'when called', ->
      beforeEach ->
        @meshblu.whoami = sinon.stub()
        @pins = [
              {uuid: 'sarah', pin: 'ballin' }
              {uuid: 'george', pin: 'bushy'}
            ]
        @uuid = @pins[1].uuid
        @uuid2 = @pins[0].uuid

      it 'should call meshblu.whoami', ->
        @sut.insert @pins[0]
        expect(@meshblu.whoami).to.have.been.calledWith null

      describe 'and whoami yields a device without any pins', ->
        beforeEach ->
          @device = uuid: 1
          @meshblu.whoami.yields @device

        it 'should call meshblu.update with the device record with a "pins" key containing the pin', ->
          @sut.insert @pins[0]
          expect(@meshblu.update).to.have.been.calledWith { pins : [ @pins[0] ]}

        it 'should call meshblu.update with the device record with a "pins" key containing the pin', ->
          @sut.insert @pins[1]
          expect(@meshblu.update).to.have.been.calledWith { pins : [ @pins[1] ]}

      describe 'and whoami yields a different device without any pins', ->
        beforeEach ->
          @device = uuid: 2, alarm: false
          @meshblu.whoami.yields @device

        it 'should call meshblu.update with the device record with a "pins" key containing the pin', ->
          @sut.insert @pins[0]
          expect(@meshblu.update).to.have.been.calledWith { pins : [ @pins[0] ]}

      describe 'and whoami yields a device with pins', ->
        beforeEach ->
          @callback = sinon.stub()
          @rec1 = { uuid: 'wut', pin: 'mate' }
          @rec2 = { uuid: 'weiner', pin: 'snitzel' }
          @rec3 = { uuid: 'calico', pin: 'cat' }
          @device = uuid: 1, pins: [ @rec1, @rec2 ]
          @meshblu.whoami.yields @device

        it 'should call meshblu.update with the device record with a "pins" key containing the pin', ->
          @sut.insert @rec3
          expect(@meshblu.update.args[0][0].pins).to.have.same.deep.members([@rec1,@rec2,@rec3])

        describe 'when meshblu.update yields the device', ->
          beforeEach ->
            @meshblu.update.yields @device
          it 'should call it\'s callback the node way', ->
            @sut.insert @rec3, @callback
            expect(@callback).to.have.been.calledWith null, true

