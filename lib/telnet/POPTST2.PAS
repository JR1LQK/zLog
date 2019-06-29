unit PopTst2;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TMessageForm = class(TForm)
    DisplayMemo: TMemo;
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  MessageForm: TMessageForm;

implementation

{$R *.DFM}

end.
