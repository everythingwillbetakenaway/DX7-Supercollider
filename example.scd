// Supercollider DX7 Clone v1.0
// Implemented by Aziz Ege Gonul for more info go to www.egegonul.com
// Under GNU GPL 3 as per SuperCollider license

//Example

//STEP 1 - START THE SERVER (cmd+enter or control+enter)
( // init
	// Server.killAll
	s.boot;
)

//STEP 2 - LOAD THE FILE BELOW
(
~mainCaller = ("./DX7.scd").loadRelative.wrapAt(-1);
)

//STEP 3 - FIRST NOTE
( // Note On 80 message with velocity value 100 and preset value 10000
    ~mainCaller.value(80, 10, 10000);
)

( // Note Off message
	~mainCaller.value(80, 0);
)

/*
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
