unit ccczlogconv;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  zLogGlobal, StdCtrls;

type
 monthtype= ShortInt;
 daytype  = ShortInt;
 calltype = array[1..10] of char;
 rsType   = (f1,f2,f3,f4,f5,f6,f7,f8,f9);
 numtype  = array[1..4] of char;
 timetype = SmallInt;
 modetype = (mmSSB,mmCW,mmFM);
 bandtype = (aa,bb,cc,dd,ee,ff,gg,hh,ii,jj,kk,LL);
 countrytype = string[6];
 ptstype  = Byte;
 WWQSOdata  = packed record
             month    : monthtype;
             day      : daytype;
             time     : timetype;
             callsign : calltype;
             rs       : rsType;
             number   : numtype;
             band     : bandtype;
             mode     : modetype;
             country  : countrytype;
             pts      : ptstype;
             newmulti : ByteBool;
             memo     : SmallInt;
             cq : boolean;
            end;


var WWLog : array[1..7000] of WWQSOdata;
    MaxQSO : integer;
type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var filename : string;
    f : file of WWQSOdata;
    q : WWQSOdata;
begin
  If OpenDialog1.Execute then
    begin
      filename := OpenDialog1.FileName;
      System.assign(f, filename);
      reset(f);
      while not(eof(f)) do
        begin
          read(f, q);
          inc(MaxQSO);
          WWLog[MaxQSO] := q;
        end;
      system.close(f);
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  MaxQSO := 0;
end;

procedure TForm1.Button2Click(Sender: TObject);
var f : file of TQSOdata;
    Q0 : TQSO;
    Q : TQSOdata;
    W : WWQSOdata;
    i, k : integer;
    s : string;
    r : double;
begin
  System.assign(f, 'OUTPUT.ZLO');
  rewrite(f);
  Q0 := TQSO.Create;
  for k := 1 to MaxQSO - 1 do
    begin
      Q := Q0.QSO;
      W := WWLog[k];
      i := W.time;
      R := EncodeDate(1998,W.month,w.day) + EncodeTime(W.Time div 100,W.Time mod 100, 0, 0);
      Q.Time := R;
      s := '';
      for i := 1 to 10 do
        s := s + W.callsign[i];
      s := TrimRight(s);
      Q.Callsign := s;
      Q.RSTRcvd := 51 + ord(W.rs);
      s := '';
      for i := 1 to 4 do
        s := s + W.number[i];
      s := TrimRight(s);
      Q.NrRcvd := s;
      case W.band of
        aa : Q.Band := b19;
        bb : Q.band := b35;
        cc : Q.band := b7;
        dd : Q.band := b14;
        ee : Q.band := b21;
        ff : Q.band := b28;
      end;
      case W.Mode of
        mmSSB : Q.mode := mSSB;
        mmCW : Q.mode := mCW;
        mmFM : Q.mode := mFM;
      end;
      Q.NrSent := '7';
      Q.NewMulti1 := false;
      Q.NewMulti2 := false;
      {
      if W.country <> '' then
        begin
          Q.NewMulti2 := True;
          Q.Multi2 := W.Country;
        end;
      Q.Points := W.pts;
      if W.newmulti then
        Q.NewMulti1 := True
      else
        Q.NewMulti1 := False;}
      write(f, Q);
    end;
  system.close(f);
end;

end.
