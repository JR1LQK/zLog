program Midimon;

uses
  Forms,
  Midimonp in 'MIDIMONP.PAS' {Form1},
  MIDIIn in 'MIDIIN.PAS',
  Circbuf in 'CIRCBUF.PAS',
  midiout in 'MIDIOUT.PAS',
  Monprocs in 'MONPROCS.PAS';

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
