include("shapepoint.jl")

mutable struct ShRect
    shape::EShape
    corner1::ShPoint
    corner2::ShPoint
    ShRect() = new(EShape(),ShPoint(),10,10)
    ShRect(x1,y1,x2,y2) = new(EShape(),ShPoint(x1,y1),ShPoint(x2,y2))
end

function move(e::ShRect,dx,dy)
    elem.corner1 = move(elem.corner1,dx,dy)
    elem.corner2 = move(elem.corner2,dx,dy)
    elem
end

function sdraw(e::ShRect)
   global panx,pany
   Luxor.gsave()
   Luxor.translate(e.corner1.x+panx,e.corner1.y+pany)
   Luxor.sethue(e.shape.bg)
   Luxor.rect(0,0,e.corner2.x,e.corner2.y, :fill)
   Luxor.sethue(e.shape.fg)
   sdrawshape(e.shape)
   Luxor.rect(0,0,e.corner2.x,e.corner2.y, :stroke)
   if e.shape.selected
      sdrawboundary(e)
   end
   Luxor.grestore()
end

function sdrawboundary(e::ShRect)
   Luxor.setcolor("red")
   Luxor.circle(0,0,5, :fill)
   Luxor.circle(0,e.corner2.y,5, :fill)
   Luxor.circle(e.corner2.x,0,5, :fill)
   Luxor.circle(e.corner2.x,e.corner2.y,5, :fill)
end
