module GtkLuxorNanoCad
    import Luxor
    import Gtk
    # using Gtk.Window
    using Gtk.ShortNames
    using Gtk.GConstants
    import Graphics
    using Colors, Cairo, Compat, FileIO

    global L=Luxor
    global winx = 1200
    global winy = 800
    global cursorposx = 0
    global cursorposy = 0
    global lastcursorposx = 0
    global lastcursorposy = 0
    global needdrawgrid = false
    global needredraw = true
    global needgrid = true
    global bgcolor = "cyan"
    global fgcolor = "black"
    global curzoom = 1.0
    global curgrid = 10
    global entities = []
    global showcursorpos = false
    global showaxes = true
    global panx = 0.0
    global pany = 0.0

    include("extendGtk.jl")
    include("cadMenus.jl")
    include("entities.jl")
    include("shapepoint.jl")
    include("shaperect.jl")
    include("shapecircle.jl")


    push!(entities,ShPoint(20,30))
    r0 = ShRect(20,30,20,20)
    r1 = ShRect(50,80,50,50)
    r3 = ShRect(600,600,400,400)
    r0.shape.size = 2
    r1.shape.size = 10
    r3.shape.size = 10
    r2 = ShRect(100,350,200,100)
    r2.shape.size = 2
    r2.shape.dash = "dotted"
    r2.shape.selected=true
    c1 = ShCircleRadius(400,500,50)
    c1.shape.bg = "green"
    c1.shape.fg = "darkblue"
    c1.shape.size=8
    c2 = ShCircle3Pts(150,150,150,250,200,200)
    c2.shape.selected = true
    push!(entities,r0)
    push!(entities,r1)
    push!(entities,r2)
    push!(entities,r3)
    push!(entities,c1)
    push!(entities,c2)

    function myLuxDraw()
        global panx,pany
        # reset origin
        L.setmatrix([1.0, 0.0, 0.0, 1.0, 0.0, 0.0])
        L.translate(-panx,-pany)
        L.background(bgcolor)
        L.scale(curzoom,curzoom)
        #### draw entities
        for e in entities
           sdraw(e)
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
    function drawgrid(ctx,w,h)
            Cairo.save(ctx)
            Cairo.set_source_rgba(ctx, 1, 0, 0 , 255)
            Cairo.set_line_width(ctx, 1.0);
            for i in range(0 ,step=curgrid,stop=w)
                for j in  range(0, step=curgrid, stop=h)
                    Cairo.circle(ctx,i,j, 1)
                    Cairo.stroke(ctx)
                end
            end
            Cairo.restore(ctx)
    end
    function drawcursor(ctx,w,h)
        global showcursorpos,cursorposx,cursorposy
        Cairo.save(ctx)
        Cairo.set_source_rgba(ctx, 1, 0, 0 , 255)
        Cairo.set_line_width(ctx, 2.0)
        Cairo.move_to(ctx, 0, cursorposy)
        Cairo.line_to(ctx, w, cursorposy)
        Cairo.move_to(ctx, cursorposx, 0)
        Cairo.line_to(ctx, cursorposx, h)
        Cairo.set_source_rgba(ctx, 0, 0, 0, 1)
        Cairo.stroke(ctx)
        Cairo.restore(ctx)
        if needdrawgrid
            drawgrid(ctx,w,h)
        end
    end

    function redraw()
                global needredraw = true
    end
    function resetredraw()
        global needredraw = false
    end

    function prtcolor(c)
        if typeof(c)==String
          c
        else
           " RGB=$(round(c.r,digits=3)):$(round(c.r,digits=3)):$(round(c.r,digits=3))"
        end
    end

    function mainwin()
        # main win
        win = Window("NanoCad Test Demo")
        vbox = Box(:v)
        hbox = Box(:h)
        vboxentities = Box(:v)
        vboxcanvas = Box(:v)
        butresetpan = Button("reset pan")
        gridstat = CheckButton("show grid")
        gridcursor = CheckButton("cursor to grid")
        gridscale =  Scale(false,1:10)
        gridadj = Adjustment(gridscale)
        zoomscale = Scale(false,1:10)
        zoomadj = Adjustment(zoomscale)
        butcolbg = ButtonColor()
        butcolfg = ButtonColor()
        sb = Statusbar()
        sbid = Gtk.context_id(sb, "Statusbar example")


        #gtk canvas
        global c =  Canvas(winx,winy)

        # create luxor drawing
        global currentdrawing =  Luxor.Drawing(10000,10000, "gtkluxordemo.png")
        global luxctx = currentdrawing.cr
        #gtk canvas

        entitiesel   = ComboBoxText()
        linetypesel = ComboBoxText()
        #linetype selector
        for choice in  ["rounded", "squared"]
          push!(linetypesel,choice)
        end
        set_gtk_property!(linetypesel,:active,0)
        # model selector
        for choice in ["line","rect","roundedrect","arc","circle_c_r","circle3p"]
          push!(entitiesel,choice)
        end
        set_gtk_property!(entitiesel,:active,1)

        signal_connect(entitiesel, "changed") do widget, others...
          idx = get_gtk_property(entitiesel, "active", Int)
          global curdraw = Gtk.bytestring( GAccessor.active_text(entitiesel) )
        end
        signal_connect(zoomscale, "value-changed") do widget, others...
            valzoom = trunc(Int, get_gtk_property(zoomadj,:value,Float64))
            setzoom(valzoom)
        end
        signal_connect(gridscale, "value-changed") do widget, others...
            global curgrid = trunc(Int, get_gtk_property(gridadj,:value,Float64))*10
            global needredraw = true
            # println(needgrid," ",curgrid)
            Gtk.draw(c)
        end
      (menuBar,toolbarMain) = setMenus()

        @guarded Gtk.draw(c) do widget
            global cursorposx,cursorposy,panx,pany
            ctx = Gtk.getgc(c)
            h = height(c)
            w = width(c)
            Cairo.save(ctx)
            Cairo.set_source_rgba(ctx, 255,255,255,255)
            Cairo.paint(ctx)
            Cairo.restore(ctx)
            if needredraw
               myLuxDraw()
            end
            Cairo.set_source_surface(ctx, currentdrawing.surface, panx, pany)
            # Cairo.rectangle(ctx,-panx, pany, w+panx , h+pany)
            Cairo.paint(ctx)
            Gtk.fill(ctx)
            drawcursor(ctx,w,h)
            resetredraw()
        end


        signal_connect(gridstat, :toggled) do widget
            # print(" toggle  ")
            if get_gtk_property(gridstat, :active, Bool)
                # println("set grid")
                global needdrawgrid = true
            else
                # println("hide grid")
                global needdrawgrid = false
            end
            # global togglegrid = true
            redraw()
            draw(c)
        end

        c.mouse.button3press = @guarded (widget, event) -> begin
            ctx = Gtk.getgc(widget)
            global panx =  panx + event.x
            global pany =  pany + event.y
            redraw()
            draw(c)
        end
        c.mouse.button1press = @guarded (widget, event) -> begin
            ctx = Gtk.getgc(widget)
            global cursorposx = round(event.x)
            global cursorposy = round(event.y)
            global panx =  panx - cursorposx
            global pany =  pany - cursorposy
            # println("cx",cursorposx," cy",cursorposy," px",panx," py",pany)
            redraw()
            draw(c)
        end

        signal_connect(c, "motion-notify-event") do widget, others...
            global bgcolor,fgcolor, panx,pany
            ev = others[1]
            global cursorposx = round(ev.x)
            global cursorposy = round(ev.y)
            pop!(sb, sbid)
            push!(sb, sbid, string("Cursor Coord x:", cursorposx+panx ,
                                                  " y:", cursorposy+pany ,
                                                  " \t bgcol: ",
                                                  prtcolor(bgcolor),
                                                  " \t fgcolor: ",
                                                  prtcolor(fgcolor)))
            draw(c)
        end

        signal_connect(butcolbg, "color-set") do widget
          ncol = gtk_color_butcol_get_rgba(widget)
          retcol = Colors.RGBA(ncol.r,ncol.g,ncol.b,1.0)
          global  bgcolor = retcol
          redraw()
          draw(c)
        end

        signal_connect(butcolfg, "color-set") do widget
          ncol = gtk_color_butcol_get_rgba(widget)
          retcol = Colors.RGBA(ncol.r,ncol.g,ncol.b,1.0)
          global  fgcolor = retcol
          redraw()
          draw(c)
        end

        signal_connect(butresetpan, "clicked") do widget
          global  panx,pany
          panx = -0
          pany = -0
          redraw()
          draw(c)
        end
        #setproperty!(vbox,:border_width,1)
        push!(win, vbox)
        push!(vbox, menuBar)
        push!(vbox, toolbarMain)
        push!(vbox, hbox)
        push!(vbox,sb)
        push!(hbox,vboxentities)
        push!(hbox,vboxcanvas)
        push!(vboxentities, butresetpan)
        push!(vboxentities, gridstat)
        push!(vboxentities, Label(" "))
        push!(vboxentities, Label("Grid Size"))
        push!(vboxentities, gridscale)
        push!(vboxentities, Label("Zoom Factor"))
        push!(vboxentities, zoomscale)
        push!(vboxentities, linetypesel)
        push!(vboxentities, entitiesel)
        push!(vboxentities, Label("BackColor"))
        push!(vboxentities, butcolbg)
        push!(vboxentities, Label("ForeColor"))
        push!(vboxentities, butcolfg)
        push!(vboxcanvas, c)
        signal_connect(win, :destroy) do widget
        end
        Gtk.showall(win)
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
end
# if interactive
    if isinteractive()
        win = GtkLuxorNanoCad.mainwin()
    end
