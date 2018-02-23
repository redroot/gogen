### Gogen Puzzle Solver

Caveat - I haven't really used anything other than Ruby beyond simple tutorials before this.

Attempts at solving a gogen puzzle solver in various languages

    cd ruby & ruby gogen.rb
    cd go & go run gogen.go
    cd elixir & elixir gogen.go

Coming Soon: Clojure

### Thoughts

#### Ruby

- I was keen to use set operations and there are available on arrays out of the box which was a pleasant surprise

#### Go

- Set isn't part of the standard library so used a great third party representation. I definitely missed the unified API that Ruby provides for array/sets and maps.
- Typed definition especially involving maps took a little while to grok, plenty of the shortcuts in Ruby unavailable but I appreciated it, if it compiles it tended to run
- Lack of `cond || default` was a little frustrating.

#### Elixir

- Fun to use list comprehension style syntax to work on `all_positions` and `all_letters` methods
- Piping syntax made nested reduces for data_from_input method messy, decided to use fixed grid size and modulus/rounding to get correct positions
- I initially used a `%Position{x,y}` struct, but building maps of remaining positions was super slow compared to straight maps, so dropped that in favour of straight maps
- Building letter adjacencies was interesting, reduce a list of strings to a map of Letters of a List of the adjacent ones.  Without the ability to set a default values per array matching the reduce approach from the Ruby attempt was messy, but when I realised I could intialise the map outside
- The solve function was another interesting issue using the parameters I'd used in previous solutons, namely: `letters_to_find`, map of unfound letters and potential positions, `letters_found` a map of found letters and known positios, and `adjacencies`, a map of letter adjacencies from the word list. The inability to modify variables outside of the loop i.e. updating the maps meant that I ended up nesting reduce statements, and inplementing my own break/continue pattern using the accumulator tuple. One question that came to me was if I could do the same with only one map of known letters - possible but I doubt I could use guards since determining if there was still work to do would involve `map_size(Enum.filter(letter_pos_set, fn {k,v} -> length(v) > 1))` which I wouldn't be able to write in a guard - I'd have to implement control flow within the function itself.
