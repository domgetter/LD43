PPU_CTRL = $2000
PPU_MASK = $2001
PPU_STATUS = $2002
PPU_OAM = $2003
PPU_SCROLL = $2005
PPU_ADDR = $2006
PPU_DATA = $2007
PPU_Palette = $3F00
PPU_Nametable_0 = $2000
PPU_Attribute_Table_0 = $23C0
APU_DMC = $4010
OAM_DMA = $4014
APU_Frame_Counter = $4017
Sprite_RAM = $0200

;; Configuration flags
Show_Sprites               = %00010000
Show_Background            = %00001000
Enable_NMI                 = %10000000
Inhibit_Frame_Counter      = %01000000
Background_Pattern_Table_0 = %00000000
Background_Pattern_Table_1 = %00010000
Sprite_Pattern_Table_0     = %00000000
Sprite_Pattern_Table_1     = %00001000
Emphasize_Red              = %00100000
Emphasize_Green            = %01000000
Emphasize_Blue             = %10000000

;; 76543210
;; ||||||||
;; ||||||++- Palette (4 to 7) of sprite
;; |||+++--- Unimplemented
;; ||+------ Priority (0: in front of background; 1: behind background)
;; |+------- Flip sprite horizontally
;; +-------- Flip sprite vertically

Sprite_Flip_Vertical   = %10000000
Sprite_Flip_Horizontal = %01000000
Sprite_Priority        = %00100000
Sprite_Palette_0       = %00000000
Sprite_Palette_1       = %00000001
Sprite_Palette_2       = %00000010
Sprite_Palette_3       = %00000011