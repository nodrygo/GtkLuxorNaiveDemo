function showAbout()
    dlg = AboutDialog(win)
    set_gtk_property!(dlg,:authors,"nodrgo")
    set_gtk_property!(dlg,:program_name,"GtkLuxorNanoCad")
    set_gtk_property!(dlg,:comments,"demo for stupid naive cad with Gtk and Luxor")
    set_gtk_property!(dlg,:license,"MIT")
    set_gtk_property!(dlg,:modal,true)
    run(dlg)
    destroy(dlg)
end
function setMenus()
    menuFile = MenuItem("File")
    filemenu = Menu(menuFile)
    menuNew = MenuItem("New")
    push!(filemenu, menuNew)
    menuOpen = MenuItem("Open")
    push!(filemenu, menuOpen)
    menuSaveAs = MenuItem("SaveAs")
    push!(filemenu, menuSaveAs)
    push!(filemenu, SeparatorMenuItem())
    menuQuit = MenuItem("Quit")
    push!(filemenu, menuQuit)
    menuHelp = MenuItem("Help")
    helpmenu = Menu(menuHelp)
    menuAbout = MenuItem("About")
    push!(helpmenu, menuAbout)
    menuBar = MenuBar()
    push!(menuBar, menuFile)  # notice this is the "File" item, not filemenu
    push!(menuBar, menuHelp)

    signal_connect(menuOpen, :activate) do widget
        global curfname = open_dialog("Pick a file")
        println("Open $curfname")
    end
    signal_connect(menuSaveAs, :activate) do widget
        global curfname = save_dialog("SaveAs", win, ("*.jl",))
        show("Save As $curfname")
    end
    idabout = signal_connect(menuAbout, :activate) do widget
        showAbout()
    end
    ####### TOOLBAR
    ####### TOOLBAR
    toolbarMain = Toolbar()
    btnTbNew = ToolButton("gtk-new")
    btnTbOpen = ToolButton("gtk-open")
    btnTbSave = ToolButton("gtk-save")
    btnTbSaveAs = ToolButton("gtk-save-as")
    btnTbZoombase = ToolButton("gtk-zoom-100")
    btnTbZoomIn = ToolButton("gtk-zoom-in")
    btnTbZoomOut = ToolButton("gtk-zoom-out")
    btnTbAbout = ToolButton("gtk-about")
    push!(toolbarMain,btnTbNew,btnTbOpen,btnTbSave,btnTbSaveAs,SeparatorToolItem(),
                      btnTbZoomIn,btnTbZoomOut,btnTbZoombase,SeparatorToolItem(),
                      btnTbAbout)
    G_.style(toolbarMain,GtkToolbarStyle.BOTH)
    G_.style(toolbarMain,GtkShadowType.GTK_SHADOW_OUT)
    signal_connect(btnTbOpen,:clicked) do widget
        global curfname = open_dialog("Pick a file")
        println("Open $curfname")
    end
    signal_connect(btnTbSaveAs, :clicked) do widget
        global curfname = save_dialog("SaveAs", win, ("*.jl",))
        show("Save As $curfname")
    end
    signal_connect(btnTbZoomIn, :clicked) do widget
        inczoom()
    end
    signal_connect(btnTbZoomOut, :clicked) do widget
        deczoom()
    end
    signal_connect(btnTbZoombase, :clicked) do widget
        setzoom(1)
    end
    signal_connect(btnTbAbout, :clicked) do widget
        showAbout()
    end

    (menuBar,toolbarMain)
end
