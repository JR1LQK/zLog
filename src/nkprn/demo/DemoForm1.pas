unit DemoForm1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, checklst, ComCtrls, Menus, NkPrinters;

type
  TMainfForm = class(TForm)
    ComboBox1: TComboBox;
    Memo1: TMemo;
    ComboBox2: TComboBox;
    RadioGroup1: TRadioGroup;
    btnSetUp: TButton;
    ComboBox3: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnUserDefined: TButton;
    btnPrint: TButton;
    CheckListBox1: TCheckListBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblMaxCopies: TLabel;
    udCopies: TUpDown;
    edtCopies: TEdit;
    chkCollate: TCheckBox;
    chkColor: TCheckBox;
    grpDuplex: TRadioGroup;
    Label7: TLabel;
    edtScale: TEdit;
    udScale: TUpDown;
    Label8: TLabel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Update1: TMenuItem;
    cbPorts: TComboBox;
    NkPrintDialog1: TNkPrintDialog;
    Label9: TLabel;
    btnPrintQuality: TButton;
    btnApply: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure btnSetUpClick(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure btnUserDefinedClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure udCopiesClick(Sender: TObject; Button: TUDBtnType);
    procedure chkCollateClick(Sender: TObject);
    procedure chkColorClick(Sender: TObject);
    procedure grpDuplexClick(Sender: TObject);
    procedure udScaleClick(Sender: TObject; Button: TUDBtnType);
    procedure Exit1Click(Sender: TObject);
    procedure Update1Click(Sender: TObject);
    procedure cbPortsChange(Sender: TObject);
    procedure btnPrintQualityClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
    Updating: Boolean;
    AllowCopiesChange: Boolean;
    procedure UpdatePrinterInfo;
    procedure Hook(Sender: TObject);
  end;

var
  MainfForm: TMainfForm;

implementation

{$R *.DFM}
uses Printers, DemoForm2, DemoForm3;

procedure TMainfForm.UpdatePrinterInfo;
var Size: TSize;
    Caps: TNkPrintcaps;
    i: Integer;
    s: string;
begin
  if Updating then Exit;
  Updating := True;
  try
    ComboBox1.Enabled := True;
    try
      ComboBox1.Items := NkPrinter.PrinterNames;
      ComboBox1.ItemIndex := NkPrinter.Index;
    except
      on ENkPrinter do begin
        ComboBox1.Enabled := False;
        ComboBox2.Enabled := False;
        ComboBox3.Enabled := False;
        cbPorts.Enabled := False;
        RadioGroup1.Enabled := False;
        lblMaxCopies.Enabled := False;
        Exit;
      end;
    end;

    ComboBox2.Enabled := False;
    if nkPcPaperSize in NkPrinter.PrintCaps then begin
      ComboBox2.Enabled := True;
      try
        ComboBox2.Items := NkPrinter.PaperSizeNames;
        ComboBox2.ItemIndex := NkPrinter.PaperSizeIndex;
      except
        On ENkPrinter do ComboBox2.ItemIndex := -1;
      end;
    end;


    ComboBox3.Enabled := False;
    if nkPcDefaultSource in NkPrinter.Printcaps then begin
      ComboBox3.Enabled := True;
      try
        ComboBox3.Items := NkPrinter.BinNames;
        ComboBox3.ItemIndex := NkPrinter.BinIndex;
      except
        on ENkPrinter do ComboBox3.ItemIndex := -1;
      end;
    end;

    cbPorts.Enabled := True;
    try
      cbPorts.Items := NkPrinter.PortNames;
      cbPorts.Text := NkPrinter.Port;
    except
      on ENkPrinter do ComboBox3.Enabled := False;
    end;


    RadioGroup1.Enabled := False;
    if nkPcOrientation in NkPrinter.PrintCaps then begin
      RadioGroup1.Enabled := True;
      try
        if NkPrinter.Orientation = nkOrPortrait then
          RadioGroup1.ItemIndex := 0
        else
          RadioGroup1.ItemIndex := 1;
      except
        On ENkPrinter do RadioGroup1.Enabled := False;
      end;
    end;

    btnUserDefined.Enabled := False;
    if (nkPcPaperSize in  NkPrinter.PrintCaps) and
       (NkPrinter.PaperSizeNumber = DMPAPER_USER) and
       (not NkPrinter.Modified) then
      btnUserDefined.Enabled := True;

    btnPrintQuality.Enabled := False;
    if nkPcPrintQuality in NkPrinter.Printcaps then
      btnPrintQuality.Enabled := True;


    Memo1.Lines.Clear;

    if not NkPrinter.Modified then begin
      Memo1.Lines.BeginUpdate;
      try
        try
          if nkPcPaperSize in NkPrinter.PrintCaps then
            Memo1.Lines.Add(NkPrinter.PaperSizeNames[NkPrinter.PaperSizeIndex]);
        except on ENkPrinter do;
        end;

        try
          Size := NkPrinter.PageExtent;
          Memo1.Lines.Add('PageExtent  = (' + IntToStr(Size.cx) + ',' +
                                              IntToStr(Size.cy) + ')');
        except on ENkPrinter do ShowMessage('PageExtent Error');
        end;

        try
          Size := NkPrinter.MMPageExtent;
          Memo1.Lines.Add('MMPageExtent= (' + IntToStr(Size.cx) + ',' +
                                              IntToStr(Size.cy) + ')');
        except on ENkPrinter do ShowMessage('PageExtent Error');
        end;


        try
          Size := NkPrinter.PaperExtent;
          Memo1.Lines.Add('PaperExtent = (' + IntToStr(Size.cx) + ',' +
                                              IntToStr(Size.cy) + ')');
        except on ENkPrinter do;
        end;
        try
          Size := NkPrinter.MMPaperExtent;
          Memo1.Lines.Add('MMPaperExtent= (' + IntToStr(Size.cx) + ',' +
                                              IntToStr(Size.cy) + ')');
        except on ENkPrinter do;
        end;
        try
          Size := NkPrinter.DPI;
          Memo1.Lines.Add('DPI         = (' + IntToStr(Size.cx) + ',' +
                                              IntToStr(Size.cy) + ')');
        except on ENkPrinter do;
        end;
        try
          Size := NkPrinter.Offset;
          Memo1.Lines.Add('Offset      = (' + IntToStr(Size.cx) + ',' +
                                              IntToStr(Size.cy) + ')');
        except on ENkPrinter do;
        end;
        try
          Memo1.Lines.Add('ColorBitCount =' +  IntToStr(NkPrinter.ColorBitCount));
        except on ENkPrinter do;
        end;
        try
          Size := NkPrinter.Quality;
          Memo1.Lines.Add('PrintQuality =(' +  IntToStr(Size.cx) + ',' +
                                               IntToStr(Size.cy) + ')');
        except on ENkPrinter do;
        end;

        try
          s := 'Info= ';
          if nkAvPaperSize in NkPrinter.AvailInfos then s := s + '紙 ';
          if nkAvBin       in NkPrinter.AvailInfos then s := s + 'ビン ';
          if nkAvQuality   in NkPrinter.AvailInfos then s := s + '品質 ';
          if nkAvMaxCopies in NkPrinter.AvailInfos then s := s + '最大枚数 ';

          Memo1.Lines.Add(s);
        except on ENkPrinter do;
        end;
      finally
        Memo1.Lines.EndUpdate;
      end;
    end;

    for i := 0 to 16 do CheckListBox1.Checked[i] := False;
    Caps := NkPrinter.PrintCaps;
    if nkPcOrientation in Caps then
      CheckListBox1.Checked[0] := True;
    if nkPcpaperSize in Caps then
      CheckListBox1.Checked[1] := True;
    if nkPcPaperlength in Caps then
      CheckListBox1.Checked[2] := True;
    if nkPcpaperWidth in Caps then
      CheckListBox1.Checked[3] := True;
    if nkPcScale in Caps then
      CheckListBox1.Checked[4] := True;
    if nkPcCopies in Caps then
      CheckListBox1.Checked[5] := True;
    if nkPcDefaultSource in Caps then
      CheckListBox1.Checked[6] := True;
    if nkPcPrintQuality in Caps then
      CheckListBox1.Checked[7] := True;
    if nkPcColor in Caps then
      CheckListBox1.Checked[8] := True;
    if nkPcDuplex in Caps then
      CheckListBox1.Checked[9] := True;
    if nkPcYResolution in Caps then
      CheckListBox1.Checked[10] := True;
    if nkPcTTOption in Caps then
      CheckListBox1.Checked[11] := True;
    if nkPcCollate in Caps then
      CheckListBox1.Checked[12] := True;
    if nkPcFormName in Caps then
      CheckListBox1.Checked[13] := True;
    if nkPcLogPixels in Caps then
      CheckListBox1.Checked[14] := True;
    if nkPcMediaType in Caps then
      CheckListBox1.Checked[15] := True;
    if nkPcDitherType in Caps then
      CheckListBox1.Checked[16] := True;

    try
      lblMaxCopies.Enabled := True;
      lblMaxCopies.Caption := IntToStr(NkPrinter.MaxCopies);
    except
      on ENkPrinter do lblMaxCopies.Enabled := False;
    end;

    try
      edtCopies.Enabled := True;
      udCopies.Enabled := True;
      udCopies.Position := NkPrinter.Copies;
      udCopies.Max := NkPrinter.MaxCopies;
    except
      on ENkPrinter do begin
        edtCopies.Enabled := False;
        udCopies.Enabled := False;
      end;
    end;

    try
      chkCollate.Enabled := True;
      chkCollate.Checked := NkPrinter.Collate;
    except
      on ENkPrinter do chkCollate.Enabled := False;
    end;

    try
      chkColor.Enabled := True;
      chkColor.Checked := NkPrinter.Color;
    except
      on ENkPrinter do chkColor.Enabled := False;
    end;

    try
      grpDuplex.Enabled := True;
      grpDuplex.ItemIndex := Ord(NkPrinter.Duplex);
    except
      on ENkPrinter do grpDuplex.Enabled := False;
    end;

    try
      if nkPcScale in NkPrinter.Printcaps then begin
        edtScale.Enabled := True;
        udScale.Enabled := True;
        udScale.Position := NkPrinter.Scale;
      end
      else begin
        edtScale.Enabled := False;
        udScale.Enabled := False;
      end;
    except
      on ENkPrinter do begin
        edtScale.Enabled := False;
        udScale.Enabled := False;
      end;
    end;

    if NkPrinter.Modified then btnApply.Enabled := True
                          else btnApply.Enabled := False;

  finally
    Updating := False;
  end;
end;


procedure TMainfForm.FormCreate(Sender: TObject);
begin
  NkPrinter.OnSystemChanged := Hook;
  UpdatePrinterInfo;
end;

procedure TMainfForm.Hook(Sender: TObject);
begin
  ShowMessage('ひょっとするとプリンタが削除／追加されたかも！！');
  UpdatePrinterInfo;
end;


procedure TMainfForm.ComboBox1Change(Sender: TObject);
begin
  if Updating then Exit;
  NkPrinter.Index := ComboBox1.ItemIndex;
  UpdatePrinterInfo;
end;

procedure TMainfForm.ComboBox2Change(Sender: TObject);
begin
  if Updating then Exit;
  NkPrinter.PaperSizeIndex := ComboBox2.ItemIndex;
  UpdatePrinterInfo;
end;

procedure TMainfForm.RadioGroup1Click(Sender: TObject);
begin
  if Updating then Exit;
  if RadioGroup1.ItemIndex = 0 then
    NkPrinter.Orientation := nkOrPortrait
  else
    NkPrinter.orientation := nkOrLandScape;
  UpdatePrinterInfo;
end;

procedure TMainfForm.btnSetUpClick(Sender: TObject);
begin
  NkPrintDialog1.Execute;
  UpdatePrinterInfo;
end;

procedure TMainfForm.ComboBox3Change(Sender: TObject);
begin
  if Updating then Exit;
  NkPrinter.BinIndex := ComboBox3.ItemIndex;
  UpdatePrinterInfo;
end;

procedure TMainfForm.btnUserDefinedClick(Sender: TObject);
var Size: TSize;
begin
  PaperSizeForm.grpUnitClick(Self);
  if PaperSizeForm.ShowModal = mrOK then begin
    Size.cx := StrToInt(PaperSizeForm.EditWidth.Text);
    Size.cy := StrToInt(PaperSizeForm.EditLength.Text);
    NkPrinter.UserPaperExtent := Size;
    UpdatePrinterInfo;
  end;
end;

procedure TMainfForm.btnPrintClick(Sender: TObject);
var
  Info: PBitmapInfo;
  InfoSize: DWORD;
  Image: Pointer;
  ImageSize: DWORD;
  bm: TBitmap;
  Size: TSize;
begin
  Size := NkPrinter.PageExtent;
  NkPrinter.BeginDoc('Demo');
  try
    bm := TBitmap.Create;
    try
      bm.LoadFromFile(ExtractFilePath(Application.ExeName) + 'shun06.bmp');
      GetDIBSizes(bm.Handle, InfoSize, ImageSize);
      Info := AllocMem(InfoSize);
      try
        Image := AllocMem(ImageSize);
        try
          GetDIB(bm.Handle, bm.Palette, Info^, Image^);
          with Info^.bmiHeader do
            if (biHeight / biWidth) < (Size.cy / Size.cx) then
              StretchDIBits(NkPrinter.Canvas.Handle,
                            0, 0, Size.cx, Size.cx * biHeight div biWidth,
                            0, 0, biWidth, biHeight,
                            Image, Info^, DIB_RGB_COLORS, SRCCOPY)
            else
              StretchDIBits(NkPrinter.Canvas.Handle,
                            0, 0, Size.cy * biWidth div biHeight, Size.cy,
                            0, 0, biWidth, biHeight,
                            Image, Info^, DIB_RGB_COLORS, SRCCOPY);
        finally
          FreeMem(Image);
        end;
      finally
        FreeMem(Info);
      end;
    finally
      bm.Free;
    end;
    NkPrinter.Canvas.Font.Size := 40;
    NkPrinter.Canvas.Font.Color := clBlack;
    NkPrinter.Canvas.Brush.Color := clWhite;
    NkPrinter.Canvas.TextOut(10, 10, '息子の俊一です');
  except
    NkPrinter.Abort;
    raise;
  end;
  NkPrinter.EndDoc;
end;

procedure TMainfForm.udCopiesClick(Sender: TObject; Button: TUDBtnType);
begin
  if Updating then Exit;
  NkPrinter.Copies := udCopies.Position;
  PostMessage(Self.Handle, WM_COMMAND, Update1.Command, 0);
end;

procedure TMainfForm.chkCollateClick(Sender: TObject);
begin
  if Updating then Exit;
  NkPrinter.Collate := chkCollate.Checked;
  UpdatePrinterInfo;
end;

procedure TMainfForm.chkColorClick(Sender: TObject);
begin
  if Updating then Exit;
  NkPrinter.Color := chkColor.Checked;
  UpdatePrinterInfo;
end;

procedure TMainfForm.grpDuplexClick(Sender: TObject);
begin
  if Updating then Exit;
  case grpDuplex.ItemIndex of
  0: NkPrinter.Duplex := nkDupSimplex;
  1: NkPrinter.Duplex := nkDupHorizontal;
  2: NkPrinter.Duplex := nkDupVertical;
  end;
  UpdatePrinterInfo;
end;

procedure TMainfForm.udScaleClick(Sender: TObject; Button: TUDBtnType);
begin
  if Updating then Exit;
  NkPrinter.Scale := udScale.Position;
  PostMessage(Self.Handle, WM_COMMAND, Update1.Command, 0);
end;

procedure TMainfForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainfForm.Update1Click(Sender: TObject);
begin
  UpdatePrinterInfo;
end;

procedure TMainfForm.cbPortsChange(Sender: TObject);
begin
  if Updating then Exit;
  NkPrinter.Port := cbPorts.Text;
  PostMessage(Self.Handle, WM_COMMAND, Update1.Command, 0);
end;

procedure TMainfForm.btnPrintQualityClick(Sender: TObject);
var Size: TSize;
    i: Integer;
    Quality: TSize;
begin
  Size := NkPrinter.Quality;
  with PrintQualityForm do begin
    rgQuality.ItemIndex := -1;
    lbQualities.Clear;

    if nkAvQuality in NkPrinter.AvailInfos then
      for i := 0 to NkPrinter.NumQualities-1 do begin
        Quality := NkPrinter.Qualities[i];
        lbQualities.Items.Add(
          '(' + IntToStr(Quality.cx) + ',' + IntToStr(Quality.cy) + ')');
      end;
    lblXRes.Caption := IntToStr(Size.cx);
    lblYRes.Caption := IntToStr(Size.cy);

    if PrintQualityForm.ShowModal = mrOK then
      try
        Size.cx := StrToInt(lblXRes.Caption);
        Size.cy := StrToInt(lblYRes.Caption);
        NkPrinter.Quality := Size;
      finally
        UpdatePrinterInfo;
      end;
  end;
end;

procedure TMainfForm.btnApplyClick(Sender: TObject);
begin
  NkPrinter.ApplySettings;
  UpdatePrinterInfo;
end;

end.
