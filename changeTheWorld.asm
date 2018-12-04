ChangeTheWorld:

  JSR UpdateChickenBasedOnControllerInput
  
  RTS

;; Overall pipeline
;; 1. Get controller input
;; 2. collision detection to set movement and direction flags
;; 3. update chicken state
;; 4. change chicken sprites
;; 5. (next vblank) copy chicken sprites over
;; Set flags for actual update to occur later
;; Previously, I complected the chicken state update
;; with collision detection
CheckRight:
  ;; Can I go to the right?
  ;; Am I already going to the right?
  ;; Is there something in the way?

  ;; If I'm moving, then stop doing work
  LDA chicken+Chicken::moving
  BNE @doneCheckingRight

  ;; If there's something in the way,
  ;; then don't try to go that way
  ;; Given the chicken's grid coordinates
  ;; see what block type is to the right
  ;; and act accordingly

  LDA #$00
  BEQ @doneCheckingRight

  LDA Directions::RIGHT
  STA chicken+Chicken::direction
  INC chicken+Chicken::grid_xcoord_end

@doneCheckingRight:
  RTS

CheckLeft:
  LDA chicken+Chicken::moving
  BNE @doneCheckingLeft

  LDA #$00
  BEQ @doneCheckingLeft

  LDA Directions::LEFT
  STA chicken+Chicken::direction
  DEC chicken+Chicken::grid_xcoord_end

@doneCheckingLeft:
  RTS

CheckUp:
  LDA chicken+Chicken::moving
  BNE @doneCheckingUp

  LDA #$00
  BEQ @doneCheckingUp

  LDA Directions::UP
  STA chicken+Chicken::direction
  DEC chicken+Chicken::grid_ycoord_end

@doneCheckingUp:
  RTS

CheckDown:
  LDA chicken+Chicken::moving
  BNE @doneCheckingDown

  LDA #$00
  BEQ @doneCheckingDown

  LDA Directions::DOWN
  STA chicken+Chicken::direction
  INC chicken+Chicken::grid_ycoord_end

@doneCheckingDown:
  RTS

;; Select which update functions are called
;; We either run {{}, U, D, L, R, {U,L}, {U,R}, {D,L}, {D,R}}
;; *  *  *
;; *  *  *
;; *  *  *

UpdateChickenBasedOnControllerInput:
  LDA right_pressed
  BEQ @noRight
  JSR CheckRight
  JMP @noOthers
@noRight:

  LDA left_pressed
  BEQ @noLeft
  JSR CheckLeft
  JMP @noOthers
@noLeft:

  LDA up_pressed
  BEQ @noUp
  JSR CheckUp
  JMP @noOthers
@noUp:

  LDA down_pressed
  BEQ @noDown
  JSR CheckDown
@noDown:
@noOthers:
  RTS

;; Check if the current chicken position is colliding with
;; anything

;; (x,y),(x+16,y+16)
;; given a coordinate, what bit in level1_collision is it over?
;; (0,0)..(7,7) -> (0,0), (8,0)..(15,7) -> (1,0), (16,0)..(23,7) -> (2,0)
;; (24,0)..(31,7) -> (3,0), (32,0)..(39,7) -> (4,0), (40,0)..(47,7) -> (5,0)
;; (48,0)..(55,7) -> (6,0), (56,0)..(63,7) -> (7,0), (64,0)..(71,7) -> (8,0)
;; (50,50) -> (6,6)

;; a = x/8
;; b = y/8
;; c = a/8
;; c = b*4+c
;; d = a & 7
;; e = 7 - d
;; f = 2^e
;; A = coll[c] & f

;; c = (y >> 2) & $FC + x >> 6
;; f =  1 << (7 - (x >> 3 & $07))
;; A = coll[(y >> 2) & $FC + x >> 6] & (1 << (7 - (x >> 3 & $07)))
CheckCollision:
  LDA chicken+Chicken::xcoord
  LSR
  LSR
  LSR
  STA $00
  LDA chicken+Chicken::ycoord
  LSR
  LSR
  LSR
  STA $01

;; consider (50,50) -> (6,6)
;;          (32, 63) -> (4,7)
;;          (64, 49) -> (8,6)
;; (0,0)..(7,0) ->  0, (8,0)..(15,0) ->  1, (16,0)..(23,0) ->  2, (24,0)..(31,0) ->  3
;; (0,1)..(7,1) ->  4, (8,1)..(15,1) ->  5, (16,1)..(23,1) ->  6, (24,1)..(31,1) ->  7
;; (0,2)..(7,2) ->  8, (8,2)..(15,2) ->  9, (16,2)..(23,2) -> 10, (24,2)..(31,2) -> 11
;; (0,3)..(7,3) -> 12, (8,3)..(15,3) -> 13, (16,3)..(23,3) -> 14, (24,3)..(31,3) -> 15
;; (0,4)..(7,4) -> 16, (8,4)..(15,4) -> 17, (16,4)..(23,4) -> 18, (24,4)..(31,4) -> 19
;; (0,5)..(7,5) -> 20, (8,5)..(15,5) -> 21, (16,5)..(23,5) -> 22, (24,5)..(31,5) -> 23
;; (0,6)..(7,6) -> 24, (8,6)..(15,6) -> 25, (16,6)..(23,6) -> 26, (24,6)..(31,6) -> 27
;; (0,7)..(7,7) -> 28, (8,7)..(15,7) -> 29, (16,7)..(23,7) -> 30, (24,7)..(31,7) -> 31
;; (0,8)..(7,8) -> 32, (8,8)..(15,8) -> 33, (16,8)..(23,8) -> 34, (24,8)..(31,8) -> 35
  LDA $00
  LSR
  LSR
  LSR
  STA $02
  LDA $01
  ASL
  ASL
  CLC
  ADC $02
  ;; byte $02 now has the byte offset into level1_collision
  ;; 10011001
  ;; 
  STA $02

  LDA $00
  AND #$07
  STA $04
  LDA #$07
  SEC
  SBC $04
  STA $05
  LDA #$01
  LDX $05
  BEQ @skipRaise
@raise:
  ASL
  DEX
  BNE @raise
@skipRaise:
  STA $06
  LDX $02
  LDA level1_collision,X
  AND $06



  BNE @collision
  LDA #$00
  JMP @noCollision
@collision:
  LDA #$01
@noCollision:
  TSX
  INX
  INX
  INX
  STA $0100,X
  RTS