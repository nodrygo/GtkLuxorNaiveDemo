# Adaptation of Luxor text demo
function textdemo()
  L.origin()
  # L.background("blue")
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
