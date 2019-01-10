mutable struct EShape
    fg::String
    bg::String
    size::Float64
    rotate::Float64
    dash::String  ### "solid", "dotted", "dot", "dotdashed", "longdashed",
                  ### "shortdashed", "dash", "dashed", "dotdotdashed", "dotdotdotdashed"
    join::String  ### "round", "miter", "bevel"
    cap::String   ###"butt", "square", "round"
    selected::Bool
    EShape()=new("black","green",0,0,"solid","round","round",false)
end

mutable struct ShPoint
    x::Float64
    y::Float64
    shape::EShape
    ShPoint() = new(0,0,EShape())
    ShPoint(x,y) = new(x,y,EShape())
end

function translate(e::ShPoint,dx,dy)
    e.x = e.x + dx
    e.y = e.y + dy
    e
end

function sdrawshape(e::EShape)
    Luxor.setline(e.size)
    Luxor.setlinejoin(e.join)
    Luxor.setlinecap(e.cap)
    Luxor.setdash(e.dash)
end

function sdraw(e::ShPoint)
    Luxor.gsave()
    Luxor.translate(e.x,e.y)
    Luxor.sethue("red")
    Luxor.circle(0,0,5, :fill)
    Luxor.strokepath()
    Luxor.grestore()
end

function sdrawboundary(e::ShPoint)
    #do nothing
end
