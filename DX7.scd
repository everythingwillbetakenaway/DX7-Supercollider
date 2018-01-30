// Supercollider DX7 Clone v1.0
// Implemented by Aziz Ege Gonul for more info go to www.egegonul.com
// Under GNU GPL 3 as per SuperCollider license

//Example
( // Note On 80 message with velocity value 100 and preset value 10000
~mainCaller.value(80, 100, 10002);
)
( // Note Off message
~mainCaller.value(80, 0);
)

/*
%%%---INSTRUCTIONS---%%%
1) Put the DX7.afx file in the same directory of this file. (If you don't have it you can download it from "http://www.egegonul.com/DX7.afx.zip")
2) Compile the parenthesis below.
3) Run the ~mainCaller.value function with the desired note, velocity and preset values.

important notes:
-FM7.ar plugin is needed (It comes with the SC3 plugins).
-Velocity value, drastically changes the overall timbre of sound.
-Gate time is in use, so in order to close the node, velocity value zero must be send to the same note number. (Just like the MIDI convention)
-If you change presets on the run, newly opened notes with new presets might affect the existing notes. Most of the time this is a very minimal effect because it only affects the global LFO value. This happens due to the architecture design of DX7. Remember this is a single clone of DX7, not a clones of clones.
-Not all presets have velocity depth. So it might sound same no matter what the velocity is.
-Sometimes you see "FAILURE IN SERVER /n_free Node 808 not found" message, this is due to the DetectSilence.ar UGen which helps me to close some forgotten notes in combination with FreeSelfWhenDone (Sometimes nodes skips detect silence because of DC component). FreeSelfDone commmand has a 10 second duration. So if you need longer duration please increase the argument but don't comment out completely.
-You can ignore all the commented out areas. It is mostly for debug use. Everything works perfectly. Nothing to worry about.

//order of things: [note, velocity, preset]
//note value range: 0 - 127
//velocity value range: 0 - 127
//preset value range: 0 - 16383 (2 ^ 14)
//example: ~mainCaller.value(note,velocity,preset)
//for more extra info go to the end of this file
*/

//First compile below
(
var novaDX7 = ParGroup.new,

coarseArrR = #[0.5,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31],

coarseArrF = #[
	1, 10, 100, 1000,
	1, 10, 100, 1000,
	1, 10, 100, 1000,
	1, 10, 100, 1000,
	1, 10, 100, 1000,
	1, 10, 100, 1000,
	1, 10, 100, 1000,
	1, 10, 100, 1000],

fineArrR = #[
	1.00,1.01,1.02,1.03,1.04,1.05,1.06,1.07,1.08,1.09,
	1.10,1.11,1.12,1.13,1.14,1.15,1.16,1.17,1.18,1.19,
	1.20,1.21,1.22,1.23,1.24,1.25,1.26,1.27,1.28,1.29,
	1.30,1.31,1.32,1.33,1.34,1.35,1.36,1.37,1.38,1.39,
	1.40,1.41,1.42,1.43,1.44,1.45,1.46,1.47,1.48,1.49,
	1.50,1.51,1.52,1.53,1.54,1.55,1.56,1.57,1.58,1.59,
	1.60,1.61,1.62,1.63,1.64,1.65,1.66,1.67,1.68,1.69,
	1.70,1.71,1.72,1.73,1.74,1.75,1.76,1.77,1.78,1.79,
	1.80,1.81,1.82,1.83,1.84,1.85,1.86,1.87,1.88,1.89,
	1.90,1.91,1.92,1.93,1.94,1.95,1.96,1.97,1.98,1.99],

fineArrF = #[
	1.000,1.023,1.047,1.072,1.096,1.122,1.148,1.175,1.202,1.230,
	1.259,1.288,1.318,1.349,1.380,1.413,1.445,1.479,1.514,1.549,
	1.585,1.622,1.660,1.698,1.738,1.778,1.820,1.862,1.905,1.950,
	1.995,2.042,2.089,2.138,2.188,2.239,2.291,2.344,2.399,2.455,
	2.512,2.570,2.630,2.692,2.716,2.818,2.884,2.951,3.020,3.090,
	3.162,3.236,3.311,3.388,3.467,3.548,3.631,3.715,3.802,3.890,
	3.981,4.074,4.169,4.266,4.365,4.467,4.571,4.677,4.786,4.898,
	5.012,5.129,5.248,5.370,5.495,5.623,5.754,5.888,6.026,6.166,
	6.310,6.457,6.607,6.761,6.918,7.079,7.244,7.413,7.586,7.762,
	7.943,8.128,8.318,8.511,8.718,8.913,9.120,9.333,9.550,9.772],

voice_eg_rate_rise_duration = #[ 39.638000,  37.013000,  34.388000,  31.763000,  27.210500,     22.658000,  20.408000,  18.158000,  15.908000,  14.557000,     13.206000,  12.108333,  11.010667,   9.913000,   8.921000,     7.929000,   7.171333,   6.413667,   5.656000,   5.307000,      4.958000,   4.405667,   3.853333,   3.301000,   2.889000,      2.477000,   2.313000,   2.149000,   1.985000,   1.700500,      1.416000,   1.274333,   1.132667,   0.991000,   0.909000,      0.827000,   0.758000,   0.689000,   0.620000,   0.558000,      0.496000,   0.448667,   0.401333,   0.354000,   0.332000,      0.310000,   0.275667,   0.241333,   0.207000,   0.180950,      0.154900,   0.144567,   0.134233,   0.123900,   0.106200,      0.088500,   0.079667,   0.070833,   0.062000,   0.056800,      0.051600,   0.047300,   0.043000,   0.038700,   0.034800,      0.030900,   0.028000,   0.025100,   0.022200,   0.020815,      0.019430,   0.017237,   0.015043,   0.012850,   0.011230,      0.009610,   0.009077,   0.008543,   0.008010,   0.006960,      0.005910,   0.005357,   0.004803,   0.004250,   0.003960,      0.003670,   0.003310,   0.002950,   0.002590,   0.002420,      0.002250,   0.002000,   0.001749,   0.001499,   0.001443,      0.001387,   0.001242,   0.001096,   0.000951,   0.000815,      0.000815,   0.000815,   0.000815,   0.000815,   0.000815,      0.000815,   0.000815,   0.000815,   0.000815,   0.000815,      0.000815,   0.000815,   0.000815,   0.000815,   0.000815,      0.000815,   0.000815,   0.000815,   0.000815,   0.000815,      0.000815,   0.000815,   0.000815,   0.000815,   0.000815,      0.000815,   0.000815,   0.000815],

