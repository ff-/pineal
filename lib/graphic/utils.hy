(import
  [pyglet.gl :as gl]
  [pyglet.graphics [vertex_list]]
  [pyglet.image]
  [pyglet.image.codecs.png [PNGImageDecoder]]
  [lib.windows [getRenderTexture :as _getRenderTexture]]
  [math [cos sin pi]]
  [time [time]]
  [lib.graphic.transforming [*]]
  [lib.graphic.coloring [*]])

(require hy.contrib.multi)


(defun time2rad [&optional [mult 1]]
  "trigonometric functions don't handle really hight numbers"
  (% (* mult (time)) (* 2 pi)))


(defclass _Entity []
  "
  Base class of drawing primitives
  "
  [[vertsGl None]
   [n 4]
   [slist []]
   [wlist []]

   [_definePolygon
     (with-decorator staticmethod (fn []))]

   [__init__
     (fn [self]
         (setv self.r 1)

         (setv [self.x self.y self.z]
               [0 0 0])

         (setv self.fill
               [1 1 1 1])
         (setv self.stroke
               [1 1 1 1])
         None)]

   [draw
     (fn [self])]])


(defclass _PolInt [_Entity]
  "
  Interface of polygon classes
  "
  [[_definePolygon
      (with-decorator staticmethod (fn [c n]
                                       (setv c.n n)))]

   [draw
     (fn [self]
         (when (!= self.r 0)  ; TODO do something else, please

           (gl.glTranslatef self.x
                            self.y
                            self.z)
           (gl.glScalef self.r
                        self.r
                        1)

           (unless self.wlist
             (setv self.wlist
                   (vertex_list self.n
                                (tuple ["v2f/static"
                                        (flatten
                                          (map (fn [i]
                                                   (setv theta
                                                         (-> (/ pi self.n)
                                                             (* 2 i)))
                                                   [(cos theta) (sin theta)])
                                               (range self.n)))])
                                (tuple ["c4f/stream"
                                        (* [1] 4
                                           self.n)]))))

           (unless self.slist
             (setv self.slist
                   (vertex_list (* self.n 3)
                                (tuple ["v2f/static"
                                        (flatten
                                          (map (fn [i]
                                                   (setv dtheta
                                                         (* 2 (/ pi self.n)))
                                                   (setv theta0
                                                         (* i dtheta))
                                                   (setv theta1
                                                         (+ theta0 dtheta))
                                                   [ 0 0
                                                     (cos theta0) (sin theta0)
                                                     (cos theta1) (sin theta1)])
                                               (range self.n)))])
                                (tuple ["c4f/stream"
                                        (* [1] 4
                                           (* self.n 3))]))))

           (setv self.wlist.colors (* (color self.stroke)
                                      self.n))
           (setv self.slist.colors (* (color self.fill)
                                      (* self.n 3)))

           (.draw self.slist gl.GL_TRIANGLES)
           (.draw self.wlist gl.GL_LINE_LOOP)

           (gl.glScalef (/ 1 self.r)
                        (/ 1 self.r)
                        1)
           (gl.glTranslatef (- self.x)
                            (- self.y)
                            (- self.z))))]])


(defn Polygon [n]
  "
  Generates a new polygon class, with the given number of sides,
  and return an instance
  "
  (defclass PolClass [_PolInt] [])
  (._definePolygon PolClass PolClass n)
  (PolClass))


(defclass _Blittable [_Entity]
  "
  Base image
  "
  [[__init__
      (fn [self blittable]
          (.__init__ _Entity self)
          (setv self.blittable blittable)
          None)]

   [draw
     (fn [self]
         (setv w (* 2 self.r))
         (setv h (* -2 self.r))
         (if self.blittable
           (.blit self.blittable
                  (- self.x (/ w 2))
                  (- self.y (/ h 2))
                  self.z
                  w h)))]])


(defclass _Frame [_Blittable]
  "
  Gets framebuffer from renderer window and displays it
  "
  [ [draw
      (fn [self]
          (setv self.blittable (_getRenderTexture))
          (.draw _Blittable self))]])

(defn Frame [] (_Frame None))

(defclass Image [_Blittable]
  "
  Image from png file
  "
  [[__init__
     (fn [self name]
         (.__init__ _Blittable
                    self
                    (apply pyglet.image.load
                           [(+ "images/" name ".png")]
                           {"decoder" (PNGImageDecoder)}))
         None)]])
