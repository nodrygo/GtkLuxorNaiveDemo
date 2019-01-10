include("shapepoint.jl")

mutable struct ShCircleRadius
    shape::EShape
    center::ShPoint
    radius::Float64
    ShCircleRadius() = new(EShape(),ShPoint(),10)
    ShCircleRadius(x1,y1,r) = new(EShape(),ShPoint(x1,y1),r)
end
mutable struct ShCircle3Pts
    shape::EShape
    p1::ShPoint
    p2::ShPoint
    p3::ShPoint
    ShCircle3Pts() = new(EShape(),ShPoint(),ShPoint(),ShPoint())
    ShCircle3Pts(x1,y1,x2,y2,x3,y3) = new(EShape(),ShPoint(x1,y1),ShPoint(x2,y2),ShPoint(x3,y3))
end

function move(e::ShCircleRadius,dx,dy)
    e.center = move(e.center,dx,dy)
    e
end
function move(e::ShCircle3Pts,dx,dy)
    e
end

function sdrawcircle(x,y,r,e)
   Luxor.sethue(e.shape.bg)
   Luxor.circle(x,y,r, :fill)
   Luxor.sethue(e.shape.fg)
   sdrawshape(e.shape)
   Luxor.circle(x,y,r, :stroke)
end

function sdraw(e::ShCircleRadius)
   Luxor.gsave()
   Luxor.translate(e.center.x,e.center.y)
   sdrawcircle(0,0,e.radius,e)
   if e.shape.selected
      sdrawboundary(e)
   end
   Luxor.grestore()
end

function sdraw(e::ShCircle3Pts)
   Luxor.gsave()
   Luxor.translate(0,0)
   p1 = Luxor.Point(e.p1.x,e.p1.y)
   p2 = Luxor.Point(e.p2.x,e.p2.y)
   p3 = Luxor.Point(e.p3.x,e.p3.y)
   #println("p1=",p1,"p2=",p2,"p3=",p3)
   (c::Luxor.Point,r) =  Luxor.center3pts(p1, p2, p3)
   #println(c, "  ",c.x ,"  ", c.y,"   r",r)
   sdrawcircle(c.x,c.y,r,e)
   if e.shape.selected
      sdrawboundary(e)
   end
   Luxor.grestore()
end
function sdrawboundary(e::ShCircleRadius)
   Luxor.setcolor("red")
   Luxor.circle(0,0,5, :fill)
end
function sdrawboundary(e::ShCircle3Pts)
   Luxor.setcolor("red")
   Luxor.circle(e.p1.x,e.p1.y,5, :fill)
   Luxor.circle(e.p2.x,e.p2.y,5, :fill)
   Luxor.circle(e.p3.x,e.p3.y,5, :fill)
end