dx7_voice_eg_rate_rise_percent = #[    0.000010, 0.000010, 0.000010, 0.000010, 0.000010,    0.000010, 0.000010, 0.000010, 0.000010, 0.000010,    0.000010, 0.000010, 0.000010, 0.000010, 0.000010,    0.000010, 0.000010, 0.000010, 0.000010, 0.000010,    0.000010, 0.000010, 0.000010, 0.000010, 0.000010,    0.000010, 0.000010, 0.000010, 0.000010, 0.000010,    0.000010, 0.000010, 0.005007, 0.010005, 0.015003,    0.020000, 0.028000, 0.036000, 0.044000, 0.052000,    0.060000, 0.068000, 0.076000, 0.084000, 0.092000,    0.100000, 0.108000, 0.116000, 0.124000, 0.132000,    0.140000, 0.150000, 0.160000, 0.170000, 0.180000,    0.190000, 0.200000, 0.210000, 0.220000, 0.230000,    0.240000, 0.251000, 0.262000, 0.273000, 0.284000,    0.295000, 0.306000, 0.317000, 0.328000, 0.339000,    0.350000, 0.365000, 0.380000, 0.395000, 0.410000,    0.425000, 0.440000, 0.455000, 0.470000, 0.485000,    0.500000, 0.520000, 0.540000, 0.560000, 0.580000,    0.600000, 0.620000, 0.640000, 0.660000, 0.680000,    0.700000, 0.732000, 0.764000, 0.796000, 0.828000,    0.860000, 0.895000, 0.930000, 0.965000, 1.000000,    1.000000, 1.000000, 1.000000, 1.000000, 1.000000,    1.000000, 1.000000, 1.000000, 1.000000, 1.000000,    1.000000, 1.000000, 1.000000, 1.000000, 1.000000,    1.000000, 1.000000, 1.000000, 1.000000, 1.000000,    1.000000, 1.000000, 1.000000, 1.000000, 1.000000,    1.000000, 1.000000, 1.000000],

velTable = #[-99.0,-10.295511,-9.709229,-9.372207,-9.121093,-8.629703,-8.441805,-8.205647,-7.810857,-7.653259,-7.299901,-7.242308,-6.934396, 6.727051,-6.594723,-6.427755,-6.275133,-6.015212,-5.843023,-5.828787,-5.725659,-5.443202,-5.421110,-5.222133,-5.160615,-5.038265,-4.948225,-4.812105,    -4.632120,-4.511531,-4.488645,-4.370043,-4.370610,-4.058591,-4.066902,-3.952988,-3.909686,-3.810096,-3.691883,-3.621306,-3.527286,-3.437519,-3.373512,-3.339195,-3.195983, -3.167622, -3.094788, -2.984045,-2.937463, -2.890713, -2.890660, -2.691874,-2.649229, -2.544696, -2.498147, -2.462573,-2.396637, -2.399795, -2.236338, -2.217625, -2.158336, -2.135569, -1.978521, -1.913965,-1.937082, -1.752275, -1.704013, -1.640514,-1.598791, -1.553859, -1.512187, -1.448088,-1.450443, -1.220567, -1.182340, -1.123139,-1.098469, -1.020642, -0.973039, -0.933279,-0.938035, -0.757380, -0.740860, -0.669721,-0.681526, -0.555390, -0.519321, -0.509318,-0.456936, -0.460622, -0.290578, -0.264393,-0.252716, -0.194141, -0.153566, -0.067842,-0.033402, -0.054947,  0.012860, 0.000000,-0.009715,  0.236054,  0.273956,  0.271968,0.330177,  0.345427,  0.352333,  0.433861,0.442952,  0.476411,  0.539632,  0.525355,0.526115,  0.707022, 0.701551,  0.734875,0.739149,  0.794320,  0.801578,  0.814225,0.818939,  0.897102,  0.895082,  0.927998,0.929797,  0.956112,  0.956789,  0.958121],

/* This table converts LFO speed to frequency in Hz. It is based on
* interpolation of Jamie Bullock's measurements. */

dx7_voice_lfo_frequency = #[
	0.062506,  0.124815,  0.311474,  0.435381,  0.619784,
	0.744396,  0.930495,  1.116390,  1.284220,  1.496880,
	1.567830,  1.738994,  1.910158,  2.081322,  2.252486,
	2.423650,  2.580668,  2.737686,  2.894704,  3.051722,
	3.208740,  3.366820,  3.524900,  3.682980,  3.841060,
	3.999140,  4.159420,  4.319700,  4.479980,  4.640260,
	4.800540,  4.953584,  5.106628,  5.259672,  5.412716,
	5.565760,  5.724918,  5.884076,  6.043234,  6.202392,
	6.361550,  6.520044,  6.678538,  6.837032,  6.995526,
	7.154020,  7.300500,  7.446980,  7.593460,  7.739940,
	7.886420,  8.020588,  8.154756,  8.288924,  8.423092,
	8.557260,  8.712624,  8.867988,  9.023352,  9.178716,
	9.334080,  9.669644, 10.005208, 10.340772, 10.676336,
	11.011900, 11.963680, 12.915460, 13.867240, 14.819020,
	15.770800, 16.640240, 17.509680, 18.379120, 19.248560,
	20.118000, 21.040700, 21.963400, 22.886100, 23.808800,
	24.731500, 25.759740, 26.787980, 27.816220, 28.844460,
	29.872700, 31.228200, 32.583700, 33.939200, 35.294700,
	36.650200, 37.812480, 38.974760, 40.137040, 41.299320,
	42.461600, 43.639800, 44.818000, 45.996200, 47.174400,
	47.174400, 47.174400, 47.174400, 47.174400, 47.174400,
	47.174400, 47.174400, 47.174400, 47.174400, 47.174400,
	47.174400, 47.174400, 47.174400, 47.174400, 47.174400,
	47.174400, 47.174400, 47.174400, 47.174400, 47.174400,
	47.174400, 47.174400, 47.174400, 47.174400, 47.174400,
	47.174400, 47.174400, 47.174400],

/* This table converts pitch modulation sensitivity to semitones at full
* modulation (assuming a perfectly linear pitch mod depth to pitch
* relationship).  It is from a simple averaging of Jamie Bullock's
* TX-data-1/PMD and TX-data-2/ENV data, and ignores the apparent ~0.1
* semitone positive bias that Jamie observed. [-FIX- smbolton: my
* inclination would be to call this bias, if it's reproducible, a
* non-desirable 'bug', and _not_ implement it in hexter. And, at
* least for my own personal build, I'd change that PMS=7 value to a
* full octave, since that's one thing that's always bugged me about
* my TX7.  Thoughts? ] */

dx7_voice_pms_to_semitones= #[ //8
	0.0, 0.450584, 0.900392, 1.474744,
	2.587385, 4.232292, 6.982097, /* 11.722111 */ 12.0],


