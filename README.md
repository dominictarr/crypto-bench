# crypto-bench

benchmark the various js crypto libs

## libraries

* node.js (openssl binding)
* sjcl
* crypto-js
* forge
* sha.js (part of crypto-browserify)

## benchmarks

### hash

Hash random data from 20 bytes - 10 mb.
This tests the libraries ability to hash lots of data.

``` js
#                  library                       algorithm
node bench-hash.js [node|crypto-js|forge|sha.js] [sha1|sha256]
```


### pkbdf2

pkbdf2 a password, with variable iterations.
This tests how fast it is to create hash objects,
as thousand of hashes are created, but they each hash a small amount of data.

``` js
#                    library                       algorithm
node bench-pkbdf2.js [node|crypto-js|forge|sha.js] [sha1|sha256]
```

## results

please run them yourself, there is a bit more work to do
here to display results in a useful way.

## License

MIT
