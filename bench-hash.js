var lib = process.argv[2] || 'crypto-browserify'
var alg = process.argv[3] || 'sha1'
var randomData = require('crypto').pseudoRandomBytes

// generate 10 megs of random data
var M = 10 * 1000 * 1000
var data = randomData(M)

var libs = {
  'sha.js': function (alg) {
    var sha = require('sha.js')
    return function (data) {
      return (new (sha[alg])()).update(data).digest('hex')
    }
  },
  'hash.js': function (alg) {
    var hash = require('hash.js')
    return function (data) {
      return (new (hash[alg])()).update(data).digest('hex')
    }
  },

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
      return sjcl.codec.hex.fromBits(new (sjcl.hash[alg].hash(data)))
    }
  },

  node: function (alg) {
    var crypto = require('crypto')
    return function (data) {
      return crypto.createHash(alg).update(data).digest('hex')
    }
  },
  jshashes: function (alg) {
    var jshashes = require('jshashes')
    if (alg === 'ripemd160') alg = 'RMD160'

    var Hash = jshashes[alg.toUpperCase()]
    var hash = new Hash()
    return function (data) {
      return hash.hex(data.toString('binary'))
    }
  },
  cryptomx: function (alg) {
    if (!/^(sha256|ripemd)$/.test(alg)) throw new Error('algorithm ' + alg + ' is not implemented by cryptomx library')
    return function (data) {
      return require('cryptomx')[alg](data.toString('binary'))
    }
  },
  blake2s: function (alg) {
    if (alg !== 'blake2s') throw new Error('algorithm ' + alg + ' is not implemented by blake2s library')
    var Blake2s = require('blake2s')
    return function (data) {
      return new Blake2s().update(data).digest('hex')
    }
  },
  'git-sha1': function (alg) {
    if (alg !== 'sha1') throw new Error('algorithm ' + alg + 'is not implemented by git-sha1 library')
    var sha1 = require('git-sha1')
    return function (data) {
      return sha1(data)
    }
  },
  'rusha': function (alg) {
    if (alg !== 'sha1') throw new Error('algorithm ' + alg + 'is not implemented by git-sha1 library')
    var Rusha = require('rusha')
    var sha1 = new Rusha()
    return function (data) {
      return sha1.digestFromBuffer(data)
    }
  }
}

var prev = 0
var hash = libs[lib](alg)

console.log('run (N), input-size (bytes), ops (bytes/ms), time (ms)')
;(function loop (i) {
  if (i > 80) return
  var n = Math.pow(M, i / 80) | 0
  if (n === prev) return loop(i + 1)
  prev = n
  var _data = data.slice(data.length - n, data.length)
  var start = Date.now()
  var end
  var j = 0
  do {
    var _hash = hash(_data) // eslint-disable-line no-unused-vars
    end = Date.now()
    j++
  } while (end - start < 100)
  var time = end - start

  console.log(['' + i, _data.length, (_data.length * j) / time, time / j].join(', '))
  setTimeout(loop, 10, i + 1)
})(0)
