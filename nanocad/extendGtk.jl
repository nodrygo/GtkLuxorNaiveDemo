###### naive code to add ButtonColor
function ButtonColor()
    hnd = ccall((:gtk_color_button_new, Gtk.libgtk ), Ptr{GObject}, ())
    w = convert(Gtk.GtkWidget, hnd)
    w
end

mutable struct GtkRGBA
   r::Float64
   g::Float64
   b::Float64
   a::Float64
   GtkRGBA(r, g, b ,a) = new(r, g, b, a)
end

function gtk_color_butcol_get_rgba(widget)
      col = GtkRGBA(0,0,0,1)
      pcol = Base.pointer_from_objref(col)
      ccall((:gtk_color_button_get_rgba, Gtk.libgtk)
                   , Ptr{Nothing}
                   , (Ptr{GObject},Ptr{GtkRGBA}),widget,pcol)
      ncol = Base.unsafe_pointer_to_objref(pcol)
      ncol
end
