unit Unit1;

// lancement de l'appli directement par le CMDSET("Plink -telnet 139.54.46.9")
// => pas de lancement de session CMD avec Plink et Psftp ! ! ! !

interface

uses
  Windows, Messages, Controls, SysUtils,
  StdCtrls, Tlhelp32, strutils, ExtCtrls,Forms,  Classes ;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    Panel1: TPanel;
    Timer1: TTimer;

    function  mypath:WideString;
    procedure Button1Click(Sender: TObject);
    procedure run(s: string) ;
    function  NT_InternalGetWindowText(Wnd: HWND): string;
    procedure stopCMDprocess;
    function  KillTask(ExeFileName: string): Integer;
    procedure Timer1Timer(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure MemoAddLines(Memo : TMemo; Msg : String);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  CMDname : string;
  whandle, Phandle : cardinal;
  var _Waitfor: array[0..6] of string;
  var _Waittemp: array[0..6] of string;
  var _Sendfor: array[0..6] of string;
  _waitresult: byte;
  // datas for CMD.EXE interface
  buf: array[0..1024] of char;           //i/o buffer
  txt : string;
  si: STARTUPINFO;
  sa: SECURITY_ATTRIBUTES;
  sd: SECURITY_DESCRIPTOR;               //security information for pipes
  pi: PROCESS_INFORMATION;
  newstdin,newstdout,read_stdout,write_stdin: THandle;  //pipe handles
  vexit,bread,avail: cardinal;   //bytes available

implementation

{$R *.DFM}
uses
 IniFiles, unit2;

//------------Sample using CreateProcess and Anonymous Pipes-----------------
//---------------------childspawn.cpp----------------------------------------

//---------------------use freely--------------------------------------------
function IsWinNT:Boolean;  //check if we're running NT
//---------------------------------------------------------------------------
Var
  osv: OSVERSIONINFO;
begin
  osv.dwOSVersionInfoSize := sizeof(osv);
  GetVersionEx(osv);
  Result := (osv.dwPlatformId = VER_PLATFORM_WIN32_NT);
end;

//---------------------------------------------------------------------------
procedure ErrorMessage(str: string) ; //display detailed error info
//---------------------------------------------------------------------------
begin
  Form1.Memo1.lines.add('CMD OLE: Console interface error' + #$D + str);
end;

//---------------------------------------------------------------------------
function Tform1.mypath:WideString;
//---------------------------------------------------------------------------
begin
  mypath := ExtractFilePath(Application.ExeName) ;
end;

//---------------------------------------------------------------------------
procedure Tform1.Run(S: String);
//---------------------------------------------------------------------------
begin
  if (IsWinNT()) then       //initialize security descriptor (Windows NT)
  begin
    InitializeSecurityDescriptor(@sd,SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl(@sd, true, nil, false);
    sa.lpSecurityDescriptor := @sd;
  end
  else
    sa.lpSecurityDescriptor := nil;
    sa.nLength := sizeof(SECURITY_ATTRIBUTES);
    sa.bInheritHandle := true;         //allow inheritable handles
  if (not CreatePipe(newstdin,write_stdin, @sa,0))   then //create stdin pipe
  begin
    ErrorMessage('CreatePipe In');
    exit;
  end;
  if (not CreatePipe(read_stdout,newstdout, @sa,0)) then //create stdout pipe
  begin
    ErrorMessage('CreatePipe Out');
    CloseHandle(newstdin);
    CloseHandle(write_stdin);
    exit;
  end;
  GetStartupInfo(si);      //set startupinfo for the spawned process
 (*
  The dwFlags member tells CreateProcess how to make the process.
  STARTF_USESTDHANDLES validates the hStd* members. STARTF_USESHOWWINDOW
  validates the wShowWindow member.
  *)
  CMDname := 'Putty OLE';
  si.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  si.wShowWindow := SW_Hide;  //SW_Normal; //
  si.hStdOutput := newstdout;
  si.hStdError := newstdout;     // set the new handles for the child process
  si.hStdInput := newstdin;
  si.lpTitle := pchar(CMDname);
 //spawn the child process
   sleep(100);
  if (not CreateProcess(nil,PChar(S),nil,nil,TRUE,CREATE_NEW_CONSOLE,nil,nil,si,pi)) then
  begin
    ErrorMessage('CreateProcess CMD');
    CloseHandle(newstdin);
    CloseHandle(newstdout);
    CloseHandle(read_stdout);
    CloseHandle(write_stdin);
    exit;
  end;
  FillChar(buf,sizeof(buf),0);
  Phandle := pi.hProcess;
  sleep(200);
  Whandle :=  FindWindow(nil,pchar(CMDname));
   Timer1.Enabled := true;
   timer1.Tag := 2;
//  sleep(500);

end;

//---------------------------------------------------------------------------
procedure TForm1.Timer1Timer(Sender: TObject);
//---------------------------------------------------------------------------
begin
  GetExitCodeProcess(pi.hProcess,vexit); //while the process is running
  if ((vexit <> STILL_ACTIVE)) then timer1.Tag := timer1.Tag - 1;

  if timer1.Tag < 1 then
  begin
    // on quitte la boucle si pas de fenêtre ouverte
    Button1.Caption := 'Run';
    Button1.Tag := 0;
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    CloseHandle(newstdin);            //clean stuff up
    CloseHandle(newstdout);
    CloseHandle(read_stdout);
    CloseHandle(write_stdin);
    Timer1.Enabled := false;
  end
  else
  begin
    // arret de la fenêtre CMD + Appli  d'après Button1.tag
    if (button1.Tag = 1) then
    begin
      // cas 1 on arrete le process avec l'appli qui tourne dessus si nécessaire
      stopCMDprocess;
      button1.Tag := 0;
    end;
    //stdout: check to see if there is any data to read from stdout
    PeekNamedPipe(read_stdout, @buf,1023, @bread, @avail,nil);
    if (bread <> 0) then
    begin
      FillChar(buf,sizeof(buf),0);
      if (avail > 1023) then
      begin
        while (bread >= 1023) do
        begin
          ReadFile(read_stdout,buf,1023,bread,nil);  //read the stdout pipe
          MemoAddLines(memo1,buf);
          FillChar(buf,sizeof(buf),0);
        end;
      end
      else
      begin
        ReadFile(read_stdout,buf,1023,bread,nil);
        MemoAddLines(memo1,buf);
      end;
    end;
  end;
end;

//---------------------------------------------------------------------------
procedure TForm1.Button1Click(Sender: TObject);
//---------------------------------------------------------------------------
begin
  if Button1.Caption = 'Run' then
  begin
    Button1.Caption := 'Stop';
    if Unit2._text_reset  then memo1.Lines.Clear;
    Edit1.Enabled := true;
    Run('CMD.exe');
    Timer1.Enabled := true
  end
  else
  begin
    Button1.Caption := 'Run';
    Button1.Tag := 1;
    Edit1.Enabled := false;
  end;
end;

//---------------------------------------------------------------------------
procedure TForm1.stopCMDprocess;
//---------------------------------------------------------------------------
var
   appli : string;
begin
  if CMDname = NT_InternalGetWindowText(Whandle)then
  begin
    // cas CMD.EXE seul : exit normal
    SendMessage(Whandle,WM_CLOSE,0,0) ;
    memo1.Lines.Add('CMD OLE: Exit of Console session') ;
  end
  else
  begin
    // cas appli qui tourne sous session CMD
    // plusieurs cas à traiter: Putty + AppNom, AppNom seul, AppNom + ligne de paramêtre
    appli := trim(stringreplace(NT_InternalGetWindowText(Whandle),CMDname+' - ','',[rfReplaceAll]));
    if pos(' ',appli) <> 0 then
    appli := leftstr(appli,pos(' ',appli)-1);
    if appli <> '' then KillTask(appli +'.exe');
    SendMessage(Whandle,WM_CLOSE,0,0);
    memo1.Lines.Add('CMDole: Abort of '+ appli + ' session');
    memo1.Lines.Add('CMDole: Exit of Console session');
  end;
end;

//---------------------------------------------------------------------------
function TForm1.KillTask(ExeFileName: string): Integer;
//---------------------------------------------------------------------------
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then

//************** test du handle de cette appli
      Result := Integer(TerminateProcess(
                        OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
      ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);

  end;
  CloseHandle(FSnapshotHandle);
end;

//---------------------------------------------------------------------------
function Tform1.NT_InternalGetWindowText(Wnd: HWND): string;
//---------------------------------------------------------------------------
type
  TInternalGetWindowText = function(Wnd: HWND; lpString: PWideChar;
    nMaxCount: Integer): Integer;
  stdcall;
var
  hUserDll: THandle;
  InternalGetWindowText: TInternalGetWindowText;
  lpString: array[0..MAX_PATH] of WideChar; //Buffer for window caption
begin
  Result   := '';
  hUserDll := GetModuleHandle('user32.dll');
  if (hUserDll > 0) then
  begin @InternalGetWindowText := GetProcAddress(hUserDll, 'InternalGetWindowText');
    if Assigned(InternalGetWindowText) then
    begin
      InternalGetWindowText(Wnd, lpString, SizeOf(lpString));
      Result := string(lpString);
    end;
  end;
end;

//---------------------------------------------------------------------------
procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
//---------------------------------------------------------------------------
var
  txt : string;
begin
  if key = #$D then
  begin
    memo1.lines.Clear;
    txt := Edit1.text + #$A ;
    WriteFile(write_stdin,txt[1],length(txt),bread,nil) ;
  end;
  if key = #$1B then edit1.Clear;
end;

//---------------------------------------------------------------------------
procedure TForm1.MemoAddLines(Memo : TMemo; Msg : String);
//---------------------------------------------------------------------------
const
  CR = #13;
  LF = #10;
var
  Start, Stop : Integer;
  i,j: byte;
  Msgcopy , txt: string;
begin
  Msgcopy := Msg;
  {affichage du texte reçu }
  if Memo1.Lines.Count = 0 then
  Memo1.Lines.Add('');
  Start := 1;
  Stop  := Pos(CR, Msg);
  if Stop = 0 then
    Stop := Length(Msg) + 1;
  while Start <= Length(Msg) do
  begin
    Memo1.Lines.Strings[Memo1.Lines.Count - 1] :=
    Memo1.Lines.Strings[Memo1.Lines.Count - 1] + Copy(Msg, Start, Stop - Start);
    if Msg[Stop] = CR then
    begin
      Memo1.Lines.Add('');
      SendMessage(Memo1.Handle, WM_KEYDOWN, VK_UP, 1);
    end;
    Start := Stop + 1;
    if Start > Length(Msg) then
    Break;
    if Msg[Start] = LF then
    Start := Start + 1;
    Stop := Start;
    while (Msg[Stop] <> CR) and (Stop <= Length(Msg)) do
      Stop := Stop + 1;
  end;
 {test sur Waitfor/SendFor }
  j :=1;
  for i := 0 to 6 do
  begin
    if (_waitfor[i] <> '') then
    begin
      _WaitTemp[i] := _WaitTemp[i] + msgcopy;
      if  not(pos(_waitfor[i],_WaitTemp[i])= 0) then
      begin
      //=> on a trouvé une valeur identique
        if not(length(_Sendfor[i])= 0) then
        begin
          txt := _Sendfor[i] + #$A ;
          WriteFile(write_stdin,txt[1],length(txt),bread,nil) ;
          //cas à répéter une seule fois
          if i > 4 then _waitfor[i] := '';
        end
        else
        begin
            _WaitResult := _WaitResult OR j;
        end;
      end;
      _WaitTemp[i] := rightstr(_WaitTemp[i],length(_waitfor[i])-1);
    end;
    j := j *2;
  end;
end;

//---------------------------------------------------------------------------
procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
//---------------------------------------------------------------------------
begin
 if ((Shift=[ssCtrl]) and (Key=Ord('C'))) then
   edit1.text := chr(27)+chr(3)  ;
end;

//---------------------------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
//---------------------------------------------------------------------------
var
  ServerIni: TMemIniFile;
begin
  ServerIni := TMemIniFile.Create(ChangeFileExt( Application.ExeName, '.ini'));
  form1.top :=  ServerIni.Readinteger('windows', 'top',362);
  form1.left :=  ServerIni.Readinteger('windows', 'left',299);
  form1.height :=  ServerIni.Readinteger('windows', 'height',183);
  form1.width :=  ServerIni.Readinteger('windows', 'width',407);
  ServerIni.Free;
end;

//---------------------------------------------------------------------------
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
//---------------------------------------------------------------------------
var
  ServerIni: TMemIniFile;
begin
  if Button1.Caption = 'Stop'
  then Button1click(nil);
  ServerIni := TMemIniFile.Create(ChangeFileExt( Application.ExeName, '.ini') );
  ServerIni.Writeinteger('windows', 'top',form1.top);
  ServerIni.Writeinteger('windows', 'left',form1.left);
  ServerIni.Writeinteger('windows', 'height',form1.height);
  ServerIni.Writeinteger('windows', 'width',form1.width);
  ServerIni.UpdateFile;
  ServerIni.Free;
end;

//---------------------------------------------------------------------------
procedure TForm1.FormResize(Sender: TObject);
//---------------------------------------------------------------------------
begin
  edit1.Width := form1.Width - 120;
end;

//----------------------------------------------------------------------
procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//---------------------------------------------------------------------------
begin
   if (Button1.Caption = 'Stop')
   then  CanClose := False;
end;

end.
