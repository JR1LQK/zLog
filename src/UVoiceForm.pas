unit UVoiceForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MPlayer, ExtCtrls, BGK32LIB, UOptions;

type
  TVoiceForm = class(TForm)
    MP: TMediaPlayer;
    Timer: TTimer;
    procedure TimerTimer(Sender: TObject);
  private
    { Private éŒ¾ }
  public
    LoopInterval : integer; // in milliseconds;
    LoopCount : integer;
    procedure SetLoopInterval(Intvl : integer);
    function Playing : boolean;
    { Public éŒ¾ }
  end;

var
  VoiceForm: TVoiceForm;

implementation

{$R *.dfm}

procedure TVoiceForm.SetLoopInterval(Intvl : integer);
begin
  LoopInterval := Intvl;
  LoopCount := Intvl div 100;
end;

function TVoiceForm.Playing : boolean;
begin
  Result := MP.Mode = mpPlaying;
end;

procedure TVoiceForm.TimerTimer(Sender: TObject);
begin
  if MP.Mode = mpPlaying then
    exit;
  BGK32LIB.SetVoiceFlag(0);
  if Options.PTTEnabled then
    ControlPTT(False);
  if LoopInterval > 0 then
    begin
      if LoopCount > 0 then
        dec(LoopCount)
      else // end of wait time
        begin
          LoopCount := LoopInterval div 100;
          BGK32LIB.SetVoiceFlag(1);
          if Options.PTTEnabled then
            ControlPTT(True);
          MP.Rewind;
          MP.Play;
        end;
      exit;
    end;
  Timer.Enabled := False;
end;

end.
