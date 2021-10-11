unit Unit2;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ComObj, ActiveX, CMDole_TLB,strutils, windows, StdVcl;
type
  Tserver = class(TAutoObject, Iserver)
  protected
    function Get_CmdStatus: WideString; safecall;
    function Get_LineIn(Param1: Integer): WideString; safecall;
    function Get_LineNbIn: Integer; safecall;
    function Get_Path: WideString; safecall;
    function Get_TextIn: WideString; safecall;
    function Get_WaitStatus: Integer; safecall;
    procedure CmdOut(const Param1: WideString); safecall;
    procedure CmdSet(const Param1: WideString); safecall;
    procedure FilterSet(const Param1: WideString); safecall;
    procedure FilterFor(Param1: Integer; const Param2, Param3: WideString);
      safecall;
    procedure InitReset; safecall;
    procedure Show(Param1: Integer); safecall;
    procedure WaitFor(Param1: Integer; const Param2, Param3: WideString);
      safecall;
    procedure WaitReset; safecall;
    procedure PasswOut(const Param1, Param2: WideString); safecall;
    procedure UserOut(const Param1, Param2: WideString); safecall;

end;

var
  _FilterKey: array[0..9] of string;
  _FilterBy: array[0..9] of string;
  _FilterStatus : boolean = false;
  _text_reset : boolean = true;

implementation

uses ComServ, unit1;

function Tserver.Get_CmdStatus: WideString;
begin
   if form1.button1.Caption = 'run' then
     Get_CmdStatus := 'OFF'
   else
     Get_CmdStatus := 'ON';
end;

function Tserver.Get_LineIn(Param1: Integer): WideString;
begin
   if form1.Memo1.Lines.Count > param1 then
     Get_LineIn := form1.Memo1.Lines[Param1];
end;

function Tserver.Get_LineNbIn: Integer;
begin
   Get_LineNbIn := form1.Memo1.Lines.count;
end;

function Tserver.Get_Path: WideString;
begin
   Get_Path := form1.mypath;
end;

function Tserver.Get_TextIn: WideString;
var
i: byte;
j: string;
begin
J := Form1.Memo1.Text;
  if _filterstatus then
  begin
    for i := 0 to 9 do
    begin
      if (_FilterKey[i] <> '') then
      begin
        J := ansireplaceText(J,_FilterKey[i],_FilterBy[i]);
      end;
    end;
  end;
  get_TextIn := J;
end;

function Tserver.Get_WaitStatus: Integer;
begin
Get_Waitstatus := Unit1._WaitResult;
end;

procedure Tserver.CmdOut(const Param1: WideString);
var
  txt : string;
begin
  Unit1._Waitresult := 0;
  if _text_reset then Form1.memo1.lines.Clear;
  txt := Param1 + #$A ;
  WriteFile(write_stdin,txt[1],length(txt),bread,nil) ;
end;

procedure Tserver.CmdSet(const Param1: WideString);
begin
  if ((Param1 = 'OFF')  and (Form1.Button1.caption <> 'run')) then
    Form1.Button1click(Nil)
  else
  begin
    if ((Param1 <> '')  and (Form1.Button1.caption = 'run')) then
    begin
      Form1.Button1.Caption := 'stop';
      if _text_reset then Form1.memo1.Lines.Clear;
      Form1.Edit1.Enabled := true;
      Form1.Run(param1);
      Form1.Timer1.Enabled := true;
      Form1.timer1.Tag := 2;
      sleep(100);
      end;
  end;
end;

procedure Tserver.FilterSet(const Param1: WideString);
begin
 if Param1 = 'ON' then _filterstatus := true
 else _filterstatus := False;
end;

procedure Tserver.FilterFor(Param1: Integer; const Param2,
  Param3: WideString);
begin
  if Param1 in [0..9] then
  begin
     _FilterKey[Param1] := param2;
     _FilterBy[Param1] := param3;
  end;
end;

procedure Tserver.InitReset;
var
  i: byte ;
begin
  for i := 0 to 4 do
  begin
    Unit1._WaitFor[i] := '';
    Unit1._SendFor[i] := '';
  end;
  Unit1._Waitresult := 0;
  for i := 0 to 9 do
  begin
    _FilterKey[i] := '';
    _FilterBy[i] := '';
  end;
  _FilterStatus := true;
  _text_reset := true;
  Show(2);

end;

procedure Tserver.Show(Param1: Integer);
begin
   if Param1 = 0 then
   begin
     Form1.Edit1.enabled := true ;
     Form1.Visible := false;
   end;
   if Param1 = 1 then
   begin
     Form1.Edit1.enabled := false ;
     Form1.Visible := true;
   end;
   if Param1 = 2 then
   begin
     Form1.visible := true ;
     Form1.Edit1.enabled := true ;
     _text_reset := true;
   end;
   if Param1 = 3 then
   begin
     _text_reset := false;
   end;
end;

procedure Tserver.WaitFor(Param1: Integer; const Param2,
  Param3: WideString);
begin
   if Param1 in [0..4] then
   begin
     Unit1._WaitFor[Param1] := param2;
     Unit1._SendFor[Param1] := param3;
   end;
end;

procedure Tserver.WaitReset;
begin
   Unit1._Waitresult := 0;
end;

procedure Tserver.PasswOut(const Param1, Param2: WideString);
begin
    Unit1._SendFor[5] := param2;
    Unit1._WaitFor[5] := param1;
end;

procedure Tserver.UserOut(const Param1, Param2: WideString);
begin
    Unit1._SendFor[6] := param2;
    Unit1._WaitFor[6] := param1;
end;

initialization
  TAutoObjectFactory.Create(ComServer, Tserver, Class_server,
    ciSingleInstance, tmApartment);
end.
