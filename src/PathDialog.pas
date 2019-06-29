unit PathDialog;

{ The TPathDialog Component V1.0

  MOST IMPORTANT :)
  =================
  This is NOT Freeware: It's PostCardWare. When you use
  this component or think it's useful, send me a post-card
  to: Florian Bömers, Werderstr.31, D - 68165 Mannheim, Germany

  And of course, I am very interested in any application
  that uses this component (or any other application you wrote).
  If so, mail me (not the program, just an URL or similar) !
  (mail address below)

  Installation:
  =============
  1. Copy the File PathDialog.pas to the directory where
     you store your components (or let it where it is)
  2. In Delphi, select Component|Install Component. In the
     following dialog enter the path and filename of
     PathDialog.pas and hit OK.
  3. Now the TPathDialog Component is available in the
     Component palette under Samples.


  How to use it
  =============
  It's as easy as the other CommonDialogs: Drop the icon
  on your form. Then a call to Execute shows the Path Dialog.
  If Execute returned true, the directory property contains
  the selected path. When you assigned a directory prior to
  calling Execute, it is selected when showing.

  Advanced functionality
  ======================
  - property Title: This text is shown at the top of the
    PathDialog. It is normally a line like: 'Select the installation
    folder'

  - property ShowStatus and StatusText: if ShowStatus is true, an
    extra line is inserted above the tree. There the StatusText is
    displayed. You might set StatusText in the Event-Handler of
    OnSelect.

  - Event OnShow: Is called when the Dialog is appearing

  - Event OnSelect: Is called each time, when the user changes
    the selected item in the tree. The Path parameter is
    the currently selected directory. It is '' when the user
    selected a non-directory item like Control Panel, etc.

  - function setOKButton: When the Dialog is visible, you
    can enable or disable the OK Button with this function.
    This may be handy when you want to limit the possible
    directories the user can select. You should call this only
    in one of the event handler procedures.

  - property visible: is true when the Dialog is showing.

  - property Handle: Window Handle of the Dialog. Should not be
    necessary to use it.

  Copyright
  =========
  (c) 1997 by Florian Bömers

  send any comments, proposals, enhancements etc. to:
  fbomers@erato.unice.fr
  (if this address does not work: boemers@rumms.uni-mannheim.de)

}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ShlObj,ActiveX;

type
  TSelectEvent=procedure(Sender:TObject; Path:String) of object;

  TPathDialog = class(TComponent)
  private
    FHandle:THandle;
    FTitle:String;
    FDirectory:String;
    FShowStatus:Boolean;
    FStatusText:String;

    FOnShow:TNotifyEvent;
    FOnSelect:TSelectEvent;

    function getVisible:Boolean;
    procedure SetDirectory(Dir:String);
    procedure SetStatusText(Text:String);
  public
    { Shows the dialog. Returns false if the user clicked Cancel }
    { or if an error occurred }
    function Execute:Boolean;
    { Sets the status of the OK-Button to either enabled or disabled    }
    { This function should only be called in one of the 2 Eventhandlers }
    function setOKButton(enabled:Boolean):Boolean;
    { whether the dialog is visible }
    property visible:Boolean read getVisible;
    { Window Handle of the dialog is only valid when visible }
    { ...should not be used...}
    property Handle:THandle read FHandle;
  published
    { should be set before calling Execute }
    property Title:String read FTitle write FTitle;
    { is not valid while the Dialog is visible }
    property Directory:String read FDirectory write setDirectory;
    { must be set before executing the dialog }
    property ShowStatus:Boolean read FShowStatus write FShowStatus default false;
    { is only used if ShowStatus is true }
    property StatusText:String read FStatusText write SetStatusText;

    property Tag;
    // Events
    property OnShow:TNotifyEvent read FOnShow write FOnShow;
    property OnSelect:TSelectEvent read FOnSelect write FOnSelect;
  end;

procedure Register;

implementation

function CallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
var dir:String;
begin
 try
  with TPathDialog(lpData) do
  case uMsg of
   BFFM_INITIALIZED:
    begin
     FHandle:=Wnd;
     SetDirectory(FDirectory);
     SetStatusText(FStatusText);
     try
      if assigned(FOnShow) then
       FOnShow(TPathDialog(lpData));
     except
      On e:Exception do
       ShowMessage(e.Message);
     end;
    end;
   BFFM_SELCHANGED: // lpParam is a pointer to the item identifier list for the newly selected folder.
    begin
     if assigned(FOnSelect) then
     try
      SetString(dir,nil,MAX_PATH);
      if SHGetPathFromIDList(PItemIDList(lParam),PChar(Dir)) then
       FOnSelect(TPathDialog(lpData),PChar(Dir))
      else
       FOnSelect(TPathDialog(lpData),'');
     except
      On e:Exception do
       ShowMessage(e.Message);
     end;
    end;
  end;
 except
 end;
 result:=0;
end;

function TPathDialog.Execute:Boolean;
var iList,Root:PItemIDList;
    bi:TBrowseInfo;
    DispName:String;
    malloc:IMalloc;
begin
 result:=false;
 if (Owner is TWinControl) then
  bi.hwndOwner:=TWinControl(Owner).Handle
 else exit;
 if SHGetSpecialFolderLocation(Handle, CSIDL_DRIVES,Root)=NOERROR then
 try
  SHGetMalloc(malloc);
  SetString(DispName,nil,MAX_PATH);
  with bi do
  begin
   pidlRoot := root;
   pszDisplayName := PChar(DispName);
   lpszTitle := PChar(FTitle);
   ulFlags:=BIF_RETURNONLYFSDIRS;
   if FShowStatus then
    ulFlags:=ulFlags or BIF_STATUSTEXT;
   lpfn:=@CallBack;
   lParam:=Integer(self);

  end;
  iList:=SHBrowseForFolder(bi);
  FHandle:=0;
  if iList<>nil then
  try
   if SHGetPathFromIDList(iList,PChar(DispName)) then
   begin
    FDirectory:=PChar(DispName);
    result:=true;
   end;
  finally
   malloc.Free(iList);
  end;
 finally
  malloc.Free(root);
 end;
end;

function TPathDialog.setOKButton(enabled:Boolean):Boolean;
begin
 result:=false;
 if (FHandle<>0) then
 begin
  result:=true;
  if enabled then
   SendMessage(FHandle,BFFM_ENABLEOK,1,0)
  else
   SendMessage(FHandle,BFFM_ENABLEOK,0,0);
 end;
end;

function TPathDialog.getVisible:Boolean;
begin
 result:=FHandle<>0;
end;

procedure TPathDialog.SetDirectory(Dir:String);
begin
 if (Dir<>'') and (Dir[length(Dir)]='\') then
  FDirectory:=copy(Dir,1,length(Dir)-1)
 else
  FDirectory:=Dir;
 if (FHandle<>0) and (FDirectory<>'') then
  SendMessage(FHandle,BFFM_SETSELECTION,Integer(LongBool(true)),Integer(PChar(FDirectory)));
end;

procedure TPathDialog.SetStatusText(Text:String);
begin
 FStatusText:=Text;
 if (FHandle<>0) and FShowStatus then
  SendMessage(FHandle,BFFM_SETSTATUSTEXT,0,Integer(PChar(FStatusText)));
end;

procedure Register;
begin
  RegisterComponents('Samples', [TPathDialog]);
end;

end.
