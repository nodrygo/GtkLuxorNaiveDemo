using Luxor, Colors
# Adaptation of Luxor text demo
function textdemo()
  L.origin()
  L.background(curcolor)
  L.fontface("Arial")
  L.fontsize(24)
  L.setdash("dot")
  L.sethue("black")
  L.setline(5)
  L.circle(L.Point(0,0), 100, :stroke)
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
  L.sethue("red")
  L.circle(L.Point(0,0), 50, :fill)
  
end
