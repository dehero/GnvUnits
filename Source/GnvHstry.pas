unit GnvHstry;

interface

uses
  SysUtils, Classes;

type

  TGnvHistoryChangeEvent = procedure of object;
  TGnvHistoryFreeEvent = procedure(Data: Pointer) of object;
  TGnvHistoryRedoEvent = procedure(Data: Pointer; var Flag: Boolean) of object;
  TGnvHistoryUndoEvent = procedure(Data: Pointer; var Flag: Boolean) of object;

  TGnvHistory = class
  private
    FEvents: TList;
    FState: Cardinal;
    FStates: TList;
    FWritingState: Boolean;
    FOnChange: TGnvHistoryChangeEvent;
    FOnFreeEvent: TGnvHistoryFreeEvent;
    FOnRedoEvent: TGnvHistoryRedoEvent;
    FOnUndoEvent: TGnvHistoryUndoEvent;
    FChangingState: Boolean;
    function GetCount: Integer;
    procedure FreeState(Index: Integer);
  protected
    procedure DoChange; virtual;
    procedure DoFreeEvent(Data: Pointer); virtual;
    procedure DoRedoEvent(Data: Pointer; var Flag: Boolean); virtual;
    procedure DoUndoEvent(Data: Pointer; var Flag: Boolean); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddEvent(Data: Pointer);
    procedure BeginState;
    procedure CancelState;
    function CanRedo: Boolean;
    function CanUndo: Boolean;
    procedure EndState;
    procedure Redo;
    procedure Undo;
    property ChangingState: Boolean read FChangingState;
    property Count: Integer read GetCount;
    property OnChange: TGnvHistoryChangeEvent read FOnChange write FOnChange;
    property OnFreeEvent: TGnvHistoryFreeEvent read FOnFreeEvent write FOnFreeEvent;
    property OnRedoEvent: TGnvHistoryRedoEvent read FOnRedoEvent write FOnRedoEvent;
    property OnUndoEvent: TGnvHistoryUndoEvent read FOnUndoEvent write FOnUndoEvent;
    property State: Cardinal read FState;
    property WritingState: Boolean read FWritingState;
  end;

implementation


{ TGnvHistory }

procedure TGnvHistory.AddEvent(Data: Pointer);
begin
  if FWritingState then
    FEvents.Add(Data)
  else
    DoFreeEvent(Data);
end;

procedure TGnvHistory.BeginState;
begin
  if FWritingState then Exit;
  // Start writing history state
  FEvents := TList.Create;
  FWritingState := True;
end;

procedure TGnvHistory.CancelState;
var
  Flag: Boolean;
  I: Integer;
begin
  Flag := False;
  if FWritingState then
  begin
    // If there are no events, state does not change
    if FEvents.Count > 0 then
      // Play events backward
      for I := FEvents.Count - 1 downto 0 do
      begin
        DoUndoEvent(FEvents[I], Flag);
        // Free events memory
        DoFreeEvent(FEvents[I]);
      end;
    FreeAndNil(FEvents);
    FWritingState := False;
  end;
end;

function TGnvHistory.CanRedo: Boolean;
begin
  Result := Integer(FState) < GetCount;
end;

function TGnvHistory.CanUndo: Boolean;
begin
  Result := FState > 0;
end;

constructor TGnvHistory.Create;
begin
  inherited;
  FStates := TList.Create;
  FState := 0;
  FWritingState := False;
end;

destructor TGnvHistory.Destroy;
var
  I: Integer;
begin
  // Force end writing state and destroy all history states
  EndState;
  for I := 0 to FStates.Count - 1 do
    FreeState(I);
  FStates.Free;
  inherited;
end;

procedure TGnvHistory.DoChange;
begin
  if Assigned(FOnChange) then FOnChange;
end;

procedure TGnvHistory.DoFreeEvent(Data: Pointer);
begin
  if Assigned(FOnFreeEvent) then FOnFreeEvent(Data);
end;

procedure TGnvHistory.DoRedoEvent(Data: Pointer; var Flag: Boolean);
begin
  if Assigned(OnRedoEvent) then FOnRedoEvent(Data, Flag);
end;

procedure TGnvHistory.DoUndoEvent(Data: Pointer; var Flag: Boolean);
begin
  if Assigned(OnUndoEvent) then FOnUndoEvent(Data, Flag);
end;

procedure TGnvHistory.EndState;
var
  I: Integer;
begin
  if FWritingState then
  begin
    // If there are no events, state does not change
    if FEvents.Count > 0 then
    begin
      // Delete obsolete history change branch
      for I := FStates.Count - 1 downto FState do
      begin
        FreeState(I);
        FStates.Delete(I);
      end;
      // Create new state and make it current
      FState := FStates.Add(FEvents) + 1;
    end
    else
      FreeAndNil(FEvents);
    FWritingState := False;
    DoChange;
  end;
end;

procedure TGnvHistory.FreeState(Index: Integer);
var
  Events: TList;
  I: Integer;
begin
  Events := FStates[Index];
  // Free events memory
  for I := 0 to Events.Count - 1 do
    DoFreeEvent(Events[I]);
  Events.Free;
end;

function TGnvHistory.GetCount: Integer;
begin
  Result := FStates.Count;
end;

procedure TGnvHistory.Redo;
var
  Flag: Boolean;
  Events: TList;
  I: Integer;
begin
  if CanRedo then
  begin
    FChangingState := True;
    Flag := False;
    Events := FStates[FState];
    // Play events forward
    for I := 0 to Events.Count - 1 do
      DoRedoEvent(Events[I], Flag);
    // Change current state and notify subscribers
    FState := FState + 1;
    DoChange;
    FChangingState := False;
  end;
end;

procedure TGnvHistory.Undo;
var
  Flag: Boolean;
  Events: TList;
  I: Integer;
begin
  if CanUndo then
  begin
    FChangingState := True;
    Flag := False;
    Events := FStates[FState - 1];
    // Play events backward
    for I := Events.Count - 1 downto 0 do
      DoUndoEvent(Events[I], Flag);
    // Change current state and notify subscribers
    FState := FState - 1;
    DoChange;
    FChangingState := False;
  end;
end;

end.