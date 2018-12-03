UpdateChickSprite:
    LDA chick+Chick::xcoord
    STA chick_sprite+Sprite::xcoord
    LDA chick+Chick::ycoord
    STA chick_sprite+Sprite::ycoord

    RTS