/* This table converts amplitude modulation depth to output level
* reduction at full modulation with an amplitude modulation sensitivity
* of 3.  It was constructed from regression of a very few data points,
* using this code:
*   perl -e 'for ($i = 0; $i <= 99; $i++) { printf " %f,\n", exp($i * 0.0428993 - 0.285189); }' >x.c
* and is probably rather rough in its accuracy. -FIX- */
dx7_voice_amd_to_ol_adjustment = #[ //100
	0.0, 0.784829, 0.819230, 0.855139, 0.892622, 0.931748,
	0.972589, 1.015221, 1.059721, 1.106171, 1.154658, 1.205270,
	1.258100, 1.313246, 1.370809, 1.430896, 1.493616, 1.559085,
	1.627424, 1.698759, 1.773220, 1.850945, 1.932077, 2.016765,
	2.105166, 2.197441, 2.293761, 2.394303, 2.499252, 2.608801,
	2.723152, 2.842515, 2.967111, 3.097167, 3.232925, 3.374633,
	3.522552, 3.676956, 3.838127, 4.006362, 4.181972, 4.365280,
	4.556622, 4.756352, 4.964836, 5.182458, 5.409620, 5.646738,
	5.894251, 6.152612, 6.422298, 6.703805, 6.997652, 7.304378,
	7.624549, 7.958754, 8.307609, 8.671754, 9.051861, 9.448629,
	9.862789, 10.295103, 10.746365, 11.217408, 11.709099,
	12.222341, 12.758080, 13.317302, 13.901036, 14.510357,
	15.146387, 15.810295, 16.503304, 17.226690, 17.981783,
	18.769975, 19.592715, 20.451518, 21.347965, 22.283705,
	23.260462, 24.280032, 25.344294, 26.455204, 27.614809,
	28.825243, 30.088734, 31.407606, 32.784289, 34.221315,
	35.721330, 37.287095, 38.921492, 40.627529, 42.408347,
	44.267222, 46.207578, 48.232984, 50.347169, 52.75],


/* This table converts pitch envelope level parameters into the
* actual pitch shift in semitones.  For levels [17,85], this is
* just ((level - 50) / 32 * 12), but at the outer edges the shift
* is exagerated to 0 = -48 and 99 => 47.624.  This is based on
* measurements I took from my TX7. */

dx7_voice_pitch_level_to_shift = #[ //128
	-48.000000, -43.497081, -38.995993, -35.626132, -31.873615,
	-28.495880, -25.500672, -22.872620, -20.998167, -19.496961,
	-18.373238, -17.251065, -16.122139, -15.375956, -14.624487,
	-13.876516, -13.126351, -12.375000, -12.000000, -11.625000,
	-11.250000, -10.875000, -10.500000, -10.125000, -9.750000,
	-9.375000, -9.000000, -8.625000, -8.250000, -7.875000,
	-7.500000, -7.125000, -6.750000, -6.375000, -6.000000,
	-5.625000, -5.250000, -4.875000, -4.500000, -4.125000,
	-3.750000, -3.375000, -3.000000, -2.625000, -2.250000,
	-1.875000, -1.500000, -1.125000, -0.750000, -0.375000, 0.000000,
	0.375000, 0.750000, 1.125000, 1.500000, 1.875000, 2.250000,
	2.625000, 3.000000, 3.375000, 3.750000, 4.125000, 4.500000,
	4.875000, 5.250000, 5.625000, 6.000000, 6.375000, 6.750000,
	7.125000, 7.500000, 7.875000, 8.250000, 8.625000, 9.000000,
	9.375000, 9.750000, 10.125000, 10.500000, 10.875000, 11.250000,
	11.625000, 12.000000, 12.375000, 12.750000, 13.125000,
	14.251187, 15.001922, 16.126327, 17.250917, 18.375718,
	19.877643, 21.753528, 24.373913, 27.378021, 30.748956,
	34.499234, 38.627888, 43.122335, 47.624065, 48.0, 48.0, 48.0,
	48.0, 48.0, 48.0, 48.0, 48.0, 48.0, 48.0, 48.0, 48.0, 48.0,
	48.0, 48.0, 48.0, 48.0, 48.0, 48.0, 48.0, 48.0, 48.0, 48.0,
	48.0, 48.0, 48.0, 48.0, 48.0],
/*

adepth = dx7_voice_amd_to_ol_adjustment[voice->lfo_amd];

%%%%%%%%%%%%%%%%%%%%%%%%


/* full-scale amp mod for adepth and edepth should be 52.75 and
* their sum _must_ be limited to less than 128, or bad things will happen! */
if (adepth > 127.5f) adepth = 127.5f;
if (adepth + mdepth > 127.5f)
mdepth = 127.5f - adepth;
if (adepth + mdepth + edepth > 127.5f)
edepth = 127.5f - (adepth + mdepth);

*/
dx7patches = Array.newClear(16384),
vr = Array.fill(256, 63),
noteArrayDX7 = Array.newClear(128),
defme, defjamHead0, defjamHead1, betass = 0, headno, defPitchEnv, noteParser,
scale_vrv, envCal, dumm, selector = #[66, 48, 54, 60, 66],
feedbackSel = #[
	35, 7, 35, 33, 35, 34, 35, 21,
	7, 14, 35,  7, 35, 35,  7, 35,
	7, 14, 35, 14, 14, 35, 35, 35,
	35, 35, 14, 28, 35, 28, 35, 35
],

feedbackIndex = #[0, 0.0066, 0.0077, 0.011, 0.0153, 0.018, 0.0226, 0.063],

