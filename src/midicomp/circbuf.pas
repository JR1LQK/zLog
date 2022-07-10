{ $Header:   F:/delphi/midi/vcs/circbuf.pas   1.8   02 Jul 1995 00:51:04   DAVEC  $ }

{ A First-In First-Out circular buffer.
  Port of circbuf.c from Microsoft's Windows MIDI monitor example.
  I did do a version of this as an object (see Rev 1.1) but it was getting too 
  complicated and I couldn't see any real benefits to it so I dumped it 
  for an ordinary memory buffer with pointers. 

  The main problem is that the object has to be allocated in global shared
  memory and the PutEvent method has to be accessed from a DLL at interrupt
  time. Since you can't debug DLLs in Delphi this could be a nightmare to 
  get working. Maybe later!

  This unit is a bit C-like, everything is done with pointers and extensive
  use is made of the undocumented feature of the Inc() function that 
  increments pointers by the size of the object pointed to.
  All of this could probably be done using Pascal array notation with
  range-checking turned off, but I'm not sure it's worth it.
}

Unit Circbuf;

interface

Uses Wintypes, WinProcs, MMSystem;

type
	{ MIDI input event }
	TMidiInputBufferItem = record				
	  	timestamp: Longint;	{ Timestamp in milliseconds after midiInStart }
		data: Longint;		{ MIDI message received }
		sysex: PMidiHdr;	{ Pointer to sysex MIDIHDR, nil if not sysex }
	end;
	PMidiInputBufferItem = ^TMidiInputBufferItem;

	{ MIDI input buffer }
	TCircularBuffer = record
		RecordHandle: THANDLE;		{ Windows memory handle for this record }
		BufferHandle: THANDLE;		{ Windows memory handle for the buffer }
		pStart: PMidiInputBufferItem;		{ ptr to start of buffer }
		pEnd: PMidiInputBufferItem;			{ ptr to end of buffer }
		pNextPut: PMidiInputBufferItem;		{ next location to fill }
		pNextGet: PMidiInputBufferItem;		{ next location to empty }
		Error: Word;		 		{ error code from MMSYSTEM functions }
		Capacity: Word;				{ buffer size (in TMidiInputBufferItems) }
		EventCount: Word;			{ Number of events in buffer }
	end;

   PCircularBuffer = ^TCircularBuffer;

function GlobalSharedLockedAlloc( Capacity: Word; var hMem: THANDLE ): Pointer;
procedure GlobalSharedLockedFree( hMem: THANDLE; ptr: Pointer );

function CircbufAlloc( Capacity: Word ): PCircularBuffer;
procedure CircbufFree( PBuffer: PCircularBuffer );
function CircbufRemoveEvent( PBuffer: PCircularBuffer ): Boolean;
function CircbufReadEvent( PBuffer: PCircularBuffer; PEvent: PMidiInputBufferItem ): Boolean;
{ Note: The PutEvent function is in the DLL }

implementation

{ Allocates in global shared memory, returns pointer and handle }
function GlobalSharedLockedAlloc( Capacity: Word; var hMem: THANDLE ): Pointer;
var
	ptr: Pointer;
begin
	{ Allocate the buffer memory }
	hMem := GlobalAlloc(GMEM_SHARE Or GMEM_MOVEABLE Or GMEM_ZEROINIT, Capacity );

	if (hMem = 0) then
		ptr := Nil
	else
		begin
		ptr := GlobalLock(hMem);
		if (ptr = Nil) then
			GlobalFree(hMem);
		end;

	if (ptr <> Nil) then
		GlobalPageLock(HIWORD(Longint(ptr)));

	GlobalSharedLockedAlloc := Ptr;
end;

procedure GlobalSharedLockedFree( hMem: THANDLE; ptr: Pointer );
begin
	if (ptr <> Nil) then
		GlobalPageUnlock(HIWORD(Longint(ptr)));
	if (hMem <> 0) then
		begin
		GlobalUnlock(hMem);
		GlobalFree(hMem);
		end;
end;

function CircbufAlloc( Capacity: Word ): PCircularBuffer;
var
	NewCircularBuffer: PCircularBuffer;
	NewMIDIBuffer: PMidiInputBufferItem;
	hMem: THANDLE;
begin
	{ TODO: Validate circbuf size, <64K }
	NewCircularBuffer := 
		GlobalSharedLockedAlloc( Sizeof(TCircularBuffer), hMem );
	if (NewCircularBuffer <> Nil) then
		begin
		NewCircularBuffer^.RecordHandle := hMem;
		NewMIDIBuffer := 
			GlobalSharedLockedAlloc( Capacity * Sizeof(TMidiInputBufferItem), hMem );
		if (NewMIDIBuffer = Nil) then
			begin
			{ TODO: Exception here? }
			GlobalSharedLockedFree( NewCircularBuffer^.RecordHandle, 
											NewCircularBuffer );
			NewCircularBuffer := Nil;
			end
		else
			begin
                	NewCircularBuffer^.pStart := NewMidiBuffer;
			{ Point to item at end of buffer }
			NewCircularBuffer^.pEnd := NewMidiBuffer;
			Inc(NewCircularBuffer^.pEnd, Capacity);
			{ Start off the get and put pointers in the same position. These
			  will get out of sync as the interrupts start rolling in }
			NewCircularBuffer^.pNextPut := NewMidiBuffer;
			NewCircularBuffer^.pNextGet := NewMidiBuffer;
			NewCircularBuffer^.Error := 0;
			NewCircularBuffer^.Capacity := Capacity;
			NewCircularBuffer^.EventCount := 0;
			end;
		end;
	CircbufAlloc := NewCircularBuffer;
end;

procedure CircbufFree( pBuffer: PCircularBuffer );
begin
	if (pBuffer <> Nil) then
		begin
		GlobalSharedLockedFree(pBuffer^.BufferHandle, pBuffer^.pStart);
		GlobalSharedLockedFree(pBuffer^.RecordHandle, pBuffer);
		end;
end;

{ Reads first event in queue without removing it.
  Returns true if successful, False if no events in queue }
function CircbufReadEvent( PBuffer: PCircularBuffer; PEvent: PMidiInputBufferItem ): Boolean;
var
	PCurrentEvent: PMidiInputBufferItem;
begin
	if (PBuffer^.EventCount <= 0) then
			CircbufReadEvent := False
	else
		begin
		PCurrentEvent := PBuffer^.PNextget;

		{ Copy the object from the "tail" of the buffer to the caller's object }
		PEvent^.Timestamp := PCurrentEvent^.Timestamp;
		PEvent^.Data := PCurrentEvent^.Data;
                PEvent^.Sysex := PCurrentEvent^.Sysex;
		CircbufReadEvent := True;
		end;
end;

{ Remove current event from the queue }
function CircbufRemoveEvent(PBuffer: PCircularBuffer): Boolean;
begin
	if (PBuffer^.EventCount > 0) then
		begin
		Dec( Pbuffer^.EventCount);

		{ Advance the buffer pointer, with wrap }
		Inc( Pbuffer^.PNextGet );
		If (PBuffer^.PNextGet = PBuffer^.PEnd) then
			PBuffer^.PNextGet := PBuffer^.PStart;

		CircbufRemoveEvent := True;
		end
	else
		CircbufRemoveEvent := False;
end;

end.
