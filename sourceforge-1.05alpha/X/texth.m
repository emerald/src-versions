const texthelper <- immutable object texthelper
  export operation left [w : Window, s : String, tlx : Integer, bly : Integer, width : Integer]
    w.text[s, tlx, bly]
  end left
  export operation right [w : Window, s : String, tlx : Integer, bly : Integer, width : Integer]
    const twidth <- w.textWidth[s]
    w.text[s, tlx + width - twidth, bly]
  end right
  export operation center [w : Window, s : String, tlx : Integer, bly : Integer, width : Integer]
    const twidth <- w.textWidth[s]
    w.text[s, tlx + (width - twidth)/2, bly]
  end center
end texthelper

export texthelper