waveform_selector, phase_selector,
wf = Array2D.fromArray(32, 42, [
	//algorithm matrix
	/*Alg #1*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,(pi * 4),0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,0,1,0,0,0,
	/*Alg #2*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,(pi * 4),0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,(pi * 4),0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,0,/*V*/1,0,1,0,0,0,
	/*Alg #3*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,(pi * 4),0,0,0,/*3*/0,0,0,0,0,0,/*4*/0,0,0,0,(pi * 4),0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,0,0,1,0,0,
	/*Alg #4*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,(pi * 4),0,0,0,/*3*/0,0,0,0,0,0,/*4*/0,0,0,0,(pi * 4),0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,(pi * 4),0,0,/*V*/1,0,0,1,0,0,
	/*Alg #5*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,0,1,0,1,0,
	/*Alg #6*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,(pi * 4),0,/*V*/1,0,1,0,1,0,
	/*Alg #7*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),(pi * 4),0,/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,0,1,0,0,0,
	/*Alg #8*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),(pi * 4),0,/*4*/0,0,0,(pi * 4),0,0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,0,/*V*/1,0,1,0,0,0,
	/*Alg #9*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,(pi * 4),0,0,0,0,/*3*/0,0,0,(pi * 4),(pi * 4),0,/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,0,/*V*/1,0,1,0,0,0,
	/*Alg #10*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,(pi * 4),0,0,0,/*3*/0,0,(pi * 4),0,0,0,/*4*/0,0,0,0,(pi * 4),(pi * 4),/*5*/0,0,0,0,0,0,/*6*/0,0,0,0,0,0,/*V*/1,0,0,1,0,0,
	/*Alg #11*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,(pi * 4),0,0,0,/*3*/0,0,0,0,0,0,/*4*/0,0,0,0,(pi * 4),(pi * 4),/*5*/0,0,0,0,0,0,/*6*/0,0,0,0,0,(pi * 4),/*V*/1,0,0,1,0,0,
	/*Alg #12*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,(pi * 4),0,0,0,0,/*3*/0,0,0,(pi * 4),(pi * 4),(pi * 4),/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,0,/*6*/0,0,0,0,0,0,/*V*/1,0,1,0,0,0,
	/*Alg #13*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),(pi * 4),(pi * 4),/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,0,/*6*/0,0,0,0,0,(pi * 4),/*V*/1,0,1,0,0,0,
	/*Alg #14*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,(pi * 4),(pi * 4),/*5*/0,0,0,0,0,0,/*6*/0,0,0,0,0,(pi * 4),/*V*/1,0,1,0,0,0,
	/*Alg #15*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,(pi * 4),0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,(pi * 4),(pi * 4),/*5*/0,0,0,0,0,0,/*6*/0,0,0,0,0,0,/*V*/1,0,1,0,0,0,
	/*Alg #16*/ /*1*/0,(pi * 4),(pi * 4),0,(pi * 4),0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,0,0,0,0,0,
	/*Alg #17*/ /*1*/0,(pi * 4),(pi * 4),0,(pi * 4),0,/*2*/0,(pi * 4),0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,0,/*V*/1,0,0,0,0,0,
	/*Alg #18*/ /*1*/0,(pi * 4),(pi * 4),(pi * 4),0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,(pi * 4),0,0,0,/*4*/0,0,0,0,(pi * 4),0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,0,/*V*/1,0,0,0,0,0,
	/*Alg #19*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,(pi * 4),0,0,0,/*3*/0,0,0,0,0,0,/*4*/0,0,0,0,0,(pi * 4),/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,0,0,1,1,0,
	/*Alg #20*/ /*1*/0,0,(pi * 4),0,0,0,/*2*/0,0,(pi * 4),0,0,0,/*3*/0,0,(pi * 4),0,0,0,/*4*/0,0,0,0,(pi * 4),(pi * 4),/*5*/0,0,0,0,0,0,/*6*/0,0,0,0,0,0,/*V*/1,1,0,1,0,0,
	/*Alg #21*/ /*1*/0,0,(pi * 4),0,0,0,/*2*/0,0,(pi * 4),0,0,0,/*3*/0,0,(pi * 4),0,0,0,/*4*/0,0,0,0,0,(pi * 4),/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,0,/*V*/1,1,0,1,1,0,
	/*Alg #22*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,0,0,(pi * 4),/*4*/0,0,0,0,0,(pi * 4),/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,0,1,1,1,0,
	/*Alg #23*/ /*1*/0,0,0,0,0,0,/*2*/0,0,(pi * 4),0,0,0,/*3*/0,0,0,0,0,0,/*4*/0,0,0,0,0,(pi * 4),/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,1,0,1,1,0,
	/*Alg #24*/ /*1*/0,0,0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,0,0,(pi * 4),/*4*/0,0,0,0,0,(pi * 4),/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,1,1,1,1,0,
	/*Alg #25*/ /*1*/0,0,0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,0,0,0,/*4*/0,0,0,0,0,(pi * 4),/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,1,1,1,1,0,
	/*Alg #26*/ /*1*/0,0,0,0,0,0,/*2*/0,0,(pi * 4),0,0,0,/*3*/0,0,0,0,0,0,/*4*/0,0,0,0,(pi * 4),(pi * 4),/*5*/0,0,0,0,0,0,/*6*/0,0,0,0,0,(pi * 4),/*V*/1,1,0,1,0,0,
	/*Alg #27*/ /*1*/0,0,0,0,0,0,/*2*/0,0,(pi * 4),0,0,0,/*3*/0,0,(pi * 4),0,0,0,/*4*/0,0,0,0,(pi * 4),(pi * 4),/*5*/0,0,0,0,0,0,/*6*/0,0,0,0,0,0,/*V*/1,1,0,1,0,0,
	/*Alg #28*/ /*1*/0,(pi * 4),0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,(pi * 4),0,/*5*/0,0,0,0,(pi * 4),0,/*6*/0,0,0,0,0,0,/*V*/1,0,1,0,0,1,
	/*Alg #29*/ /*1*/0,0,0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,1,1,0,1,0,
	/*Alg #30*/ /*1*/0,0,0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,(pi * 4),0,0,/*4*/0,0,0,0,(pi * 4),0,/*5*/0,0,0,0,(pi * 4),0,/*6*/0,0,0,0,0,0,/*V*/1,1,1,0,0,1,
	/*Alg #31*/ /*1*/0,0,0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,0,0,0,/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,(pi * 4),/*6*/0,0,0,0,0,(pi * 4),/*V*/1,1,1,1,1,0,
	/*Alg #32*/ /*1*/0,0,0,0,0,0,/*2*/0,0,0,0,0,0,/*3*/0,0,0,0,0,0,/*4*/0,0,0,0,0,0,/*5*/0,0,0,0,0,0,/*6*/0,0,0,0,0,(pi * 4),/*V*/1,1,1,1,1,1

]),

cirklonCCparse = #[
	[4,0],[4,1],[4,3],[4,5],[4,4],[4,10],[4,7],[4,8],[4,9],[4,6],[4,2],
	[4,11],[4,12],[4,13],[4,14],[4,15],[4,16],[4,17],[4,18],
	[4,48],[3,0],[3,114],[3,12],[3,72],[3,24],[3,30],[3,36],[3,42],[3,48],[3,54],[3,60],[3,66],[3,6], [3,90],[3,102],[3,84],[3,96], [3,78],[3,108],[3,18],
	[4,49],[3,1],[3,115],[3,13],[3,73],[3,25],[3,31],[3,37],[3,43],[3,49],[3,55],[3,61],[3,67],[3,7], [3,91],[3,103],[3,85],[3,97], [3,79],[3,109],[3,19],
	[4,50],[3,2],[3,116],[3,14],[3,74],[3,26],[3,32],[3,38],[3,44],[3,50],[3,56],[3,62],[3,68],[3,8], [3,92],[3,104],[3,86],[3,98], [3,80],[3,110],[3,20],
	[4,51],[3,3],[3,117],[3,15],[3,75],[3,27],[3,33],[3,39],[3,45],[3,51],[3,57],[3,63],[3,69],[3,9], [3,93],[3,105],[3,87],[3,99], [3,81],[3,111],[3,21],
	[4,52],[3,4],[3,118],[3,16],[3,76],[3,28],[3,34],[3,40],[3,46],[3,52],[3,58],[3,64],[3,70],[3,10],[3,94],[3,106],[3,88],[3,100],[3,82],[3,112],[3,22],
	[4,53],[3,5],[3,119],[3,17],[3,77],[3,29],[3,35],[3,41],[3,47],[3,53],[3,59],[3,65],[3,71],[3,11],[3,95],[3,107],[3,89],[3,101],[3,83],[3,113],[3,23],
],

outOscVol = #[2, 2, 2, 2, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 3, 3, 4, 4, 4, 5, 5, 3, 3, 3, 4, 4, 5, 6],

