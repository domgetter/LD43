.segment "HEADER"
  .byte "NES", $1A 
  .byte $2
  .byte $1
  .byte $1
  .byte 0,0,0,0,0,0,0,0,0

PPU_STATUS = $2002
PPU_ADDR = $2006
PPU_DATA = $2007
PPU_Palette = $3F00

.segment "STARTUP"
RESET:
  SEI
  CLD
  LDX #%01000000
  STX $4017
  LDX #$FF
  TXS

  LDX #%10000000
  STX $2000

  LDA #%00011000
  STA $2001
  
  LDA #$00
  STA $4010

;; Wait for the first vblank to synchronize with the TV
vblankwait1:
  BIT $2002
  BPL vblankwait1

;; Load initial pallete from ROM into PPU RAM
InitializePalette:
  LDA PPU_STATUS
  LDA #<PPU_Palette
  STA PPU_ADDR
  LDA #>PPU_Palette
  STA PPU_ADDR

  LDX #$00
LoadPalette:
  LDA initialPalette, X
  STA PPU_DATA
  INX
  CPX #$20
  BMI LoadPalette

;; Zero out all memory
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
  BMI ClearRAM

vblankwait2:
  BIT $2002
  BPL vblankwait2

Forever:
  JMP Forever

DoOnVBlank:
  RTI

.include "initialPalette.asm"

.segment "VECTORS"
  .word DoOnVBlank
  .word RESET
  .word 0

.segment "CHARS"
  .incbin "just_a_chicken_little.chr"