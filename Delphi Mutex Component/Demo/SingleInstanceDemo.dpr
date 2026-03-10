program SingleInstanceDemo;

uses
  Vcl.Forms,
  DemoMainForm in 'DemoMainForm.pas' {frmSingleInstanceDemo},
  uSingleInstanceGuard in '..\uSingleInstanceGuard.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmSingleInstanceDemo, frmSingleInstanceDemo);
  Application.Run;
end.
