### Gogen Puzzle Solver

![Gogen Puzzle Example](https://cdn2-img.pressreader.com/pressdisplay/docserver/getimage.aspx?regionKey=o4DpXghKETWCC2xVID7ljw%3D%3D)

Caveat - I haven't really used anything other than Ruby beyond simple tutorials before this.

Attempts at solving a gogen puzzle solver in various languages

    cd ruby & ruby gogen.rb
    cd go & go run gogen.go
    cd elixir & elixir gogen.exs
    cd clojure & lein repl # then (-main) I have no idea what I'm doing here

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
- The solve function was another interesting issue using the parameters I'd used in previous solutions, namely: `letters_to_find`, map of unfound letters and potential positions, `letters_found` a map of found letters and known positions, and `adjacencies`, a map of letter adjacencies from the word list. The inability to modify variables outside of the loop, i.e. updating the maps - meant that I ended up nesting reduce statements, and implementing my own break/continue pattern using the accumulator tuple, [see here](https://github.com/redroot/gogen/blob/d66047ff2e9e8b9387ee65756ae93287838eabe4/elixir/gogen.exs#L16).
- One question that came to me while I was doing above if I could do the same with only one map of known letters - possible but I doubt I could use guards since determining if there was still work to do would involve `map_size(Enum.filter(letter_pos_set, fn {k,v} -> length(v) > 1 end))` which I wouldn't be able to write in a guard. Unless I passed the count of remaining letters through as a parameter on each pass. Thats what I did in the `elixir-alt` branch - simplifying the data structures making the reduce accumlator simpler too and only involving a control parameter within the loop once! [See the commit here](https://github.com/redroot/gogen/commit/c9656f92a4460e05a1fb61a0125e809e871e3cf9)
- But then I realised I didn't even need to control variable now I was doing the length check in the nested reducer! So I managed to make it even simpler, which was the final edition.

#### Clojure

- `lein repl` is super useful, but a pain if there are compilation errors as you have to restart the whole repl to get things to load properly.
- Errors messaging relating to syntax aren't the most helpful out of the box
- Simple pure functions are a joy to write, many different ways of doing it, however complicated control flows took a little while longer and doesn't seem as neat, such as print a few blank lines either side of the grid - later I found out you can have multiple statements in a function body with negates the wrapping method I found first. Feels like its best for people who know exactly what they are doing from the get go rather than stepping through an idea.
