.include "header.asm"
.include "constants.asm"
.include "structs.asm"
.include "macros.asm"

.segment "STARTUP"
RESET:

;; Disable maskable interrupts
  SEI

  LDX #Inhibit_Frame_Counter
  STX APU_Frame_Counter

;; Initialize Stack Pointer
  LDX #$FF
  TXS
  
;; Disable DMC
  LDA #$00
  STA APU_DMC

;; Wait for the first vblank to synchronize with the TV
@vblankwait:
  BIT PPU_STATUS
  BPL @vblankwait

  LDA PPU_STATUS
  LDA #$00
  STA PPU_CTRL
  STA PPU_MASK

;; Load initial pallete from ROM into PPU RAM
InitializePalette:
  set_PPU_ADDR PPU_Palette

  LDX #$00
LoadPalette:
  LDA initialPalette, X
  STA PPU_DATA
  INX
  CPX #$20
  BNE LoadPalette

;; Zero out all memory, except for RAM Sprite
  LDX #$00
ClearRAM:
  LDA #$00
  STA $0000, X
  STA $0100, X
  STA $0300, X
  STA $0400, X
  STA $0500, X
  STA $0600, X
  STA $0700, X
  LDA #$FF
  STA $0200, X
  INX
  BNE ClearRAM

;; Set initial RAM Sprite values.  Ideas to make this more dynamic
;; but keep the abstractions?
InitializeSprites:
  LDA #$00
  STA tail+Sprite::index
  LDA #$01
  STA head+Sprite::index
  LDA #$10
  STA body_left+Sprite::index
  LDA #$11
  STA body_right+Sprite::index
  LDA #$02
  STA chick_sprite+Sprite::index
  LDA #$03
  STA egg_sprite+Sprite::index

  LDA #Sprite_Palette_0
  STA tail+Sprite::attrs
  STA head+Sprite::attrs
  STA body_left+Sprite::attrs
  STA body_right+Sprite::attrs
  STA egg_sprite+Sprite::attrs

  LDA #Sprite_Palette_1
  STA chick_sprite+Sprite::attrs

LoadLevel1:
  set_PPU_ADDR PPU_Nametable_1

  LDX #$00
@loadBackground1:
  LDA level1, X
  STA PPU_DATA
  INX
  BNE @loadBackground1

@loadBackground2:
  LDA level1+$0100, X
  STA PPU_DATA
  INX
  BNE @loadBackground2

@loadBackground3:
  LDA level1+$0200, X
  STA PPU_DATA
  INX
  BNE @loadBackground3

@loadBackground4:
  LDA level1+$0300, X
  STA PPU_DATA
  INX
  CPX #$C0
  BNE @loadBackground4

LoadAttributes:
  set_PPU_ADDR PPU_Attribute_Table_1

;; for(int i = 0; i < 64; i++) {
;;   ppu_ram = level1_attr[i]
;; }
  LDX #$00
@loadAttributesLoop:
  LDA level1_attr, X
  STA PPU_DATA
  INX
  CPX #$40
  BNE @loadAttributesLoop

  LDX #(Enable_NMI | Background_Pattern_Table_1)
  STX PPU_CTRL

  LDA #(Show_Background | Show_Sprites)
  STA PPU_MASK

  LDA #50
  STA chicken+Chicken::xcoord
  STA chicken+Chicken::ycoord

  LDA #120
  STA egg+Egg::xcoord
  LDA #100
  STA egg+Egg::ycoord

  LDA #70
  STA chick+Chick::xcoord
  LDA #150
  STA chick+Chick::ycoord

  JSR UpdateChickenSprites
  JSR UpdateEggSprite
  JSR UpdateChickSprite

@vblankwait:
  BIT PPU_STATUS
  BPL @vblankwait

Forever:
  JMP Forever

;; Copy sprites from $0200-$02FF to PPU RAM.
;; This takes ~520 cycles
SpriteDMA:
  LDA #<Sprite_RAM
  STA PPU_OAM
  LDA #>Sprite_RAM
  STA OAM_DMA
  RTS

;; Set nametable scroll to (0,0)
;; Do we *have* to do this every frame?
SetScroll:
  LDA #$00
  STA PPU_SCROLL
  STA PPU_SCROLL
  RTS

;; Run per-frame code.
;; Pipe over Sprites
;; Move over any new tile info
;; Collect user input
;; Update world
DoOnVBlank:
  JSR SpriteDMA
  JSR SetScroll
  JSR ReadPlayer1Controller
  JSR ChangeTheWorld
  JSR UpdateChickenSprites
  JSR UpdateEggSprite
  RTI

.include "initialPalette.asm"
.include "level1.asm"
.include "readPlayer1Controller.asm"
.include "changeTheWorld.asm"
.include "updateChickenSprites.asm"
.include "updateEggSprite.asm"
.include "updateChickSprite.asm"

.segment "ZEROPAGE"
.org $0200
head:
  .tag Sprite
body_left:
  .tag Sprite
body_right:
  .tag Sprite
tail:
  .tag Sprite
egg_sprite:
  .tag Sprite
chick_sprite:
  .tag Sprite

.org $0300
a_pressed: .res 1
b_pressed: .res 1
select_pressed: .res 1
start_pressed: .res 1
up_pressed: .res 1
down_pressed: .res 1
left_pressed: .res 1
right_pressed: .res 1
chicken: .tag Chicken
egg: .tag Egg
chick: .tag Chick


.segment "VECTORS"
  .word DoOnVBlank
  .word RESET
  .word 0

.segment "CHARS"
  .incbin "just_a_chicken_little.chr"