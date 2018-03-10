(ns gogen-clojure.core
  "A Gogen solver!"
  (require clojure.string clojure.set)
  (:gen-class))

(def ^:const text-input-split "#####")
(def ^:const grid-size 5)
(def ^:const blank-character "_")

(defn surround-vec
  [middle end]
  (into [end]
    (conj middle end)))

(def all-positions
  (for [row (range 0 grid-size)
       col (range 0 grid-size)]
    [col row]))

(def all-letters
  (map #(str (char %))
    (range (int \A) (int \Z))))

(def initial-letter-map
  (let [letter all-letters]
    (into {}
      (map
        (fn [l] [l,[]])
        all-letters))))

(defn build-neighbourhood [x y]
  (let [low-x (max 0 (- x 1))
        low-y (max 0 (- y 1))
        high-x (min (- grid-size 1) (+ x 1))
        high-y (min (- grid-size 1) (+ y 1))
        x-range (range low-x (+ high-x 1))
        y-range (range low-y (+ high-y 1))]
    (map vec
      (for [a x-range b y-range]
        (list a b)))))

; optimise this to break to false if it finds any count > 1?
(defn is-solved?
  [letters-pos-map]
  (= (count all-letters)
     (count
       (filter
         #(-> (second %) count (= 1))
         letters-pos-map))))

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

(defn unique-letter-pairs
  [words]
  (distinct
    (apply concat
      (map word-to-letter-pairs words))))

(defn extract-adjacencies
  [words]
  (let [pairs-list (unique-letter-pairs words)]
    (reduce
      (fn [acc pair]
        (let [a (first pair)
              b (second pair)
              a-val (get acc a)
              b-val (get acc b)]
          (assoc acc a (conj a-val b)
                     b (conj b-val a))))
       initial-letter-map
       pairs-list)))

(defn extract-known-positions-from-grid
  [grid]
  (into {}
    (remove nil?
      (apply concat
        (map-indexed
          (fn [row_idx row]
            (map-indexed
              (fn [col_idx val]
                (if (= val "_") nil [val [[col_idx row_idx]]])) row))
          grid)))))

(defn extract-known-positions-from-map
  [letters-pos-map]
  (set
    (mapcat second
      (filter
        #(-> (second %) count (= 1))
        letters-pos-map))))

(defn extract-letters-pos-map
  [grid]
  (let [known-letters-pos-map (extract-known-positions-from-grid grid)
        known-letters-positions (set (map first (vals known-letters-pos-map)))
        unknown-positions (clojure.set/difference (set all-positions) known-letters-positions)]
    (into {}
      (map
        (fn [[letter v]]
          (let [known-val (get known-letters-pos-map letter)]
            (if (nil? known-val) [letter unknown-positions] [letter (set known-val)])))
        initial-letter-map))))

; we can have statements per function, fix this
(defn print-grid
  [grid]
  (map
    (fn [l] (apply println l))
      (vec
        (map
          (fn [pos] (clojure.string/join "" pos))
          grid))))

(defn data-from-puzzle []
  (let [[grid-raw words-raw] (raw-from-puzzle)
        grid (extract-grid grid-raw)
        words (extract-words words-raw)]
    (into []
          [grid
           (extract-adjacencies words)
           (extract-letters-pos-map grid)])))

(defn build-neighbourhood-set-from-pos-list
  [pos-list]
  (set
    (distinct ; uniq positible identity
      (mapcat identity ; flatten 1 layer
        (map
          (fn
            [pos]
            (build-neighbourhood (first pos) (second pos)))
          pos-list)))))

(defn updated-value-from-adjacencies
  [letter-positions adj-letter-positions known-positions]
  (let [neighbour-set (build-neighbourhood-set-from-pos-list adj-letter-positions)]
    (clojure.set/intersection
      letter-positions
      (clojure.set/difference neighbour-set known-positions))))

(defn solve-step
  [adjacencies letters-pos-map]
  (reduce
    (fn
      [acc [letter _]]
      (reduce
        (fn [inner-map adj-letter]
          (let [inner-map-letter-ps (get inner-map letter)
                inner-map-adj-letter-ps (get inner-map adj-letter)
                known-positions (extract-known-positions-from-map inner-map)
                neighbour-set (build-neighbourhood-set-from-pos-list inner-map-adj-letter-ps)
                updated-value (updated-value-from-adjacencies inner-map-letter-ps inner-map-adj-letter-ps known-positions)]
                (if (= (count inner-map-letter-ps) 1)
                  inner-map ; exit early
                  (assoc inner-map letter updated-value))))
        acc
        (get adjacencies letter)))
    letters-pos-map
    letters-pos-map))

(defn solve
  [adjacencies letters-pos-map]
  (if (is-solved? letters-pos-map)
      letters-pos-map
      (recur adjacencies (solve-step adjacencies letters-pos-map))))

(defn update-grid
  [grid letters-pos-map]
  (reduce
    (fn
      [new-grid [letter pos-map]]
      (let [[x y] (first pos-map)]
        (update-in new-grid [y x] (fn [_] letter))))
    grid
    letters-pos-map))

(defn -main
  "Main entry point to solving Gogen puzzles"
  [& args]
  (let [[grid adjacencies letters-pos-map] (data-from-puzzle)]
    (print-grid
      (update-grid grid
        (solve adjacencies letters-pos-map)))))
