unit GnvSysUtils;

interface

uses
  Classes, Windows;

type
  TGnvCPIdentData = record
    CodePage: Integer;
    Ident: string;
  end;

  TFileSize = Int64;

const
  GNV_CP_IDENTS_MAX = 140;

  GNV_CP_IDENTS: array[0..GNV_CP_IDENTS_MAX - 1] of TGnvCPIdentData =
  (
    (CodePage: 37; Ident: 'IBM037'),
    (CodePage: 437; Ident: 'IBM437'),
    (CodePage: 500; Ident: 'IBM500'),
    (CodePage: 708; Ident: 'ASMO-708'),
    (CodePage: 720; Ident: 'DOS-720'),
    (CodePage: 737; Ident: 'ibm737'),
    (CodePage: 775; Ident: 'ibm775'),
    (CodePage: 850; Ident: 'ibm850'),
    (CodePage: 852; Ident: 'ibm852'),
    (CodePage: 855; Ident: 'IBM855'),
    (CodePage: 857; Ident: 'ibm857'),
    (CodePage: 858; Ident: 'IBM00858'),
    (CodePage: 860; Ident: 'IBM860'),
    (CodePage: 861; Ident: 'ibm861'),
    (CodePage: 862; Ident: 'DOS-862'),
    (CodePage: 863; Ident: 'IBM863'),
    (CodePage: 864; Ident: 'IBM864'),
    (CodePage: 865; Ident: 'IBM865'),
    (CodePage: 866; Ident: 'cp866'),
    (CodePage: 869; Ident: 'ibm869'),
    (CodePage: 870; Ident: 'IBM870'),
    (CodePage: 874; Ident: 'windows-874'),
    (CodePage: 875; Ident: 'cp875'),
    (CodePage: 932; Ident: 'shift_jis'),
    (CodePage: 936; Ident: 'gb2312'),
    (CodePage: 949; Ident: 'ks_c_5601-1987'),
    (CodePage: 950; Ident: 'big5'),
    (CodePage: 1026; Ident: 'IBM1026'),
    (CodePage: 1047; Ident: 'IBM01047'),
    (CodePage: 1140; Ident: 'IBM01140'),
    (CodePage: 1141; Ident: 'IBM01141'),
    (CodePage: 1142; Ident: 'IBM01142'),
    (CodePage: 1143; Ident: 'IBM01143'),
    (CodePage: 1144; Ident: 'IBM01144'),
    (CodePage: 1145; Ident: 'IBM01145'),
    (CodePage: 1146; Ident: 'IBM01146'),
    (CodePage: 1147; Ident: 'IBM01147'),
    (CodePage: 1148; Ident: 'IBM01148'),
    (CodePage: 1149; Ident: 'IBM01149'),
    (CodePage: 1200; Ident: 'utf-16'),
    (CodePage: 1201; Ident: 'unicodeFFFE'),
    (CodePage: 1250; Ident: 'windows-1250'),
    (CodePage: 1251; Ident: 'windows-1251'),
    (CodePage: 1252; Ident: 'Windows-1252'),
    (CodePage: 1253; Ident: 'windows-1253'),
    (CodePage: 1254; Ident: 'windows-1254'),
    (CodePage: 1255; Ident: 'windows-1255'),
    (CodePage: 1256; Ident: 'windows-1256'),
    (CodePage: 1257; Ident: 'windows-1257'),
    (CodePage: 1258; Ident: 'windows-1258'),
    (CodePage: 1361; Ident: 'Johab'),
    (CodePage: 10000; Ident: 'macintosh'),
    (CodePage: 10001; Ident: 'x-mac-japanese'),
    (CodePage: 10002; Ident: 'x-mac-chinesetrad'),
    (CodePage: 10003; Ident: 'x-mac-korean'),
    (CodePage: 10004; Ident: 'x-mac-arabic'),
    (CodePage: 10005; Ident: 'x-mac-hebrew'),
    (CodePage: 10006; Ident: 'x-mac-greek'),
    (CodePage: 10007; Ident: 'x-mac-cyrillic'),
    (CodePage: 10008; Ident: 'x-mac-chinesesimp'),
    (CodePage: 10010; Ident: 'x-mac-romanian'),
    (CodePage: 10017; Ident: 'x-mac-ukrainian'),
    (CodePage: 10021; Ident: 'x-mac-thai'),
    (CodePage: 10029; Ident: 'x-mac-ce'),
    (CodePage: 10079; Ident: 'x-mac-icelandic'),
    (CodePage: 10081; Ident: 'x-mac-turkish'),
    (CodePage: 10082; Ident: 'x-mac-croatian'),
    (CodePage: 12000; Ident: 'utf-32'),
    (CodePage: 12001; Ident: 'utf-32BE'),
    (CodePage: 20000; Ident: 'x-Chinese-CNS'),
    (CodePage: 20001; Ident: 'x-cp20001'),
    (CodePage: 20002; Ident: 'x-Chinese-Eten'),
    (CodePage: 20003; Ident: 'x-cp20003'),
    (CodePage: 20004; Ident: 'x-cp20004'),
    (CodePage: 20005; Ident: 'x-cp20005'),
    (CodePage: 20105; Ident: 'x-IA5'),
    (CodePage: 20106; Ident: 'x-IA5-German'),
    (CodePage: 20107; Ident: 'x-IA5-Swedish'),
    (CodePage: 20108; Ident: 'x-IA5-Norwegian'),
    (CodePage: 20127; Ident: 'us-ascii'),
    (CodePage: 20261; Ident: 'x-cp20261'),
    (CodePage: 20269; Ident: 'x-cp20269'),
    (CodePage: 20273; Ident: 'IBM273'),
    (CodePage: 20277; Ident: 'IBM277'),
    (CodePage: 20278; Ident: 'IBM278'),
    (CodePage: 20280; Ident: 'IBM280'),
    (CodePage: 20284; Ident: 'IBM284'),
    (CodePage: 20285; Ident: 'IBM285'),
    (CodePage: 20290; Ident: 'IBM290'),
    (CodePage: 20297; Ident: 'IBM297'),
    (CodePage: 20420; Ident: 'IBM420'),
    (CodePage: 20423; Ident: 'IBM423'),
    (CodePage: 20424; Ident: 'IBM424'),
    (CodePage: 20833; Ident: 'x-EBCDIC-KoreanExtended'),
    (CodePage: 20838; Ident: 'IBM-Thai'),
    (CodePage: 20866; Ident: 'koi8-r'),
    (CodePage: 20871; Ident: 'IBM871'),
    (CodePage: 20880; Ident: 'IBM880'),
    (CodePage: 20905; Ident: 'IBM905'),
    (CodePage: 20924; Ident: 'IBM00924'),
    (CodePage: 20932; Ident: 'EUC-JP'),
    (CodePage: 20936; Ident: 'x-cp20936'),
    (CodePage: 20949; Ident: 'x-cp20949'),
    (CodePage: 21025; Ident: 'cp1025'),
    (CodePage: 21866; Ident: 'koi8-u'),
    (CodePage: 28591; Ident: 'iso-8859-1'),
    (CodePage: 28592; Ident: 'iso-8859-2'),
    (CodePage: 28593; Ident: 'iso-8859-3'),
    (CodePage: 28594; Ident: 'iso-8859-4'),
    (CodePage: 28595; Ident: 'iso-8859-5'),
    (CodePage: 28596; Ident: 'iso-8859-6'),
    (CodePage: 28597; Ident: 'iso-8859-7'),
    (CodePage: 28598; Ident: 'iso-8859-8'),
    (CodePage: 28599; Ident: 'iso-8859-9'),
    (CodePage: 28603; Ident: 'iso-8859-13'),
    (CodePage: 28605; Ident: 'iso-8859-15'),
    (CodePage: 29001; Ident: 'x-Europa'),
    (CodePage: 38598; Ident: 'iso-8859-8-i'),
    (CodePage: 50220; Ident: 'iso-2022-jp'),
    (CodePage: 50221; Ident: 'csISO2022JP'),
    (CodePage: 50222; Ident: 'iso-2022-jp'),
    (CodePage: 50225; Ident: 'iso-2022-kr'),
    (CodePage: 50227; Ident: 'x-cp50227'),
    (CodePage: 51932; Ident: 'euc-jp'),
    (CodePage: 51936; Ident: 'EUC-CN'),
    (CodePage: 51949; Ident: 'euc-kr'),
    (CodePage: 52936; Ident: 'hz-gb-2312'),
    (CodePage: 54936; Ident: 'GB18030'),
    (CodePage: 57002; Ident: 'x-iscii-de'),
    (CodePage: 57003; Ident: 'x-iscii-be'),
    (CodePage: 57004; Ident: 'x-iscii-ta'),
    (CodePage: 57005; Ident: 'x-iscii-te'),
    (CodePage: 57006; Ident: 'x-iscii-as'),
    (CodePage: 57007; Ident: 'x-iscii-or'),
    (CodePage: 57008; Ident: 'x-iscii-ka'),
    (CodePage: 57009; Ident: 'x-iscii-ma'),
    (CodePage: 57010; Ident: 'x-iscii-gu'),
    (CodePage: 57011; Ident: 'x-iscii-pa'),
    (CodePage: 65000; Ident: 'utf-7'),
    (CodePage: 65001; Ident: 'utf-8')
  );

