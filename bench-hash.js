
var args = process.argv.slice(2)
var lib = args.shift() || 'crypto-browserify'
var alg = args.shift() || 'sha1'
var randomData = require('crypto').pseudoRandomBytes
var Buffer = require('buffer').Buffer

//generate 10 megs of random data
var M = 10*1000*1000
var data = randomData(M)

var libs = {
  'crypto-browserify': function (alg) {
    var createHash = require('crypto-browserify').createHash
    return function (data) {
      return createHash(alg).update(data).digest('hex')
    }
  },
  forge: function (alg) {
    var forge = require('node-forge')()
    return function (data) {
      return forge[alg].create().start().update(data.toString('binary')).digest().toHex()
    }
  },
  'crypto-js': function (alg) {
    var cjs = require('crypto-js')
    return function (data) {
      return cjs[alg.toUpperCase()](data.toString('binary')).toString()
    }
  },
  sjcl: function (alg) {
    var sjcl = require('sjcl/core')
    return function (data) {
      return sjcl.codec.hex.fromBits(new sjcl.hash[alg].hash(data))
    }
  },

  node: function (alg) {
    var crypto = require('crypto')
    return function (data) {
      return crypto.createHash(alg).update(data).digest('hex')
    }
  }
}

var prev = 0
var hash = libs[lib](alg)

//for(var i = 79; i <= 80; i++) {
var i = 1
;(function loop () {
  if(i > 80) return
  var n = Math.round(Math.pow(Math.pow(M, 1/80), i))
  if(n === prev) return i++, loop();
  prev = n
  var _data = data.slice(data.length - n, data.length)
  var start = Date.now(), end, _hash, j = 0
  do {
    _hash = hash(_data)
    end = Date.now()
    j++
  } while(end - start < 100)
  var time = end - start

  console.log(''+i, n, _data.length, j, time, (_data.length*j)/time, _hash)
  i++
  setTimeout(loop, 10)
})()
//}
