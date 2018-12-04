.struct Sprite
  ycoord .byte
  index .byte
  attrs .byte
  xcoord .byte
.endstruct

.struct Chicken
  xcoord .byte
  ycoord .byte
  direction .byte
  grid_xcoord .byte
  grid_ycoord .byte
  grid_xcoord_start .byte
  grid_ycoord_start .byte
  grid_xcoord_end .byte
  grid_ycoord_end .byte
  moving .byte
.endstruct

.struct Egg
  xcoord .byte
  ycoord .byte
.endstruct

.struct Chick
  xcoord .byte
  ycoord .byte
.endstruct

.enum Directions
  UP
  DOWN
  LEFT
  RIGHT
.endenum