# raytracer - 
# $Id: scene2.rb 2010-08-18 21:22:42 nineties $

require 'raytracer'

raytracer = Raytracer.new
raytracer.window_width  = 800
raytracer.window_height = 600

raytracer << Plane.new(
    Material.new(Color.new(0.4, 0.3, 0.3), 1.0),
    Vector.new(0.0, 1.0, 0.0),
    Vector.new(0.0, -4.4, 0.0)
)

raytracer << Sphere.new(
    Material.new(Color.new(0.7, 0.7, 1.0), 0.0, 0.2, 1.3),
    Vector.new(2.0, 0.8, 3.0),
    2.5
)

raytracer << Sphere.new(
    Material.new(Color.new(0.7, 0.7, 1.0), 0.1, 0.5, 1.3),
    Vector.new(-5.5, -0.5, 7.0),
    2.0
)

raytracer << Light.new(
    Color.new(0.4, 0.4, 0.4),
    Vector.new(0.0, 5.0, 5.0),
    0.1
)

raytracer << Light.new(
    Color.new(0.6, 0.6, 0.8),
    Vector.new(-3.0, 5.0, 1.0),
    0.1
)

raytracer << Sphere.new(
    Material.new(Color.new(1.0, 0.4, 0.4), 0.0, 0.0, 0.8),
    Vector.new(-1.5, -3.8, 1.0),
    1.5
)

raytracer << Plane.new(
    Material.new(Color.new(0.5, 0.3, 0.5), 0.6, 0.0, 0.0, 0.0),
    Vector.new(0.4, 0.0, -1.0),
    Vector.new(0.0, 0.0, 12.0)
)

raytracer << Plane.new(
    Material.new(Color.new(0.4, 0.7, 0.7), 0.5, 0.0, 0.0, 0.0),
    Vector.new(0.0, -1.0, 0.0),
    Vector.new(0.0, 7.4, 0.0)
)

mat = Material.new(Color.new(0.3, 1.0, 0.4), 0.6, 0.0, 0.0, 0.6)
(0..7).each do |x|
    (0..7).each do |y|
        raytracer << Sphere.new(mat, Vector.new(-4.5 + x * 1.5, -4.3 + y * 1.5, 10.0), 0.3)
    end
end

raytracer.render
