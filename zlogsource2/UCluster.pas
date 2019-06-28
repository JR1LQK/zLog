unit UCluster;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TClusterForm = class(TForm)
    ListBox: TListBox;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Add(Spot : string);
    { Public declarations }
  end;

var
  ClusterForm: TClusterForm;

implementation

{$R *.DFM}

procedure TClusterForm.Add(Spot : string);
begin
  ListBox.Items.Add(Spot);
end;

procedure TClusterForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TClusterForm.Button2Click(Sender: TObject);
begin
  if Self.FormStyle = fsStayOnTop then
    begin
      Self.FormStyle := fsNormal;
      Button2.Caption := 'Stay on Top';
    end
  else
    begin
      Self.FormStyle := fsStayOnTop;
      Button2.Caption := 'Normal';
    end;
end;

end.
