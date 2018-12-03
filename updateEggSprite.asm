UpdateEggSprite:
    LDA egg+Egg::xcoord
    STA egg_sprite+Sprite::xcoord

    LDA egg+Egg::ycoord
    STA egg_sprite+Sprite::ycoord

    RTS