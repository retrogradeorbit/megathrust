(ns process.core
  (:require [mikera.image.core :as mikera]
            [mikera.image.colours :as colours]
            [clojure.java.io :as io])
  (:gen-class))

(defn make-byte
  "turn the 8 pixels from x,y to the right into a byte.
  black is 0. Any coloured pixel is 1"
  [img [x y]]
  (->> (range 8)
       (map (fn [i]
              (when (not= [0 0 0]
                        (colours/components-rgb
                         (mikera/get-pixel
                          img
                          (+ i x)
                          y)))
                (int (Math/pow 2 (- 7 i))))))
       (filter identity)
       (apply +))
  )

(defn dedup [chars]
  (into {}
        (for [[k v] (group-by second chars)]
          [k (map first v)])))

(defn make-char-set [deduped]
  (mapv first deduped))

(defn char-locations
  "map each char [x y] => char index"
  [charset deduped]
  (into {}
        (apply concat
               (for [[ch locs] deduped]
                 (map
                  (fn [l]
                    [l (.indexOf charset ch)])
                  locs)))))

(defn process-chars []
  (let [charmap (mikera/load-image "../gfx/charmap-01.png")
        order (concat
                    (for [y (range 5)
                          x (range 18)]
                      [x y])
                    (for [y (range 5)
                          x (range 18 40)]
                      [x y])
                    )
        chars (->> (for [[x y] order]
                     [[x y] (for [yp (range 8)]
                              (make-byte charmap [(* 8 x) (+ (* 8 y) yp)]))])
                   (into {}))
        ;;data (byte-array bytes)

        deduped (dedup chars)
        charset (concat [(list 0 0 0 0 0 0 0 0)
                         (list 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff)
                         ]
                        (make-char-set deduped))
        locations (char-locations charset deduped)
        ]
    ;;(io/copy data (io/file "../gfx/charmap-01.bin"))

    ;; (prn chars)
    ;; (println)
    ;; (prn deduped)
    ;; (println)
    ;; (prn charset)
    ;; (println)
    ;; (prn locations)

    (let [charset-data (byte-array (flatten charset))]
      (println "writing gfx/charmap-01.bin ...")
      (io/copy charset-data (io/file "../gfx/charmap-01.bin")))

    ;; width, height, chars.
    (let [mega-charmap
          (concat [18 5]
                  (for [y (range 5)
                        x (range 18)]
                    (locations [x y])))]
      (println "writing gfx/mega-chars.bin ...")
      (io/copy (byte-array mega-charmap) (io/file "../gfx/mega-chars.bin")))

    (let [thrust-charmap
          (concat [(- 40 18) 5]
                  (for [y (range 5)
                        x (range 18 40)]
                    (locations [x y])))]
      (println "writing gfx/thrust-chars.bin ...")
      (io/copy (byte-array thrust-charmap) (io/file "../gfx/thrust-chars.bin")))))

(defn process-sprites []
  (let [spritemap (mikera/load-image "../gfx/spritemap-01.png")
        order [[0 0] [1 0] [2 0] [3 0] [4 0] [5 0]
               [0 1] [1 1] [2 1] [3 1] [4 1] [5 1]
               ]
        sprites (->> (for [[x y] order]
                       (let [xx (* 24 x)
                             yy (* 21 y)]
                         (concat
                          (for [yoff (range 21)
                                xoff [0 1 2]]
                            (make-byte spritemap [(+ xx (* 8 xoff)) (+ yoff yy)]))
                          [0] ;; 63 bytes + 1 byte padding
                          )
                         )))]
    (println "writing gfx/spritemap-01.bin ...")
    (io/copy (byte-array (flatten sprites)) (io/file "../gfx/spritemap-01.bin"))
    ))

(defn -main
  "process charmap"
  [& args]
  (process-chars)
  (process-sprites)
  )