procedure GnvReverseBytes(Source, Dest: Pointer; Size: Cardinal);

function GnvGetFileChanged(const FileName: string): TDateTime;
function GnvGetFileSize(const FileName: string): TFileSize;
function GnvExpandEnvPath(const Path: string): string;
function GnvExpandRelativePath(const BaseName, DestName: string): string;
function GnvExtractRelativePath(const BaseName, DestName: string): string;
procedure GnvSetFileDate(const FileName: string; const Date: TDateTime);

function GnvCPToStr(CodePage: Integer): string;
function GnvStrToCP(Str: string): Integer;

function GnvLocaleNameToLCID(const LocaleName: string): Cardinal;
function GnvLCIDToLocaleName(LCID: Cardinal): string;
function GnvGetLocaleInfo(LCID: Cardinal; Field: Cardinal): string;

implementation

uses
  SysUtils;

procedure GnvReverseBytes(Source, Dest: Pointer; Size: Cardinal);
begin
  Dest := PByte(NativeUInt(Dest) + Size - 1);
  while Size > 0 do
  begin
    PByte(Dest)^ := PByte(Source)^;
    Inc(PByte(Source));
    Dec(PByte(Dest));
    Dec(Size);
  end;
end;

function GnvLocaleNameToLCID(const LocaleName: string): Cardinal;
type
  TLocaleNameToLCID = function(lpName: LPWSTR; dwFlags: DWORD): LCID; stdcall;
