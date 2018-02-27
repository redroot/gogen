(ns gogen-clojure.core
  "A Gogen solver!"
  (require clojure.string clojure.set)
  (:gen-class))

(def ^:const text-input-split "#####")
(def ^:const grid-size 5)
(def ^:const print_padding 3)
(def ^:const blank_character "_")

(def all-positions
  (for [row (range 0 grid-size)
        col (range 0 grid-size)]
    [col row]))

(defn puzzle-id []
  (or (System/getenv "PUZZLE")
      "1"))

(defn puzzle-raw []
  (let [id (puzzle-id)]
    (slurp
      (str "../examples/" id "-unsolved.txt"))))

(defn raw-from-puzzle []
  (let [raw (puzzle-raw)]
    (clojure.string/split raw #"#####")))

(defn extract-grid
  [grid-raw]
  (apply mapv vector
    (mapv #(clojure.string/split % #" ")
      (clojure.string/split grid-raw #"\n"))))

(defn extract-words
  [words-raw]
  (clojure.string/split (clojure.string/trim words-raw) #"\n"))

(defn word-to-letter-pairs
  [word]
  (let [word-length (count word)
        max-index (- word-length 1)]
    (map
      (fn [index]
        (into []
          [(subs word index (+ index 1))
           (subs word (+ index 1) (+ index 2))]))
      (range 0 max-index))))

(defn extract-adjacencies
  [words]
  words)

(defn extract-letters-pos-map
  [grid]
  grid)

(defn data-from-puzzle []
  (let [[grid-raw words-raw] (raw-from-puzzle)
        grid (extract-grid grid-raw)
        words (extract-words words-raw)]
    (into []
          [(extract-adjacencies words)
           (extract-letters-pos-map grid)])))

(defn -main
  "Main entry point to solving puzzles"
  [& args]
  (println "asdasd"))
