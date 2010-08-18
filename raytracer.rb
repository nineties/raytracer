# raytracer - 
# $Id: raytracer.rb 2010-08-18 20:48:53 nineties $

class Vector
    def initialize(x, y, z)
        @x = x
        @y = y
        @z = z
    end
    def length
        Math.sqrt(@x * @x + @y * @y + @z * @z)
    end
    def normalize
        l = 1 / length()
        @x *= l
        @y *= l
        @z *= l
        self
    end
    def + (v)
        Vector.new(@x + v.x, @y + v.y, @z + v.z)
    end
    def - (v)
        Vector.new(@x - v.x, @y - v.y, @z - v.z)
    end
    def * (t)
        if t.kind_of?(Vector) then
            Vector.new(@x * t.x, @y * t.y, @z * t.z)
        else
            Vector.new(@x * t, @y * t, @z * t)
        end
    end
    attr_accessor :x, :y, :z
end

def iprod(u, v)
    u.x * v.x + u.y * v.y + u.z * v.z
end

Color = Vector

# objects
class Material
    def initialize(color, diffuse = 0.0, reflection = 0.0, refraction = 0.0, specular = -1.0)
        @color = color
        @diffuse = diffuse
        @reflection = reflection
        @refraction = refraction
        @specular = specular
        @specular = 1.0 - @diffuse if specular < 0
    end
    attr_accessor :color, :diffuse, :reflection, :refraction, :specular
end

class Ray
    def initialize(origin, direction, distance = Float::MAX)
        @origin    = origin
        @direction = direction.normalize
        @distance  = distance
        @inside    = false
        @hit = nil
    end
    def terminal
        @origin + @direction * @distance
    end
    attr_accessor :origin, :direction, :distance, :inside, :hit
end

class Primitive
    attr_accessor :material
end

class Sphere < Primitive
    def initialize(mat, center, radius)
        @material = mat
        @center = center
        @radius = radius
    end
    def intersect(ray)
        c = @center - ray.origin
        cd = iprod(c, ray.direction)
        det = @radius * @radius - iprod(c, c) + cd * cd
        if det > 0 then
            det = Math.sqrt(det)
            d1 = cd + det
            d2 = cd - det
            return if d1 < 0
            if d2 < 0 then
                if d1 < ray.distance then
                    ray.distance = d1
                    ray.hit = self
                    ray.inside = true
                end
            else
                if d2 < ray.distance then
                    ray.distance = d2
                    ray.hit = self
                    ray.inside = false
                end
            end
        end
    end
    def normal(point)
        n = point - @center
        n.normalize
    end
    attr_reader :center, :radius
end

class Plane < Primitive
    def initialize(mat, normal, point)
        @material = mat
        @normal = normal.normalize
        @const = iprod(normal, point)
    end
    def intersect(ray)
        d = iprod(@normal, ray.direction)
        if d != 0 then
            l = (@const - iprod(ray.origin, @normal))/d
            return nil if l < 0
            if l < ray.distance then
                ray.distance = l
                ray.hit = self
                ray.inside = false
            end
        end
    end
    def normal(point)
        @normal
    end
end

class Light < Sphere
    def initialize(color, center, radius)
        super(Material.new(color), center, radius)
    end
end

class Raytracer
    def initialize
        @window_width  = 800
        @window_height = 600
        @view_width    = 7.0
        @view_height   = 5.25

        @origin = Vector.new(0.0, 0.0, -5.0)
        @primitives = []
    end
    attr_accessor :window_width, :window_height, :view_width, :view_height
    attr_accessor :origin

    def setup_mapping
        @dx = @view_width / @window_width
        @dy = @view_height / @window_height
        @left = -@view_width/2
        @top  = @view_height/2
    end

    def << (prim)
        @primitives << prim
    end

    def render
        setup_mapping
        print "P3\n#{@window_width} #{@window_height}\n255\n"
        y = @top
        @window_height.times do
            x = @left
            @window_width.times do 
                dir = Vector.new(x, y, 0.0) - @origin
                ray = Ray.new(@origin, dir)
                color = trace(ray, 1, 1.0)
                if color then
                    r = (color.x * 255).to_i
                    g = (color.y * 255).to_i
                    b = (color.z * 255).to_i
                    r = 255 if r > 255
                    g = 255 if g > 255
                    b = 255 if b > 255
                    print "#{r} #{g} #{b} "
                else
                    print "0 0 0 "
                end
                x += @dx
            end
            print "\n"
            y -= @dy
        end
    end

    DEPTH_MAX = 6
    EPSILON   = 0.0001
    def trace(ray, depth, cur_refr)
        return nil if depth > DEPTH_MAX
        ray.hit = nil
        @primitives.each do |prim|
            prim.intersect(ray)
        end
        return nil unless ray.hit
        prim = ray.hit
        if prim.kind_of?(Light) then
            return Color.new(1.0, 1.0, 1.0)
        else
            color = Color.new(0.0, 0.0, 0.0)

            # interaction point
            ip = ray.terminal

            # handle lights
            @primitives.each do |light|
                next unless light.kind_of?(Light)

                l = light.center - ip
                r = Ray.new(ip + l * EPSILON, l, l.length)

                shade = 1.0
                @primitives.each do |prim|
                    next if prim == light
                    prim.intersect(r)
                    if r.hit then
                        shade = 0.0
                        break
                    end
                end

                n = prim.normal(ip)
                l.normalize

                # diffuse shading
                if prim.material.diffuse > 0 then
                    d = iprod(n, l)
                    if d > 0 then
                        diffuse = d * prim.material.diffuse * shade
                        color += prim.material.color * light.material.color * diffuse
                    end
                end
                # specular
                if prim.material.specular > 0 then
                    r = l - n * 2.0 * iprod(l, n)
                    d = iprod(ray.direction, r)
                    if d > 0 then
                        specular = d**20 * prim.material.specular * shade
                        color += light.material.color * specular
                    end
                end
            end

            # reflection
            refl = prim.material.reflection
            if refl > 0 then
                n = prim.normal(ip)
                r = ray.direction - n * 2.0 * iprod(ray.direction, n)
                c = trace(Ray.new(ip + r * EPSILON, r), depth + 1, cur_refr)
                color += c * prim.material.color * refl if c
            end

            # refraction
            refr = prim.material.refraction
            if refr > 0 then
                n = cur_refr / refr 
                norm = prim.normal(ip)
                norm *= -1 if ray.inside
                cosI = iprod(norm, ray.direction)
                cosT2 = 1.0 - n*n*(1.0 - cosI * cosI)
                if cosT2 > 0 then
                    t = ray.direction * n + norm * (n * cosI - Math.sqrt(cosT2))
                    ray = Ray.new(ip + t * EPSILON, t)
                    c = trace(ray, depth + 1, refr)
                    if c then
                       # Beer's law
                       absorbance = prim.material.color * 0.15 * (-ray.distance)
                       transparency = Color.new(
                           Math.exp(absorbance.x),
                           Math.exp(absorbance.y),
                           Math.exp(absorbance.z)
                       )
                       color += transparency * c
                    end
                end
            end

            color
        end
    end
end

