_ = require 'lodash'

SecureMeshbluDb = 
  findSigned: (query, callback=->) ->
    @db.find query , (error, devices=[])=>
      return callback error if error?
      devices = _.filter devices, (device) =>
        @meshblu.verify(_.omit( device[@uuid], 'signature' ), device[@uuid]?.signature)

      callback null, devices

module.exports = SecureMeshbluDb
