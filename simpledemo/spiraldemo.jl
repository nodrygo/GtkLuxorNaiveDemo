# adaptation of stolen code from Luxor
function spiraldemo()
    sp = L.spiral(4, 1, stepby=pi/24, period=12pi, vertices=true)

    for i in 1:10
        L.setgray(i/10)
        L.setline(22-2i)
        L.poly(sp, :stroke)
    end
end
