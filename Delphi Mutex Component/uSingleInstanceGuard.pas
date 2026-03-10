unit uSingleInstanceGuard;

{*******************************************************************************
  TSingleInstanceGuard - VCL single-instance mutex component
  ===========================================================

  Author  : BitmasterXor
  Purpose : Prevent multiple instances of the same application (or logical app
            group) from running at the same time.

  How it works:
    - Uses a named Windows mutex.
    - First instance acquires ownership.
    - Second instance detects ERROR_ALREADY_EXISTS.

  Typical usage:
    - Drop TSingleInstanceGuard on your main form/datamodule.
    - Set MutexName (same name across EXEs you want to restrict).
    - Keep Active = True.
*******************************************************************************}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  Vcl.Forms;

type
  TDuplicateAction = (daNone, daTerminate);

  TSecondInstanceEvent = procedure(Sender: TObject;
                                   const MutexName: string) of object;

  TSingleInstanceGuard = class(TComponent)
  private
    FMutexHandle: THandle;
    FActive: Boolean;
    FMutexName: string;
    FEffectiveMutexName: string;
    FUseGlobalNamespace: Boolean;
    FOwnsMutex: Boolean;
    FIsPrimaryInstance: Boolean;
    FLastErrorCode: Cardinal;
    FDuplicateAction: TDuplicateAction;
    FOnSecondInstance: TSecondInstanceEvent;

    function  GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    procedure SetMutexName(const Value: string);
    procedure SetUseGlobalNamespace(const Value: Boolean);
    procedure SetDuplicateAction(const Value: TDuplicateAction);

    function  BuildDefaultMutexName: string;
    function  NormalizeMutexName(const Value: string): string;
    procedure ValidateMutexName(const Value: string);
    procedure TerminateCurrentInstance;
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure StartGuard;
    procedure StopGuard;

    property EffectiveMutexName: string read FEffectiveMutexName;
    property IsPrimaryInstance: Boolean read FIsPrimaryInstance;
    property LastErrorCode: Cardinal read FLastErrorCode;
  published
    property Active: Boolean
      read GetActive
      write SetActive
      default True;

    property MutexName: string
      read FMutexName
      write SetMutexName;

    property UseGlobalNamespace: Boolean
      read FUseGlobalNamespace
      write SetUseGlobalNamespace
      default False;

    property DuplicateAction: TDuplicateAction
      read FDuplicateAction
      write SetDuplicateAction
      default daTerminate;

    property OnSecondInstance: TSecondInstanceEvent
      read FOnSecondInstance
      write FOnSecondInstance;
  end;

procedure Register;

implementation

{$R uSingleInstanceGuard.dcr}

function MakeSafeName(const Value: string): string;
var
  I: Integer;
  Ch: Char;
begin
  Result := '';
  for I := 1 to Length(Value) do
  begin
    Ch := Value[I];
    if CharInSet(Ch, ['A'..'Z', 'a'..'z', '0'..'9', '.', '-', '_']) then
      Result := Result + Ch
    else
      Result := Result + '_';
  end;

  if Result = '' then
    Result := 'App';
end;

constructor TSingleInstanceGuard.Create(AOwner: TComponent);
var
  AppName: string;
begin
  inherited Create(AOwner);

  FMutexHandle := 0;
  FActive := True;
  FUseGlobalNamespace := False;
  FDuplicateAction := daTerminate;
  FOwnsMutex := False;
  FIsPrimaryInstance := True;
  FLastErrorCode := ERROR_SUCCESS;

  AppName := ChangeFileExt(ExtractFileName(ParamStr(0)), '');
  if AppName = '' then
    AppName := 'DelphiApp';

  FMutexName := 'MutexGuard.' + MakeSafeName(AppName) + '.SingleInstance';
  FEffectiveMutexName := '';
end;

destructor TSingleInstanceGuard.Destroy;
begin
  StopGuard;
  inherited Destroy;
end;

procedure TSingleInstanceGuard.Loaded;
begin
  inherited Loaded;

  if FActive then
  begin
    FActive := False;
    StartGuard;
  end;
end;

function TSingleInstanceGuard.GetActive: Boolean;
begin
  Result := FActive;
end;

procedure TSingleInstanceGuard.SetActive(const Value: Boolean);
begin
  if Value = FActive then
    Exit;

  if csLoading in ComponentState then
  begin
    FActive := Value;
    Exit;
  end;

  if csDesigning in ComponentState then
  begin
    FActive := Value;
    Exit;
  end;

  if Value then
    StartGuard
  else
    StopGuard;
end;

procedure TSingleInstanceGuard.SetDuplicateAction(const Value: TDuplicateAction);
begin
  FDuplicateAction := Value;
