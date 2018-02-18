module GtkLuxorDemo
    using Gtk
    using Luxor
    using Colors, Cairo, Compat, FileIO
    global L=Luxor
    include("textdemo.jl")
    include("starsdemo.jl")
    include("eggsdemo.jl")

    global winx = 800
    global winy = 600
    global curcolor = "red"
    global curdraw = "textdemo"

    function mydraw()
        L.background("white") # hide
        println("Draw $curdraw")
        if curdraw == "stars"
            starsdemo()
        elseif curdraw == "eggs"
            eggsdemo(200)
        else
            textdemo()
        end
    end

    function mainwin()
        # main win
        win = GtkWindow("ComboBoxText Example",winx,winy)
        vbox = GtkBox(:v)
        #gtk canvas
        global c = Gtk.Canvas(winx,winy)
        # create luxor drawing
        global currentdrawing =  L.Drawing(winx,winy, "gtkluxordemo.png")
        global luxctx = currentdrawing.cr
        #gtk canvas
        btnsave  = Gtk.Button("Save tmp.png")
        colsel   = GtkComboBoxText()
        modelsel = GtkComboBoxText()

        #color selector
        colorchoices = ["red", "black", "green"]
        for choice in colorchoices
          push!(colsel,choice)
        end
        setproperty!(colsel,:active,0)
        # model selector
        modelchoices = ["text", "stars", "eggs"]
        for choice in modelchoices
          push!(modelsel,choice)
        end
        setproperty!(modelsel,:active,0)

        #change color
        signal_connect(colsel, "changed") do widget, others...
          idx = getproperty(colsel, "active", Int)
          global curcolor = Gtk.bytestring( GAccessor.active_text(colsel) )
          println("Change curcolor to \"$curcolor\" index $idx")
          Gtk.draw(c)
          reveal(c)
        end
        signal_connect(modelsel, "changed") do widget, others...
          idx = getproperty(modelsel, "active", Int)
          global curdraw = Gtk.bytestring( GAccessor.active_text(modelsel) )
          Gtk.draw(c)
          reveal(c)
        end
        # button save
        signal_connect(btnsave, :clicked) do widget
            Cairo.write_to_png(currentdrawing.surface,  currentdrawing.filename)
            L.preview()
        end
        @guarded Gtk.draw(c) do widget
            ctx = Gtk.getgc(c)
            mydraw()
            Cairo.set_source_surface(ctx, currentdrawing.surface, 0, 0)
            Cairo.paint(ctx)
            Gtk.fill(ctx)
        end

        #setproperty!(vbox,:border_width,1)
        push!(win, vbox)
        push!(vbox, colsel)
        push!(vbox, modelsel)
        push!(vbox, c)
        push!(vbox, btnsave)
        showall(win)
        win
    end

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

    if isinteractive()
        mainwin()
    end
end
