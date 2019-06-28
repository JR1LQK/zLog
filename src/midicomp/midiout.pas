{ $Header:   F:/delphi/midi/vcs/midiout.pas   1.5   03 Jul 1995 01:51:06   DAVEC  $ }

unit MidiOut;

{ 
  MIDI Output component.

  Properties:
  	DeviceID: 	Windows numeric device ID for the MIDI output device.
	Between 0 and (midioutGetNumDevs-1), or MIDI_MAPPER (-1).
    Special value MIDI_MAPPER specifies output to the Windows MIDI mapper
	Read-only while device is open, exception if changed while open

	MIDIHandle:	The output handle to the MIDI device.
	0 when device is not open
	Read-only, runtime-only

	ProductName: Name of the output device product that corresponds to the
	DeviceID property (e.g. 'MPU 401 out').
	You can write to this while the device is closed to select a particular
	output device by name (the DeviceID property will change to match).
	Exception if this property is changed while the device is open.

	Numdevs: Number of MIDI output devices installed on the system. This
	is the value returned by midiOutGetNumDevs. It's included for 
	completeness.

	See the MIDIOUTCAPS entry in MMSYSTEM.HLP for descriptions of the
	following properties:
		DriverVersion
		Technology
		Voices
		Notes
		ChannelMask
		Support

	Error: The error code for the last MMSYSTEM error. See the MMSYSERR_
	entries in MMSYSTEM.INT for possible values.

  Methods:
	Open: Open MIDI device specified by DeviceID property for output

	Close: Close device

	PutMidiEvent(Event:TMidiEvent): Output a note or sysex message to the
	device. This method takes a TMidiEvent object and transmits it.
	Notes:
	  1. If the object contains a sysex event the OnMidiOutput event will
		  be triggered when the sysex transmission is complete.
	  2. You can queue up multiple blocks of system exclusive data for
		  transmission by chucking them at this method; they will be
		 transmitted as quickly as the device can manage.
	  3. This method will not free the TMidiEvent object, the caller
		  must do that. Any sysex data in the TMidiEvent is copied before
		 transmission so you can free the TMidiEvent immediately after
		 calling PutMidiEvent, even if output has not yet finished.

	PutShort(MidiMessage: Byte; Data1: Byte; Data2: Byte): Output a short
	MIDI message. Handy when you can't be bothered to build a TMidiEvent.
	If the message you're sending doesn't use Data1 or Data2, set them to 0.

	PutLong(SysexPointer: Pointer; msgLength: Word): Output sysex data.
		SysexPointer: Pointer to sysex data to send
		msgLength: Length of sysex data.
	This is handy when you don't have a TMidiEvent.

	SetVolume(Left: Word, Right: Word): Set the volume of the
	left and right channels on the output device (only on internal devices?).
	0xFFFF is maximum volume. If the device doesn't support separate
	left/right volume control, the value of the Left parameter will be used.
	Check the Support property to see whether the device supports volume
	control. See also other notes on volume control under midiOutSetVolume()
	in MMSYSTEM.HLP.

  Events:
	OnMidiOutput: Procedure called when output of a system exclusive block
	is completed.

  Notes:
   I haven't implemented any methods for midiOutCachePatches and 
  midiOutCacheDrumpatches, mainly 'cause I don't have any way of testing
  them. Does anyone really use these?
}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, MMSystem, Circbuf, Midiin;

