# adaptation of stolen code from Luxor
function egg(radius, action=:none)
    A, B = [L.Point(x, 0) for x in [-radius, radius]]
    nints, C, D =
        L.intersectionlinecircle(Point(0, -2radius), L.Point(0, 2radius), A, 2radius)

    flag, C1 = L.intersectionlinecircle(C, D, O, radius)
    nints, I3, I4 = L.intersectionlinecircle(A, C1, A, 2radius)
    nints, I1, I2 = L.intersectionlinecircle(B, C1, B, 2radius)

    if L.norm(C1, I1) < L.norm(C1, I2)
        ip1 = I1
    else
        ip1 = I2
    end
    if L.norm(C1, I3) < L.norm(C1, I4)
        ip2 = I3
    else
        ip2 = I4
    end
    L.newpath()
    L.arc2r(B, A, ip1, :path)
    L.arc2r(C1, ip1, ip2, :path)
    L.arc2r(A, ip2, B, :path)
    L.arc2r(O, B, A, :path)
    L.closepath()
    L.do_action(action)
end

function eggsdemo(radius, action=:none)
    L.setopacity(0.7)
    for theta in range(0, pi/6, 12)
        L.@layer begin
            L.rotate(theta)
            L.translate(0, -150)
            egg(50, :path)
            L.setline(10)
            L.randomhue()
            L.fillpreserve()
            L.randomhue()
            L.strokepath()
        end
    end
end
