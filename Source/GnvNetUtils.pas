unit GnvNetUtils;

interface

uses
  Classes;

type
  TGnvMacAddr = array[0..5] of Byte;

  TGnvIP4Range = record
    IP41: LongWord;
    IP42: LongWord;
  end;

  TGnvIP4Array = array of LongWord;


const
  GNV_IP4_RANGE_DELIMITER = '-';
  GNV_MAC_ADDR_NULL: TGnvMacAddr = (0, 0, 0, 0, 0, 0);

function GnvCompareIP4(IP41, IP42: LongWord): Integer;
function GnvIP4ToStr(IP4: LongWord): string;
function GnvIP4RangeToStr(Range: TGnvIP4Range): string; overload;
function GnvIP4RangeToStr(IP41, IP42: LongWord): string; overload;
function GnvIP4RangeToArray(Range: TGnvIP4Range): TGnvIP4Array; overload;
function GnvIP4RangeToArray(IP41, IP42: LongWord): TGnvIP4Array; overload;
function GnvStrToIP4(S: string): LongWord;
function GnvStrToIP4Range(S: string): TGnvIP4Range;

function GnvCompareMacAddr(Mac1, Mac2: TGnvMacAddr): Integer;
function GnvMacAddrToStr(Mac: TGnvMacAddr): string;
function GnvMacAddrToInt64(Mac: TGnvMacAddr): Int64;
function GnvStrToMacAddr(const S: string): TGnvMacAddr;
function GnvInt64ToMacAddr(Value: Int64): TGnvMacAddr;

implementation

uses
  Math, SysUtils;

function GnvCompareIP4(IP41, IP42: LongWord): Integer;
var
  B1, B2: array[0..3] of Byte;
begin
{
  PInteger(@B1)^ := IP41;
  PInteger(@B2)^ := IP42;
  Result := CompareValue(B1[0], B2[0]);
  if Result = 0 then Result := CompareValue(B1[1], B2[1]);
  if Result = 0 then Result := CompareValue(B1[2], B2[2]);
  if Result = 0 then Result := CompareValue(B1[3], B2[3]);
}
  Result := CompareValue(IP41, IP42);
end;

function GnvIP4ToStr(IP4: LongWord): string;
var
  B: array[0..3] of Byte;
begin
  Result := '';
  if IP4 = 0 then Exit;
  PInteger(@B)^ := IP4;
  Result := IntToStr(B[3]) + '.' + IntToStr(B[2]) + '.' + IntToStr(B[1]) + '.' + IntToStr(B[0]);
end;

function GnvIP4RangeToStr(Range: TGnvIP4Range): string; overload;
begin
  Result := GnvIP4RangeToStr(Range.IP41, Range.IP42);
end;

function GnvIP4RangeToStr(IP41, IP42: LongWord): string; overload;
begin
  Result := GnvIP4ToStr(IP41) + GNV_IP4_RANGE_DELIMITER + GnvIP4ToStr(IP42);
end;

function GnvIP4RangeToArray(Range: TGnvIP4Range): TGnvIP4Array; overload;
begin
  Result := GnvIP4RangeToArray(Range.IP41, Range.IP42);
end;

function GnvIP4RangeToArray(IP41, IP42: LongWord): TGnvIP4Array; overload;
var
  I, Count: Cardinal;
  NormalRange: TGnvIP4Range;
begin
  if IP41 > IP42 then
  begin
    NormalRange.IP41 := IP42;
    NormalRange.IP42 := IP41;
  end
  else
  begin
    NormalRange.IP41 := IP41;
    NormalRange.IP42 := IP42;
  end;
  SetLength(Result, NormalRange.IP42 - NormalRange.IP41 + 1);
  Count := 0;
  for I := NormalRange.IP41 to NormalRange.IP42 do
  begin
    Result[Count] := I;
    Inc(Count);
  end;
end;

function GnvStrToIP4(S: string): LongWord;
var
  Strings : TStrings;
  B: array[0..3] of Byte;
  I, Count, Index: Integer;
begin
  PInteger(@B)^ := 0;
  Strings := TStringList.Create;
  ExtractStrings(['.'], [], PChar(S), Strings);
  Count := 0;
  for I := Strings.Count - 1 downto 0 do
  begin
    if Count > 3 then Break;
    Index := StrToIntDef(Strings[I], 0);
    if Index > 255 then Index := 255;
    B[Count] := Index;
    Inc(Count);
  end;
  Result := PInteger(@B)^;
  Strings.Free;
end;

function GnvStrToIP4Range(S: string): TGnvIP4Range;
var
  Strings : TStrings;
  B: array[0..3] of Byte;
  I, Index: Integer;
begin
  Result.IP41 := 0;
  Result.IP42 := 0;

  Strings := TStringList.Create;
  ExtractStrings([GNV_IP4_RANGE_DELIMITER], [], PChar(S), Strings);
  for I := 0 to Strings.Count - 1 do
  begin
    if I > 1 then Break;
    case I of
      0: Result.IP41 := GnvStrToIP4(Trim(Strings[I]));
      1: Result.IP42 := GnvStrToIP4(Trim(Strings[I]));
    end;
  end;
  Strings.Free;
end;

function GnvCompareMacAddr(Mac1, Mac2: TGnvMacAddr): Integer;
begin
  Result := CompareValue(Mac1[0], Mac2[0]);
  if Result = 0 then Result := CompareValue(Mac1[1], Mac2[1]);
  if Result = 0 then Result := CompareValue(Mac1[2], Mac2[2]);
  if Result = 0 then Result := CompareValue(Mac1[3], Mac2[3]);
  if Result = 0 then Result := CompareValue(Mac1[4], Mac2[4]);
  if Result = 0 then Result := CompareValue(Mac1[5], Mac2[5]);
end;

function GnvMacAddrToStr(Mac: TGnvMacAddr): string;
begin
  Result := '';
  if GnvCompareMacAddr(Mac, GNV_MAC_ADDR_NULL) = 0 then Exit;

  Result := Format('%.2x:%.2x:%.2x:%.2x:%.2x:%.2x',
    [Mac[0], Mac[1], Mac[2], Mac[3], Mac[4], Mac[5]]);
end;

function GnvMacAddrToInt64(Mac: TGnvMacAddr): Int64;
var
  B: array[0..7] of Byte;
  I: Integer;
begin
  for I := 0 to 7 do
    if I < 6 then
      B[I] := Mac[I]
    else
      B[I] := 0;

  Result := PInt64(@B)^;
end;

function GnvStrToMacAddr(const S: string): TGnvMacAddr;
var
  Strings : TStrings;
  I, Index: Integer;
begin
  FillChar(Result, 6, 0);
  Strings := TStringList.Create;
  ExtractStrings([':'], [], PChar(S), Strings);
  for I := 0 to Strings.Count - 1 do
  begin
    if I > 5 then Break;
    Index := StrToIntDef('$' + Strings[I], 0);
    if Index > 255 then Index := 255;
    Result[I] := Index;
  end;
  Strings.Free;
end;

function GnvInt64ToMacAddr(Value: Int64): TGnvMacAddr;
var
  B: array[0..7] of Byte;
  I: Integer;
begin
  PInt64(@B)^ := Value;
  for I := 0 to 5 do
    Result[I] := B[I];
end;

end.