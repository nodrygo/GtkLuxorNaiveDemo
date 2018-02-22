# adaptation of stolen code from Luxor
function colornames()
    L.origin()
    L.sethue("white")
    L.fontface("Agenda-Black")
    L.fontsize(10)
    cols = L.collect(Colors.color_names)
    tiles = L.Tiler(800, 600, 10, 10)
    for (pos, n) in tiles
        L.sethue(cols[n][1])
        L.box(pos, tiles.tilewidth, tiles.tileheight, :fill)
        clab = L.convert(Lab, L.parse(Colorant, cols[n][1]))
        labelbrightness = 100 - clab.l
        L.sethue(L.convert(RGB, L.Lab(labelbrightness, clab.b, clab.a)))
        L.text(string(cols[n][1]), pos, halign=:center)
    end
end
