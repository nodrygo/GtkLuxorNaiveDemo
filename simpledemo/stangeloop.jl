using Luxor, Colors, ColorSchemes,Statistics
# adaptation of stolen code from Luxor
function strange(dotsize, w=800.0)
    xmin = -2.0; xmax = 2.0; ymin= -2.0; ymax = 2.0
    cs = ColorSchemes.botticelli
    L.origin()
    L.background("white")
    xinc = w/(xmax - xmin)
    yinc = w/(ymax - ymin)
    # control parameters
    a = 2.24; b = 0.43; c = -0.65; d = -2.43; e1 = 1.0
    x = y = z = 0.0
    wover2 = w/2
    for j in 1:w
        for i in 1:w
            xx = sin(a * y) - z  *  cos(b * x)
            yy = z * sin(c * x) - cos(d * y)
            zz = e1 * sin(x)
            x = xx; y = yy; z = zz
            if xx < xmax && xx > xmin && yy < ymax && yy > ymin
                xpos = L.rescale(xx, xmin, xmax, -wover2, wover2) # scale to range
                ypos = L.rescale(yy, ymin, ymax, -wover2, wover2) # scale to range
                col1 = L.get(cs, rescale(xx, -1, 1, 0.0, .5))
                col2 = L.get(cs, rescale(yy, -1, 1, 0.0, .4))
                col3 = L.get(cs, rescale(zz, -1, 1, 0.0, .2))
                L.sethue(mean([col1, col2, col3]))
                L.circle(L.Point(xpos, ypos), dotsize, :fill)
            end
        end
    end
end
