using Gtk
using Luxor
using Colors, Cairo, Compat, FileIO
L=Luxor
G=Gtk

btnsave = G.Button("Save tmp.png")
cb = GtkComboBoxText()
#gtk canvas
c = G.Canvas(400,300)
# create luxor drawing
L.Drawing(400, 300, "gtkluxordemo.png")
luxctx = currentdrawing.cr

#color selector
colorchoices = ["red", "black", "green"]
for choice in colorchoices
  push!(cb,choice)
end
setproperty!(cb,:active,0)
curcolor = "red"

function mydraw()
  L.origin()
  L.background("blue")
  L.fontface("Arial-Black")
  L.fontsize(24)
  L.setdash("dot")
  L.sethue("black")
  L.setline(0.25)
  L.circle(O, 100, :stroke)
  L.textcurvecentered("hello world", -pi/2, 100, O;
      clockwise = true,
      letter_spacing = 0,
      baselineshift = -20
      )
  L.textcurvecentered("hello world", pi/2, 100, O;
      clockwise = false,
      letter_spacing = 0,
      baselineshift = 10
      )
  L.sethue(curcolor)
  L.circle(Point(0,0), 50, :fill)
end

@guarded draw(c) do widget
    ctx = G.getgc(c)
    # surf = G.cairo_surface(c)
    # set luxorcanvas to Canvas context
    currentdrawing.cr = ctx
    mydraw()
    h = height(ctx)
    w = width(ctx)
    G.rectangle(ctx, 0, 110,w,h)
    G.set_source_rgba(ctx, 1, 0, 0 , 1)
    G.fill(ctx)
end

#change color
signal_connect(cb, "changed") do widget, others...
  idx = getproperty(cb, "active", Int)
  global curcolor = Gtk.bytestring( GAccessor.active_text(cb) )
  println("Change curcolor to \"$curcolor\" index $idx")
  mydraw()
  reveal(c)
end
# button save
idsave = signal_connect(btnsave, :clicked) do widget
    ctx = G.getgc(c)
    surf = G.cairo_surface(c)
    h = height(ctx)
    w = width(ctx)
    # Restore luxor context
    global luxctx , currentdrawing
    currentdrawing.cr =luxctx
    mydraw()
    L.finish()
    L.preview()
    #re create drawing context because L.finish destroy surface
    currentdrawing=L.Drawing(400, 300, "gtkluxordemo.png")
    luxctx = currentdrawing.cr
    currentdrawing.cr = ctx
    reveal(c)
end

# main win
win = GtkWindow("ComboBoxText Example",400,200)
vbox = GtkBox(:v)
#setproperty!(vbox,:border_width,1)
push!(win, vbox)
push!(vbox, cb)
push!(vbox, c)
push!(vbox, btnsave)
showall(win)
