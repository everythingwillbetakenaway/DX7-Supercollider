// This is the CC implementation of the DX7.
/*
For each 6 oscillator
(1)  Osc Coarse -- "OP1_FreqCoarse" = 0-32
(2)  Osc Fine -- "OP1_FreqFine" = 0-99
3)  Osc Detune -- "OP1_Detune" = 0-14
4)  Mod Sens -- "OP1_LFO_AmplitudeModSens" = 0-4
(5)  Env Rate-1 -- "OP1_EG_R1_reversed"  = 0-99
(6)  Env Rate-2 -- "OP1_EG_R2_reversed"  = 0-99
(7)  Env Rate-3 -- "OP1_EG_R3_reversed"  = 0-99
(8)  Env Rate-4 -- "OP1_EG_R4_reversed"  = 0-99
9)  Env Level-1-- "OP1_EG_L1" 		= 0-99
10) Env Level-2-- "OP1_EG_L2"		= 0-99
11) Env Level-3-- "OP1_EG_L3"		= 0-99
12) Env Level-4-- "OP1_EG_L4"		= 0-99
13) Scaletel -- "OP1_KRS"	 	= 0-7
14) Keyboard Breakpoint -- "OP1_KLS_BreakPoint" = 0-99
15) L Curve      -- "OP1_KLS_LeftCurve"  = 0-3
16) L Depth      -- "OP1_KLS_LeftDepth"  = 0-99
17) R Curve      -- "OP1_KLS_RightCurve" = 0-3
18) R Depth      -- "OP1_KLS_RightDepth" = 0-99
19) Velocity     --"OP1_KeybVelSens"  = 0-7
20) Output Volume--"OP1_OutputLevel"= 0-99
21) Osc Fix Ratio -- "OP1_FreqMode" = 0-1
%%%%%->Break_
CC# 0<=>5     : Osc Coarse -------> DONE!
CC# 6<=>11    : Output Volume -------> DONE!
CC# 12<=>17   : Osc Detune -------> DONE!
CC# 18<=>23   : Mod Sens -------> DONE!
CC# 24<=>29   : Env Rate-1 -------> DONE!
CC# 30<=>35   : Env Rate-2 -------> DONE!
CC# 36<=>41   : Env Rate-3 -------> DONE!
CC# 42<=>47   : Env Rate-4 -------> DONE!
CC# 48<=>53   : Env Level-1 -------> DONE!
CC# 54<=>59   : Env Level-2 -------> DONE!
CC# 60<=>65   : Env Level-3 -------> DONE!
CC# 66<=>71   : Env Level-4 -------> DONE!
CC# 72<=>77   : Scaletel -------> DONE!
CC# 78<=>83   : Keyboard Breakpoint -------> DONE!
CC# 84<=>89   : L Curve -------> DONE!
CC# 90<=>95   : L Depth -------> DONE!
CC# 96<=>101  : R Curve -------> DONE!
CC# 102<=>107 : R Depth -------> DONE!
CC# 108<=>113 : Velocity -------> DONE!
CC# 114<=>119 : Osc Fine -------> DONE!
CC# 5<=>0     : Osc Fix Ratio %% Connected Osc Coarse %% -------> DONE!
=================
Global
CC# 0) Algorithm   -- "Algorithm"= 0-31 -------> DONE!
CC# 1) Feedback    -- "Feedback" = 0-7 -------> DONE!
CC# 2) Osc Key Sync -- "Oscillator_Sync" = 0-1 -------> DONE!
CC# 3) Transpose -- "Transpose" = 0-48 -------> DONE!
CC# 4) LFO speed -- "LFO_Speed" = 0-99 -------> DONE!
CC# 5) LFO wave  -- "LFO_Waveform" = 0-5 // triangle, saw down, saw up, square, sine, S&H -------> DONE!
CC# 6) LFO delay -- "LFO_Delay" = 0-99 -------> DONE!
CC# 7) LFO PMD   -- "LFO_PMD" = 0-99 -------> DONE!
CC# 8) LFO AMD   -- "LFO_AMD" = 0-99 -------> DONE!
CC# 9)LFO Key Sync -- "LFO_Sync" = 0-1 -------> DONE!
CC# 10)LFO PMS -- "LFO_PitchModSens" = 0-7 -------> DONE!
CC# 11)Pitch EG Rate-1 -- "Pitch_EG_R1_reversed" = 0-99 -------> DONE!
CC# 12)Pitch EG Rate-2 -- "Pitch_EG_R2_reversed" = 0-99 -------> DONE!
CC# 13)Pitch EG Rate-3 -- "Pitch_EG_R3_reversed" = 0-99 -------> DONE!
CC# 14)Pitch EG Rate-4 -- "Pitch_EG_R4_reversed" = 0-99 -------> DONE!
CC# 15)Pitch EG Level-1-- "Pitch_EG_L1" = 0-99 -------> DONE!
CC# 16)Pitch EG Level-2-- "Pitch_EG_L2" = 0-99 -------> DONE!
CC# 17)Pitch EG Level-3-- "Pitch_EG_L3" = 0-99 -------> DONE!
CC# 18)Pitch EG Level-4-- "Pitch_EG_L4" = 0-99 -------> DONE!
===============.no need
Function Parameter // DX7 Midi Inputs
1)Portament Mode,
2)Portament Glisanddi
3)Portamento Time
Aftertouch
Breath
Foot Ctrl
Mod Wheel
PitchBend Range
Mono/Poly
*/