/*
buffers and busses
*/

lfoSqr = Buffer.alloc(s, 512, 1),
lfoSawDown = Buffer.alloc(s, 512, 1),
lfoSawUp = Buffer.alloc(s, 512, 1),
lfoSin = Buffer.alloc(s, 512, 1),
lfoTri = Buffer.alloc(s, 512, 1),
pitchTameConst,
pitchTameMult,
busMeAmp = Bus.audio(s, 1),
busMePitch = Bus.audio(s, 1);
lfoSqr.sine3(Array.series(50, 1, 2), 1/Array.series(50, 1, 2)); //square waveform
lfoTri.sine3(Array.series(50, 1, 2), ((1/(Array.series(50, 1, 2).squared)) * [1,-1])); //triangle waveform
lfoSawDown.sine3(Array.series(100, 1, 1), (1/(Array.series(100, 1, 1)) * [-1,1]),4pi); //sawtooth waveform down
lfoSawUp.sine3(Array.series(100, 1, 1), (1/(Array.series(100, 1, 1)) * [-1,1]),3pi); //sawtooth waveform rising
lfoSin.sine3([1],[1]); // sine waveform
waveform_selector = [lfoTri, lfoSawDown, lfoSawUp, lfoSqr, lfoSin, lfoSin];
phase_selector =    [0.5pi , 0.98pi    , 0.98    , 0.98pi,  0    , 0     ];
pitchTameConst =    [0,1,1,0,0,0];
pitchTameMult =     [1,0,0,1,1,1];

/*

SynthDefs

*/


SynthDef(\InfEfx, {
	arg outBus=0, pitch, gate,
	lfoGet1 = 0, lfoGet2=1,
	lfo_speed, lfo_wave, lfo_phase,
	lfo_delay, lfo_pmd, lfo_amd, lfo_sync, lfo_pms, pitchCons,envTrig, tameC, tameM,
	eg_r1, eg_r2, eg_r3, eg_r4, eg_L1, eg_L2, eg_L3, eg_L4;
	//
	var lfo, pitchenv, output, randomlfo, multiPitch, lfoAmp;
	//
	FreeSelf.kr(gate);
	lfo = Osc.ar(lfo_wave,lfo_speed, lfo_phase, 0.5 * lfoGet2, 0.5 * lfoGet2) + LFNoise0.ar(lfo_speed, 0.5 * lfoGet1, 0.5 * lfoGet1);
	lfo = lfo * EnvGen.ar(Env.asr(lfo_delay,releaseTime:0.01, curve: -5),envTrig);
	multiPitch = LinLin.ar(lfo, 0, 1, (pitchCons.neg.midiratio * tameM) + tameC, pitchCons.midiratio);
	lfoAmp = LinLin.ar(lfo, 0, 1, lfo_amd * (-3/4), 0);

	//Poll.ar(Impulse.ar(10), lfoAmp);
	//PHASE PART++
	//tri en tepeden basliyor
	//sawdown en asagidan baslio
	//pms 4, pmd 40, +-1 semitone yapiyor
	//sawup en yukardan
	//square en asaidan
	//sine sifirdan baslio

	Out.ar(busMePitch, multiPitch);
	Out.ar(busMeAmp, lfoAmp)
}).add;


