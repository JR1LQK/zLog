{ $Header:   G:/delphi/midi/vcs/multimon.dpr   1.1   30 Apr 1996 19:05:38   DAVEC  $ }

{ Written by David Churcher <dchurcher@cix.compulink.co.uk>,
  released to the public domain. }

program Multimon;

uses
  Forms,
  Multimnp in 'MULTIMNP.PAS' {Form1},
  MIDIIn in 'MIDIIN.PAS',
  Circbuf in 'CIRCBUF.PAS',
  midiout in 'MIDIOUT.PAS',
  Midicons in 'midicons.pas',
  Miditype in 'Miditype.pas',
  Monprocs in 'Monprocs.pas',
  Mididefs in 'mididefs.pas',
  Delphmcb in 'Delphmcb.pas';

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