var
  Handle: THandle;
  Func: TLocaleNameToLCID;
begin
  Result := LOCALE_USER_DEFAULT;
  Handle := INVALID_HANDLE_VALUE;
  try
    if Win32MajorVersion >= 6 then
    begin
      Handle := LoadLibrary('kernel32.dll');
      @Func := GetProcAddress(Handle, 'LocaleNameToLCID');
    end
    else
    begin
      Handle := LoadLibrary('nlsdl.dll');
      @Func := GetProcAddress(Handle, 'DownlevelLocaleNameToLCID');
    end;
    if Addr(Func) <> nil then
      Result := Func(PChar(LocaleName), 0);
  finally
    FreeLibrary(Handle);
  end;
end;

function GnvLCIDToLocaleName(LCID: Cardinal): string;
var
  Buffer: array[0..254] of Char;
begin
  GetLocaleInfo(LCID, LOCALE_SISO639LANGNAME, Buffer, 255);
  Result := Buffer;
  GetLocaleInfo(LCID, LOCALE_SISO3166CTRYNAME, Buffer, 255);
  Result := Result + '-' + Buffer;
end;

function GnvGetLocaleInfo(LCID: Cardinal; Field: Cardinal): string;
var
  Buffer: array[0..254] of Char;
begin
  GetLocaleInfo(LCID, Field, Buffer, 255);
  Result := Buffer;
end;

function GnvCPToStr(CodePage: Integer): string;
var
  I: Integer;
begin
  Result := GNV_CP_IDENTS[GNV_CP_IDENTS_MAX - 1].Ident;

  for I := 0 to GNV_CP_IDENTS_MAX - 1 do
    if GNV_CP_IDENTS[I].CodePage = CodePage then
      Exit(GNV_CP_IDENTS[I].Ident);
end;

function GnvStrToCP(Str: string): Integer;
var
  I: Integer;
begin
  Result := GNV_CP_IDENTS[GNV_CP_IDENTS_MAX - 1].CodePage;

  for I := 0 to GNV_CP_IDENTS_MAX - 1 do
    if SameText(GNV_CP_IDENTS[I].Ident, Str) then
      Exit(GNV_CP_IDENTS[I].CodePage);
end;

function GnvGetFileChanged(const FileName: string): TDateTime;
var
  Handle: THandle;
  LocalFileTime: TFileTime;
  DosFileTime: DWORD;
  FindData: TWin32FindData;
begin
  Result := 0;
  Handle := FindFirstFile(PWideChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
      FileTimeToDosDateTime(LocalFileTime, LongRec(DosFileTime).Hi,
        LongRec(DosFileTime).Lo);

      Result := FileDateToDateTime(DosFileTime);
    end;
  end;
end;

function GnvGetFileSize(const FileName: string): TFileSize;
var
  SearchRec: TSearchRec;
begin
  Result := -1;
  if FindFirst(FileName, faAnyFile, SearchRec) = 0 then
    Result := SearchRec.Size;
  FindClose(SearchRec);
end;

function GnvExpandEnvPath(const Path: string): string;
var
  Size: Integer;
begin
  // Get required buffer size
  Size := ExpandEnvironmentStrings(PChar(Path), nil, 0);

  Result := '';
  if Size > 0 then
  begin
    // Read expanded string into result string
    SetLength(Result, Size - 1);
    ExpandEnvironmentStrings(PChar(Path), PChar(Result), Size);
  end;
end;

function GnvExpandRelativePath(const BaseName, DestName: string): string;
begin
  Result := DestName;
  if (ExtractFileDrive(DestName) = '') and (DestName <> '') then
    Result := ExpandFileName(ExtractFilePath(BaseName) + DestName);
end;

function GnvExtractRelativePath(const BaseName, DestName: string): string;
begin
  Result := DestName;
  if DestName <> '' then
    Result := ExtractRelativePath(BaseName, DestName);
end;

procedure GnvSetFileDate(const FileName: string; const Date: TDateTime);
var
  Handle: Integer;
begin
  if FileExists(FileName) then
  begin
    Handle := FileOpen(FileName, fmOpenWrite OR fmShareDenyNone);
    try
      FileSetDate(Handle, DateTimeToFileDate(Date));
    finally
      FileClose(Handle);
    end;
  end;
end;

end.
