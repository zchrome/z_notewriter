# z_notewriter

Some very simple and work-in-progress SuperCollider functions for writing arbitrary notes directly to aa clip in an open Ableton Live session.
Also includes a sorting function to sort intervals in an array of degrees (such as a scale) from largest to smallest interval.

## Dependencies

Requires [LiveOSC](https://github.com/ideoforms/LiveOSC) to write clip and note data to Ableton Live.

## Usage

Call the function ```~makeNotes``` to write an array as notes to an open Live session.

Arrays should be degrees (interval steps from root note), and can be of an arbitrary length. The ```root``` argument use MIDI note values to set root note (0 degrees).

Scales can be generated with the ```~makeScale``` function, which uses the built-in Scale directory to select what scale to output.
