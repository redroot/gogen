### Gogen Puzzle Solver

Attempts at solving a gogen puzzle solver in various languages

    cd ruby & ruby gogen.rb
    cd go & go run gogen.go

Coming Soon: Elixir, Clojure

### Thoughts

#### Ruby

- I was keen to use set operations and there are available on arrays out of the box which was a pleasant surprise

#### Go

- Set isn't part of the standard library so used a great third party representation. I definitely missed the unified API that Ruby provides for array/sets and maps.
- Typed definition especially involving maps took a little while to grok, plenty of the shortcuts in Ruby unavailable but I appreciated it, if it compiles it tended to run
- Lack of `cond || default` was a little frustrating.
