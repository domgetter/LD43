Controller1 = $4016

;; $4016
;; 7  bit  0
;; ---- ----
;; xxxx xxxS
;;         |
;;         +- Controller shift register strobe
;;
;; While S (strobe) is high, the shift registers in the controllers are continuously
;; reloaded from the button states, and reading $4016/$4017 will keep returning the
;; current state of the first button (A). Once S goes low, this reloading will stop.
;; Hence a 1/0 write sequence is required to get the button states, after which the
;; buttons can be read back one at a time.
;;
;; (Note that bits 2-0 of $4016/write are stored in internal latches in the 2A03/07.)

ReadPlayer1Controller:
  LDA #$01
  STA Controller1
  LDA #$00
  STA Controller1

  LDA Controller1
  AND #$01
  STA a_pressed
  LDA Controller1
  AND #$01
  STA b_pressed
  LDA Controller1
  AND #$01
  STA select_pressed
  LDA Controller1
  AND #$01
  STA start_pressed
  LDA Controller1
  AND #$01
  STA up_pressed
  LDA Controller1
  AND #$01
  STA down_pressed
  LDA Controller1
  AND #$01
  STA left_pressed
  LDA Controller1
  AND #$01
  STA right_pressed

  RTS