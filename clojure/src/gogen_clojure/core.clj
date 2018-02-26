(ns gogen-clojure.core
  (require '[clojure.string :as str])
  (:gen-class))

(def ^:const text-input-split "#####")
(def ^:const grid-size 5)
(def ^:const print_padding 3)
(def ^:const blank_character "_")

(defn get-puzzle-id []
  (or (System/getenv "PUZZLE")
      "1"))

(defn get-puzzle-raw []
  (let [id (get-puzzle-id)]
    (slurp
      (str "../examples/" id "-unsolved.txt"))))

(defn data-from-puzzle []
  (let [raw (get-puzzle-raw)])
    )

(defn -main
  "Main entry point to solving puzzles"
  [& args]
  (println "asdasd"))