/*


(

~DX7.control(3, 0,  1);
~DX7.control(3, 1,  1);
~DX7.control(3, 2,  1);
~DX7.control(3, 3,  1);
~DX7.control(3, 4,  1);
~DX7.control(3, 5,  1);//Osc Coarse
~DX7.control(3, 6,  99);
~DX7.control(3, 7,  99);
~DX7.control(3, 8,  0);
~DX7.control(3, 9,  0);
~DX7.control(3, 10, 0);
~DX7.control(3, 11, 0);  //Output Volume
~DX7.control(3, 12, 0);
~DX7.control(3, 13, 0);
~DX7.control(3, 14, 1);
~DX7.control(3, 15, 4);
~DX7.control(3, 16, 4);
~DX7.control(3, 17, 4);//Osc Detune
~DX7.control(3, 18, 3);
~DX7.control(3, 19, 3);
~DX7.control(3, 20, 3);
~DX7.control(3, 21, 1);
~DX7.control(3, 22, 1);
~DX7.control(3, 23, 1);//Mod Sens
~DX7.control(3, 24, 0);
~DX7.control(3, 25, 0);
~DX7.control(3, 26, 0);
~DX7.control(3, 27, 0);
~DX7.control(3, 28, 0);
~DX7.control(3, 29, 0);//Env Rate-1
~DX7.control(3, 30, 0);
~DX7.control(3, 31, 0);
~DX7.control(3, 32, 0);
~DX7.control(3, 33, 0);
~DX7.control(3, 34, 0);
~DX7.control(3, 35, 0);//Env Rate-2
~DX7.control(3, 36, 0);
~DX7.control(3, 37, 0);
~DX7.control(3, 38, 0);
~DX7.control(3, 39, 0);
~DX7.control(3, 40, 0);
~DX7.control(3, 41, 0);//Env Rate-3
~DX7.control(3, 42, 30);
~DX7.control(3, 43, 30);
~DX7.control(3, 44, 10);
~DX7.control(3, 45, 10);
~DX7.control(3, 46, 10);
~DX7.control(3, 47, 10);//Env Rate-4
~DX7.control(3, 48, 99);
~DX7.control(3, 49, 99);
~DX7.control(3, 50, 99);
~DX7.control(3, 51, 99);
~DX7.control(3, 52, 99);
~DX7.control(3, 53, 99);//Env Level-1
~DX7.control(3, 54, 99);
~DX7.control(3, 55, 99);
~DX7.control(3, 56, 99);
~DX7.control(3, 57, 99);
~DX7.control(3, 58, 99);
~DX7.control(3, 59, 99);//Env Level-2
~DX7.control(3, 60, 99);
~DX7.control(3, 61, 99);
~DX7.control(3, 62, 99);
~DX7.control(3, 63, 99);
~DX7.control(3, 64, 99);
~DX7.control(3, 65, 99);//Env Level-3
~DX7.control(3, 66, 0);
~DX7.control(3, 67, 0);
~DX7.control(3, 68, 0);
~DX7.control(3, 69, 0);
~DX7.control(3, 70, 0);
~DX7.control(3, 71, 0); //Env Level-4
~DX7.control(3, 72, 0);
~DX7.control(3, 73, 0);
~DX7.control(3, 74, 0);
~DX7.control(3, 75, 0);
~DX7.control(3, 76, 0);
~DX7.control(3, 77, 0); //Scaletel
~DX7.control(3, 78, 42);
~DX7.control(3, 79, 42);
~DX7.control(3, 80, 42);
~DX7.control(3, 81, 42);
~DX7.control(3, 82, 42);
~DX7.control(3, 83, 42);//Keyboard Breakpoint
~DX7.control(3, 84, 0);
~DX7.control(3, 85, 0);
~DX7.control(3, 86, 0);
~DX7.control(3, 87, 0);
~DX7.control(3, 88, 0);
~DX7.control(3, 89, 0); //L Curve
~DX7.control(3, 90, 0);
~DX7.control(3, 91, 0);
~DX7.control(3, 92, 0);
~DX7.control(3, 93, 0);
~DX7.control(3, 94, 0);
~DX7.control(3, 95, 0); //L Depth
~DX7.control(3, 96, 0);
~DX7.control(3, 97, 0);
~DX7.control(3, 98, 0);
~DX7.control(3, 99, 0);
~DX7.control(3, 100, 0);
~DX7.control(3, 101, 0); //R Curve
~DX7.control(3, 102,0);
~DX7.control(3, 103,0);
~DX7.control(3, 104,0);
~DX7.control(3, 105,0);
~DX7.control(3, 106,0);
~DX7.control(3, 107,0); //R Depth
~DX7.control(3, 108,0);
~DX7.control(3, 109,0);
~DX7.control(3, 110,0);
~DX7.control(3, 111,0);
~DX7.control(3, 112,0);
~DX7.control(3, 113,0); //Velocity Sens
~DX7.control(3, 114,0);
~DX7.control(3, 115,0);
~DX7.control(3, 116,0);
~DX7.control(3, 117,0);
~DX7.control(3, 118,0);
~DX7.control(3, 119,0); //Osc Fine

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

~DX7.control(4, 0, 31); //algo
~DX7.control(4, 1, 6); //feedback
~DX7.control(4, 2, 1); //osc_sync
~DX7.control(4, 3, 23); //transpose
~DX7.control(4, 4, 33); //lfo speed
~DX7.control(4, 5, 3); //lfo wave
~DX7.control(4, 6, 0); //lfo delay
~DX7.control(4, 7, 99); //lfo pmd
~DX7.control(4, 8, 99); //lfo amd
~DX7.control(4, 9, 1); //lfo sync
~DX7.control(4, 10, 0);//lfo pms
~DX7.control(4, 11, 99);//eg-r1
~DX7.control(4, 12, 99);//eg-r2
~DX7.control(4, 13, 99);//eg-r3
~DX7.control(4, 14, 99);//eg-r4
~DX7.control(4, 15, 50);//eg-L1
~DX7.control(4, 16, 50);//eg-L2
~DX7.control(4, 17, 50);//eg-L3
~DX7.control(4, 18, 50);//eg-L4
~DX7.control(4, 19, 1);//
~DX7.control(4, 20, 1);//
~DX7.control(4, 21, 1);//
~DX7.control(4, 22, 1);//
~DX7.control(4, 23, 1);//
~DX7.control(4, 48, 0);
~DX7.control(4, 49, 0);
~DX7.control(4, 50, 0);
~DX7.control(4, 51, 0);
~DX7.control(4, 52, 0);
~DX7.control(4, 53, 0);// fixed or ratio 0 is fixed, 1 is ratio
//envPL0, envPL1, envPL2, envPL3, envPL4, envPR0, envPR1, envPR2,envPR3,
)
(

~DX7.control(3, 0,  3);
~DX7.control(3, 1,  3);
~DX7.control(3, 2,  3);
~DX7.control(3, 3,  3);
~DX7.control(3, 4,  3);
~DX7.control(3, 5,  3);//Osc Coarse
~DX7.control(3, 6,  0);
~DX7.control(3, 7,  0);
~DX7.control(3, 8,  0);
~DX7.control(3, 9,  0);
~DX7.control(3, 10,  0);
~DX7.control(3, 11,  0);//Output Volume
~DX7.control(3, 12, 0);
~DX7.control(3, 13, 0);
~DX7.control(3, 14, 0);
~DX7.control(3, 15, 0);
~DX7.control(3, 16, 0);
~DX7.control(3, 17, 0);//Osc Detune
~DX7.control(3, 18, 0);
~DX7.control(3, 19, 0);
~DX7.control(3, 20, 0);
~DX7.control(3, 21, 0);
~DX7.control(3, 22, 0);
~DX7.control(3, 23, 0);//Mod Sens
~DX7.control(3, 24, 0);
~DX7.control(3, 25, 0);
~DX7.control(3, 26, 0);
~DX7.control(3, 27, 0);
~DX7.control(3, 28, 0);
~DX7.control(3, 29, 0);//Env Rate-1
~DX7.control(3, 30, 0);
~DX7.control(3, 31, 0);
~DX7.control(3, 32, 0);
~DX7.control(3, 33, 0);
~DX7.control(3, 34, 0);
~DX7.control(3, 35, 0);//Env Rate-2
~DX7.control(3, 36, 0);
~DX7.control(3, 37, 0);
~DX7.control(3, 38, 0);
~DX7.control(3, 39, 0);
~DX7.control(3, 40, 0);
~DX7.control(3, 41, 0);//Env Rate-3
~DX7.control(3, 42, 0);
~DX7.control(3, 43, 0);
~DX7.control(3, 44, 0);
~DX7.control(3, 45, 0);
~DX7.control(3, 46, 0);
~DX7.control(3, 47, 0);//Env Rate-4
~DX7.control(3, 48, 0);
~DX7.control(3, 49, 0);
~DX7.control(3, 50, 0);
~DX7.control(3, 51, 0);
~DX7.control(3, 52, 0);
~DX7.control(3, 53, 0);//Env Level-1
~DX7.control(3, 54, 0);
~DX7.control(3, 55, 0);
~DX7.control(3, 56, 0);
~DX7.control(3, 57, 0);
~DX7.control(3, 58, 0);
~DX7.control(3, 59, 0);//Env Level-2
~DX7.control(3, 60, 0);
~DX7.control(3, 61, 0);
~DX7.control(3, 62, 0);
~DX7.control(3, 63, 0);
~DX7.control(3, 64, 0);
~DX7.control(3, 65, 0);//Env Level-3
~DX7.control(3, 66, 1);
~DX7.control(3, 67, 1);
~DX7.control(3, 68, 1);
~DX7.control(3, 69, 1);
~DX7.control(3, 70, 1);
~DX7.control(3, 71, 1);//Env Level-4
~DX7.control(3, 72, 1);
~DX7.control(3, 73, 1);
~DX7.control(3, 74, 1);
~DX7.control(3, 75, 1);
~DX7.control(3, 76, 1);
~DX7.control(3, 77, 1);//Scaletel
~DX7.control(3, 78, 0);
~DX7.control(3, 79, 0);
~DX7.control(3, 80, 0);
~DX7.control(3, 81, 0);
~DX7.control(3, 82, 0);
~DX7.control(3, 83, 0);//Keyboard Breakpoint
~DX7.control(3, 84, 1);
~DX7.control(3, 85, 1);
~DX7.control(3, 86, 1);
~DX7.control(3, 87, 1);
~DX7.control(3, 88, 1);
~DX7.control(3, 89, 1);//L Curve
~DX7.control(3, 90, 1);
~DX7.control(3, 91, 1);
~DX7.control(3, 92, 1);
~DX7.control(3, 93, 1);
~DX7.control(3, 94, 1);
~DX7.control(3, 95, 1);//L Depth
~DX7.control(3, 96, 1);
~DX7.control(3, 97, 1);
~DX7.control(3, 98, 1);
~DX7.control(3, 99, 1);
~DX7.control(3, 100, 1);
~DX7.control(3, 101, 1);//R Curve
~DX7.control(3, 102,1);
~DX7.control(3, 103,1);
~DX7.control(3, 104,1);
~DX7.control(3, 105,1);
~DX7.control(3, 106,1);
~DX7.control(3, 107,1);//R Depth
~DX7.control(3, 108,1);
~DX7.control(3, 109,1);
~DX7.control(3, 110,1);
~DX7.control(3, 111,1);
~DX7.control(3, 112,1);
~DX7.control(3, 113,1);//Velocity Sens
~DX7.control(3, 114,1);
~DX7.control(3, 115,1);
~DX7.control(3, 116,1);
~DX7.control(3, 117,1);
~DX7.control(3, 118,1);
~DX7.control(3, 119,1);//Osc Fine

//%%%%%%%%%%%%%%%%%%

~DX7.control(4, 0, 13);
~DX7.control(4, 1, 19);
~DX7.control(4, 2, 11);
~DX7.control(4, 3, 11);
~DX7.control(4, 4, 11);
~DX7.control(4, 5, 11);
~DX7.control(4, 6, 11);
~DX7.control(4, 7, 11);
~DX7.control(4, 8, 11);
~DX7.control(4, 9, 11);
~DX7.control(4, 10, 11);
~DX7.control(4, 11, 11);
~DX7.control(4, 12, 11);
~DX7.control(4, 13, 11);
~DX7.control(4, 14, 11);
~DX7.control(4, 15, 11);
~DX7.control(4, 16, 11);
~DX7.control(4, 17, 11);
~DX7.control(4, 18, 11);
~DX7.control(4, 19, 11);
~DX7.control(4, 20, 11);
~DX7.control(4, 21, 11);
~DX7.control(4, 22, 11);
~DX7.control(4, 23, 11);

)

//27 JUNE 2016 10:41:19 (ECT +2)//
//((((8096 - ((64 * (14 + (vr[3] >> 1))) + (32 * (99 + 28)))) * 0.0235) / (0.2819*(2.pow(24*0.16)))) / (2 + (((64 * (14 + (99 >> 1))) / 256).floor)));
//example code shows how deep the rabbit hole goes

ps
Sorry for adding this CC after all these years, but you have to understand that, you are basically at my bedroom musician setup DX7 code, and I don't owe you anything, especially at a time when my life is basically: 7 days empty a year seems like heaven, and this went for 10 years straight. So before asking why did I not include CC notes in the first release, consider that, I don't get anything in return, also as this case, with many cases with solo open-source projects, developer has all the right to do whatever he wants, you cannot impose me in anyway a claim/request/comment, there is no hieararchy here, or a cop saying: you cannot change this project to a blog post about DSP (i won't), or why is this code not fitted in Pbind, well figure it out yourself than, and be thankful that, I bring a code that brings a value to your music system, and as luckily as a happy ending, you can now do it yourself, basic code for CC, so maybe Go ahead try, it should take 1/10000th time I spent for DX7 project to debug this CC messages yourself and trust this strangers advice that the sound of modulating CC is amazing. //aggression fades off

~DX7.control(3, 0,  3);
~DX7.control(3, 1,  3);
~DX7.control(3, 2,  3);
~DX7.control(3, 3,  3);
~DX7.control(3, 4,  3);
~DX7.control(3, 5,  3);//Osc Coarse
added at the end for some reason, means this is all Osc Course, and CC 0, 1, 2, 3, 4, 5, are all Osc Coarse of different DX7 operators (respectively)

//here is a beginning, you should just send, two arguments, check DX7.scd, its embedded in it (CC values),
MIDIdef.cc(\DX7CC, {arg ...args;
	presetz2[args[1]] = args[0];
},(0..1),srcID:~midiInINST4,chan:5).add;

*/