SynthDef(\DX7, {
	arg outBus=0, pitch, gate = 1,
	envPL0, envPL1, envPL2, envPL3, envPL4, envPR0, envPR1, envPR2, envPR3,
	coars1, fine_1,	coars2, fine_2,	coars3, fine_3,	coars4, fine_4,	coars5, fine_5,	coars6, fine_6,
	env1L0, env1L1, env1L2, env1L3, env1L4, env1R0, env1R1, env1R2, env1R3, env1C0, env1C1, env1C2, env1C3,
	env2L0, env2L1, env2L2, env2L3, env2L4, env2R0, env2R1, env2R2, env2R3, env2C0, env2C1, env2C2, env2C3,
	env3L0, env3L1, env3L2, env3L3, env3L4, env3R0, env3R1, env3R2, env3R3, env3C0, env3C1, env3C2, env3C3,
	env4L0, env4L1, env4L2, env4L3, env4L4, env4R0, env4R1, env4R2, env4R3, env4C0, env4C1, env4C2, env4C3,
	env5L0, env5L1, env5L2, env5L3, env5L4, env5R0, env5R1, env5R2, env5R3, env5C0, env5C1, env5C2, env5C3,
	env6L0, env6L1, env6L2, env6L3, env6L4, env6R0, env6R1, env6R2, env6R3, env6C0, env6C1, env6C2, env6C3,
	noteBlok1, noteBlok2, noteBlok3, noteBlok4, noteBlok5, noteBlok6,
	dn0, dn1, dn2, dn3, dn4, dn5,
	dn6, dn7, dn8, dn9, dn10, dn11,
	dn12, dn13, dn14, dn15, dn16, dn17,
	dn18, dn19, dn20, dn21, dn22, dn23,
	dn24, dn25, dn26, dn27, dn28, dn29,
	dn30, dn31, dn32, dn33, dn34, dn35,
	dn36, dn37, dn38, dn39, dn40, dn41,
	detun1, detun2, detun3, detun4, detun5, detun6,
	modSens1, modSens2, modSens3, modSens4, modSens5, modSens6, outMult,
	//below is the general,
	osc_sync, transpose,
	gate1=1, gate1Rel = 1, amp=0.1, totVol;
	var ctls, mods, chans, out, kilnod,
	envAmp1, envEnv1, envAmp2, envEnv2, envAmp3, envEnv3 ,envAmp4, envEnv4, envAmp5, envEnv5, envAmp6, envEnv6, dca, envAmpP, envEnvP;
	//
	envEnvP = Env.new([ envPL0, envPL1, envPL2, envPL3, envPL4], [envPR0,envPR1,envPR2,envPR3], 0, 3);
	envAmpP = EnvGen.kr(envEnvP, gate, doneAction:0);
	envEnv1 = Env.new([(-1 * env1L0).dbamp ,(-1 * env1L1).dbamp, (-1 * env1L2).dbamp, (-1 * env1L3).dbamp, (-1 * env1L4).dbamp], [env1R0,env1R1,env1R2,env1R3], [env1C0,env1C1,env1C2,env1C3], 3);
	envAmp1 = EnvGen.kr(envEnv1, gate, doneAction:0 );
	envEnv2 = Env.new([(-1 * env2L0).dbamp ,(-1 * env2L1).dbamp, (-1 * env2L2).dbamp, (-1 * env2L3).dbamp, (-1 * env2L4).dbamp], [env2R0,env2R1,env2R2,env2R3], [env2C0,env2C1,env2C2,env2C3], 3);
	envAmp2 = EnvGen.kr(envEnv2, gate, doneAction:0 );
	envEnv3 = Env.new([(-1 * env3L0).dbamp ,(-1 * env3L1).dbamp, (-1 * env3L2).dbamp, (-1 * env3L3).dbamp, (-1 * env3L4).dbamp], [env3R0,env3R1,env3R2,env3R3], [env3C0,env3C1,env3C2,env3C3], 3);
	envAmp3 = EnvGen.kr(envEnv3, gate, doneAction:0 );
	envEnv4 = Env.new([(-1 * env4L0).dbamp ,(-1 * env4L1).dbamp, (-1 * env4L2).dbamp, (-1 * env4L3).dbamp, (-1 * env4L4).dbamp], [env4R0,env4R1,env4R2,env4R3], [env4C0,env4C1,env4C2,env4C3], 3);
	envAmp4 = EnvGen.kr(envEnv4, gate, doneAction:0 );
	envEnv5 = Env.new([(-1 * env5L0).dbamp ,(-1 * env5L1).dbamp, (-1 * env5L2).dbamp, (-1 * env5L3).dbamp, (-1 * env5L4).dbamp], [env5R0,env5R1,env5R2,env5R3], [env5C0,env5C1,env5C2,env5C3], 3);
	envAmp5 = EnvGen.kr(envEnv5, gate, doneAction:0 );
	envEnv6 = Env.new([(-1 * env6L0).dbamp ,(-1 * env6L1).dbamp, (-1 * env6L2).dbamp, (-1 * env6L3).dbamp, (-1 * env6L4).dbamp], [env6R0,env6R1,env6R2,env6R3], [env6C0,env6C1,env6C2,env6C3], 3);
	envAmp6 = EnvGen.kr(envEnv6, gate, doneAction:0 );
	//	envEnv1.test.plot;
	ctls = [
		[coars1 * fine_1 * ((pitch * noteBlok1) + ((detun1-7)/32)) * (envAmpP.midiratio) * Lag2.ar(In.ar(busMePitch),0.01),  Rand(0,2pi) * osc_sync, envAmp1 * (Lag2.ar(In.ar(busMeAmp),0.01) * (modSens1/3)).dbamp],
		[coars2 * fine_2 * ((pitch  * noteBlok2) + ((detun2-7)/32)) * (envAmpP.midiratio) * Lag2.ar(In.ar(busMePitch),0.01),  Rand(0,2pi) * osc_sync, envAmp2 * (Lag2.ar(In.ar(busMeAmp),0.01) * (modSens2/3)).dbamp],
		[coars3 * fine_3 * ((pitch * noteBlok3) + ((detun3-7)/32)) * (envAmpP.midiratio) * Lag2.ar(In.ar(busMePitch),0.01),  Rand(0,2pi) * osc_sync, envAmp3 * (Lag2.ar(In.ar(busMeAmp),0.01) * (modSens3/3)).dbamp],
		[coars4 * fine_4 * ((pitch  * noteBlok4) + ((detun4-7)/32)) * (envAmpP.midiratio) * Lag2.ar(In.ar(busMePitch),0.01),  Rand(0,2pi) * osc_sync, envAmp4 * (Lag2.ar(In.ar(busMeAmp),0.01) * (modSens4/3)).dbamp],
		[coars5 * fine_5 * ((pitch  * noteBlok5) + ((detun5-7)/32)) * (envAmpP.midiratio) * Lag2.ar(In.ar(busMePitch),0.01),  Rand(0,2pi) * osc_sync, envAmp5 * (Lag2.ar(In.ar(busMeAmp),0.01) * (modSens5/3)).dbamp],
		[coars6 * fine_6 * ((pitch  * noteBlok6) + ((detun6-7)/32)) * (envAmpP.midiratio) * Lag2.ar(In.ar(busMePitch),0.01),  Rand(0,2pi) * osc_sync, envAmp6 * (Lag2.ar(In.ar(busMeAmp),0.01) * (modSens6/3)).dbamp]
	];
	mods = [
		[dn0, dn1, dn2, dn3, dn4, dn5],
		[dn6, dn7, dn8, dn9, dn10, dn11],
		[dn12, dn13, dn14, dn15, dn16, dn17],
		[dn18, dn19, dn20, dn21, dn22, dn23],
		[dn24, dn25, dn26, dn27, dn28, dn29],
		[dn30, dn31, dn32, dn33, dn34, dn35]
	];
	chans = [0, 1, 2, 3, 4, 5];
	out = FM7.ar(ctls, mods).slice(chans) * -12.dbamp;
	out = Mix.new([
		(out[0] * 1 * dn36),
		(out[1] * 1 * dn37),
		(out[2] * 1 * dn38),
		(out[3] * 1 * dn39),
		(out[4] * 1 * dn40),
		(out[5] * 1 * dn41),
	]);
	FreeSelfWhenDone.kr(Line.kr(0, 1, 10));
	kilnod = DetectSilence.ar(out, 0.01, 0.2, doneAction:2);
	//out = out * Lag2.ar(In.ar(busMe),0.01);
	//Out.ar([0,1], 0.5 * In.ar(busMe)); //deneme
	out = out / outMult;
	//DetectSilence.ar(out, 0.01, 0.2,doneAction:2);
	//out = out * ((totVol -15).dbamp);
	Out.ar(outBus, out.dup); //orj

}).add;

scale_vrv = { arg dummy, scaling_curve, scaling_depth, vrv;
	switch(scaling_curve,
		0, {(vrv - ((dummy / 45) * scaling_depth).asInt)}, // -lin
		1, {(vrv - (((dummy - 72) / 13.5).exp * scaling_depth).asInt)}, // -exp
		2, {(vrv + (((dummy - 72) / 13.5).exp * scaling_depth).asInt)}, // +exp
		3, {(vrv + ((dummy / 45) * scaling_depth).asInt)} // +lin
        )
};

