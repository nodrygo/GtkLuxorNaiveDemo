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

    ####### TOOLBAR
    toolbarMain = Toolbar()
    runfileTb = ToolButton("Run")
    setproperty!(runfileTb, :label, "Run")
    setproperty!(runfileTb, :is_important, true)

    undoTb = ToolButton("Undo")
    setproperty!(undoTb, :label, "undo")
    setproperty!(undoTb, :is_important, true)

    map(t->push!(toolbarMain,t),[runfileTb,undoTb])
    setproperty!(toolbarMain,:hexpand,true)
    (menuBar,toolbarMain)
end
