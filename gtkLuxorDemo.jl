using Gtk
using Luxor
using Colors, Cairo, Compat, FileIO
L=Luxor
G=Gtk

winx = 800
winy = 600
curcolor = "red"
curdraw = "textdemo"

include("textdemo.jl")
include("starsdemo.jl")
include("eggsdemo.jl")

btnsave = G.Button("Save tmp.png")
colsel = GtkComboBoxText()
modelsel = GtkComboBoxText()

#gtk canvas
c = G.Canvas(winx,winy)
# create luxor drawing
L.Drawing(winx,winy, "gtkluxordemo.png")
luxctx = currentdrawing.cr

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

@guarded draw(c) do widget
    ctx = G.getgc(c)
    mydraw()
    Cairo.set_source_surface(ctx, currentdrawing.surface, 0, 0)
    Cairo.paint(ctx)
    # surf = G.cairo_surface(c)
    # set luxorcanvas to Canvas context
    # currentdrawing.cr = ctx
    # Cairo is still avalaible if need
    # h = height(ctx)
    # w = width(ctx)
    # G.rectangle(ctx, 0, 0,w,h)
    # G.set_source_rgba(ctx, 1, 0, 0 , 0)
    G.fill(ctx)
end

#change color
signal_connect(colsel, "changed") do widget, others...
  idx = getproperty(colsel, "active", Int)
  global curcolor = Gtk.bytestring( GAccessor.active_text(colsel) )
  println("Change curcolor to \"$curcolor\" index $idx")
  draw(c)
  reveal(c)
end
signal_connect(modelsel, "changed") do widget, others...
  idx = getproperty(modelsel, "active", Int)
  global curdraw = Gtk.bytestring( GAccessor.active_text(modelsel) )
  draw(c)
  reveal(c)
end
# button save
idsave = signal_connect(btnsave, :clicked) do widget
    Cairo.write_to_png(currentdrawing.surface,  currentdrawing.filename)
    L.preview()
end

# main win
win = GtkWindow("ComboBoxText Example",winx,winy)
vbox = GtkBox(:v)
#setproperty!(vbox,:border_width,1)
push!(win, vbox)
push!(vbox, colsel)
push!(vbox, modelsel)
push!(vbox, c)
push!(vbox, btnsave)
showall(win)
