# adaptation of stolen code from Luxor
    function starsdemo()
        # L.background(curcolor) # hide
        L.origin() # hide
        tiles = L.Tiler(400, 300, 4, 6, margin=5)
        for (pos, n) in tiles
            L.randomhue()
            L.star(pos, tiles.tilewidth/3, rand(3:8), 0.5, 0, :fill)
        end
    end
    function luxordemo()
        stardemo()
    end
