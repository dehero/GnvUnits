unit GnvOptns;

interface

uses
  AnsiStrings, Classes, SysUtils;

const
  GNV_OPTIONS_ANY = 255;

type
  TGnvOptions = class;

  TGnvOptionIdent = Byte;
  TGnvOptionIdents = set of TGnvOptionIdent;

  TGnvOptionsEvent = procedure(Sender: TGnvOptions; Ident: TGnvOptionIdent) of object;

  TGnvOptions = class(TInterfacedPersistent)
  private
    FProcs: TList;
    FUpdateCount: Integer;
    FUpdating: Boolean;
  protected
    procedure Change(var Field: Word; Value: Word); overload;
    procedure Change(var Field: string; Value: string); overload;
    procedure Change(var Field: AnsiString; Value: AnsiString); overload;
    procedure Change(var Field: TDateTime; Value: TDateTime); overload;
    procedure Change(var Field: Boolean; Value: Boolean); overload;
    procedure Change(var Field: Cardinal; Value: Cardinal); overload;
    procedure Change(var Field: Byte; Value: Byte); overload;
    procedure Change(var Field: Integer; Value: Integer); overload;
    procedure Change(var Field: Int64; Value: Int64); overload;
    procedure Change(var Field: Single; Value: Single); overload;
    function GetIdent(P: Pointer): TGnvOptionIdent; virtual; abstract;
    procedure Notify(Ident: TGnvOptionIdent);
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Subscribe(Proc: TGnvOptionsEvent);
    procedure Unsubscribe(Proc: TGnvOptionsEvent);
    property Updating: Boolean read FUpdating;
  end;

  PMethod = ^TMethod;

implementation

{ TGnvOptions }

procedure TGnvOptions.Change(var Field: string; Value: string);
begin
  if not SameStr(Field, Value) then
  begin
    Field := Value;
    Notify(GetIdent(@Field));
  end;
end;

procedure TGnvOptions.Change(var Field: Boolean; Value: Boolean);
begin
  if Field <> Value then
  begin
    Field := Value;
    Notify(GetIdent(@Field));
  end;
end;

procedure TGnvOptions.Change(var Field: Integer; Value: Integer);
begin
  if Field <> Value then
  begin
    Field := Value;
    Notify(GetIdent(@Field));
  end;
end;

procedure TGnvOptions.Change(var Field: TDateTime; Value: TDateTime);
begin
  if Field <> Value then
  begin
    Field := Value;
    Notify(GetIdent(@Field));
  end;
end;

constructor TGnvOptions.Create;
begin
  inherited;
  FUpdating := False;
  FProcs := TList.Create;
end;

destructor TGnvOptions.Destroy;
var
  I: Integer;
begin
  for I := 0 to FProcs.Count - 1 do
    Dispose(FProcs[I]);
  FProcs.Free;
  inherited;
end;

procedure TGnvOptions.EndUpdate;
begin
  FUpdating := False;
  if FUpdateCount > 0 then Notify(GNV_OPTIONS_ANY);
end;

procedure TGnvOptions.Notify(Ident: TGnvOptionIdent);
var
  I: Integer;
begin
  if FUpdating then
    Inc(FUpdateCount)
  else
    for I := 0 to FProcs.Count - 1 do
      TGnvOptionsEvent(FProcs[I]^)(Self, Ident);
end;

procedure TGnvOptions.Subscribe(Proc: TGnvOptionsEvent);
var
  Method: PMethod;
begin
  Method := New(PMethod);
  Method^ := TMethod(Proc);
  FProcs.Add(Method);
end;

procedure TGnvOptions.Unsubscribe(Proc: TGnvOptionsEvent);
var
  I: Integer;
begin
  for I := 0 to FProcs.Count - 1 do
    if (PMethod(FProcs[I]).Code = TMethod(Proc).Code) and
      (PMethod(FProcs[I]).Data = TMethod(Proc).Data) then
    begin
      Dispose(FProcs[I]);
      FProcs.Delete(I);
      Exit;
    end;
end;

procedure TGnvOptions.BeginUpdate;
begin
  FUpdating := True;
  FUpdateCount := 0;
end;

procedure TGnvOptions.Change(var Field: Int64; Value: Int64);
begin
  if Field <> Value then
  begin
    Field := Value;
    Notify(GetIdent(@Field));
  end;
end;

procedure TGnvOptions.Change(var Field: Cardinal; Value: Cardinal);
begin
  if Field <> Value then
  begin
    Field := Value;
    Notify(GetIdent(@Field));
  end;
end;

procedure TGnvOptions.Change(var Field: Byte; Value: Byte);
begin
  if Field <> Value then
  begin
    Field := Value;
    Notify(GetIdent(@Field));
  end;
end;

procedure TGnvOptions.Change(var Field: Word; Value: Word);
begin
  if Field <> Value then
  begin
    Field := Value;
    Notify(GetIdent(@Field));
  end;
end;

procedure TGnvOptions.Change(var Field: AnsiString; Value: AnsiString);
begin
  if not SameStr(Field, Value) then
  begin
    Field := Value;
    Notify(GetIdent(@Field));
  end;
end;

procedure TGnvOptions.Change(var Field: Single; Value: Single);
begin
  if Field <> Value then
  begin
    Field := Value;
    Notify(GetIdent(@Field));
  end;
end;

end.
