module GtkLuxorNanoCad
    import Luxor
    importall Gtk
    using Gtk.Window
    using Gtk.ShortNames
    using Gtk.GConstants
    importall Graphics
    using Colors, Cairo, Compat, FileIO

    global L=Luxor
    global winx = 1000
    global winy = 800
    global cursorposx = 0
    global cursorposy = 0
    global drawgrid = false
    global needredraw = true
    global needgrid = true
    global bgcolor = "white"
    global fgcolor = "black"
    global curzoom = 1.0
    global curgrid = 10

    include("cadMenus.jl")


    function mydraw(ctx,w,h,grid)
        L.background(bgcolor)
        L.origin()
        if grid
            # print("drawgrid :")
            L.sethue("black")
            # println("$c")
            mx = trunc(Int, w / 2)
            my = trunc(Int, h / 2)
            # println("$mx $my")
            for j in range(-my ,curgrid,my)
                for i in  range(-mx, curgrid, mx)
                        L.circle(i,j, 1, :fill)
                end
            end
        end
        L.scale(curzoom,curzoom)
        #### draw entities
        sp = L.spiral(4, 1, stepby=pi/24, period=12pi, vertices=true)
        for i in 1:10
            L.setgray(i/10)
            L.setline(22-2i)
            L.poly(sp, :stroke)
        end
    end

function setzoom(x)
        global curzoom = x
        global needredraw = true
        Gtk.draw(c)
end
function deczoom()
    if curzoom > 1
        global curzoom = curzoom - 1
        global needredraw = true
        Gtk.draw(c)
    end
end
function inczoom()
    if curzoom < 10
        global curzoom = curzoom + 1
        global needredraw = true
        Gtk.draw(c)
    end
end
    function drawcursor(ctx,w,h)
        Cairo.save(ctx)
        Cairo.set_source_rgba(ctx, 1, 0, 0 , 255)
        Cairo.set_line_width(ctx, 2.0);
        Cairo.move_to(ctx, 0, cursorposy)
        Cairo.line_to(ctx, w, cursorposy)
        Cairo.move_to(ctx, cursorposx, 0)
        Cairo.line_to(ctx, cursorposx, h)
        Cairo.set_source_rgba(ctx, 0, 0, 0, 1)
        Cairo.stroke(ctx)
        Cairo.restore(ctx)
    end

    function redraw()
            if drawgrid
                global needgrid = true
                global needredraw = true
            else
                global needgrid = false
                global needredraw = true
            end
    end
    function resetredraw()
        global needredraw = false
    end

    function mainwin()
        # main win
        win = GtkWindow("NanoCad Test Demo")
        vbox = GtkBox(:v)
        hbox = GtkBox(:h)
        vboxentities = GtkBox(:v)
        vboxcanvas = GtkBox(:v)
        gridstat = CheckButton("show grid")
        gridscale =  Scale(false,1:10)
        gridadj = Adjustment(gridscale)
        zoomscale = Scale(false,1:10)
        zoomadj = Adjustment(zoomscale)
        #gtk canvas
        global c =  Canvas(winx,winy)

        # create luxor drawing
        global currentdrawing =  L.Drawing(winx,winy, "gtkluxordemo.png")
        global luxctx = currentdrawing.cr
        #gtk canvas

        entitiesel   = GtkComboBoxText()
        colorsel = GtkComboBoxText()
        #color selector
        for choice in  ["black", "red", "blue", "green"]
          push!(colorsel,choice)
        end
        setproperty!(colorsel,:active,0)
        # model selector
        for choice in ["line","rect","roundedrect","arc","circle_c_r","circle3p"]
          push!(entitiesel,choice)
        end
        setproperty!(entitiesel,:active,1)

        #change color
        signal_connect(colorsel, "changed") do widget, others...
          idx = getproperty(colorsel, "active", Int)
          global curcolor = Gtk.bytestring( GAccessor.active_text(colorsel) )
          Gtk.draw(c)
        end
        signal_connect(entitiesel, "changed") do widget, others...
          idx = getproperty(entitiesel, "active", Int)
          global curdraw = Gtk.bytestring( GAccessor.active_text(entitiesel) )
        end
        signal_connect(zoomscale, "value-changed") do widget, others...
            valzoom = trunc(Int, getproperty(zoomadj,:value,Float64))
            println("VALZOOM = $valzoom")
            # global needredraw = true
            # Gtk.draw(c)
            setzoom(valzoom)
        end
        signal_connect(gridscale, "value-changed") do widget, others...
            global curgrid = trunc(Int, getproperty(gridadj,:value,Float64))*10
            global needredraw = true
            Gtk.draw(c)
        end
      (menuBar,toolbarMain) = setMenus()

        @guarded Gtk.draw(c) do widget
            ctx = Gtk.getgc(c)
            h = height(c)
            w = width(c)
            Cairo.save(ctx)
            Cairo.set_source_rgba(ctx, 255,255,255,255);
            Cairo.paint(ctx);
            Cairo.restore(ctx)
            if needredraw
               mydraw(ctx,w,h,needgrid)
            end
            Cairo.set_source_surface(ctx, currentdrawing.surface, 0, 0)
            Cairo.paint(ctx)
            Gtk.fill(ctx)
            drawcursor(ctx,w,h)
            resetredraw()
        end

        c.mouse.button1press = @guarded (widget, event) -> begin
            ctx = getgc(widget)
            set_source_rgba(ctx, 0, 0, 0, 1)
            arc(ctx, event.x, event.y, 8, 0, 2pi)
            stroke(ctx)
            reveal(widget)
        end

        signal_connect(gridstat, :toggled) do widget
            # print(" toggle  ")
            if getproperty(gridstat, :active, Bool)
                # println("set grid")
                global drawgrid = true
            else
                # println("hide grid")
                global drawgrid = false
            end
            # global togglegrid = true
            redraw()
            draw(c)
        end

        signal_connect(c, "motion-notify-event") do widget, others...
            ev = others[1]
            global cursorposx = ev.x
            global cursorposy = ev.y
            draw(c)
        end

        # c.mouse.button3press = (widget,event) -> popup(popupmenu, event)
        # signal_connect(printcolor, :activate) do widget
        #     println("Red or Yellow???")
        # end

        #setproperty!(vbox,:border_width,1)
        push!(win, vbox)
        push!(vbox, menuBar)
        push!(vbox, toolbarMain)
        push!(vbox, hbox)
        push!(hbox,vboxentities)
        push!(hbox,vboxcanvas)
        push!(vboxentities, colorsel)
        push!(vboxentities, entitiesel)
        push!(vboxentities, gridstat)
        push!(vboxentities, Label(" "))
        push!(vboxentities, Label("Grid Size"))
        push!(vboxentities, gridscale)
        push!(vboxentities, Label("Zoom Factor"))
        push!(vboxentities, zoomscale)
        push!(vboxcanvas, c)
        showall(win)
        redraw()
        win
    end

    # function main for static compiler
    Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
        win = mainwin()
    	if !isinteractive()
    	    c = Condition()
    	    signal_connect(win, :destroy) do widget
    		notify(c)
    	    end
    	    wait(c)
    	end
        return 0
    end

# if interactive
    if isinteractive()
        win = mainwin()
        signal_connect(win, :destroy) do widget
        end
    end
end
