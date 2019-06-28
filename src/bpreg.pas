unit BPReg;

interface

procedure Register;

implementation

uses
  Classes, Rbutton, Bpanel;

procedure Register;
begin
  RegisterComponents('Samples',[TRoundButton,TBevelPanel]);
  { to automatically place these components into a page, change
    'Brendan' to the prefered location }
end;

end.
