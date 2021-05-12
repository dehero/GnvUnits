unit GnvJSON;

interface

uses Classes, SysUtils, Variants, Windows;

const
  cBlockWriteStreamBlockSize = $2000 - 2*SizeOf(Pointer);

type
  // Provides a write-only block-based stream.
  TBlockWriteStream = class (TStream)
  private
    FFirstBlock: PPointerArray;
    FCurrentBlock: PPointerArray;
    FBlockRemaining: PInteger;
    FTotalSize: Integer;
  protected
    function GetSize: Int64; override;
    procedure AllocateCurrentBlock;
    procedure FreeBlocks;
  public
    constructor Create;
    destructor Destroy; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    {$ifdef FPC}
    procedure WriteString(const utf8String: string); overload;
    {$endif}
    // Must be strictly an utf16 string
    procedure WriteString(const utf16String: UnicodeString); overload;
    procedure WriteSubString(const Utf16String: UnicodeString; StartPos: Integer); overload;
    procedure WriteSubString(const Utf16String: UnicodeString; StartPos, Length: Integer); overload;
    procedure WriteChar(utf16Char: WideChar); inline;
    // Assumes data is an utf16 string, spits out utf8 in FPC, utf16 in Delphi
    function ToString: string; override;
    procedure Clear;
    procedure StoreData(var Buffer); overload;
    procedure StoreData(Stream: TStream); overload;
  end;

  // Uses Monitor hidden field to store refcount, so not compatible with monitor use
  // (but Monitor is buggy, so no great loss)
  TRefCountedObject = class
  private
    {$ifdef FPC}
    FRefCount: Integer;
    {$endif}
    function  GetRefCount: Integer; inline;
    procedure SetRefCount(N: Integer); inline;
  public
    function  IncRefCount: Integer; inline;
    function  DecRefCount: Integer;
    property  RefCount: Integer read GetRefCount write SetRefCount;
    procedure Free;
  end;

  // Compact list embedded in a record.
  // If the list holds only 1 item, no dynamic memory is allocated
  // (the list pointer is used).
  // Make sure to Clear or Clean in the destructor of the Owner.
  TTightListArray = array [0..MaxInt shr 4] of TRefCountedObject;
  PObjectTightList = ^TTightListArray;

  // Embeddable stack functionality
  TTightStack = record
  private
    FList: PObjectTightList;
    FCount: Integer;
    FCapacity: Integer;
    procedure Grow;
  public
    procedure Push(item: TRefCountedObject); inline;
    function  Peek: TRefCountedObject; inline;
    procedure Pop; inline;
    procedure Clear; inline;
    procedure Clean;
    procedure Free;
    property List: PObjectTightList read FList;
    property Count: Integer read FCount;
  end;

  TStringReader = class
  private
    FStr: UnicodeString;
    FPointer, FLineStart: PWideChar;
    FLine: Integer;
  public
    constructor Create(const AStr: string);
    function NextChar: WideChar;
    function Location: string;
  end;

  TGnvJSONDataType = (jstUndefined, jstNull, jstObject, jstArray, jstString, jstNumber, jstBoolean);

  TGnvJSONData = class;
  TGnvJSONArray = class;
  TGnvJSONObject = class;
  TGnvJSONValue = class;
  TGnvJSONWriter = class;

  PGnvJSONBeautifyInfo = ^TGnvJSONBeautifyInfo;
  TGnvJSONBeautifyInfo = record
    Tabs: Integer;
    Indent: Integer;
  end;

  TGnvJSONNextCharFunc = function: WideChar of object;

  TGnvJSONData = class(TPersistent)
	private
    FDataType: TGnvJSONDataType;
  	FOverridden: Boolean;
    FOwner: TGnvJSONData;
    procedure SetItemValue(const Name, Value: Variant);
    function GetObject(const Name: Variant): TGnvJSONObject;
    function GetArray(const Name: Variant): TGnvJSONArray;
    function GetValue: Variant;
    procedure SetValue(const Value: Variant);
  protected
    procedure DetachChild(Child: TGnvJSONData); virtual;
    function DoGetItemByIndex(Index: Integer): TGnvJSONData; virtual;
    function DoGetItemByName(const Name: Variant): TGnvJSONData; virtual;
    function GetItemCount: Integer; virtual;
    function DoGetName(Index: Integer): Variant; virtual;
    procedure DoParse(InitialChar: WideChar; const NextChar: TGnvJSONNextCharFunc;
      var EndingChar: WideChar); virtual; abstract;
    procedure DoSetValue(Name, Value: Variant); virtual;
    function GetItemByIndex(Index: Integer): TGnvJSONData; inline;
    function GetName(Index: Integer): string;
    function GetItemValue(const Name: Variant): Variant;
    function GetDataType: TGnvJSONDataType;
    procedure WriteTo(Writer: TGnvJSONWriter); virtual; abstract;
    class procedure RaiseJSONException(const Msg: string); static;
    class procedure RaiseJSONParseError(const Msg: string; C: WideChar = #0); static;
  public
    class function Parse(const NextChar: TGnvJSONNextCharFunc;
      var EndingChar: WideChar): TGnvJSONData; static;
    class function ParseString(const Str: string): TGnvJSONData; static;
    destructor Destroy; override;
    procedure Detach;
    procedure Merge(Data: TGnvJSONData; RemoveArrayDuplicates: Boolean = False;
      SkipKeys: TStrings = nil); virtual; abstract;
    function ItemByName(const Name: Variant): TGnvJSONData; inline;
    function ToString: string; reintroduce;
    function ToFormattedString(InitialTabs: Integer = 0; IndentTabs: Integer = 1): string;
    property Arrays[const Name: Variant]: TGnvJSONArray read GetArray;
    property DataType: TGnvJSONDataType read GetDataType;
		property Items[Index: Integer]: TGnvJSONData read GetItemByIndex;
    property ItemCount: Integer read GetItemCount;
		property Names[Index: Integer]: string read GetName;
		property Objects[const Name: Variant]: TGnvJSONObject read GetObject;
		property Overridden: Boolean read FOverridden;
    property Owner: TGnvJSONData read FOwner;
    property Value: Variant read GetValue write SetValue;
    property Values[const Name: Variant]: Variant read GetItemValue write SetItemValue; default;
  end;

  TGnvJSONPair = record
    Name: string;
    Data: TGnvJSONData;
  end;
  TGnvJSONPairArray = array [0..MaxInt shr 5] of TGnvJSONPair;
  PGnvJSONPairArray = ^TGnvJSONPairArray;

  TGnvJSONObject = class(TGnvJSONData)
  private
    FItems: TStringList;
    FPositions: TList;
		function IndexOfData(const AData: TGnvJSONData): Integer;
	protected
		procedure AssignTo(Dest: TPersistent); override;
		procedure DetachChild(Child: TGnvJSONData); override;
		function DoGetName(Index: Integer): Variant; override;
		function DoGetItemByIndex(Index: Integer): TGnvJSONData; override;
		function DoGetItemByName(const Name: Variant): TGnvJSONData; override;
		function GetItemCount: Integer; override;
		procedure DoParse(InitialChar: WideChar; const NextChar: TGnvJSONNextCharFunc;
			var EndingChar: WideChar); override;
		procedure DoSetValue(Name, Value: Variant); override;
		procedure WriteTo(Writer: TGnvJSONWriter); override;
	public
		constructor Create;
		destructor Destroy; override;
		procedure Clear;
		procedure Add(const AName: Variant; AValue: TGnvJSONData);
		function AddObject(const Name: Variant): TGnvJSONObject;
		function AddArray(const Name: Variant): TGnvJSONArray;
		function AddValue(const Name: Variant): TGnvJSONValue; overload;
		function GetUnmappedString(Map: TStrings): string;
    function IndexOfName(const AName: string): Integer;
    procedure Merge(Data: TGnvJSONData; RemoveArrayDuplicates: Boolean = False;
      SkipKeys: TStrings = nil); override;
  end;

  TGnvJSONArray = class(TGnvJSONData)
  private
    FItems: TList;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure DetachChild(Child: TGnvJSONData); override;
    function DoGetName(Index: Integer): Variant; override;
    function DoGetItemByIndex(Index: Integer): TGnvJSONData; override;
    function DoGetItemByName(const Name: Variant): TGnvJSONData; override;
    function GetItemCount: Integer; override;
    procedure DoParse(InitialChar: WideChar; const NextChar: TGnvJSONNextCharFunc;
      var EndingChar: WideChar); override;
    procedure WriteTo(Writer: TGnvJSONWriter); override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(AItem: TGnvJSONData);
    function AddObject: TGnvJSONObject;
    function AddArray: TGnvJSONArray;
    function AddValue: TGnvJSONValue;
    procedure Merge(Data: TGnvJSONData; RemoveArrayDuplicates: Boolean = False;
      SkipKeys: TStrings = nil); override;
  end;

  TGnvJSONValue = class(TGnvJSONData)
  private
    FValue: Variant;
    function GetAsBoolean: Boolean;
    function GetAsNumber: Double;
    function GetAsString: string; inline;
    function GetIsNull: Boolean; inline;
    procedure SetAsBoolean(const AValue: Boolean); inline;
    procedure SetAsNumber(const AValue: Double); inline;
    procedure SetAsString(const AValue: string); inline;
    procedure SetIsNull(const AValue: Boolean);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure DoParse(InitialChar: WideChar; const NextChar: TGnvJSONNextCharFunc;
      var EndingChar: WideChar); override;
    procedure WriteTo(Writer: TGnvJSONWriter); override;
  public
    class function ParseString(const JSON: string): TGnvJSONValue; static;
    procedure Merge(Data: TGnvJSONData; RemoveArrayDuplicates: Boolean = False;
      SkipKeys: TStrings = nil); override;
    property AsString: string read GetAsString write SetAsString;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsNumber: Double read GetAsNumber write SetAsNumber;
    property IsNull: Boolean read GetIsNull write SetIsNull;
  end;

  TGnvJSONWriterState = (wsNone, wsObject, wsObjectValue, wsArray, wsArrayValue, wsDone);

  TGnvJSONWriter = class
  private
    FStream: TBlockWriteStream;
    FStateStack: TTightStack;
    FState: TGnvJSONWriterState;
    FOwnsStream: Boolean;
  protected
    procedure BeforeWriteImmediate; virtual;
    procedure AfterWriteImmediate;
  public
    constructor Create(AStream: TBlockWriteStream);
    destructor Destroy; override;
    procedure BeginObject; virtual;
    procedure BeginArray; virtual;
    procedure EndObject; virtual;
    procedure EndArray; virtual;
    function ToString: string; override;
    procedure WriteBoolean(B: Boolean);
    procedure WriteInteger(const n: Integer);
    procedure WriteNull;
    procedure WriteName(const AName: string); virtual;
    procedure WriteNumber(const N: Double);
    procedure WriteString(const Str: string);
    procedure WriteStrings(const Str: TStrings);
    property Stream: TBlockWriteStream read FStream write FStream;
  end;

  TGnvJSONFormattedWriter = class(TGnvJSONWriter)
  private
    FTabs: Integer;
    FIndent: Integer;
    procedure EnterIndent;
    procedure LeaveIndent;
    procedure WriteIndents;
  protected
    procedure BeforeWriteImmediate; override;
  public
    constructor Create(AStream: TBlockWriteStream; InitialTabs, IndentTabs: Integer);
    procedure BeginObject; override;
    procedure BeginArray; override;
    procedure EndObject; override;
    procedure EndArray; override;
    procedure WriteName(const AName: string); override;
  end;

  EGnvJSONException = class (Exception);
  EGnvJSONParseError = class (EGnvJSONException);

function EscapeJSString(const Str: string): string;
procedure WriteJSString(Stream: TBlockWriteStream; const Str: string);

function TryTextToFloat(const Str: PChar; var Value: Extended;
  const FormatSettings: TFormatSettings): Boolean; {$ifndef FPC} inline; {$endif}

function InterlockedIncrement(var Value: Integer): Integer;

implementation

var
  GnvJSONFormatSettings: TFormatSettings;

function SkipBlanks(CurrentChar: WideChar; const NextChar: TGnvJSONNextCharFunc): WideChar; overload; inline;
begin
  Result := CurrentChar;
  repeat
    case Result of
      #9..#13, ' ': ;
      else          Break;
    end;
    Result := NextChar;
  until False;
end;

function ParseJSONString(InitialChar: WideChar; const NextChar: TGnvJSONNextCharFunc): UnicodeString;
var
  C: WideChar;
  Stream: TBlockWriteStream;
  HexBuffer, HexCount, N, NW: Integer;
  LocalBufferPtr: PWideChar;
  LocalBuffer: array [0..59] of WideChar; // range adjusted to have a stack space of 128 for the proc
begin
  Assert(InitialChar = '"');
  Stream := nil;

  try
    LocalBufferPtr := @LocalBuffer[0];
    repeat
      C := NextChar;
      case C of
        #0..#31 :  TGnvJSONData.RaiseJSONParseError('Invalid string character %s', C);
        '"': Break;
        '\': begin
          C := NextChar;
          case C of
            '"',
            '\',
            '/': LocalBufferPtr^ := C;
            'n': LocalBufferPtr^ := #10;
            'r': LocalBufferPtr^ := #13;
            't': LocalBufferPtr^ := #9;
            'b': LocalBufferPtr^ := #8;
            'f': LocalBufferPtr^ := #12;
            'u':
            begin
              HexBuffer := 0;
              for HexCount := 1 to 4 do begin
                C := NextChar;
                case C of
                  '0'..'9': HexBuffer := (HexBuffer shl 4) + Ord(C) - Ord('0');
                  'a'..'f': HexBuffer := (HexBuffer shl 4) + Ord(C) - (Ord('a') - 10);
                  'A'..'F': HexBuffer := (HexBuffer shl 4) + Ord(C) - (Ord('A') - 10);
                  else      TGnvJSONData.RaiseJSONParseError('Invalid unicode hex character "%s"', C);
                end;
              end;
              LocalBufferPtr^ := WideChar(HexBuffer);
            end;
          else
            TGnvJSONData.RaiseJSONParseError('Invalid character "%s" after escape', C);
          end;
        end;
        else LocalBufferPtr^ := C;
      end;

      if LocalBufferPtr = @LocalBuffer[High(LocalBuffer)] then
      begin
        if Stream = nil then Stream := TBlockWriteStream.Create;
        Stream.Write(LocalBuffer[0], Length(LocalBuffer)*SizeOf(WideChar));
        LocalBufferPtr := @LocalBuffer[0];
      end
      else
        Inc(LocalBufferPtr);
    until False;

    N := (NativeInt(LocalBufferPtr) - NativeInt(@LocalBuffer[0])) shr (SizeOf(WideChar) - 1);

    if Stream <> nil then
    begin
      NW := (Stream.Size div SizeOf(WideChar));
      SetLength(Result, N + NW);
      LocalBufferPtr := PWideChar(Pointer(Result));
      Stream.StoreData(LocalBufferPtr^);
      Move(LocalBuffer[0], LocalBufferPtr[NW], N*SizeOf(WideChar));
    end
    else if N > 0 then
    begin
      SetLength(Result, N);
      LocalBufferPtr := PWideChar(Pointer(Result));
      Move(LocalBuffer[0], LocalBufferPtr^, N*SizeOf(WideChar));
    end
    else
      Result := '';
  finally
    Stream.Free;
  end;
end;

function ParseHugeJSONNumber(InitialChars: PChar; InitialCharCount: Integer;
  const NeedChar: TGnvJSONNextCharFunc; var EndingChar: WideChar): Double;
var
  Buffer: string;
  C: WideChar;
begin
  SetString(Buffer, InitialChars, InitialCharCount);

  repeat
    C := NeedChar;
    case C of
      '0'..'9',
      '-',
      '+',
      'e',
      'E',
      '.': Buffer := Buffer + Char(C);
      else
      begin
        EndingChar := C;
        Break;
      end;
    end;
  until False;

  Result := StrToFloat(Buffer, GnvJSONFormatSettings);
end;

function ParseJSONNumber(InitialChar: WideChar; const NextChar: TGnvJSONNextCharFunc;
  var EndingChar: WideChar): Double;
var
  BufferPtr: PChar;
  C: WideChar;
  ResultBuffer: Extended;
  Buffer: array [0..40] of Char;
begin
  Buffer[0] := InitialChar;
  BufferPtr := @Buffer[1];
  repeat
    C := NextChar;
    case C of
      '0'..'9', '-', '+', 'e', 'E', '.':
      begin
        BufferPtr^ := C;
        Inc(BufferPtr);
        if BufferPtr = @Buffer[High(Buffer)] then
          Exit(ParseHugeJSONNumber(@Buffer[0], Length(Buffer) - 1, NextChar, EndingChar));
      end
      else
      begin
        EndingChar := C;
        Break;
      end;
    end;
  until False;
  BufferPtr^ := #0;
  TryTextToFloat(PChar(@Buffer[0]), ResultBuffer, GnvJSONFormatSettings);
  Result := ResultBuffer;
end;

function EscapeJSString(const Str: string): string;
var
  Stream: TBlockWriteStream;
begin
  Stream := TBlockWriteStream.Create;
  WriteJSString(Stream, Str);
  Result := Stream.ToString;
  Stream.Free;
end;

procedure WriteJSString(Stream: TBlockWriteStream; const Str: string);

  procedure WriteUTF16(Stream: TBlockWriteStream; C: Integer);
  const
    IntToHex: array [0..15] of Char = (
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
  var
    Hex: array [0..5] of Char;
  begin
    Hex[0] := '\';
    Hex[1] := 'u';
    Hex[2] := IntToHex[C shr 12];
    Hex[3] := IntToHex[(C shr 8) and $F];
    Hex[4] := IntToHex[(C shr 4) and $F];
    Hex[5] := IntToHex[C and $F];
    Stream.Write(Hex[0], 6*SizeOf(Char));
  end;

const
  Quote: Char = '"';
var
  C: Char;
  P: PChar;
begin
  Stream.Write(Quote, SizeOf(Char));
  P := PChar(Pointer(Str));
  if P <> nil then
    while True do
    begin
      C := P^;
      case C of
        #0..#31:
          case C of
            #0:   Break;
            #8:   Stream.WriteString('\b');
            #9:   Stream.WriteString('\t');
            #10:  Stream.WriteString('\n');
            #12:  Stream.WriteString('\f');
            #13:  Stream.WriteString('\r');
            else  WriteUTF16(Stream, Ord(C));
          end;
        '"':      Stream.WriteString('\"');
        '\':      Stream.WriteString('\\');
        {$ifndef FPC}
//        #255..#65535: WriteUTF16(Stream, Ord(C));
        {$endif}
        else          Stream.Write(P^, SizeOf(Char));
      end;
      Inc(P);
    end;
  Stream.Write(Quote, SizeOf(Char));
end;

function TryTextToFloat(const Str: PChar; var Value: Extended; const FormatSettings: TFormatSettings): Boolean;
{$ifdef FPC}
var
  CW: Word;
begin
  CW := Get8087CW;;
  Set8087CW($133F);
  if TryStrToFloat(Str, Value, FormatSettings) then
    Result := (Value > -1.7e308) and (Value < 1.7e308);
  if not Result then
    Value := 0;
  asm fclex end;
  Set8087CW(CW);
{$else}
begin
  Result := TextToFloat(Str, Value, fvExtended, FormatSettings)
{$endif}
end;

function InterlockedIncrement(var Value: Integer): Integer;
begin
  Result := Windows.InterlockedIncrement(Value);
end;

{ TRefCountedObject }

procedure TRefCountedObject.Free;
begin
  if Self <> nil then DecRefCount;
end;

function TRefCountedObject.IncRefCount: Integer;
var
  P: PInteger;
begin
  {$ifdef FPC}
  P := @FRefCount;
  {$else}
  P := PInteger(NativeInt(Self) + InstanceSize - hfFieldSize + hfMonitorOffset);
  {$endif}
  Result := InterlockedIncrement(P^);
end;

function TRefCountedObject.DecRefCount: Integer;
var
  P: PInteger;
begin
  {$ifdef FPC}
  P := @FRefCount;
  {$else}
  P := PInteger(NativeInt(Self) + InstanceSize - hfFieldSize + hfMonitorOffset);
  {$endif}
  if P^ = 0 then
  begin
    Destroy;
    Result := 0;
  end
  else
    Result := InterlockedDecrement(P^);
end;

function TRefCountedObject.GetRefCount: Integer;
var
  P: PInteger;
begin
  {$ifdef FPC}
  P := @FRefCount;
  {$else}
  P := PInteger(NativeInt(Self) + InstanceSize - hfFieldSize + hfMonitorOffset);
  {$endif}
  Result := P^;
end;

procedure TRefCountedObject.SetRefCount(N: Integer);
var
  P: PInteger;
begin
  {$ifdef FPC}
  P := @FRefCount;
  {$else}
  P := PInteger(NativeInt(Self) + InstanceSize - hfFieldSize + hfMonitorOffset);
  {$endif}
  P^ := N;
end;

{ TBlockWriteStream }

constructor TBlockWriteStream.Create;
begin
  inherited Create;
  AllocateCurrentBlock;
end;

destructor TBlockWriteStream.Destroy;
begin
  inherited;
  FreeBlocks;
end;

procedure TBlockWriteStream.FreeBlocks;
var
  Block, Next: PPointerArray;
begin
  Block := FFirstBlock;
  while Block <> nil do
  begin
    Next := PPointerArray(Block[0]);
    FreeMem(Block);
    Block := Next;
  end;
  FCurrentBlock := nil;
  FFirstBlock := nil;
  FTotalSize := 0;
end;

procedure TBlockWriteStream.AllocateCurrentBlock;
var
  NewBlock: PPointerArray;
begin
  NewBlock := GetMemory(cBlockWriteStreamBlockSize + 2*SizeOf(Pointer));
  NewBlock[0] := nil;
  FBlockRemaining := @NewBlock[1];
  FBlockRemaining^ := 0;

  if FCurrentBlock <> nil then
    FCurrentBlock[0] := NewBlock
  else
    FFirstBlock := NewBlock;

  FCurrentBlock := NewBlock;
end;

procedure TBlockWriteStream.Clear;
begin
  FreeBlocks;
  AllocateCurrentBlock;
end;

procedure TBlockWriteStream.StoreData(var Buffer);
var
  N: Integer;
  Block: PPointerArray;
  Dest: PByteArray;
begin
  Dest := @Buffer;
  Block := FFirstBlock;
  while Block <> nil do
  begin
    N := PInteger(@Block[1])^;
    if N > 0 then
    begin
      Move(Block[2], Dest^, N);
      Dest := @Dest[N];
    end;
    Block := Block[0];
  end;
end;

procedure TBlockWriteStream.StoreData(Stream: TStream);
var
  N: Integer;
  Block: PPointerArray;
begin
  Block := FFirstBlock;
  while Block <> nil do
  begin
    N := PInteger(@Block[1])^;
    Stream.Write(Block[2], N);
    Block := Block[0];
  end;
end;

function TBlockWriteStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  if (Origin = soFromCurrent) and (Offset = 0) then
    Result := FTotalSize
  else
    raise EStreamError.Create('not allowed');
end;

function TBlockWriteStream.Read(var Buffer; Count: Longint): Longint;
begin
  raise EStreamError.Create('not allowed');
end;

function TBlockWriteStream.Write(const Buffer; Count: Longint): Longint;
var
  NewBlock: PPointerArray;
  Dest, Source: PByteArray;
  Fraction: Integer;
begin
  Result := Count;
  if Count <= 0 then Exit;

  Inc(FTotalSize, Count);
  Source := @Buffer;

  Fraction := cBlockWriteStreamBlockSize-FBlockRemaining^;
  if Count > Fraction then
  begin
    // Does not fit in current block
    if FBlockRemaining^ > 0 then
    begin
      // Current block contains some data, write fraction, allocate new block
      Move(Source^, PByteArray(@FCurrentBlock[2])[FBlockRemaining^], Fraction);
      Dec(Count, Fraction);
      Source := @Source[Fraction];
      FBlockRemaining^ := cBlockWriteStreamBlockSize;
      AllocateCurrentBlock;
    end;

    if Count > cBlockWriteStreamBlockSize div 2 then
    begin
      // Large amount still to be written, insert specific block
      NewBlock := GetMemory(Count + 2*SizeOf(Pointer));
      NewBlock[0] := FCurrentBlock;
      PInteger(@NewBlock[1])^ := Count;
      Move(Source^, NewBlock[2], Count);
      FCurrentBlock[0] := NewBlock;
      FCurrentBlock := NewBlock;
      AllocateCurrentBlock;
      Exit;
    end;
  end;

  // If we reach here, everything fits in current block
  Dest := @PByteArray(@FCurrentBlock[2])[FBlockRemaining^];
  case Count of
    1:    Dest[0] := Source[0];
    2:    PWord(Dest)^ := PWord(Source)^;
    else  Move(Source^, Dest^, Count);
  end;
  Inc(FBlockRemaining^, Count);
end;

{$ifdef FPC}
procedure TBlockWriteStream.WriteString(const Utf8String: string); overload;
begin
  WriteString(UTF8Decode(Utf8String));
end;
{$endif}

procedure TBlockWriteStream.WriteString(const Utf16String: UnicodeString);
var
  StringCracker: NativeInt;
begin
  {$ifdef FPC}
  if Utf16String <> '' then
    Write(Utf16String[1], Length(Utf16String)*SizeOf(WideChar));
  {$else}
  StringCracker := NativeInt(Utf16String);
  if StringCracker <> 0 then
    Write(Pointer(StringCracker)^, PInteger(StringCracker - SizeOf(Integer))^*SizeOf(WideChar));
  {$endif}
end;

procedure TBlockWriteStream.WriteChar(utf16Char: WideChar);
begin
  Write(utf16Char, SizeOf(WideChar));
end;

function TBlockWriteStream.ToString: string;
{$ifdef FPC}
var
  Buffer: UnicodeString;
begin
  if FTotalSize > 0 then
  begin
    Assert((FTotalSize and 1) = 0);
    SetLength(Buffer, FTotalSize div SizeOf(WideChar));
    StoreData(Buffer[1]);
    Result := UTF8Encode(Buffer);
  end
  else
    Result := '';
{$else}
begin
  if FTotalSize > 0 then
  begin
    Assert((FTotalSize and 1) = 0);
    SetLength(Result, FTotalSize div SizeOf(WideChar));
    StoreData(Result[1]);
  end
  else
    Result := '';
  {$endif}
end;

function TBlockWriteStream.GetSize: Int64;
begin
  Result := FTotalSize;
end;

procedure TBlockWriteStream.WriteSubString(const Utf16String: UnicodeString; StartPos: Integer);
begin
  WriteSubString(Utf16String, StartPos, Length(Utf16String) - StartPos + 1);
end;

procedure TBlockWriteStream.WriteSubString(const Utf16String: UnicodeString; StartPos, Length: Integer);
var
  P, N: Integer;
begin
  Assert(StartPos >= 1);
  if Length <= 0 then Exit;
  N := System.Length(Utf16String);
  if StartPos > N then Exit;
  P := StartPos + Length - 1;
  if P > N then P := N;
  Length := P - StartPos + 1;
  if Length > 0 then
    Write(Utf16String[StartPos], Length*SizeOf(WideChar));
end;

{ TTightStack }

procedure TTightStack.Grow;
begin
  FCapacity := FCapacity + 8 + FCapacity shr 1;
  ReallocMem(FList, FCapacity*SizeOf(Pointer));
end;

procedure TTightStack.Push(item: TRefCountedObject);
begin
  if FCount = FCapacity then Grow;
  FList[FCount] := item;
  Inc(FCount);
end;

function TTightStack.Peek: TRefCountedObject;
begin
  Result := FList[FCount - 1];
end;

procedure TTightStack.Pop;
begin
  Dec(FCount);
end;

procedure TTightStack.Clear;
begin
  FCount := 0;
end;

procedure TTightStack.Clean;
begin
  while Count > 0 do
  begin
    TRefCountedObject(Peek).Free;
    Pop;
  end;
end;

procedure TTightStack.Free;
begin
  FCount := 0;
  FCapacity := 0;
  FreeMem(FList);
  FList := nil;
end;

{ TStringReader }

constructor TStringReader.Create(const AStr: string);
begin
  {$ifdef FPC}
  FStr := UTF8Decode(AStr);
  {$else}
  FStr := AStr;
  {$endif}
  FPointer := PWideChar(FStr);
  FLineStart := FPointer;
end;

function TStringReader.NextChar: WideChar;
var
  P: PWideChar;
begin
  P := FPointer;
  Inc(FPointer);
  if P^ = #10 then
  begin
    FLineStart := P;
    Inc(FLine);
  end;
  Result := P^;
end;

function TStringReader.Location: string;
begin
  Result := Format('line %d, col %d (offset %d)',
    [FLine + 1,
    (NativeInt(FPointer) - NativeInt(FLineStart)) div SizeOf(Char) + 1,
    (NativeInt(FPointer) - NativeInt(PChar(FStr))) div SizeOf(Char) + 1]);
end;

{ TGnvJSONData }

destructor TGnvJSONData.Destroy;
begin
  if FOwner <> nil then Detach;
  inherited;
end;

class function TGnvJSONData.Parse(const NextChar: TGnvJSONNextCharFunc; var EndingChar: WideChar): TGnvJSONData;
var
  C: WideChar;
begin
  Result := nil;

  if not Assigned(NextChar) then Exit;

  repeat
    C := NextChar;
    case C of
      #0:     Break;
      #9..#13,
      ' ':    ;
      '{':    Result := TGnvJSONObject.Create;
      '[':    Result := TGnvJSONArray.Create;
      '0'..'9',
      '"',
      '-',
      't',
      'f',
      'n':    Result := TGnvJSONValue.Create;
      ']',
      '}':
      begin
        // Empty array or object
        EndingChar := C;
        Exit(nil);
      end;
      else    RaiseJSONParseError('Invalid value start character "%s"', C);
    end;
  until Result <> nil;

  if Result <> nil then
  try
    Result.DoParse(C, NextChar, EndingChar);
  except
    Result.Free;
    raise;
  end;
end;

class function TGnvJSONData.ParseString(const Str: string): TGnvJSONData;
var
  C: WideChar;
  Reader: TStringReader;
begin
  Result := nil;
  Reader := TStringReader.Create(Str);
  try
    try
      Result := TGnvJSONData.Parse(Reader.NextChar, C);
    except
      on E: EGnvJSONParseError do
        raise EGnvJSONParseError.CreateFmt('%s, at %s',
          [E.Message, Reader.Location]);
      else
        raise;
    end;
  finally
    Reader.Free;
  end;
end;

function TGnvJSONData.ToString: string;
var
  Writer: TGnvJSONWriter;
begin
  if Self = nil then Exit('');
  Writer := TGnvJSONWriter.Create(nil);
  try
    WriteTo(Writer);
    Result := Writer.Stream.ToString;
  finally
    Writer.Free;
  end;
end;

function TGnvJSONData.ToFormattedString(InitialTabs, IndentTabs: Integer): string;
var
  Writer: TGnvJSONFormattedWriter;
begin
  if Self = nil then Exit('');
  Writer := TGnvJSONFormattedWriter.Create(nil, InitialTabs, IndentTabs);
  try
    WriteTo(Writer);
    Result := Writer.Stream.ToString;
  finally
    Writer.Free;
  end;
end;

procedure TGnvJSONData.Detach;
begin
  if FOwner <> nil then
  begin
    FOwner.DetachChild(Self);
    FOwner := nil;
  end;
end;

function TGnvJSONData.GetItemCount: Integer;
begin
  Result := 0;
end;

function TGnvJSONData.GetValue: Variant;
begin
  if FDataType in [jstObject, jstArray] then
    RaiseJSONException('Not a value');
  Result := TGnvJSONValue(Self).FValue;
end;

function TGnvJSONData.GetItemValue(const Name: Variant): Variant;
var
  Item: TGnvJSONData;
begin
  Result := Null;
  Item := nil;

  if Assigned(Self) then
  begin
    if VarIsOrdinal(Name) then
      Item := GetItemByIndex(Name)
    else
      Item := ItemByName(Name);
  end;

  if Assigned(Item) and (Item is TGnvJSONValue) then
    Result := (Item as TGnvJSONValue).FValue;
end;

procedure TGnvJSONData.DetachChild(Child: TGnvJSONData);
begin
  Assert(False);
end;

function TGnvJSONData.GetArray(const Name: Variant): TGnvJSONArray;
var
  Item: TGnvJSONData;
begin
  Result := nil;
  Item := nil;

  if Assigned(Self) then
  begin
    if VarIsOrdinal(Name) then
      Item := GetItemByIndex(Name)
    else
      Item := ItemByName(Name);
  end;

  if Assigned(Item) and (Item.FDataType = jstArray) then
    Result := Item as TGnvJSONArray;
end;

function TGnvJSONData.GetDataType: TGnvJSONDataType;
begin
  Result := jstUndefined;
  if Assigned(Self) then
    Result := FDataType;
end;

function TGnvJSONData.GetName(Index: Integer): string;
begin
  Result := '';
  if Assigned(Self) then
    Result := DoGetName(Index);
end;

function TGnvJSONData.GetObject(const Name: Variant): TGnvJSONObject;
var
  Item: TGnvJSONData;
begin
  Result := nil;
  Item := nil;

  if Assigned(Self) then
  begin
    if VarIsOrdinal(Name) then
      Item := GetItemByIndex(Name)
    else
      Item := ItemByName(Name);
  end;

  if Assigned(Item) and (Item is TGnvJSONObject) then
    Result := Item as TGnvJSONObject;
end;

function TGnvJSONData.DoGetName(Index: Integer): Variant;
begin
  Result := '';
end;

procedure TGnvJSONData.DoSetValue(Name, Value: Variant);
begin
  // Abstract
end;

function TGnvJSONData.GetItemByIndex(Index: Integer): TGnvJSONData;
begin
  Result := nil;
  if Assigned(Self) then
    Result := DoGetItemByIndex(Index);
end;

function TGnvJSONData.DoGetItemByIndex(Index: Integer): TGnvJSONData;
begin
  Result := nil;
end;

function TGnvJSONData.ItemByName(const Name: Variant): TGnvJSONData;
begin
  Result := nil;
  if Assigned(Self) then
    Result := DoGetItemByName(Name);
end;

function TGnvJSONData.DoGetItemByName(const Name: Variant): TGnvJSONData;
begin
  Result := nil;
end;

class procedure TGnvJSONData.RaiseJSONException(const Msg: string);
begin
  raise EGnvJSONException.Create(Msg);
end;

class procedure TGnvJSONData.RaiseJSONParseError(const Msg: string; C: WideChar = #0);
begin
  if C > #31 then
    raise EGnvJSONParseError.CreateFmt(Msg, [IntToStr(Ord(C))])
  else
    raise EGnvJSONParseError.CreateFmt(Msg, ['U+' + IntToHex(Ord(C), 4)])
end;

procedure TGnvJSONData.SetItemValue(const Name, Value: Variant);
begin
  if Assigned(Self) then DoSetValue(Name, Value);
end;

procedure TGnvJSONData.SetValue(const Value: Variant);
begin
  if FDataType in [jstObject, jstArray] then
    RaiseJSONException('Not a value');

  case VarType(Value) of
    varBoolean:   FDataType := jstBoolean;
    varDouble,
    varInteger:   FDataType := jstNumber;
    varUString:   FDataType := jstString;
  end;
  (Self as TGnvJSONValue).FValue := Value;
end;

{ TGnvJSONObject }

constructor TGnvJSONObject.Create;
begin
  FDataType := jstObject;

  FItems := TStringList.Create(False);
  FItems.Duplicates := dupError;
  FItems.CaseSensitive := True;
  FItems.Sorted := True;

  FPositions := TList.Create;
end;

destructor TGnvJSONObject.Destroy;
begin
  Clear;
  FItems.Free;
  FPositions.Free;

  inherited;
end;

procedure TGnvJSONObject.WriteTo(Writer: TGnvJSONWriter);
var
  I: Integer;
begin
  Writer.BeginObject;
  for I := 0 to ItemCount - 1 do
  begin
    Writer.WriteName(GetName(I));
		TGnvJSONData(FPositions[I]).WriteTo(Writer);
  end;
  Writer.EndObject;
end;

function TGnvJSONObject.GetItemCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TGnvJSONObject.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    (FItems.Objects[I] as TGnvJSONData).FOwner := nil;
    FItems.Objects[I].Free;
  end;
  FItems.Clear;
  FPositions.Clear;
end;

function TGnvJSONObject.GetUnmappedString(Map: TStrings): string;
var
	I, Unmapped: Integer;
	Writer: TGnvJSONWriter;
  Name: string;
begin
	if Self = nil then Exit('');
	Writer := TGnvJSONWriter.Create(nil);
	try
  	Unmapped := 0;
		for I := 0 to GetItemCount - 1 do
    begin
      Name := GetName(I);
      if Map.IndexOf(Name) = -1 then
			begin
				if Unmapped = 0 then Writer.BeginObject;
        Writer.WriteName(Name);
        GetItemByIndex(I).WriteTo(Writer);
				Inc(Unmapped);
			end;
    end;
		if Unmapped > 0 then Writer.EndObject;
		Result := Writer.Stream.ToString;
	finally
		Writer.Free;
	end;
end;

procedure TGnvJSONObject.Add(const AName: Variant; AValue: TGnvJSONData);
var
  Index, PosIndex: Integer;
begin
  Assert(AValue.Owner = nil);
  AValue.FOwner := Self;
  try
    FItems.AddObject(AName, AValue);
    FPositions.Add(AValue);
  except
    Index := FItems.IndexOf(AName);
    PosIndex := FPositions.IndexOf(FItems.Objects[Index]);

    (FItems.Objects[Index] as TGnvJSONData).FOwner := nil;
    FItems.Objects[Index].Free;
    FItems.Objects[Index] := AValue;
    FPositions[PosIndex] := AValue;
  end;
end;

function TGnvJSONObject.AddObject(const Name: Variant): TGnvJSONObject;
begin
  Result := TGnvJSONObject.Create;
  Add(Name, Result);
end;

function TGnvJSONObject.AddArray(const Name: Variant): TGnvJSONArray;
begin
  Result := TGnvJSONArray.Create;
  Add(Name, Result);
end;

function TGnvJSONObject.AddValue(const Name: Variant): TGnvJSONValue;
begin
  Result := TGnvJSONValue.Create;
  Add(Name, Result);
end;

procedure TGnvJSONObject.AssignTo(Dest: TPersistent);
var
  Obj: TGnvJSONObject;
  I: Integer;
  NewItem: TGnvJSONData;
begin
  Obj := nil;
  if Dest is TGnvJSONObject then
    Obj := Dest as TGnvJSONObject;

  if Assigned(Obj) then
  begin
    Obj.Clear;
    for I := 0 to FItems.Count - 1 do
    begin
      case (FItems.Objects[I] as TGnvJSONData).FDataType of
        jstObject:  NewItem := Obj.AddObject(FItems[I]);
        jstArray:   NewItem := Obj.AddArray(FItems[I]);
        else        NewItem := Obj.AddValue(FItems[I]);
      end;
      NewItem.Assign(FItems.Objects[I] as TGnvJSONData);
    end;
  end
  else
    inherited;
end;

procedure TGnvJSONObject.DetachChild(Child: TGnvJSONData);
var
  I: Integer;
begin
  Assert(Child.Owner = Self);
  I := IndexOfData(Child);
  FPositions.Delete(I);
  FItems.Delete(FItems.IndexOfObject(Child));
end;

function TGnvJSONObject.DoGetName(Index: Integer): Variant;
var
  Obj: TObject;
begin
  Result := '';
  if Index < FItems.Count then
  begin
    Obj := TObject(FPositions[Index]);
    Result := FItems[FItems.IndexOfObject(Obj)];
  end;
end;

function TGnvJSONObject.DoGetItemByIndex(Index: Integer): TGnvJSONData;
begin
  Result := nil;
  if Index < FItems.Count then
    Result := TGnvJSONData(FPositions[Index]);
end;

function TGnvJSONObject.DoGetItemByName(const Name: Variant): TGnvJSONData;
var
  Index: Integer;
begin
  Result := nil;
  Index := FItems.IndexOf(Name);
  if Index > -1 then
    Result := FItems.Objects[Index] as TGnvJSONData;
end;

procedure TGnvJSONObject.DoParse(InitialChar: WideChar; const NextChar: TGnvJSONNextCharFunc; var EndingChar: WideChar);
var
  C: WideChar;
  Name: string;
  Value: TGnvJSONData;
begin
  Assert(InitialChar = '{');
  repeat
    C := SkipBlanks(NextChar, NextChar);
    if C <> '"' then
    begin
      if FItems.Count = 0 then Break;
      RaiseJSONParseError('Invalid object pair name start character "%s"', C)
    end;

    {$ifdef FPC}
    Name := UTF8Encode(ParseJSONString(C, NextChar));
    {$else}
    Name := ParseJSONString(C, NextChar);
    {$endif}
    C := SkipBlanks(NextChar, NextChar);
    if C <> ':' then
      RaiseJSONParseError('Invalid object pair name separator character "%s"', C);

    Value := TGnvJSONData.Parse(NextChar, C);
    Add(Name, Value);

    C := SkipBlanks(C, NextChar);
  until C <> ',';

  if C <> '}' then
    RaiseJSONParseError('Invalid object termination character "%s"', C);

  EndingChar := ' ';
end;

procedure TGnvJSONObject.DoSetValue(Name, Value: Variant);
var
  PosIndex, Index: Integer;
  Item: TGnvJSONValue;
begin
  Index := FItems.IndexOf(Name);
  if VarIsNull(Value) then
  begin
    if Index > -1 then
    begin
      FPositions.Remove(FItems.Objects[Index]);

      (FItems.Objects[Index] as TGnvJSONData).FOwner := nil;
      FItems.Objects[Index].Free;
      FItems.Delete(Index);
    end;
  end
  else
  begin
    if Index > -1 then
    begin
      if not (FItems.Objects[Index] is TGnvJSONValue) then
      begin
        PosIndex := FPositions.IndexOf(FItems.Objects[Index]);

        (FItems.Objects[Index] as TGnvJSONData).FOwner := nil;
        FItems.Objects[Index].Free;
        FItems.Objects[Index] := TGnvJSONValue.Create;
        FPositions[PosIndex] := FItems.Objects[Index];
      end;
      Item := FItems.Objects[Index] as TGnvJSONValue;
    end
    else
      Item := AddValue(Name);

    case VarType(Value) of
      varBoolean:   Item.FDataType := jstBoolean;
      varDouble,
  		varInt64,
  		varUINT64,
      varInteger:   Item.FDataType := jstNumber;
      varString,
      varUString:   Item.FDataType := jstString;
    end;
    Item.FValue := Value;
  end;
end;

function TGnvJSONObject.IndexOfName(const AName: string): Integer;
var
  Index: Integer;
begin
  Result := -1;
  Index := FItems.IndexOf(AName);
  if Index > - 1 then
    Result := FPositions.IndexOf(FItems.Objects[Index]);
end;

procedure TGnvJSONObject.Merge(Data: TGnvJSONData;
  RemoveArrayDuplicates: Boolean = False; SkipKeys: TStrings = nil);
var
  I: Integer;
	Item: TGnvJSONData;
  Obj: TGnvJSONObject;
begin
  Obj := nil;
  if Data is TGnvJSONObject then
    Obj := Data as TGnvJSONObject;

  if Assigned(Obj) then
    for I := 0 to Obj.GetItemCount - 1 do
      if not Assigned(SkipKeys) or
        (Assigned(SkipKeys) and (SkipKeys.IndexOf(Obj.GetName(I)) = -1)) then
      begin
        Item := ItemByName(Obj.GetName(I));
        if Assigned(Item) then
          Item.Merge(Obj.GetItemByIndex(I), RemoveArrayDuplicates)
        else
        begin
          case Obj.GetItemByIndex(I).FDataType of
            jstObject:  Item := AddObject(Obj.GetName(I));
            jstArray:   Item := AddArray(Obj.GetName(I));
            else        Item := AddValue(Obj.GetName(I));
          end;
          Item.Assign(Obj.GetItemByIndex(I));
        end;
      end;
end;

function TGnvJSONObject.IndexOfData(const AData: TGnvJSONData): Integer;
begin
  Result := FPositions.IndexOf(AData);
end;

{ TGnvJSONArray }

constructor TGnvJSONArray.Create;
begin
  FDataType := jstArray;
  FItems := TList.Create;
end;

destructor TGnvJSONArray.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

procedure TGnvJSONArray.WriteTo(Writer: TGnvJSONWriter);
var
  I: Integer;
begin
  Writer.BeginArray;
  for I := 0 to FItems.Count - 1 do
    GetItemByIndex(I).WriteTo(Writer);
  Writer.EndArray;
end;

function TGnvJSONArray.GetItemCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TGnvJSONArray.Merge(Data: TGnvJSONData;
  RemoveArrayDuplicates: Boolean = False; SkipKeys: TStrings = nil);
begin
  Assign(Data);
end;

procedure TGnvJSONArray.DetachChild(Child: TGnvJSONData);
begin
  Assert(Child.Owner = Self);
  FItems.Remove(Child);
end;

procedure TGnvJSONArray.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    TGnvJSONData(FItems[I]).FOwner := nil;
    TGnvJSONData(FItems[I]).Free;
  end;
  FItems.Clear;
end;

procedure TGnvJSONArray.Add(AItem: TGnvJSONData);
begin
  Assert(AItem.Owner = nil);
  AItem.FOwner := Self;
  FItems.Add(AItem);
end;

function TGnvJSONArray.AddObject: TGnvJSONObject;
begin
  Result := TGnvJSONObject.Create;
  Add(Result);
end;

function TGnvJSONArray.AddArray: TGnvJSONArray;
begin
  Result := TGnvJSONArray.Create;
  Add(Result);
end;

function TGnvJSONArray.AddValue: TGnvJSONValue;
begin
  Result := TGnvJSONValue.Create;
  Add(Result);
end;

procedure TGnvJSONArray.AssignTo(Dest: TPersistent);
var
  Obj: TGnvJSONArray;
  I: Integer;
  NewItem: TGnvJSONData;
begin
  Obj := nil;
  if Dest is TGnvJSONArray then
    Obj := Dest as TGnvJSONArray;

  if Assigned(Obj) then
  begin
    Obj.Clear;
    for I := 0 to GetItemCount - 1 do
    begin
      case GetItemByIndex(I).FDataType of
        jstObject:  NewItem := Obj.AddObject;
        jstArray:   NewItem := Obj.AddArray;
        else        NewItem := Obj.AddValue;
      end;
      NewItem.Assign(GetItemByIndex(I));
    end;
  end
  else
    inherited;
end;

function TGnvJSONArray.DoGetName(Index: Integer): Variant;
begin
  Result := '';
  if Cardinal(Index) < Cardinal(FItems.Count) then
    Result := Index;
end;

function TGnvJSONArray.DoGetItemByIndex(Index: Integer): TGnvJSONData;
begin
  if Cardinal(Index) < Cardinal(FItems.Count) then
    Result := TGnvJSONData(FItems[Index])
  else
    Result := nil;
end;

function TGnvJSONArray.DoGetItemByName(const Name: Variant): TGnvJSONData;
var
  I: Integer;
begin
  I := StrToIntDef(VarToStr(Name), -1);
  Result := DoGetItemByIndex(I);
end;

procedure TGnvJSONArray.DoParse(InitialChar: WideChar;
  const NextChar: TGnvJSONNextCharFunc; var EndingChar: WideChar);
var
  Ñ: WideChar;
  NewItem: TGnvJSONData;
begin
  Assert(InitialChar = '[');
  repeat
    NewItem := TGnvJSONData.Parse(NextChar, Ñ);
    if NewItem = nil then Break;
    Add(NewItem);
    Ñ := SkipBlanks(Ñ, NextChar);
  until Ñ <> ',';
  if Ñ <> ']' then
    RaiseJSONParseError('Invalid array termination character "%s"', Ñ);
  EndingChar := ' ';
end;

{ TGnvJSONValue }

function TGnvJSONValue.GetAsString: string;
begin
  Result := '';
  if Assigned(Self) then
    Result := FValue;
end;

procedure TGnvJSONValue.SetAsString(const AValue: string);
begin
  FValue := AValue;
  FDataType := jstString;
end;

function TGnvJSONValue.GetIsNull: Boolean;
begin
  Result := True;
  if Assigned(Self) then
    Result := FDataType = jstNull;
end;

procedure TGnvJSONValue.Merge(Data: TGnvJSONData;
  RemoveArrayDuplicates: Boolean = False; SkipKeys: TStrings = nil);
begin
  Assign(Data);
end;

procedure TGnvJSONValue.SetIsNull(const AValue: Boolean);
begin
  if AValue = GetIsNull then Exit;

  if AValue then
  begin
    VarClear(FValue);
    FDataType := jstNull;
  end
  else
    SetAsString('');
end;

function TGnvJSONValue.GetAsBoolean: Boolean;
begin
  if not Assigned(Self) then Exit(False);
  case VarType(FValue) of
    varEmpty:   Result := False;
    varBoolean: Result := FValue;
    varDouble:  Result := FValue <> 0;
    else        Result := FValue = 'true';
  end;
end;

procedure TGnvJSONValue.SetAsBoolean(const AValue: Boolean);
begin
  FValue := AValue;
  FDataType := jstBoolean;
end;

function TGnvJSONValue.GetAsNumber: Double;
begin
  if not Assigned(Self) then Exit(0);

  case VarType(FValue) of
    varEmpty:   Result := 0;
    varBoolean: if FValue then Result := -1 else Result := 0;
    varDouble:  Result := FValue;
    else        Result := StrToFloat(FValue);
  end;
end;

procedure TGnvJSONValue.SetAsNumber(const AValue: Double);
begin
  FValue := AValue;
  FDataType := jstNumber;
end;

procedure TGnvJSONValue.AssignTo(Dest: TPersistent);
begin
  if Dest is TGnvJSONValue then
  begin
    (Dest as TGnvJSONValue).FDataType := FDataType;
    (Dest as TGnvJSONValue).FValue := FValue;
  end
  else
    inherited;
end;

procedure TGnvJSONValue.DoParse(InitialChar: WideChar; const NextChar: TGnvJSONNextCharFunc;
  var EndingChar: WideChar);
begin
  EndingChar := ' ';
  case InitialChar of
    '"' :
      {$ifdef FPC}
      SetAsString(UTF8Encode(ParseJSONString(InitialChar, NextChar)));
      {$else}
      SetAsString(ParseJSONString(InitialChar, NextChar));
      {$endif}
    '0'..'9',
    '-':
      SetAsNumber(ParseJSONNumber(InitialChar, NextChar, EndingChar));
    't' :
      if (NextChar = 'r') and (NextChar = 'u') and (NextChar = 'e') then
        SetAsBoolean(True)
      else
        RaiseJSONParseError('Invalid immediate value');
    'f' :
      if (NextChar = 'a') and (NextChar = 'l') and (NextChar = 's') and (NextChar = 'e') then
        SetAsBoolean(False)
      else
        RaiseJSONParseError('Invalid immediate value');
    'n' :
      if (NextChar = 'u') and (NextChar = 'l') and (NextChar = 'l') then
        SetIsNull(True)
      else
        RaiseJSONParseError('Invalid immediate value');
    else
      RaiseJSONParseError('Invalid immediate value');
  end;
end;

procedure TGnvJSONValue.WriteTo(Writer: TGnvJSONWriter);
begin
  case VarType(FValue) of
    varEmpty:   Writer.WriteNull;
    varBoolean: Writer.WriteBoolean(TVarData(FValue).VBoolean);
		varDouble:  Writer.WriteNumber(TVarData(FValue).VDouble);
		varInt64:   Writer.WriteNumber(TVarData(FValue).VInt64);
		varUInt64:  Writer.WriteNumber(TVarData(FValue).VUInt64);
    varInteger: Writer.WriteNumber(TVarData(FValue).VInteger);
    varString:  Writer.WriteString(string(TVarData(FValue).VString));
    varUString:
    {$ifdef FPC}
      Writer.WriteString(string(TVarData(FValue).VString));
    {$else}
      Writer.WriteString(string(TVarData(FValue).VUString));
    {$endif}
    else
      Assert(False, 'Unsupported variant type: ' + VarTypeAsText(VarType(FValue)));
  end;
end;

class function TGnvJSONValue.ParseString(const JSON: string): TGnvJSONValue;
var
  Value: TGnvJSONData;
begin
  Value := TGnvJSONData.ParseString(JSON);
  if Value is TGnvJSONValue then
    Result := TGnvJSONValue(Value)
  else
  begin
    Value.Free;
    Result := nil;
  end;
end;

{ TGnvJSONWriter }

constructor TGnvJSONWriter.Create(AStream: TBlockWriteStream);
begin
  inherited Create;
  FOwnsStream := (AStream = nil);
  if FOwnsStream then
    FStream := TBlockWriteStream.Create
  else FStream := AStream;
end;

destructor TGnvJSONWriter.Destroy;
begin
  Assert(FState in [wsNone, wsDone]);
  Assert(FStateStack.Count = 0);
  if FOwnsStream then
    FStream.Free;
  FStateStack.Free;
  inherited;
end;

procedure TGnvJSONWriter.BeginObject;
begin
  Assert(FState in [wsNone, wsObjectValue, wsArray, wsArrayValue]);
  FStateStack.Push(TRefCountedObject(FState));
  BeforeWriteImmediate;
  FState := wsObject;
  FStream.WriteChar('{');
end;

procedure TGnvJSONWriter.EndObject;
begin
  Assert(FState in [wsObject, wsObjectValue]);
  Assert(FStateStack.Count > 0);
  FState := TGnvJSONWriterState(FStateStack.Peek);
  FStateStack.Pop;
  FStream.WriteChar('}');
  AfterWriteImmediate;
end;

procedure TGnvJSONWriter.BeginArray;
begin
  Assert(FState in [wsNone, wsObjectValue, wsArray, wsArrayValue]);
  FStateStack.Push(TRefCountedObject(FState));
  BeforeWriteImmediate;
  FState := wsArray;
  FStream.WriteChar('[');
end;

procedure TGnvJSONWriter.EndArray;
begin
  Assert(FState in [wsArray, wsArrayValue]);
  Assert(FStateStack.Count > 0);
  FState := TGnvJSONWriterState(FStateStack.Peek);
  FStateStack.Pop;
  FStream.WriteChar(']');
  AfterWriteImmediate;
end;

procedure TGnvJSONWriter.WriteName(const AName: string);
begin
  case FState of
    wsObject:       ;
    wsObjectValue:  FStream.WriteChar(',');
    else            Assert(False);
  end;
  WriteString(AName);
  FStream.WriteChar(':');
  FState := wsObjectValue;
end;

procedure TGnvJSONWriter.WriteString(const Str: string);
begin
  BeforeWriteImmediate;
  WriteJSString(FStream, Str);
  AfterWriteImmediate;
end;

procedure TGnvJSONWriter.WriteNumber(const N: Double);
begin
  BeforeWriteImmediate;
  FStream.WriteString(FloatToStr(N, GnvJSONFormatSettings));
  AfterWriteImmediate;
end;

procedure TGnvJSONWriter.WriteInteger(const n: Integer);
begin
  BeforeWriteImmediate;
  FStream.WriteString(IntToStr(n));
  AfterWriteImmediate;
end;

procedure TGnvJSONWriter.WriteBoolean(B: Boolean);
begin
  BeforeWriteImmediate;
  if B then
    FStream.WriteString('true')
  else
    FStream.WriteString('false');
  AfterWriteImmediate;
end;

procedure TGnvJSONWriter.WriteNull;
begin
  BeforeWriteImmediate;
  FStream.WriteString('null');
  AfterWriteImmediate;
end;

procedure TGnvJSONWriter.WriteStrings(const Str: TStrings);
var
  I: Integer;
begin
  BeginArray;
  for I := 0 to Str.Count - 1 do
    WriteString(Str[I]);
  EndArray;
end;

function TGnvJSONWriter.ToString: string;
begin
  Result := FStream.ToString;
end;

procedure TGnvJSONWriter.BeforeWriteImmediate;
begin
  case FState of
    wsArrayValue: FStream.WriteChar(',');
    wsDone:       Assert(False);
  end;
end;

procedure TGnvJSONWriter.AfterWriteImmediate;
begin
  case FState of
    wsNone:   FState := wsDone;
    wsArray:  FState := wsArrayValue;
  end;
end;

{ TGnvJSONFormattedWriter }

constructor TGnvJSONFormattedWriter.Create(AStream: TBlockWriteStream; InitialTabs, IndentTabs: Integer);
begin
  inherited Create(AStream);
  FTabs := InitialTabs;
  FIndent := IndentTabs;
end;

procedure TGnvJSONFormattedWriter.WriteIndents;
begin
  FStream.WriteString(StringOfChar(#9, FTabs));
end;

procedure TGnvJSONFormattedWriter.EnterIndent;
begin
  Inc(FTabs, FIndent);
end;

procedure TGnvJSONFormattedWriter.LeaveIndent;
begin
  Dec(FTabs, FIndent);
  if FState in [wsObjectValue, wsArrayValue] then
  begin
    FStream.WriteString(#13#10);
    WriteIndents;
  end
  else
    FStream.WriteChar(' ');
end;

procedure TGnvJSONFormattedWriter.BeforeWriteImmediate;
begin
  inherited;
  case FState of
    wsArray, wsArrayValue:
    begin
      FStream.WriteString(#13#10);
      WriteIndents;
    end;
  end;
end;

procedure TGnvJSONFormattedWriter.BeginObject;
begin
  inherited;
  EnterIndent;
end;

procedure TGnvJSONFormattedWriter.EndObject;
begin
  LeaveIndent;
  inherited;
end;

procedure TGnvJSONFormattedWriter.BeginArray;
begin
  inherited;
  EnterIndent;
end;

procedure TGnvJSONFormattedWriter.EndArray;
begin
  LeaveIndent;
  inherited;
end;

procedure TGnvJSONFormattedWriter.WriteName(const AName: string);
begin
  case FState of
    wsObject:       FStream.WriteString(#13#10);
    wsObjectValue:  FStream.WriteString(','#13#10);
    else            Assert(False);
  end;
  WriteIndents;
  WriteString(AName);
  FStream.WriteString(': ');
  FState := wsObjectValue;
end;

initialization
  GnvJSONFormatSettings.DecimalSeparator := '.';

end.
