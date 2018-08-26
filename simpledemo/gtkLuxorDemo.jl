module GtkLuxorDemo
    using Luxor
    using Colors, Cairo, Compat, FileIO
    using Gtk
    global L=Luxor
    include("textdemo.jl")
    include("starsdemo.jl")
    include("eggsdemo.jl")
    include("clockdemo.jl")
    include("colornames.jl")
    include("spiraldemo.jl")
    # include("stangeloop.jl")
    global winx = 800
    global winy = 600
    global curcolor = "red"
    global curdraw = "clock"
    global models = ["text", "stars", "eggs","clock","colornames","spiral","strangeloop"]
    global french_months = ["janvier", "février", "mars", "avril","mai", "juin","juillet", "août", "septembre", "octobre","novembre", "décembre"];
    global french_monts_abbrev=["janv","févr","mars","avril","mai","juin","juil","août","sept","oct","nov","déc"];
    global french_days=["lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche"];
    # global Dates.LOCALES["french"] = Dates.DateLocale(french_months,french_monts_abbrev,french_days, [""]);

    function callClock(tt)
        if curdraw=="clock"
            clockdemo(200)
            Gtk.draw(c)
        end
    end
    function mydraw()
        L.background("white") # hide
        # println("Draw $curdraw")
        if curdraw == "stars"
            starsdemo()
        elseif curdraw == "eggs"
            eggsdemo(200)
        elseif curdraw == "clock"
            clockdemo(200)
        elseif curdraw == "colornames"
            colornames()
        elseif curdraw == "spiral"
            spiraldemo()
        elseif curdraw == "strangeloop"
            strange(.3, 800)
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
        set_gtk_property!(colsel,:active,0)
        # model selector
        modelchoices = models
        for choice in modelchoices
          push!(modelsel,choice)
        end
        set_gtk_property!(modelsel,:active,3)

        #change color
        signal_connect(colsel, "changed") do widget, others...
          idx = getproperty(colsel, "active", Int)
          global curcolor = Gtk.bytestring( GAccessor.active_text(colsel) )
          Gtk.draw(c)
        end
        signal_connect(modelsel, "changed") do widget, others...
          idx = get_gtk_property(modelsel, "active", Int)
          global curdraw = Gtk.bytestring( GAccessor.active_text(modelsel) )
          Gtk.draw(c)
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
            Gtk.reveal(c)
        end

        #setproperty!(vbox,:border_width,1)
        push!(win, vbox)
        push!(vbox, colsel)
        push!(vbox, modelsel)
        push!(vbox, c)
        push!(vbox, btnsave)
        showall(win)
        global tt = Timer(callClock, 1, interval = 1.0)
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

# if interactive kill timer when destroy win
    if isinteractive()
        win = mainwin()
        signal_connect(win, :destroy) do widget
                close(GtkLuxorDemo.tt)
        end
    end
end
