EmailPasswordModel = require '../../app/models/email-password-model'

describe 'EmailPasswordModel', ->
  beforeEach ->
    @db = {}
    @bcrypt = {}
    @dependencies = db: @db, bcrypt: @bcrypt
    @sut = new EmailPasswordModel '1234', @dependencies

  describe '->checkEmailPassword', ->
    it 'should exist', ->
      expect(@sut.checkEmailPassword).to.exist

    describe 'when called with a email and password', ->
      beforeEach ->
        @db.find = sinon.stub()
        @sut.checkEmailPassword 'moheeb@hmm.info', 'infosec'

      it 'should call db.find with that email', ->
        expect(@db.find).to.have.been.calledWith '1234.email': 'moheeb@hmm.info'

    describe 'when sut is called with a different uuid', ->
      beforeEach ->
        @db.find = sinon.stub()
        @sut = new EmailPasswordModel '4321', @dependencies
        @sut.checkEmailPassword 'moheeb@hmm.info', 'infosec'

      it 'should call find with the key 4321.email', ->
        expect(@db.find).to.have.been.calledWith '4321.email': 'moheeb@hmm.info'

    describe 'when called and findOne yields an error', ->
      beforeEach ->
        @db.find = sinon.stub().yields new Error('DANGER')
        @callback = sinon.stub()
        @sut.checkEmailPassword 'andrew@cod.gamez', '54321', @callback

      it 'should call the callback with an error', ->
        expect(@callback.args[0][0]).to.exist

    describe 'when called and we can find a device', ->
      beforeEach ->        
        @db.find = sinon.stub().yields null, ['1234' : { password: 'spider bite' }]
        @callback = sinon.stub()
        @bcrypt.compareSync = sinon.stub()

      it 'check if the hash of the password is good.', ->
        @sut.checkEmailPassword 'andrew@cod.gamez', '54321'
        expect(@bcrypt.compareSync).to.have.been.calledWith '54321', 'spider bite'

    describe 'when called and we can find a devices', ->
      beforeEach ->        
        @db.find = sinon.stub().yields null, ['1234' : { password: 'spider bite' }, '4321' : { password: 'extensive problems' }]
        @bcrypt.compareSync = sinon.stub().returns true

      it 'check if the hash of the password is good.', ->
        @sut.checkEmailPassword 'andrew@cod.gamez', '54321'
        expect(@bcrypt.compareSync).to.have.been.calledWith '54321', 'spider bite'

    describe 'when constructed with a different uuid and called and we can find a device', ->
      beforeEach ->        
        @sut = new EmailPasswordModel '1010', @dependencies
        @db.find = sinon.stub().yields null, ['1010' : { password: 'spider bite' }]
        @callback = sinon.stub()
        @bcrypt.compareSync = sinon.stub().returns true

      it 'check if the hash of the password is good.', ->
        @sut.checkEmailPassword 'andrew@cod.gamez', '54321'
        expect(@bcrypt.compareSync).to.have.been.calledWith '54321', 'spider bite'

    describe 'and we can find a different one', ->
      beforeEach ->
        @db.find = sinon.stub().yields null, ['1234' : { password: 'tied up' }]
        @callback = sinon.stub()
        @bcrypt.compareSync = sinon.stub()

      it 'check if the hash of that password is good.', ->
        @sut.checkEmailPassword '1234', 'toaster', @callback
        expect(@bcrypt.compareSync).to.have.been.calledWith 'toaster', 'tied up'

      it 'should call db.findOne with some other token', ->
        @sut.checkEmailPassword 'ben@positions.biz', 'switched'
        expect(@db.find).to.have.been.calledWith '1234.email': 'ben@positions.biz'

  describe '->save', ->
    beforeEach ->
      @db.findOne = sinon.stub().yields message: 'Device does not exist'

    it 'should exist', ->
      expect(@sut.save).to.exist

    describe 'when called with an email', ->
      beforeEach ->
        @db.insert = sinon.stub()
        @sut.save 'petedemartini@what.com'

      it 'should call db.insert with the email', ->
        expect(@db.insert).to.have.been.calledWith '1234': email: 'petedemartini@what.com'

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

      it 'should call bcrypt.hash with the password and the 10 as a salt', ->
        expect(@bcrypt.hash).to.have.been.calledWith 'password', 10

    describe 'when called and db.insert yields an error', ->
      beforeEach -> 
        @error = new Error 'Something bad has happened'
        @db.insert = sinon.stub().yields @error
        @bcrypt.hash = sinon.spy()
        @callback = sinon.spy()
        @sut.save 'ben@ring.com', 'password', {}, @callback

      it 'should call the callback with an error', ->              
        expect(@callback).to.have.been.calledWith @error

    describe 'when called and email already exists', ->
      beforeEach (done) -> 
        @db.findOne = sinon.stub().yields null, {uuid: 'karate-monkey'}
        @sut.save 'poison@toxic.org', 'hair band', {}, (@error, @device) => done()
        
      it 'should call db.findOne with the email', ->
        expect(@db.findOne).to.have.been.calledWith '1234.email': 'poison@toxic.org'

      it 'should yield an error', ->
        expect(@error).to.exist

    describe 'when called with a different email', ->
      beforeEach (done) -> 
        @sut = new EmailPasswordModel '4321', @dependencies
        @db.findOne = sinon.stub().yields null, {uuid: 'karate-monkey'}
        @sut.save 'heart@captainplanet.org', 'hair band', {}, (@error, @device) => done()
        
      it 'should call db.findOne with the email', ->
        expect(@db.findOne).to.have.been.calledWith '4321.email': 'heart@captainplanet.org'

      it 'should yield an error', ->
        expect(@error).to.exist

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
        @db.insert = sinon.stub().yields null, { uuid: 'KopKilla69', '1234' : { email: 'exhausted@gassed.org' } }
        @db.update = sinon.spy()
        @bcrypt.hash = sinon.stub().yields null, 'used'
        @sut.save 'exhausted@gassed.org', 'Actresses Excuse'
        
      it 'should call db.update', ->        
        expect(@db.update).to.have.been.calledWith 
          uuid: 'KopKilla69'
          '1234' : { 
            email: 'exhausted@gassed.org'
            password: 'used'
          }

    describe 'when called and bcrypt yields a different hash', ->
      beforeEach -> 
        @db.insert = sinon.stub().yields null, { uuid: 'executive-order', '1234' : { email: 'something@witty.com' } }
        @db.update = sinon.spy()
        @bcrypt.hash = sinon.stub().yields null, 'predator drone'
        @sut.save 'something@witty.com', 'do you hear'
        
      it 'should call bcrypt.hash with the password and the uuid as a salt', ->
        expect(@db.update).to.have.been.calledWith uuid: 'executive-order', '1234' : { email: 'something@witty.com', password: 'predator drone' }

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
        @db.insert = sinon.stub().yields null, { uuid: 'Speedboat', '1234' : { email: 'daring@rescue.org' } }
        @db.update = sinon.stub().yields null, @device
        @bcrypt.hash = sinon.stub().yields null, 'whaaaat?'
        @sut.save 'daring@rescue.org', 'Not successful', {}, @callback
        
      it 'should call the callback with the device', ->
        expect(@callback).to.have.been.calledWith null, @device
    
    describe 'when an invalid email is passed in', ->
      beforeEach (done) ->
        @sut.save '', '', {}, (@error) => done()

      it 'should return an error', ->
        expect(@error).to.exist

    describe 'when an invalid email is passed in', ->
      beforeEach (done) ->
        @sut.save 'asdf@asdf', '', {}, (@error) => done()

      it 'should return an invalid email error', ->
        expect(@error.message).to.equal('invalid email')

