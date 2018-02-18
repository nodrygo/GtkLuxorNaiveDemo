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
    for theta in range(0, pi/6, 12)
        L.@layer begin
            L.rotate(theta)
            L.translate(0, -200)
            L.sethue("black")
            L.setline(3)
            L.line(p0,L.Point(0,10), :stroke)
        end
    end

    for theta in range(0, pi/2, 4)
        L.@layer begin
            L.rotate(theta)
            L.translate(0, -200)
            L.sethue("black")
            L.star(0,0, 20,6, 0.5, 0, :fill)
        end
    end

    L.rotate(0)
    for theta in range(0, pi/30, s+1)
        L.@layer begin
            L.origin()
            L.rotate(theta)
            L.translate(0, -250)
            L.sethue("red")
            L.circle(0,0, 4, :fill)
        end
    end
    L.origin()
    L.@layer begin
        p0 = L.Point(0, 0)
        ph = L.Point(0, 80)
        pm =  L.Point(0, 160)
        L.origin()
        L.rotate(pi+(h*(pi/6)))
        setline(10)
        sethue("gold")
        line(p0,ph, :stroke)
    end
    L.@layer begin
        L.origin()
        L.rotate(pi+(m*(pi/30)))
        setline(5)
        goldblend = blend(Point(-200, 0), Point(200, 0))
        addstop(goldblend, 0.0,  "gold4")
        addstop(goldblend, 0.25, "gold1")
        addstop(goldblend, 0.5,  "gold3")
        addstop(goldblend, 0.75, "darkgoldenrod4")
        addstop(goldblend, 1.0,  "gold2")
        setblend(goldblend)
        line(p0,pm, :stroke)
    end
    L.origin()
    L.sethue("blue")
    fontface("Agenda-Black")
    fontsize(20)
    L.text(txtday * " " *  lpad(Dates.day(t),2,0) * " "* txtmonth,0,-80,halign=:center)
    L.text("$yy",0,-40,halign=:center)
    fontsize(40)
    L.text(lpad(h,2,0) *":" * lpad(m,2,0) *":" * lpad(s,2,0),0,50,halign=:center)


end
