module CoordinateUtilities

  def cid(col, row)
    coordinates_string(col, row)#.hash
  end

  def coordinates_string(col,row)
    "x:#{col},y:#{row}"
  end

end