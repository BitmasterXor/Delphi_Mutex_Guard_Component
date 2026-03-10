unit DemoMainForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.UITypes,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  uSingleInstanceGuard;

type
  TfrmSingleInstanceDemo = class(TForm)
    lblMutexName: TLabel;
    edtMutexName: TEdit;
    btnApply: TButton;
    btnTest: TButton;
    MemoLog: TMemo;
    SingleInstanceGuard1: TSingleInstanceGuard;
    procedure FormCreate(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure SingleInstanceGuard1SecondInstance(Sender: TObject;
      const MutexName: string);
  private
    procedure Log(const Text: string);
  public
  end;

var
  frmSingleInstanceDemo: TfrmSingleInstanceDemo;

implementation

{$R *.dfm}

procedure TfrmSingleInstanceDemo.Log(const Text: string);
begin
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss.zzz', Now) + '  ' + Text);
end;

procedure TfrmSingleInstanceDemo.FormCreate(Sender: TObject);
begin
  edtMutexName.Text := SingleInstanceGuard1.MutexName;

  Log('TSingleInstanceGuard demo started.');
  Log('Effective mutex: ' + SingleInstanceGuard1.EffectiveMutexName);

  if SingleInstanceGuard1.IsPrimaryInstance then
    Log('Primary instance acquired. This copy is allowed to run.')
  else
    Log('Secondary instance detected. This copy will terminate.');
end;

procedure TfrmSingleInstanceDemo.btnApplyClick(Sender: TObject);
begin
  SingleInstanceGuard1.Active := False;
  SingleInstanceGuard1.MutexName := Trim(edtMutexName.Text);
  SingleInstanceGuard1.Active := True;

  Log('Guard restarted with mutex: ' + SingleInstanceGuard1.EffectiveMutexName);

  if SingleInstanceGuard1.IsPrimaryInstance then
    Log('Primary instance confirmed.')
  else
    Log('Another instance already owns this mutex.');
end;

procedure TfrmSingleInstanceDemo.btnTestClick(Sender: TObject);
begin
  Log('Launch a second copy of this EXE to verify single-instance behavior.');
end;

procedure TfrmSingleInstanceDemo.SingleInstanceGuard1SecondInstance(
  Sender: TObject; const MutexName: string);
begin
  MessageDlg('Another instance is already running for mutex:'#13#10 + MutexName,
             mtWarning, [mbOK], 0);
end;

end.
