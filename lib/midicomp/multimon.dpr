program Multimon;

uses
  Forms,
  Multimnp in 'MULTIMNP.PAS' {Form1},
  MIDIIn in 'MIDIIN.PAS',
  Circbuf in 'CIRCBUF.PAS',
  midiout in 'MIDIOUT.PAS';

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
