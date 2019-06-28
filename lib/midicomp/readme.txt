 Delphi MIDI I/O Components               Version 1.0  4 July 1995
 --------------------------               ------------------------
 
 These components handle low-level MIDI input and output using the 
Windows multimedia MIDI functions. They encapsulate all the nasty
low-level stuff into some intermediate-level components. They support
both short MIDI messages (e.g. note on/off, program change) and long
MIDI messages (e.g. system exclusive, sample dumps). 

 To install the components:
 
 1. Use Delphi's Options|Install Components to install MIDIIN.PAS and
 MIDIOUT.PAS. This should give you MIDI input and output components
 on the Samples tab.
 
 2. Load the project DELPHMID and select Compile|Build All to build
 DELPHMID.DLL.
 
 3. Load the project MIDIMON and try running it.
 
 There's no formal documentation, but there are lists of properties,
methods, and events in the headers of MIDIIN.PAS and MIDIOUT.PAS.
There's also a couple of example projects: MIDIMON.PAS is a simple
monitor that demonstrates using components created at design time,
and MULTIMON.PAS demonstrates using multiple input and output components
created at runtime.

 If you need to know more about MIDI messages you can get a nice package 
of MIDI documentation by sending an email message to 
listserv@auvm.american.edu with GET MIDISPEC PACKAGE in the message 
body.

 These components are in the public domain so feel free to produce
any type of program based on them. 

 The components were thrown together fairly quickly and still have a few 
rough edges. As they're my first Delphi components I'd appreciate any 
feedback and suggestions for improvement. Of course there may be a few 
bugs, so if you find any please let me know. My email address is 
dchurcher@cix.compulink.co.uk.


