unit GnvSerialization;

interface

uses
	Classes, SysUtils;

type
  TStringLengthSize = 1..4;

function GnvClearBit(const Value, Bit: Byte): Byte; inline;
function GnvToggleBit(const Value, Bit: Byte; const Flag: Boolean): Byte; inline;
function GnvGetBit(const Value, Bit: Byte): Boolean; inline;
function GnvSetBit(const Value, Bit: Byte): Byte; inline;

function GnvAnsiStrFromStream(Stream: TStream; Size: TStringLengthSize): AnsiString;
procedure GnvAnsiStrToStream(const Str: AnsiString; Stream: TStream; Size: TStringLengthSize);
function GnvWideStrFromStream(Stream: TStream; Size: TStringLengthSize): UnicodeString;
procedure GnvWideStrToStream(const Str: UnicodeString; Stream: TStream; Size: TStringLengthSize);

function GnvStrFromFile(const FileName: string; DefaultEncoding: TEncoding): string;
procedure GnvStrToFile(const FileName: string; const Str: string; Encoding: TEncoding);

implementation

function GnvClearBit(const Value, Bit: Byte): Byte;
begin
	Result := Value and not (1 shl Bit);
end;

function GnvToggleBit(const Value, Bit: Byte; const Flag: Boolean): Byte;
begin
	Result := (Value or (1 shl Bit)) xor (Byte(not Flag) shl Bit);
end;

function GnvGetBit(const Value, Bit: Byte): Boolean;
begin
  Result := (Value and (1 shl Bit)) <> 0;
end;

function GnvSetBit(const Value, Bit: Byte): Byte;
begin
	Result := Value or (1 shl Bit);
end;

function GnvAnsiStrFromStream(Stream: TStream; Size: TStringLengthSize): AnsiString;
var
  P: PAnsiChar;
  L: LongWord;
begin
  // Fill length buffer with zeros because
  // it can be read partially due to variable Size
  L := 0;
  // Reading string length
  Stream.Read(L, Size);
  // Reading string
  SetLength(Result, L);
  P := PAnsiChar(Result);
  Stream.Read(P^, L);
end;

procedure GnvAnsiStrToStream(const Str: AnsiString; Stream: TStream; Size: TStringLengthSize);
var
  P: PAnsiChar;
  L: LongWord;
begin
	P := PAnsiChar(Str);
	L := 0;
  L := Length(P);
  // Writing string length, maximal length is 4294967295 (LongWord)
  Stream.Write(L, Size);
  // Writing string
  Stream.Write(P^, L);
end;

function GnvWideStrFromStream(Stream: TStream; Size: TStringLengthSize): UnicodeString;
var
  P: PWideChar;
  L: LongWord;
begin
	// Fill length buffer with zeros because
	// it can be read partially due to variable Size
	L := 0;
	// Reading string length
	Stream.Read(L, Size);
	// Reading string
	SetLength(Result, L);
	P := PWideChar(Result);
	Stream.Read(P^, L * 2);
end;

procedure GnvWideStrToStream(const Str: UnicodeString; Stream: TStream; Size: TStringLengthSize);
var
  P: PWideChar;
  L: LongWord;
begin
	P := PWideChar(Str);
	L := 0;
	L := Length(P);
  // Writing string length, maximal length is 4294967295 (LongWord)
  Stream.Write(L, Size);
  // One Unicode symbol takes 2 bytes, so summary
  // byte count is twice larger than string length
	Stream.Write(P^, L*2);
end;

function GnvStrFromFile(const FileName: string; DefaultEncoding: TEncoding): string;
var
	Stream: TStream;
	Size: Integer;
	Buffer: TBytes;
  Encoding: TEncoding;
begin
	Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);

	try
		Size := Stream.Size - Stream.Position;
		SetLength(Buffer, Size);
		Stream.Read(Buffer[0], Size);

    Encoding := nil;
		Size := TEncoding.GetBufferEncoding(Buffer, Encoding);
    if Size > 0 then
      Result := Encoding.GetString(Buffer, Size, Length(Buffer) - Size)
    else
  		Result := DefaultEncoding.GetString(Buffer);
	finally
		Stream.Free;
	end;
end;

procedure GnvStrToFile(const FileName: string; const Str: string; Encoding: TEncoding);
var
  Buffer, Preamble: TBytes;
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);

  try
    if Encoding = nil then
      Encoding := TEncoding.Default;
    Buffer := Encoding.GetBytes(Str);
    Preamble := Encoding.GetPreamble;
    if Length(Preamble) > 0 then
      Stream.WriteBuffer(Preamble[0], Length(Preamble));
    Stream.WriteBuffer(Buffer[0], Length(Buffer));
  finally
    Stream.Free;
  end;
end;

end.
