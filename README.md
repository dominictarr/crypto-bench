# crypto-bench

benchmark the various js crypto libraries

## results

results are discussed here: [markdown format](./results.md)
and [typeset for maximum credibitily](http://dominictarr.github.io/crypto-bench)

## libraries

* sjcl
* crypto-js
* forge
* sha.js (part of crypto-browserify)

node.js is disabled, because it's so much faster (20x)
that is obscures the results of the js libraries.

## benchmarks

### hash

Hash random data from 20 bytes - 10 MB.
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

## run all benchmarks

```
./run.sh all hash
./run.sh all pbkdf2

# regenerate graphs
./runs.sh graphs

# regenerate article
npm run build
```

## License

MIT
