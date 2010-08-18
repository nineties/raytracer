# raytracer - 
# $Id: scene1.rb 2010-08-18 21:22:37 nineties $

require 'raytracer'

raytracer = Raytracer.new
raytracer.window_width  = 800
raytracer.window_height = 600

raytracer << Plane.new(
    Material.new(Color.new(0.4, 0.3, 0.3), 1.0),
    Vector.new(0.0, 1.0, 0.0),
    Vector.new(0.0, -4.0, 0.0)
)

raytracer << Sphere.new(
    Material.new(Color.new(0.7, 0.7, 0.7), 0.0, 0.2, 1.3),
    Vector.new(1.0, -0.8, 3.0),
    2.5
)

raytracer << Sphere.new(
    Material.new(Color.new(0.7, 0.7, 1.0), 0.1, 1.0),
    Vector.new(-5.5, -0.5, 7.0),
    2.0
)

raytracer << Light.new(
    Color.new(0.6, 0.6, 0.6),
    Vector.new(0.0, 5.0, 5.0),
    0.1
)

raytracer << Light.new(
    Color.new(0.7, 0.7, 0.9),
    Vector.new(2.0, 5.0, 1.0),
    0.1
)

raytracer.render
