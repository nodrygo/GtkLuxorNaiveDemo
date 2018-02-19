function drawneedle(l)
    p0  = L.Point(1,1)
    pp1 = L.Point(5,l/2)
    pp2 = L.Point(0,l)
    pp3 = L.Point(-5,l/2)
    L.setline(3)
    ptlist = [p0,pp1,pp2,pp3]
    ptlist2 = [p0,pp1+(2, 0),pp2,pp3-(2, 0)]
    L.sethue("ivory")
    L.poly(ptlist, :fill, close=true)
    L.sethue("gold4")
    L.poly(ptlist2, :stroke, close=true)

end
function clockdemo(radius, action=:none)
    t  = now()
    txtday = Dates.dayname(t;locale="french")
    txtmonth = Dates.monthname(t;locale="french")
    s  = Dates.second(t)
    m  = Dates.minute(t)
    h  = Dates.hour(t)
    yy = Dates.year(t)
    p0 = L.Point(0,0)
    L.origin()
    L.setopacity(0.7)
    L.background("lavender")
    #draw 12 lines
    for theta in range(0, pi/6, 12)
        L.@layer begin
            L.rotate(theta)
            L.translate(0, -200)
            L.sethue("black")
            L.setline(3)
            L.line(p0,L.Point(0,10), :stroke)
        end
    end
    # draw quarters
    for theta in range(0, pi/2, 4)
        L.@layer begin
            L.rotate(theta)
            L.translate(0, -200)
            L.sethue("gold3")
            L.star(0,0, 20,6, 0.5, 0, :fill)
        end
    end
    # draw seconds
    L.rotate(0)
    for theta in range(0, pi/30, s+1)
            L.origin()
            L.rotate(theta)
            L.translate(0, -230)
            L.sethue("red")
            L.circle(0,0, 4, :fill)
    end

    #draw drawneedle for hour
    L.origin()
    L.rotate(pi+(h*(pi/6)))
    drawneedle(120)
    #draw drawneedle for minutes
    L.origin()
    L.rotate(pi+(m*(pi/30)))
    drawneedle(185)


    L.origin()
    L.sethue("black")
    L.circle(0,0, 10, :fill)
    L.sethue("blue")
    fontface("Agenda-Black")
    fontsize(20)
    L.text(txtday * " " *  lpad(Dates.day(t),2,0) * " "* txtmonth,0,-80,halign=:center)
    L.text("$yy",0,-40,halign=:center)
    fontsize(40)
    L.text(lpad(h,2,0) *":" * lpad(m,2,0) *":" * lpad(s,2,0),0,50,halign=:center)


end
