// Initialize NetAddr on LiveOSC port (9000):

~live = NetAddr.new("127.0.0.1", 9000);

// OSCdef for listening to LiveOSC. Does not really work, but keep:

OSCdef.new(\liveResponder, { | msg |
	msg.postln;
},
	'/live/clip/notes', recvPort: 9001;
);

~makeNotes = {
	|trackNo = 0, slotNo = 0, degrees, root = 60, clipName = "NewClip"|
	~live.sendMsg("/live/clip/delete", trackNo, slotNo); // Clear the slot before writing a new clip
	~live.sendMsg("/live/clip/create", trackNo, slotNo, degrees.size); // Create a clip at specified slot in track
	degrees.do({
		|item, index|
		~live.sendMsg("/live/clip/add_note", trackNo, slotNo, root + degrees[index], index, 1.0, 100, 0);
		~live.sendMsg("/live/name/clip", trackNo, slotNo, clipName); // Name the clip something
	});
	("Wrote notes into slot " ++ (slotNo + 1) ++ " on track " ++ (trackNo + 1) ++ ".").postln;
};

// Call function with default values:
// C major scale in track 1, slot 1

~makeNotes.(trackNo: 0, slotNo: 0, degrees: [0, 2, 4, 5, 6, 9, 11], root: 60);

// A meta function for writing a specific scale into a slot
// MakeScale support all scales in SuperCollider, accessed with "Scales.directory":

~metaMakeScale = {
	|trackNo = 0, slotNo = 1, scaleNo = 0, root = 64|
	var scaleList, scale, degrees, scaleName, makeNotes;
	scaleList = Scale.names.collect({
		|item, index|
		Scale.at(item.asSymbol);
	});
	scaleName = Scale.names;
	scale = scaleList[scaleNo];
	degrees = scale.degrees;
	~makeNotes.(trackNo, slotNo, degrees);
	("Scale name: " ++ scaleName[scaleNo] ++ ".").postln;
};

// Call the function

~metaMakeScale.(trackNo: 0, slotNo: 0, scaleNo: 25, root: 60);

// Can be used with some randomness to give the user a few scales to choose from:

5.do({
	|item, index|
	~metaMakeScale.(0, index, 107.rand, 60);
});

// Supply simplified dictionaries for Western scales and modal scales?

// Sorting notes, making tone-rowes and their iterations (inverse, retrograde, inverse retrograde)

// Function for sorting the intervals in any given scale (!) in order from largest to smallest:


~sortLargestToSmallest = {
	|array|
	var input, output, large;
	input = Array.newFrom(array);
	large = Array.new(array.size);
	if ( input.size == array.size,
		{ input.do({ |item, index|
			var counter;
			counter = 1;
			counter = counter + index;
			// "Iteration:".postln;
			// counter.postln;
			// "Array size:".postln;
			// input.size.postln;
			// item.postln; index.postln;
		large.add(input[input.maxIndex]);
		input.removeAt(input.maxIndex);});
	}, { });
	output = [large, input].lace(array.size);
};

~sortLargestToSmallest.(Scale.major.degrees); // Using a major scale
~sortLargestToSmallest.(Scale.minor.degrees); // Using a minor scale
~sortLargestToSmallest.(Scale.at(\ionian).degrees); // Arbitrary scales using .at

// Save this into a environment variable, and write with the makeNotes function:

~toWrite = ~sortLargestToSmallest.(Scale.at(\chromatic).degrees);
~makeNotes.(trackNo: 0, slotNo: 0, degrees: ~toWrite.reverse, root: 60);
~toWrite.reverse;

// Structures for working with 12-tone rows (dodecaphony)

~toneRow = Scale.chromatic.degrees;

// Retrograde:

~toneRow.reverse;

// Inversion:
// For intervals identified by an integer number of semitones, the inversion is obtained by subtracting that number from 12

~webernPrime = [6, 5, 2, 4, 3, 0, 9, 1, 8, 11, 10, 7];
~webernRetrograde = ~webern.reverse;
~webernInversed = (~webern - 12).neg
~webernRetrogradeInversed = ~webernInversed.reverse;

~makeNotes.(trackNo: 0, slotNo: 0, degrees: ~webernPrime, root: 60);
~makeNotes.(trackNo: 0, slotNo: 1, degrees: ~webernRetrograde, root: 60);
~makeNotes.(trackNo: 0, slotNo: 2, degrees: ~webernInversed, root: 60);
~makeNotes.(trackNo: 0, slotNo: 3, degrees: ~webernRetrogradeInversed, root: 60);

// Provocerande hur annorlunda resultat det här producerar... uppenbart pga inversioner:

~webernAlternative = [6, 17, 2, 14, 3, 12, 21, 1, 10, 11, 22, 7];
~webernAlternativeInversed = (~webernAlternative -12);

~makeNotes.(trackNo: 0, slotNo: 0, degrees: ~webernAlternative, root: 60);
~makeNotes.(trackNo: 0, slotNo: 3, degrees: ~webernAlternativeInversed, root: 60);

// Production:

~toneRow = Scale.chromatic.degrees;
~toneRow = ~sortLargestToSmallest.(~toneRow);

~makeDodecaphony = {
	|tone_row|
	var pri, ret, inv, inv_ret, all_vari;
	pri = tone_row;
	ret = pri.reverse;
	inv = (pri- 12).neg;
	inv_ret = inv.reverse;
	all_vari = [pri, ret, inv, inv_ret];
	all_vari.do({
		|item, index|
		~makeNotes.(0, index, item, 60, item.asString);
	});
};

~makeDodecaphony.(~toneRow);