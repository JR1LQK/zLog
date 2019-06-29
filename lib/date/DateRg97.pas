unit DateRg97;

(******************************************************************************
TDateEdit97
TDbDateEdit97
TDateFromTo97

Author name=BOURMAD Mehdi
Author E-mail=bourmad@mygale.org
Author URL=www.mygale.org/~bourmad
******************************************************************************)

interface

uses
   Classes, DsgnIntf;

Procedure Register;

implementation

uses
  DateEd97,
  DateFT97,
  DateDB97;

procedure Register;

begin
  RegisterComponents('Freeware', [TDateEdit97]);
  RegisterComponents('Freeware', [TDateFromTo97]);
  RegisterComponents('Freeware', [TDbDateEdit97]);
  RegisterPropertyEditor (TypeInfo(TAboutMeProperty), TDateEdit97,
                          'ABOUT', TAboutMeProperty);
  RegisterPropertyEditor (TypeInfo(TAboutMeProperty), TDateFromTo97,
                          'ABOUT', TAboutMeProperty);
end;

end.

