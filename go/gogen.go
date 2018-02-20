package main

import (
  "fmt"
  "io/ioutil"
  "path/filepath"
  "os"
  "strings"
  set "github.com/deckarep/golang-set"
)

const textInputSplit = "#####"
const gridSize = 5
const blankCharacter = "_"
const availableLetters = "ABCDEFGHIJKLMNOPQRSTUVWXY"

type Pos struct {
  x int
  y int
}

type Grid [gridSize][gridSize]string
type WordList []string
type LetterPosSet map[string]set.Set
type AdjacencyMap map[string]set.Set

func log(msg string) {
  fmt.Printf("[GOGEN] %s\n", msg)
}

func checkErr(e error) {
  if e != nil {
    panic(e)
  }
}

func intMin(x, y int) int {
    if x < y {
        return x
    }
    return y
}

func intMax(x, y int) int {
    if x > y {
        return x
    }
    return y
}


func getLetterPosSetKeys(input LetterPosSet) (set.Set) {
  keys := set.NewSet()
  for k := range(input) {
    keys.Add(k)
  }
  return keys
}

func textInputToGrid(textInput string) (Grid, LetterPosSet) {
  newGrid := [gridSize][gridSize]string{}
  lettersFound := make(LetterPosSet)
  lines := strings.Split(strings.Trim(textInput, "\n"), "\n")
  for row := range(lines) {
    cells := strings.Split(lines[row], " ")
    for col, val := range(cells) {
      newGrid[col][row] = val
      posSet := set.NewSet(Pos{col, row})
      if (val != blankCharacter) {
        lettersFound[val] = posSet
      }
    }
  }
  return newGrid, lettersFound
}

func extractDataFromFile(puzzle string) (Grid, LetterPosSet, WordList) {
  absPath, err := filepath.Abs(fmt.Sprintf("../examples/%s-unsolved.txt", puzzle))
  checkErr(err)
  data, err := ioutil.ReadFile(absPath)
  checkErr(err)
  parts := strings.Split(string(data), textInputSplit)
  grid, lettersFound := textInputToGrid(parts[0])
  words := strings.Split(parts[1], "\n")
  return grid, lettersFound, words
}

func buildAllPositions() (set.Set) {
  s := set.NewSet()
  for row := 0; row < gridSize; row++ {
    for col := 0; col < gridSize; col++ {
      s.Add(Pos{col, row})
    }
  }
  return s
}

func buildLettersToFind(lettersFound LetterPosSet) (LetterPosSet) {
  allPositions := buildAllPositions()
  allLetters := strings.Split(availableLetters, "")
  allLettersSet := set.NewSet()
  for _, l := range(allLetters) {
    allLettersSet.Add(l)
  }

  knownLetters := getLetterPosSetKeys(lettersFound)
  knownPositions := set.NewSet()
  for _, ps := range(lettersFound) {
    ps.Each(func(elem interface{}) bool {
      knownPositions.Add(elem)
      return false
    })
  }

  missingLetters := allLettersSet.Difference(knownLetters)
  blankPositions := allPositions.Difference(knownPositions)

  lettersToFind := make(LetterPosSet)
  missingLetters.Each(func(letter interface{}) bool {
    l, _ := letter.(string)
    blankPositionCopy := blankPositions.Clone()
    lettersToFind[l] = blankPositionCopy   // is there any easier way to copy a set?
    return false
  })
  return lettersToFind
}

func buildAdjacencies(words WordList) (AdjacencyMap) {
  adjMap := make(AdjacencyMap)
  for _, word := range(words) {
    chars := strings.Split(word, "")
    maxLoop := len(chars) - 1;
    for i := 0; i < maxLoop; i++ {
      firstChar := chars[i]
      secondChar := chars[i+1]
      if (adjMap[firstChar] == nil) { adjMap[firstChar] = set.NewSet() }
      if (adjMap[secondChar] == nil) { adjMap[secondChar] = set.NewSet() }
      adjMap[firstChar].Add(secondChar)
      adjMap[secondChar].Add(firstChar)
    }
  }
  return adjMap
}

// done use math.Min https://mrekucci.blogspot.co.uk/2015/07/dont-abuse-mathmax-mathmin.html
func buildNeighbourhood(pos Pos) (set.Set) {
  s := set.NewSet()
  x_min := intMax(pos.x - 1, 0)
  y_min := intMax(pos.y - 1, 0)
  x_max := intMin(pos.x + 1, gridSize - 1)
  y_max := intMin(pos.y + 1, gridSize - 1)
  for x := x_min; x <= x_max; x++ {
    for y := y_min; y <= y_max; y++ {
      s.Add(Pos{x, y})
    }
  }
  return s
}


func solve(lettersToFind LetterPosSet, lettersFound LetterPosSet, adjacencies AdjacencyMap, grid Grid) (Grid) {
  // continue to iterate until we have all letters, this map
  // will get updated further down
  for len(lettersToFind) > 0 {
    for letter, _ := range(lettersToFind) {
      adjacencies[letter].Each(func(aj interface{}) bool {
        adjacentLetter, _ := aj.(string)
        positionsOfLetter := set.NewSet() // in both cases lets make this a set
        if (lettersFound[adjacentLetter] != nil) {
          // we found this already so we know where it is, only one possible position
          positionsOfLetter = lettersFound[adjacentLetter].Clone()
        } else {
          // not found so lets get all the possible positions
          positionsOfLetter = lettersToFind[adjacentLetter].Clone()
        }
        // now we work out all possible positions of that letter, build
        // neighhbourhoodas for each and flatten/uniq by using union
        validPositions := set.NewSet()
        positionsOfLetter.Each(func(ps interface{}) bool {
          pos := ps.(Pos)
          validPositions = validPositions.Union(buildNeighbourhood(pos))
          return false
        })
        // now remove all position we already now
        knownPositions := set.NewSet()
        for _, ps := range(lettersFound) {
          ps.Each(func(elem interface{}) bool {
            knownPositions.Add(elem)
            return false
          })
        }
        validPositions = validPositions.Difference(knownPositions)

        // now update the original lettersToFind by intersect with our hopefully reduced list
        lettersToFind[letter] = lettersToFind[letter].Intersect(validPositions)

        if (lettersToFind[letter].Cardinality() == 1) {
          lettersFound[letter] = lettersToFind[letter]
          delete(lettersToFind, letter)
          return true // breaks out of the inner Each, cant break in callback Each rather than for loop
        } else {
          return false
        }
      })
    }
  }

  for letter, positions := range(lettersFound) {
    // should only be one position but we have to user Iter to get first element out
    for ps := range(positions.Iter()) {
      pos := ps.(Pos)
      grid[pos.x][pos.y] = letter
    }
  }

  return grid;
}

func printGrid(grid Grid) {
  for i := range(grid) {
    fmt.Printf("\t\t%s\n", strings.Join(grid[i][:], " "))
  }
}

func main() {
  puzzle := "1"
  if len(os.Args) > 1 {
    puzzle = os.Args[1]
  }
  grid, lettersFound, words := extractDataFromFile(puzzle);
  printGrid(grid)
  log(fmt.Sprintf("Lets solve a gogen puzzle %s!\n", puzzle))
  updatedGrid := solve(buildLettersToFind(lettersFound), lettersFound, buildAdjacencies(words), grid)
  printGrid(updatedGrid)
}
