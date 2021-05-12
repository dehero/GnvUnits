unit GnvCrypt;

interface

uses
	Windows;

const
	CRYPTPROTECT_UI_FORBIDDEN = $01;	// Flag to hide DPAPI interface

type
	TDataBlob  = record
		cbData: DWORD;
		pbData: Windows.PBYTE;
	end;
	PDataBlob = ^TDataBlob;
	LPLPWSTR  = ^LPWSTR;

function GnvEncryptStr(const Data: AnsiString): AnsiString;
function GnvDecryptStr(const Data: AnsiString): AnsiString;

function CryptProtectData(pDataIn: PDataBlob; szDataDescr: LPCWSTR;
	pOptionalEntropy: PDataBlob; pvReserved: Pointer;
	pPromptStruct: Pointer; dwFlags: DWORD; pDataOut: PDataBlob): BOOL; stdcall;
	external 'crypt32.dll' name 'CryptProtectData';

function CryptUnprotectData(pDataIn: PDataBlob; ppszDataDescr: LPLPWSTR;
	pOptionalEntropy: PDataBlob; pvReserved: Pointer;
	pPromptStruct: Pointer; dwFlags: DWORD; pDataOut: PDataBlob): BOOL; stdcall;
	external 'crypt32.dll' name 'CryptUnprotectData';

implementation

uses SysUtils, Classes;

function GnvEncryptStr(const Data: AnsiString): AnsiString;
var
	DataIn,	DataOut, Entropy: TDataBlob;
	S: string;
begin
	Result         := '';
  if Length(Data) = 0 then Exit;

	DataIn.cbData  := Length(Data);
	DataIn.pbData  := PByte(Data);
	DataOut.cbData := 0;
	DataOut.pbData := nil;
	S            	 := ParamStr(0);
	Entropy.cbData := Length(S);
	Entropy.pbData := PByte(S);
	if Win32Check(CryptProtectData(@DataIn, PChar(S), @Entropy, nil, nil,
		CRYPTPROTECT_UI_FORBIDDEN, @DataOut)) then
	try
		SetLength(Result, DataOut.cbData*2);
		BinToHex(DataOut.pbData, PAnsiChar(Result), DataOut.cbData);
	finally
    LocalFree(HLOCAL(DataOut.pbData));
  end;
end;

function GnvDecryptStr(const Data: AnsiString): AnsiString;
var
	DataIn, DataOut, Entropy: TDataBlob;
	I: Integer;
	Description: PChar;
	S: string;
begin
	Result         := '';
  if Length(Data) <= 2 then Exit;

	DataIn.cbData  := Length(Data) div 2;
	GetMem(DataIn.pbData, DataIn.cbData);
	HexToBin(PAnsiChar(Data), DataIn.pbData, DataIn.cbData);
  DataOut.cbData := 0;
  DataOut.pbData := nil;
	S            	 := ParamStr(0);
  Entropy.cbData := Length(S);
	Entropy.pbData := PByte(S);
  try
    if Win32Check(CryptUnprotectData(@DataIn, @Description, @Entropy, nil, nil,
      CRYPTPROTECT_UI_FORBIDDEN, @DataOut)) then
    try
      SetLength(Result, DataOut.cbData);
      CopyMemory(PByte(Result), DataOut.pbData, DataOut.cbData);
    finally
      FreeMem(DataIn.pbData, DataIn.cbData);
      LocalFree(HLOCAL(DataOut.pbData));
      LocalFree(HLOCAL(Description));
    end;
  except
  end;
end;

end.