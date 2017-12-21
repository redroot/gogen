package main

import (
  "fmt"
  "io/ioutil"
  "path/filepath"
  "os"
  "strings"
)

const textInputSplit = "#####"
const gridSize = 5
const blankCharacter = "_"

func log(msg string) {
  fmt.Printf("[GOGEN] %s\n", msg)
}

func checkErr(e error) {
  if e != nil {
    panic(e)
  }
}

func textInputToGrid(textInput string) ([5][5]string) {
  newGrid := [gridSize][gridSize]string{}
  lines := strings.Split(strings.Trim(textInput, "\n"), "\n")
  for row := range(lines) {
    cells := strings.Split(lines[row], " ")
    for col, val := range(cells) {
      newGrid[col][row] = val
    }
  }
  return newGrid
}

func extractDataFromFile(puzzle string) ([5][5]string, []string) {
  absPath, err := filepath.Abs(fmt.Sprintf("../examples/%s-unsolved.txt", puzzle))
  checkErr(err)
  data, err := ioutil.ReadFile(absPath)
  checkErr(err)
  parts := strings.Split(string(data), textInputSplit)
  grid := textInputToGrid(parts[0])
  words := strings.Split(parts[1], "\n")
  return grid, words
}

func main() {
  puzzle := "1"
  if len(os.Args) > 1 {
    puzzle = os.Args[1]
  }
  log(fmt.Sprintf("Lets solve a gogen puzzle %s!", puzzle))
  grid, words := extractDataFromFile(puzzle);
  letters_found, letters_unfound,
  log(fmt.Sprintf("%v", grid))
  log(fmt.Sprintf("%v", words))
}


// make use of structs or are simple things good enough?
