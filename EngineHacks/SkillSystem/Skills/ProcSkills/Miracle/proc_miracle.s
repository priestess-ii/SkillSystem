.thumb
.macro blh to, reg=r3
  ldr \reg, =\to
  mov lr, \reg
  .short 0xf800
.endm
.equ MiracleID, SkillTester+4
.equ d100Result, 0x802a52c
@ r0 is attacker, r1 is defender, r2 is current buffer, r3 is battle data
push {r4-r7,lr}
mov r4, r0 @attacker
mov r5, r1 @defender
mov r6, r2 @battle buffer
mov r7, r3 @battle data
ldr     r0,[r2]           @r0 = battle buffer                @ 0802B40A 6800     
lsl     r0,r0,#0xD                @ 0802B40C 0340     
lsr     r0,r0,#0xD        @Without damage data                @ 0802B40E 0B40     
@ mov r1, #0xC0 @skill flag @it's a passive, regardless of skills
@ lsl r1, #8 @0xC000
mov r1, #2 @miss
tst r0, r1
bne End

@check defender's hp >50%
ldrb r0, [r5,#0x12] @max hp
ldrb r1, [r5,#0x13] @current hp
cmp r1, #1 @1hp left?
ble End
lsr r0, #1 @max/2
cmp r1, r0
ble End

@check damage >= currhp
mov r0, #4
ldrsh r0, [r7, r0]
cmp r0, r1
blt End @not gonna die

@check for Miracle
ldr r0, SkillTester
mov lr, r0
mov r0, r5 @defender data
ldr r1, MiracleID
.short 0xf800
cmp r0, #0
beq End


@if we proc, set the defensive skill flag
ldr     r2,[r6]    
lsl     r1,r2,#0xD                @ 0802B42C 0351     
lsr     r1,r1,#0xD                @ 0802B42E 0B49     
mov     r0, #0x80
lsl     r0, #8           @0x8000, defender skill activated
orr     r1, r0

@and unset the crit flag
mov r0, #1
mvn  r0, r0
and     r1,r0            @unset it

ldr     r0,=#0xFFF80000                @ 0802B434 4804     
and     r0,r2                @ 0802B436 4010     
orr     r0,r1                @ 0802B438 4308     
str     r0,[r6]                @ 0802B43A 6018   
ldrb r0, MiracleID
strb r0, [r6,#4]


@and set damage to currhp-1
ldrb r0, [r5, #0x13] @currhp
sub r0, #1
strh r0, [r7, #4] @final damage

End:
pop {r4-r7}
pop {r15}

.align
.ltorg
SkillTester:
@POIN SkillTester
@WORD MiracleID
