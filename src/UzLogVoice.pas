unit UzLogVoice;

interface

var CtrlZCQLoopVoice : boolean;

procedure SendVoice(i : integer);
procedure StopVoice;
procedure CQLoopVoice;
procedure CtrlZBreakVoice;

implementation

uses UOptions, SysUtils, Main, BGK32LIB, UVoiceForm, MPlayer;


procedure SendVoice(i : integer);
var filename : string;
begin
  if i > 8 then
    exit;
  filename := Options.Settings._soundfiles[i];
  if FileExists(filename) = False then
    exit;
  if VoiceForm.Playing then
    VoiceForm.MP.Stop;
  VoiceForm.MP.FileName := filename;
  VoiceForm.MP.Open;
  BGK32LIB.SetVoiceFlag(1);
  if Options.PTTEnabled then
    ControlPTT(True);
  VoiceForm.LoopInterval := 0;
  VoiceForm.MP.Play;
  VoiceForm.Timer.Enabled := True;
end;

procedure StopVoice;
begin
  try
    VoiceForm.MP.Stop;
  except
    on EMCIDeviceError do
      begin
        VoiceForm.Timer.Enabled := false;
        BGK32LIB.SetVoiceFlag(0);
        if Options.PTTEnabled then
          ControlPTT(False);
        exit;
      end;
  end;
  VoiceForm.MP.Rewind;
  VoiceForm.Timer.Enabled := false;
  BGK32LIB.SetVoiceFlag(0);
  if Options.PTTEnabled then
    ControlPTT(False);
end;

procedure CQLoopVoice;
var filename : string;
    Interval : integer;
begin
  StopVoice;
  filename := Options.Settings._soundfiles[1];
  Interval := Trunc(1000*Options.Settings.CW._cqrepeat);
  VoiceForm.SetLoopInterval(Interval);

  //filename := Options.Settings._soundfiles[1];
  if FileExists(filename) = False then
    exit;
  if VoiceForm.Playing then
    begin
      VoiceForm.MP.Stop;
    end;
  VoiceForm.MP.FileName := filename;
  VoiceForm.MP.Open;
  BGK32LIB.SetVoiceFlag(1);
  if Options.PTTEnabled then
    ControlPTT(True);
  VoiceForm.MP.Play;
  VoiceForm.Timer.Enabled := True;
end;

procedure CtrlZBreakVoice;
begin
  CtrlZCQLoopVoice := False;
  StopVoice;
end;

initialization
  CtrlZCQLoopVoice := True;
end.
