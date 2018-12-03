.macro set_PPU_ADDR addr
  LDA PPU_STATUS
  LDA #>addr
  STA PPU_ADDR
  LDA #<addr
  STA PPU_ADDR
.endmacro