envCal = { arg // Area of hardcore envelope calculation function.
	vr1, //Level Current
	vr2, //Level Next
	vrx, //Speed
	vrv, //Volume
	velo,//Velocity
	velSens,
	level_scaling_bkpoint,
	level_scaling_l_depth,
	level_scaling_r_depth,
	level_scaling_l_curve,
	level_scaling_r_curve,
	transposed_note,
	rate_scaling,
	amp_mod_sens;//not sure if i put this globa
	var dummy, velFin, env_L0, env_L1, env_R0, vrvDec, endR0, dbStr, dbEnd;
	if (((transposed_note < (level_scaling_bkpoint + 21)) && (level_scaling_l_depth > 0)), {
		dummy = (level_scaling_bkpoint - (((transposed_note + 2) / 3).asInt * 3) + 21);
		vrv = scale_vrv.(dummy, level_scaling_l_curve, level_scaling_l_depth, vrv);
	});
	if (((transposed_note > (level_scaling_bkpoint + 21)) && (level_scaling_r_depth > 0)), {
		dummy = (((transposed_note + 2) / 3).asInt * 3) - level_scaling_bkpoint - 21;
		vrv = scale_vrv.(dummy, level_scaling_r_curve, level_scaling_r_depth, vrv);
	});
	rate_scaling = ((rate_scaling * (transposed_note - 21) / (126.0 - 21.0) * 127.0 / 128.0 * 6.5 )- 0.5).asInt;
	vrx = (rate_scaling + vrx).clip(0,99);
	vrv = vrv.clip(0,99);
	velFin = (velTable[velo] * velSens);
	//~vrv = ((~vrv+(~velTable[~velo] * ~velSens)).clip(0,127));//old version
	env_L0 = case
	{(100 > vr1) && (vr1 > 20)}   { (64 * (14 + ((vr1) >> 1)))}
	{(21 > vr1)  && (vr1 > 16)}   { (64 * (4 + vr1))}
	{(17 > vr1)  && (vr1 > 5)}    { (64 * (5 + vr1))}
	{(6 > vr1)   && (vr1 > (-1))} { (64 * (2 * vr1))}
	{99 < vr1}  { (64 * (14 + (99 >> 1)))};
	env_L1 = case
	{(100 > vr2) && (vr2 > 20)}   { (64 * (14 + ((vr2) >> 1)))}
	{(21 > vr2)  && (vr2 > 16)}   { (64 * (4 + vr2))}
	{(17 > vr2)  && (vr2 > 5)}    { (64 * (5 + vr2))}
	{(6 > vr2)   && (vr2 > (-1))} { (64 * (2 * vr2 + 5))}
	{99 < vr2}  { (64 * (14 + (99 >> 1)))};

	vrvDec = ((vrv+ velFin).clip(0,127));//is this correct, limit 99?
	env_R0 = (0.2819*(2.pow((vrx)*0.16))); // attack ise -1? decay ise + 0.5?
	vrvDec = case
	{(128 > vrvDec) && (vrvDec > 20)}   {(32 * (vrvDec + 28))}
	{(21 > vrvDec)  && (vrvDec > 16)}   {(32 * (vrvDec + 17))}
	{(17 > vrvDec)  && (vrvDec > 5)}    {(32 * (vrvDec + 11))}
	{(6 > vrvDec)   && (vrvDec > (-1))} {(32 * (vrvDec))};
	dbStr = ((99 - (vr1 + vrv - 99 + velFin)) / 1.33333333);

	dbEnd = ((99 - (vr2 + vrv - 99 + velFin)) / 1.333333);
	endR0 = if( (env_L0 > env_L1),
		{
			((((env_L0 + vrvDec - 4064).clip(1,9000) - (env_L1 + vrvDec - 4064).clip(1,9000))* 0.0235) / env_R0)
		},

		{
			(voice_eg_rate_rise_duration[vrx] * (dx7_voice_eg_rate_rise_percent[((((vr2 * vrv) / 99) + velFin).clip(0,99)).asInt] - dx7_voice_eg_rate_rise_percent[((((vr1 * vrv) / 99) + velFin).clip(0,99)).asInt]))
		}
	);
	//[dbStr, dbEnd, endR0].postln;
	[dbStr, dbEnd, endR0];

};


defjamHead1 = {
	var abc = [], algo, fdbIndNo = Array.fill(42, 1);
			algo = (vr[128]).clip(0,31);
			abc = [\outMult, outOscVol[vr[128]]];
			//abc.postln;
			fdbIndNo[feedbackSel[algo]] =  feedbackIndex[(vr[129])] * (vr[129]);
			42.do(
				{
					arg x;
					abc = abc ++ [\dn ++ x, (wf[algo,x] * fdbIndNo[x])];
			});
			abc;
};

defjamHead0 = {
	var cba = [], lfoDepth, lfoGet1, lfoGet2;
			if(vr[133] == 5, {lfoGet1=1; lfoGet2 =0}, {lfoGet1 = 0; lfoGet2 =1 });
			lfoDepth = (dx7_voice_pms_to_semitones[vr[138]]) * (vr[135] / 99);
			//lfoDepth.postln;
			cba = [
				\lfo_speed, dx7_voice_lfo_frequency[vr[132]],
				\lfo_wave, (waveform_selector[vr[133]]).bufnum, //random signal icinde yap,
				\lfo_phase, phase_selector[vr[133]],
				\envTrig, 0,
				\envTrig, 1,
				\pitchCons, lfoDepth,
				/* sifirdan baslasin because we need to reset the LFO phase */
				\lfoGet1, lfoGet1,
				\lfoGet2, lfoGet2,
				\tameM, pitchTameMult[vr[133]],
				\tameC, pitchTameConst[vr[133]],
				\lfo_delay, ((vr[134]).clip(0,99)).linlin(0,99,0.01,3.4),//lineer ramp ile carp
				\lfo_amd, dx7_voice_amd_to_ol_adjustment[vr[136]]
			];
			//cba.postln;
			cba;
			//a y.removeAt(1); ['a', 'b', 'c'].do({ arg item, i; [i, item].postln; });
};


defPitchEnv = { arg rate_1, rate_2, rate_3, rate_4, level_1, level_2, level_3, level_4;
	var endy,
	envPL0, envPL1, envPL2, envPL3, envPL4, envPR0, envPR1, envPR2,envPR3;
	//functions start here
	envPL0 = dx7_voice_pitch_level_to_shift[level_4];
	envPL1 = dx7_voice_pitch_level_to_shift[level_1];
	envPL2 = dx7_voice_pitch_level_to_shift[level_2];
	envPL3 = dx7_voice_pitch_level_to_shift[level_3];
	envPL4 = dx7_voice_pitch_level_to_shift[level_4];
	envPR0 = exp((rate_1 - 70.337897) / -25.580953) * abs((envPL1 - envPL0) / 96.0) * 2.45;
	envPR1 = exp((rate_2 - 70.337897) / -25.580953) * abs((envPL2 - envPL1) / 96.0) * 2.45;
	envPR2 = exp((rate_3 - 70.337897) / -25.580953) * abs((envPL3 - envPL2) / 96.0) * 2.45;
	envPR3 = exp((rate_4 - 70.337897) / -25.580953) * abs((envPL4 - envPL3) / 96.0) * 2.45;
	endy = [
		\envPL0, envPL0,
		\envPL1, envPL1,
		\envPL2, envPL2,
		\envPL3, envPL3,
		\envPL4, envPL4,
		\envPR0, envPR0,
		\envPR1, envPR1,
		\envPR2, envPR2,
		\envPR3, envPR3
	];
	//endy.postln;
	endy;
};


