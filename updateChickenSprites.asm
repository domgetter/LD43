UpdateChickenSprites:
  LDA chicken+Chicken::xcoord
  STA tail+Sprite::xcoord
  STA body_left+Sprite::xcoord

  CLC
  ADC #$08
  STA head+Sprite::xcoord
  STA body_right+Sprite::xcoord

  LDA chicken+Chicken::ycoord
  STA tail+Sprite::ycoord
  STA head+Sprite::ycoord
  
  CLC
  ADC #$08
  STA body_left+Sprite::ycoord
  STA body_right+Sprite::ycoord

  RTS