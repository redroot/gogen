package main

import (
  "fmt"
  "io/ioutil"
  "path/filepath"
  "os"
  "strings"
  "gopkg.in/fatih/set.v0"
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
type LetterPosSet map[string]*set.Set

func log(msg string) {
  fmt.Printf("[GOGEN] %s\n", msg)
}

func checkErr(e error) {
  if e != nil {
    panic(e)
  }
}

func getLetterPosSetKeys(input LetterPosSet) (*set.Set) {
  keys := set.New()
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
      posSet := set.New(Pos{col, row})
      lettersFound[val] = posSet
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

func buildAllPositions() (*set.Set) {
  s := set.New()
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
  allLettersSet := set.New()
  for _, l := range(allLetters) {
    allLettersSet.Add(l)
  }

  knownLetters := getLetterPosSetKeys(lettersFound)
  knownPositions := set.New()
  for _, ps := range(lettersFound) {
    knownPositions.Add(ps.Pop()) // only one item so its to just pop once
  }

  missingLetters := set.Difference(allLettersSet, knownLetters)
  blankPositions := set.Difference(allPositions, knownPositions)

  lettersToFind := make(LetterPosSet)
  for _, letter := range(missingLetters.List()) {
    l, _ := letter.(string)
    lettersToFind[l] = blankPositions.Copy()
    // ?  cannot use blankPositions.Copy() (type set.Interface) as type *set.Set in assignment: need type assertion

  }
  return lettersToFind
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
  log(fmt.Sprintf("Have words %v", words))
  log(fmt.Sprintf("Have found letters %v", lettersFound))
  log(fmt.Sprintf("Lets solve a gogen puzzle %s!\n", puzzle))
  buildLettersToFind(lettersFound)
  // allPositions := buildAllPositions())
  // adjacencies = buildAdjacencies(words)
}


// make use of structs or are simple things good enough?
