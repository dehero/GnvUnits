unit GnvMenus;

interface

uses
  Classes, Menus;

type

  TGnvRecentMenuItems = class
  private
    FBaseItem: TMenuItem;
    FItems: TList;
    procedure SetBaseItem(const Value: TMenuItem);
    function GetMenuItem(Index: Integer): TMenuItem;
    procedure SetMenuItem(Index: Integer; MenuItem: TMenuItem);
    procedure Update;
    function GetCount: Integer;
  public
    constructor Create(ABaseItem: TMenuItem); reintroduce;
    destructor Destroy; override;
    function Add(MenuItem: TMenuItem): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    function IndexOf(MenuItem: TMenuItem): Integer;
    procedure Move(const CurIndex, NewIndex: Integer);
    property BaseItem: TMenuItem read FBaseItem write SetBaseItem;
    property Count: Integer read GetCount;
    property MenuItems[Index: Integer]: TMenuItem read GetMenuItem
      write SetMenuItem; default;
  end;

implementation

{ TGnvRecentMenuItems }

function TGnvRecentMenuItems.Add(MenuItem: TMenuItem): Integer;
begin
  Result := FItems.Add(MenuItem);
  FBaseItem.Parent.Insert(FBaseItem.MenuIndex + FItems.Count, MenuItem);
  Update;
end;

procedure TGnvRecentMenuItems.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    GetMenuItem(I).Free;
  FItems.Clear;
  Update;
end;

constructor TGnvRecentMenuItems.Create(ABaseItem: TMenuItem);
begin
  inherited Create;

  FItems := TList.Create;
  FBaseItem := ABaseItem;
end;

procedure TGnvRecentMenuItems.Delete(Index: Integer);
begin
  GetMenuItem(Index).Free;
  FItems.Delete(Index);
  Update;
end;

destructor TGnvRecentMenuItems.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

function TGnvRecentMenuItems.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TGnvRecentMenuItems.GetMenuItem(Index: Integer): TMenuItem;
begin
  Result := FItems[Index];
end;

function TGnvRecentMenuItems.IndexOf(MenuItem: TMenuItem): Integer;
begin
  Result := FItems.IndexOf(MenuItem);
end;

procedure TGnvRecentMenuItems.Move(const CurIndex, NewIndex: Integer);
begin
  GetMenuItem(CurIndex).MenuIndex := FBaseItem.MenuIndex + NewIndex + 1;
  FItems.Move(CurIndex, NewIndex);
end;

procedure TGnvRecentMenuItems.SetBaseItem(const Value: TMenuItem);
begin
  Clear;
  FBaseItem := Value;
end;

procedure TGnvRecentMenuItems.SetMenuItem(Index: Integer; MenuItem: TMenuItem);
begin
  FItems[Index] := MenuItem;
end;

procedure TGnvRecentMenuItems.Update;
begin
  if Assigned(FBaseItem) then
    FBaseItem.Visible := (FItems.Count = 0);
end;

end.