type
	midioutputState = (mosOpen, mosClosed);
	EmidioutputError = class(Exception);

	{-------------------------------------------------------------------}
	{ Derived from TWinControl because we need a window handle to receive
	messages from the interrupt handler in the DLL }
  TMidiOutput = class(TComponent)
  private
	Handle: THandle;				{ Window handle used for callback notification }
	FDeviceID: Integer;				{ MIDI device ID }
	FMIDIHandle: Hmidiout;		{ Handle to output device }
	FState: midioutputState;	{ Current device state }
	PCtlInfo: PMidiCtlInfo;	{ Pointer to control info for DLL }

	FError: Word;	{ Last MMSYSTEM error }

	{ Stuff from midioutCAPS }
	FDriverVersion: Version;	{ Driver version from midioutGetDevCaps }
	FProductName: string; 		{ product name }
	FTechnology: Word;			{ Type of MIDI output device }
	FVoices: Word;				{ Number of voices (internal synth) }
	FNotes: Word;				{ Number of notes (internal synth) }
	FChannelMask: Word;			{ Bit set for each MIDI channels that the 
								  device responds to (internal synth) }
	FSupport: Longint;			{ Technology supported (volume control,
								  patch caching etc. }
	FNumdevs: Word;				{ Number of MIDI output devices on system }


	FOnMIDIOutput: TNotifyEvent;	{ Sysex output finished }

  protected
	procedure MidiOutput(var Message: TMessage); 
	procedure SetDeviceID(DeviceID: Integer);
	procedure SetProductName( NewProductName: String );
	function midioutErrorString( WError: Word ): String;

  public
	{ Properties }
	property MIDIHandle: Hmidiout read FMIDIHandle;
	property DriverVersion: Version     { Driver version from midioutGetDevCaps }
				read FDriverVersion;
	property Technology: Word			{ Type of MIDI output device }
				read FTechnology;
	property Voices: Word				{ Number of voices (internal synth) }
				read FVoices;
	property Notes: Word				{ Number of notes (internal synth) }
				read FNotes;
	property ChannelMask: Word			{ Bit set for each MIDI channels that the }
				read FChannelMask;      { device responds to (internal synth) }
	property Support: Longint			{ Technology supported (volume control, }
				read FSupport;          { patch caching etc. }
	property Error: Word read FError;
	property Numdevs: Word read FNumdevs;

	{ Methods }
	function Open: Boolean;
	function Close: Boolean;
	procedure PutMidiEvent( theEvent: TMidiEvent);
	procedure PutShort(MidiMessage: Byte; Data1: Byte; Data2: Byte);
	procedure PutLong(SysexPointer: Pointer; msgLength: Word);

	procedure SetVolume( Left: Word; Right:Word );
	constructor Create(AOwner:TComponent); override;
	destructor Destroy; override;

   { Some functions to decode and classify incoming messages would be nice }

  published
	{ TODO: Property editor with dropdown list of product names }
	property ProductName: String read FProductName write SetProductName;

	property DeviceID: Integer read FDeviceID write SetDeviceID default 0;
	{ TODO: midiOutGetVolume? Or two properties for Left and Right volume?
	  Is it worth it??
			midiOutMessage?? Does anyone use this? }

	{ Events }
	property Onmidioutput: TNotifyEvent
		read FOnmidioutput
		write FOnmidioutput;
end;

procedure Register;

{-------------------------------------------------------------------}
implementation

{ This is the callback procedure in the external DLL. 
  It's used when midioutOpen is called by the Open method. 
  There are special requirements and restrictions for this callback 
  procedure (see midioutOpen in MMSYSTEM.HLP) so it's impractical to 
  make it an object method }
function midiHandler(
	  hmidiout: Hmidiout;
	  wMsg: Word;
	  dwInstance: Longint;
	  dwParam1: Longint;
	  dwParam2: Longint): Boolean; far; external 'DELPHMID';


{-------------------------------------------------------------------}
constructor Tmidioutput.Create(AOwner:TComponent);
begin
	inherited Create(AOwner);
	FState := mosClosed;
	FNumdevs := midiOutGetNumDevs;

	{ Set defaults }
	SetDeviceID(0);	{ TODO: Exception if no MIDI devices installed? }

	{ Create the window for callback notification }
	if not (csDesigning in ComponentState) then
		begin
		Handle := AllocateHwnd(MidiOutput);
		end;

end;

{-------------------------------------------------------------------}
destructor Tmidioutput.Destroy;
begin
	if FState = mosOpen then
		Close;
	if (PCtlInfo <> Nil) then
		GlobalSharedLockedFree( PCtlinfo^.hMem, PCtlInfo );
	DeallocateHwnd(Handle);
	inherited Destroy;
end;

{-------------------------------------------------------------------}
{ Convert the numeric return code from an MMSYSTEM function to a string
  using midioutGetErrorText. TODO: These errors aren't very helpful
  (e.g. "an invalid parameter was passed to a system function") so
  some proper error strings would be nice. }
function Tmidioutput.midioutErrorString( WError: Word ): String;
var
	errorDesc: PChar;
begin
	try
		errorDesc := StrAlloc(MAXERRORLENGTH);
		if midioutGetErrorText(WError, errorDesc, MAXERRORLENGTH) = 0 then
			result := StrPas(errorDesc)
		else
			result := 'Specified error number is out of range';
	finally
		StrDispose(errorDesc);
	end;
end;

{-------------------------------------------------------------------}
{ Set the output device ID and change the other properties to match }
procedure Tmidioutput.SetDeviceID(DeviceID: Integer);
var
	midioutCaps: TmidioutCaps;
begin
	if FState = mosOpen then
		raise EmidioutputError.Create('Change to DeviceID while device was open')
	else
		if (DeviceID >= midioutGetNumDevs) And (DeviceID <> MIDI_MAPPER) then
			raise EmidioutputError.Create('Invalid device ID')
		else
			begin
			FDeviceID := DeviceID;

			{ Set the name and other midioutCAPS properties to match the ID }
			FError :=
				midioutGetDevCaps(DeviceID, @midioutCaps, sizeof(TmidioutCaps));
			if Ferror > 0 then
				raise EmidioutputError.Create(midioutErrorString(FError));

			with midiOutCaps do
				begin
				FProductName := StrPas(szPname);
				FDriverVersion := vDriverVersion;
				FTechnology := wTechnology;
				FVoices := wVoices;
				FNotes := wNotes;
				FChannelMask := wChannelMask;
				FSupport := dwSupport;
				end;

			end;
end;

{-------------------------------------------------------------------}
{ Set the product name property and put the matching output device number 
  in FDeviceID.
  This is handy if you want to save a configured output/output device
  by device name instead of device number, because device numbers may
  change if users install or remove MIDI devices.
  Exception if output device with matching name not found,
  or if output device is open }
procedure Tmidioutput.SetProductName( NewProductName: String );
var
	midioutCaps: TmidioutCaps;
	testDeviceID: Integer;
	testProductName: String;
begin
	if FState = mosOpen then
		raise EmidioutputError.Create('Change to ProductName while device was open')
	else
		begin
       { Loop uses -1 to test for MIDI_MAPPER as well }
		for testDeviceID := -1 To (midioutGetNumDevs-1) do
			begin
			FError :=
				midioutGetDevCaps(testDeviceID, @midioutCaps, sizeof(TmidioutCaps));
			if Ferror > 0 then
				raise EmidioutputError.Create(midioutErrorString(FError));
			testProductName := StrPas(midioutCaps.szPname);
			if testProductName = NewProductName then
				begin
				FProductName := NewProductName;
				Break;
				end;
			end;
		if FProductName <> NewProductName then
			raise EmidioutputError.Create('MIDI output Device ' +
				NewProductName + ' not installed')
		else
			SetDeviceID(testDeviceID);
	end;
end;


{-------------------------------------------------------------------}
function Tmidioutput.Open: Boolean;
var
	hMem: THandle;
begin
	try  
		{ Create the control info for the DLL }
		if (PCtlInfo = Nil) then
			begin
			PCtlInfo := GlobalSharedLockedAlloc( Sizeof(TCtlInfo), hMem );
			PctlInfo^.hMem := hMem;
			end;

		PctlInfo^.pBuffer := Nil;	{ Not used for output }
		Pctlinfo^.hWindow := Handle;	{ Control's window handle }
		FError := midioutOpen(@FMidiHandle, FDeviceId,
						Longint(@midiHandler),
						Longint(PCtlInfo),
						CALLBACK_FUNCTION);
		If (FError <> 0) then
			{ TODO: use CreateFmtHelp to add MIDI device name/ID to message }
			raise EmidioutputError.Create(midioutErrorString(FError));

		FState := mosOpen;

	except
		if PCtlInfo <> Nil then
			begin
			GlobalSharedLockedFree(PCtlInfo^.hMem, PCtlInfo);
			PCtlInfo := Nil;
			end;
	end;

end;

{-------------------------------------------------------------------}
procedure TMidiOutput.PutShort(MidiMessage: Byte; Data1: Byte; Data2: Byte);
var
	thisMsg: Longint;
begin
	thisMsg := Longint(MidiMessage) Or
		(Longint(Data1) shl 8) Or
		(Longint(Data2) shl 16);

	FError := midiOutShortMsg(FMidiHandle, thisMsg);
	if Ferror > 0 then
		raise EmidioutputError.Create(midioutErrorString(FError));
end;

{-------------------------------------------------------------------}
procedure TMidiOutput.PutLong(SysexPointer: Pointer; msgLength: Word);
{ Notes: This works asynchronously; you send your sysex output by
calling this function, which returns immediately. When the MIDI device
driver has finished sending the data the MidiOutPut function in this
component is called, which will in turn call the OnMidiOutput method
if the component user has defined one. }

var
	MyMidiHdr: TMyMidiHdr;
begin
	{ Initialize the header and allocate buffer memory }
	MyMidiHdr := TMyMidiHdr.Create(msgLength);

	{ Copy the data over to the MidiHdr buffer
	  We can't just use the caller's PChar because the buffer memory
	  has to be global, shareable, and locked. }
	StrMove(MyMidiHdr.SysexPointer, SysexPointer, msgLength);

	{ Store the MyMidiHdr address in the header so we can find it again quickly }
	MyMidiHdr.hdrPointer^.dwUser := Longint(MyMidiHdr);

	{ Get MMSYSTEM's blessing for this header }
	FError := midiOutPrepareHeader(FMidiHandle,MyMidiHdr.hdrPointer,
		sizeof(TMIDIHDR));
	if Ferror > 0 then
		raise EMidiOutputError.Create(MidiOutErrorString(FError));

	{ Send it }
	FError := midiOutLongMsg(FMidiHandle, MyMidiHdr.hdrPointer,
		sizeof(TMIDIHDR));
	if Ferror > 0 then
		raise EMidiOutputError.Create(MidiOutErrorString(FError));

end;

{-------------------------------------------------------------------}
procedure Tmidioutput.PutMidiEvent(theEvent:TMidiEvent);
var
	thisMsg: Longint;
begin
	if FState <> mosOpen then
		raise EMidiOutputError.Create('MIDI Output device not open');

	with theEvent do
		begin
		if Sysex = Nil then
			begin
			PutShort(MidiMessage, Data1, Data2)
			end
		else
			PutLong(Sysex, SysexLength);
	end;
end;

{-------------------------------------------------------------------}
function Tmidioutput.Close: Boolean;
begin
	if FState = mosOpen then
		begin
		FError := midioutReset(FMidiHandle);
		if Ferror <> 0 then
			raise EMidiOutputError.Create(MidiOutErrorString(FError));
	
		FError := midioutClose(FMidiHandle);
		if Ferror <> 0 then
			raise EMidiOutputError.Create(MidiOutErrorString(FError));
		end;

	FMidiHandle := 0;
	FState := mosClosed;

end;

{-------------------------------------------------------------------}
procedure TMidiOutput.SetVolume( Left: Word; Right:Word );
var
	dwVolume: Longint;
begin
	dwVolume := (Longint(Left) shl 16) Or Right;
	FError := midiOutSetVolume(DeviceID, dwVolume);
	if Ferror <> 0 then
		raise EMidiOutputError.Create(MidiOutErrorString(FError));
end;

{-------------------------------------------------------------------}
procedure Tmidioutput.midioutput( var Message: TMessage );
{ Triggered when sysex output from PutLong is complete }
var
	MyMidiHdr: TMyMidiHdr;
	thisHdr: PMidiHdr;
begin
	if Message.Msg = Mom_Done then
		begin
		{ Find the MIDIHDR we used for the output. Message.lParam is its address }
		thisHdr := PMidiHdr(Message.lParam);

		{ Remove it from the output device }
		midiOutUnprepareHeader(FMidiHandle, thisHdr, sizeof(TMIDIHDR));

		{ Get the address of the MyMidiHdr containing this MIDIHDR.
			We stored this address in the PutLong procedure }
		MyMidiHdr := TMyMidiHdr(thisHdr^.dwUser);

		{ Header and copy of sysex data no longer required since output is complete }
		MyMidiHdr.Free;

		{ Call the user's event handler if any }
		if Assigned(FOnmidioutput) then
			FOnmidioutput(Self);
		end;
end;

{-------------------------------------------------------------------}
procedure Register;
begin
  RegisterComponents('Samples', [Tmidioutput]);
end;

end.