defme = { arg note, vel;
	var a , bil, ptchEnv,
	envL  = Array2D.new(6,5),
	envR  = Array2D.new(6,4),
	//selector = [66, 48, 54, 60, 66],
	envC  = Array2D.new(6,4);
	6.do { arg y;
		4.do(
			{
				arg x;//selector = [66, 48, 54, 60, 66],
				dumm = envCal.value(
					vr[selector[x] + y],//vr1, //Level Current
					vr[selector[x + 1] + y],//vr2, //Level Next
					(99-vr[(24 + (x * 6)) + y]),//vrx, //Speed
					vr[6 + y],//vrv, //Volume
					vel,//velo,//Velocity
					vr[108 + y],//velSens,
					vr[78 + y],//level_scaling_bkpoint,
					vr[90 + y],//level_scaling_l_depth,
					vr[102 + y],//level_scaling_r_depth,
					vr[84 + y],//level_scaling_l_curve,
					vr[96 + y],//level_scaling_r_curve,
					(note + 3 + vr[131] - 24),//transposed_note,
					vr[72 + y],//rate_scaling,//not implemented yer
					vr[18 + y]//amp_mod_sens;//no
				);
				envL[y,x] = dumm[0];
				envR[y,x] = dumm[2];
				if(dumm[0] > dumm[1], { envC[y,x] = 3} ,{envC[y,x] = -3});
		});
		envL[y,4] = envL[y,0];
	};
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	bil = defjamHead1.();
	a =[
		\pitch, (note + vr[131] - 24 ).midicps,
		\amp, vel.linlin(0,127,-18,18)];
	6.do { arg c;
		var trCoarse, trFine, trDetune, bloke;//176
		if(vr[176 + c] == 0, //midi CC 128 + 48 fixed frequency
			{
				trCoarse = coarseArrR[vr[0 + c]];
				trFine   = fineArrR[vr[114 + c]];
				trDetune = vr[12 + c];
				bloke = 1;
			},
			{
				trCoarse = coarseArrF[vr[0 + c]];
				trFine   = fineArrF[vr[114 + c]];
				trDetune = 39;
				bloke = 0;
		});
		a = a ++ [
			\coars ++ (c + 1), trCoarse,
			\fine_ ++ (c + 1), trFine,
			\detun ++ (c + 1), trDetune,
			\noteBlok ++ (c + 1), bloke,
		];

	};
	6.do { arg k;
		a = a ++ [
			\coars ++ (k + 1), coarseArrR[vr[0 + k]],
			\fine_ ++ (k + 1), fineArrR[vr[114 + k]],
			\env ++ (k + 1) ++ "L0", envL[k,0],
			\env ++ (k + 1) ++ "L1", envL[k,1],
			\env ++ (k + 1) ++ "L2", envL[k,2],
			\env ++ (k + 1) ++ "L3", envL[k,3],
			\env ++ (k + 1) ++ "L4", envL[k,4],
			\env ++ (k + 1) ++ "R0", envR[k,0],
			\env ++ (k + 1) ++ "R1", envR[k,1],
			\env ++ (k + 1) ++ "R2", envR[k,2],
			\env ++ (k + 1) ++ "R3", envR[k,3],
			\env ++ (k + 1) ++ "C0", envC[k,0],
			\env ++ (k + 1) ++ "C1", envC[k,1],
			\env ++ (k + 1) ++ "C2", envC[k,2],
			\env ++ (k + 1) ++ "C3", envC[k,3],
			\modSens ++ (k + 1), vr[18 + k],
		];

	};
	ptchEnv = defPitchEnv.value((99-vr[139]),(99-vr[140]),(99-vr[141]),(99-vr[142]),vr[143],vr[144],vr[145],vr[146]);
	a = bil ++ a ++ ptchEnv;
	a = a ++ [\osc_sync, ((vr[130] * (-1)) + 1)];
	//a.postln;
	a;

};
noteParser = { arg vel, note;
	1.do { arg yxx;
			if(vel > 0,
				{
					//150.do({ arg c; ("cc#" ++ c.asString ++ " = " ++ vr[c]).postln}); //general cc printer, rates are not inverted.
					if(noteArrayDX7[note] !== nil,noteArrayDX7[note].free);
					if(vr[137] == 1, {//lfo sync controller
						if(betass == 1,   {
							headno.free;
						});
						betass = 1;
						headno = Synth.before(novaDX7, \InfEfx, defjamHead0.());
					},
					{
						if(betass == 0,   {
							betass = 1;
							headno = Synth.before(novaDX7, \InfEfx, defjamHead0.())
						},
						{
							headno.set(defjamHead0.())
						});
					});
					noteArrayDX7[note] = Synth(\DX7 ,defme.value(note, vel),novaDX7);
					//noteArrayDX7[note] = Synth(\DX7 ,defme.value(note, vel), novaDX7); //orjburayi addtotail diye degistirdin

				},
				{
					noteArrayDX7[note].set(\gate,0);
					noteArrayDX7[note] = nil;

		})
	}
};


f = { arg x, y ,z; //y value, z cc no
	if(x == 3,
		{ vr[y] = z },
		{ vr[y + 128] = z }
	)
};
//Creating a patch array from .afx file to prevent "unsaved file" error.
r = File("DX7.afx".resolveRelative,"r");
16384.do({arg item;
	dx7patches[item] = r.getLine;
});

~mainCaller = { arg x, y, z;
	if(y > 0,{
//		r = File("DX7.afx".resolveRelative,"r");
		//r = File("/Users/EmanTnuocca/Desktop/3/DX7.afx","r");

		g = dx7patches[z];
		145.do({arg item;
			k = (g.at((item*2)) ++ g.at((item*2) + 1)).asInt;
			f.value(cirklonCCparse[item][0],cirklonCCparse[item][1],k);
			//~midiOutDX7.control(~cirklonCCparse[item][0],~cirklonCCparse[item][1],k);

		});
	});
	noteParser.value(y, x)

};
)

/*
extra notes from the developer:
-I've designed this instrument as accurately as possible to the original DX7, all the presets are collected from the vast DX7 libraries across the internet. Some presets were corrupt so I cleaned them according to their unused indexes but there might be still some that might not work. (I haven't found out yet)
-I've worked on this project extensively during my STEIM internship, and compared every tiny bit of detail with the Original DX7 and reverse engineered the C++ code from the best parts of DX7 VSTs out there.
-File extension .afx is just an arbitrary name, I chose it because of my admiration to Mr.RichardDavidJames <3.
-Original DX7 sysex files were converted with the help of Propellerhead's DX7 conversion tool and from there I implemented my own convention, which is just sequence of numbers stacked together, each line is one preset.

Things to be implemented in future:
-I will implement a function which will help to send all parameters of DX7. (It has 146 different parameters).
-Adding your own DX7 preset option will be implemented.
-Add some examples of original DX7 sounds compared with this Synthdef in order to show accuracy. (During my initial tests it was hard to determine which one is which with the blind tests)
-That's all folks, for questions just drop a mail to egegonul@egegonul.com


//Some fun example below. Uncomment this area and run the below parenthesis for random preset and pitch for each note. Check CPU!!

(
~number = 15000.rand; //preset start number, dont go further than 16383
~ra = Routine {
303.do({ arg a;
~sun = 99.rand + 10;
~mainCaller.value(~sun, 127.rand, ~number);
((50.rand)/100).wait; // Waits for at most half second between each node
~mainCaller.value(~sun, 0, ~number);
~number = ~number +1;
});
// Wait half second before saying we're done
0.5.wait;
"done".postln;
}.play;
)
(//stop
~ra.stop;
~mainCaller.value(~sun, 0, ~number);
)

*/