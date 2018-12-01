@echo off
ca65 just_a_chicken_little.asm -g
ld65 -t nes -o just_a_chicken_little.nes just_a_chicken_little.o --dbgfile just_a_chicken_little.dbg