end;

procedure TSingleInstanceGuard.SetMutexName(const Value: string);
var
  WasActive: Boolean;
begin
  if Value = FMutexName then
    Exit;

  FMutexName := Value;

  if (csDesigning in ComponentState) or (csLoading in ComponentState) then
    Exit;

  if FActive then
  begin
    WasActive := FActive;
    StopGuard;
    if WasActive then
      StartGuard;
  end;
end;

procedure TSingleInstanceGuard.SetUseGlobalNamespace(const Value: Boolean);
var
  WasActive: Boolean;
begin
  if Value = FUseGlobalNamespace then
    Exit;

  FUseGlobalNamespace := Value;

  if (csDesigning in ComponentState) or (csLoading in ComponentState) then
    Exit;

  if FActive then
  begin
    WasActive := FActive;
    StopGuard;
    if WasActive then
      StartGuard;
  end;
end;

function TSingleInstanceGuard.BuildDefaultMutexName: string;
var
  AppName: string;
  Prefix: string;
begin
  AppName := ChangeFileExt(ExtractFileName(ParamStr(0)), '');
  if AppName = '' then
    AppName := 'DelphiApp';

  if FUseGlobalNamespace then
    Prefix := 'Global\'
  else
    Prefix := 'Local\';

  Result := Prefix + 'MutexGuard.' + MakeSafeName(AppName) + '.SingleInstance';
end;

procedure TSingleInstanceGuard.ValidateMutexName(const Value: string);
var
  Tail: string;
begin
  if Trim(Value) = '' then
    raise Exception.Create('TSingleInstanceGuard: Mutex name cannot be empty.');

  if SameText(Copy(Value, 1, 7), 'Global\') then
    Tail := Copy(Value, 8, MaxInt)
  else if SameText(Copy(Value, 1, 6), 'Local\') then
    Tail := Copy(Value, 7, MaxInt)
  else
    Tail := Value;

  if Pos('\', Tail) > 0 then
    raise Exception.Create(
      'TSingleInstanceGuard: Backslash is only allowed in Local\ or Global\ prefix.');
end;

function TSingleInstanceGuard.NormalizeMutexName(const Value: string): string;
var
  Raw: string;
  Prefix: string;
begin
  Raw := Trim(Value);

  if Raw = '' then
    Exit(BuildDefaultMutexName);

  if SameText(Copy(Raw, 1, 7), 'Global\') or
     SameText(Copy(Raw, 1, 6), 'Local\') then
    Result := Raw
  else
  begin
    if FUseGlobalNamespace then
      Prefix := 'Global\'
    else
      Prefix := 'Local\';

    Result := Prefix + Raw;
  end;

  ValidateMutexName(Result);
end;

procedure TSingleInstanceGuard.TerminateCurrentInstance;
begin
  if csDesigning in ComponentState then
    Exit;

  if Assigned(FOnSecondInstance) then
    FOnSecondInstance(Self, FEffectiveMutexName);

  if FDuplicateAction = daTerminate then
  begin
    if Assigned(Application.MainForm) then
      Application.MainForm.Close;

    Application.Terminate;
  end;
end;

procedure TSingleInstanceGuard.StartGuard;
begin
  if csDesigning in ComponentState then
  begin
    FActive := True;
    Exit;
  end;

  if FMutexHandle <> 0 then
  begin
    FActive := True;
    Exit;
  end;

  FEffectiveMutexName := NormalizeMutexName(FMutexName);

  SetLastError(ERROR_SUCCESS);
  FMutexHandle := CreateMutex(nil, True, PChar(FEffectiveMutexName));
  if FMutexHandle = 0 then
    raise Exception.CreateFmt('TSingleInstanceGuard: CreateMutex failed (%s)',
                              [SysErrorMessage(GetLastError)]);

  FLastErrorCode := GetLastError;
  FOwnsMutex := FLastErrorCode <> ERROR_ALREADY_EXISTS;
  FIsPrimaryInstance := FOwnsMutex;
  FActive := True;

  if not FIsPrimaryInstance then
    TerminateCurrentInstance;
end;

procedure TSingleInstanceGuard.StopGuard;
begin
  if FMutexHandle <> 0 then
  begin
    if FOwnsMutex then
      ReleaseMutex(FMutexHandle);

    CloseHandle(FMutexHandle);
    FMutexHandle := 0;
  end;

  FOwnsMutex := False;
  FIsPrimaryInstance := True;
  FLastErrorCode := ERROR_SUCCESS;
  FActive := False;
end;

procedure Register;
begin
  RegisterComponents('Utilities', [TSingleInstanceGuard]);
end;

end.
