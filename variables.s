.ifndef VARIABLES_S

VARIABLES_S = 1

;*****************************************************************
; 6502 Zero Page Memory (256 bytes)
;*****************************************************************

.segment "ZEROPAGE"

nmi_ready:		.res 1 ; set to 1 to push a PPU frame update, 
					   ;        2 to turn rendering off next NMI
gamepad:		.res 1 ; stores the current gamepad values

d_x:			.res 1 ; x velocity of ball
d_y:			.res 1 ; y velocity of ball
sprite_index:	.res 1 ; current sprite index for animation
duck_x:			.res 1 ; duck sprite X
duck_y:			.res 1 ; duck sprite Y
current_state:	.res 1 ; current state of the game (title, playing, gameover)
scene_loaded:		.res 1 ; flag to indicate if the scene has been loaded (for animation purposes)
frame_count:		.res 1 ; frame counter for animation timing
curent_anim_frame:	.res 1 ; current animation frame for duck sprite
is_jumping:		.res 1 ; flag to indicate if the duck is currently jumping
jump_pressed:		.res 1 ; flag to indicate if the jump button is currently pressed
a_was_down:		.res 1 ; latch to detect a new A press (edge trigger)
obstacle_x:		.res 1 ; x position of obstacle
obstacle_dx:		.res 1 ; x velocity of obstacle


;*****************************************************************
; Sprite OAM Data area - copied to VRAM in NMI routine
;*****************************************************************

.segment "OAM"
oam: .res 256	; sprite OAM data

;*****************************************************************
; Remainder of normal RAM area
;*****************************************************************

.segment "BSS"
palette: .res 32 ; current palette buffer

.endif