program CMDole;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  CMDole_TLB in 'CMDole_TLB.pas',
  Unit2 in 'Unit2.pas' {server: CoClass};

{$R *.TLB}

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
