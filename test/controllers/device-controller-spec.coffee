DeviceController = require '../../app/controllers/device-controller'
_ = require 'lodash'

describe 'DeviceController', ->
  beforeEach ->
    @meshblu =
      find: sinon.stub()
      update: sinon.stub()
      generateAndStoreToken: sinon.stub()

    @meshbluJSON =
      uuid : 'efa781bb76904a888c31382d06d2e4c9'
      token: 'clean-master'

    @deviceAuthenticator =
      prepare: sinon.stub()

    @sut = new DeviceController @meshbluJSON, @meshblu, @deviceAuthenticator

  describe 'when the prepare function is called', ->
    describe 'when an uppercase email is passed in the request body', ->
      beforeEach ->
        @request =
          body:
            email: 'CATs@MeOW.CoM'
            password: 'cats are the best'

        @response =
          status: sinon.stub()
          send: sinon.stub()

        @sut.prepare @request, @response, ->

      it 'should do a case insensitive search for the device', ->
        expect(@request.email).to.equal 'cats@meow.com'
