EmailPasswordModel = require '../../app/models/email-password-model'

describe 'EmailPasswordModel', ->
  beforeEach ->
    @db = {}
    @bcrypt = {}
    @dependencies = db: @db, bcrypt: @bcrypt
    @sut = new EmailPasswordModel '1234', @dependencies

  describe 'constructor', ->
    describe 'when instantiated with a uuid', ->
      beforeEach ->
        @sut = new EmailPasswordModel '7f03f82a-e637-45cb-9b79-1b0d53edead4', @dependencies
      
      it 'should instantiate a EmailPasswordModel', ->
        expect(@sut).to.exist

    describe 'when instantiated with a different uuid', ->
      beforeEach ->
        @sut = new EmailPasswordModel '01a27f44-0063-4c1a-8fd3-336b2d193c0a', @dependencies

      describe 'when bcrypt.hash succeeds', ->
        beforeEach ->
          @callback = sinon.stub()
          @bcrypt.hash = sinon.stub().yields null, "But didn't it feel so right?"
          @db.insert = sinon.stub()

        it 'should call db.insert with an object that has UUID and hash and also the callback', ->
          @sut.save 'Things go wrong', {}, @callback
          expect(@db.insert).to.have.been.calledWith { '01a27f44-0063-4c1a-8fd3-336b2d193c0a': "But didn't it feel so right?" }, @callback

  describe '->checkEmailPassword', ->
    it 'should exist', ->
      expect(@sut.checkEmailPassword).to.exist

    describe 'when called with a uuid and pin', ->
      beforeEach ->
        @db.findOne = sinon.stub()
        @sut.checkEmailPassword 'moheeb@hmm.info', 'infosec'

      it 'should call db.findOne with that token', ->
        expect(@db.findOne).to.have.been.calledWith '1234.email': 'moheeb@hmm.info'

    describe 'when called and findOne yields an error', ->
      beforeEach ->
        @db.findOne.yields new Error('DANGER')
        @callback = sinon.stub()
        @sut.checkEmailPassword 'andrew@cod.gamez', '54321', @callback

      it 'should call the callback with an error', ->
        expect(@callback.args[0][0]).to.exist

    describe 'and we can find one', ->
      beforeEach ->        
        @db.findOne.yields null, '1234.password': @hash
        @callback = sinon.stub()
        @bcrypt.compare = sinon.stub()

      it 'check if the hash of the pin is good.', ->
        @sut.checkEmailPassword 'andrew@cod.gamez', '54321', @callback
        expect(@bcrypt.compare).to.have.been.calledWith '54321', 'green eggs and ham'

    describe 'and we can find a different one', ->
      beforeEach ->
        @pin2 ='Frodo'
        @hash2 = 'Baggins'
        @db.findOne.yields null, pin: @hash2
        @callback = sinon.stub()
        @bcrypt.compare = sinon.stub()

      it 'check if the hash of that pin is good.', ->
        @sut.checkEmailPassword @uuid, @pin2, @callback
        expect(@bcrypt.compare).to.have.been.calledWith @pin2, @hash2

      describe 'and bcrypt.compare yields an error', ->
        beforeEach ->
          @bcrypt.compare.yields true

        it 'should call the callback with an error', ->
           @sut.checkEmailPassword @uuid, @pin2, @callback
           expect(@callback.args[0][0]).to.exist

      it 'should call db.findOne with some other token', ->
        @sut.checkEmailPassword 'ben@positions.biz', 'switched'
        expect(@db.findOne).to.have.been.calledWith '1234.email': 'ben@positions.biz'

  describe.only '->save', ->
    it 'should exist', ->
      expect(@sut.save).to.exist

    describe 'when called with an email', ->
      beforeEach ->
        @db.insert = sinon.stub()
        @sut.save 'petedemartini@what?.com'

      it 'should call db.insert with the email', ->
        expect(@db.insert).to.have.been.calledWith '1234': email: 'petedemartini@what?.com'

    describe 'when called with a different email', ->
      beforeEach ->
        @db.insert = sinon.stub()
        @sut.save 'alisa@cats.com'

      it 'should call db.insert with the email', ->
        expect(@db.insert).to.have.been.calledWith '1234': email: 'alisa@cats.com'

    describe 'when called with an email and some device properties', ->
      beforeEach ->
        @db.insert = sinon.stub()
        @sut.save 'foo@bar.com', 'iluvcats', {serial: 'killer'}

      it 'should call db.insert with a mish-mash of the properties', ->
        expect(@db.insert).to.have.been.calledWith '1234': {email: 'foo@bar.com'}, serial: 'killer'

    describe 'when the EmailPasswordModel is instantiated with a different uuid', ->
      beforeEach ->
        @sut = new EmailPasswordModel '4312', @dependencies
        @db.insert = sinon.stub()
        @sut.save 'alisa@cats.com'

      it 'should call db.insert with the email', ->
        expect(@db.insert).to.have.been.calledWith '4312': email: 'alisa@cats.com'

    describe 'when called and insert yields a device', ->
      beforeEach -> 
        @db.insert = sinon.stub().yields null, { uuid: '101010' }
        @bcrypt.hash = sinon.spy()
        @sut.save 'ben@ring.com', 'password'

      it 'should call bcrypt.hash with the password and the uuid as a salt', ->
        expect(@bcrypt.hash).to.have.been.calledWith 'password', '101010'

    describe 'when called and db.insert yields an error', ->
      beforeEach -> 
        @error = new Error 'Something bad has happened'
        @db.insert = sinon.stub().yields @error
        @bcrypt.hash = sinon.spy()
        @callback = sinon.spy()
        @sut.save 'ben@ring.com', 'password', {}, @callback

      it 'should call the callback with an error', ->              
        expect(@callback).to.have.been.calledWith @error

    describe 'when called and insert yields a different device', ->
      beforeEach -> 
        @db.insert = sinon.stub().yields null, { uuid: '767676' }
        @bcrypt.hash = sinon.spy()
        @sut.save 'poison@toxic.org', 'hair band'
        
      it 'should call bcrypt.hash with the password and the uuid as a salt', ->
        expect(@bcrypt.hash).to.have.been.calledWith 'hair band', '767676'

    describe 'when called and insert yields an error', ->
      beforeEach ->
        @callback = sinon.spy() 
        @error = new Error 'Oh, noes!'
        @db.insert = sinon.stub().yields @error
        @bcrypt.hash = sinon.spy()
        @sut.save 'poison@toxic.org', 'hair band', {}, @callback
        
      it 'should call the callback with an error', ->
        expect(@callback).to.have.been.calledWith @error


    describe 'when called and bcrypt yields a hash', ->
      beforeEach -> 
        @db.insert = sinon.stub().yields null, { uuid: 'KopKilla69' }
        @db.update = sinon.spy()
        @bcrypt.hash = sinon.stub().yields null, 'used'
        @sut.save 'exhausted@gassed.org', 'Actresses Excuse'
        
      it 'should call bcrypt.hash with the password and the uuid as a salt', ->        
        expect(@db.update).to.have.been.calledWith 
          uuid: 'KopKilla69'
          '1234' : { 
            email: 'exhausted@gassed.org'
            password: 'used'
          }

    describe 'when called and bcrypt yields a different hash', ->
      beforeEach -> 
        @db.insert = sinon.stub().yields null, { uuid: 'executive-order' }
        @db.update = sinon.spy()
        @bcrypt.hash = sinon.stub().yields null, 'predator drone'
        @sut.save 'something@witty', 'do you hear'
        
      it 'should call bcrypt.hash with the password and the uuid as a salt', ->
        expect(@db.update).to.have.been.calledWith '1234' : { email: 'something@witty', password: 'predator drone' }

    describe 'when called and bcrypt yields an error', ->
      beforeEach -> 
        @error = new Error "I like it when things break"
        @callback = sinon.spy()
        @db.insert = sinon.stub().yields null, { uuid: 'KopKilla69' }
        @bcrypt.hash = sinon.stub().yields @error
        @sut.save 'exhausted@gassed.org', 'Actresses Excuse', {}, @callback
        
      it 'should call the callback with an error', ->
        expect(@callback).to.have.been.calledWith @error

    describe 'when called and update completes successfully', ->
      beforeEach -> 
        @device = uuid: 'Speedboat'                  
        @callback = sinon.spy()
        @db.insert = sinon.stub().yields null, { uuid: 'Speedboat' }
        @db.update = sinon.stub().yields null, @device
        @bcrypt.hash = sinon.stub().yields null, 'whaaaat?'
        @sut.save 'daring@rescue.org', 'Not successful', {}, @callback
        
      it 'should call the callback with the device', ->
        expect(@callback).to.have.been.calledWith null, @device

