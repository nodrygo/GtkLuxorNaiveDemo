function setSignals(colorsel,entitiesel)
  #change color
  signal_connect(colorsel, "changed") do widget, others...
    idx = getproperty(colorsel, "active", Int)
    global curcolor = Gtk.bytestring( GAccessor.active_text(colorsel) )
    Gtk.draw(c)
  end
  signal_connect(entitiesel, "changed") do widget, others...
    idx = getproperty(entitiesel, "active", Int)
    global curdraw = Gtk.bytestring( GAccessor.active_text(entitiesel) )
    Gtk.draw(c)
  end

end
