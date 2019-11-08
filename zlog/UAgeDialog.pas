unit UAgeDialog;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAgeDialog = class(TForm)
    OKBtn: TButton;
    Bevel2: TBevel;
    Edit1: TEdit;
    Label1: TLabel;
  private
    { Private declarations }
    function GetAge(): string;
  public
    { Public declarations }
    property Age: string read GetAge;
  end;

implementation

{$R *.DFM}

function TAgeDialog.GetAge(): string;
begin
   Result := Edit1.Text;
end;

end.
