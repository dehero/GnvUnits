unit GnvWindows;

interface

uses
  Windows, Classes, SysUtils, Forms;

type
  TGnvMsgData = record
    Msg: string;
    Flags: Longint;
  end;

  TGnvFileVersion = record
    Major: Word;
    Minor: Word;
    Release: Word;
    Build: Word;
  end;

function GnvGetCurrentUserName : string;

function GnvGetVersionInfo(const FileName, Key: string): string;
function GnvGetResourceAsPointer(ResName: PChar; ResType: PChar; out Size: LongWord): Pointer;
function GnvGetResourceAsString(ResName: string; ResType: PChar): string;
procedure GnvSaveResourceAsFile(const ResName: string; ResType: PChar; const FileName: string);

function GnvCompareFileVersion(Version1, Version2: TGnvFileVersion): Integer;
function GnvFileVersion(Major, Minor, Release, Build: Word): TGnvFileVersion;
function GnvFileVersionFromStream(Stream: TStream): TGnvFileVersion;
function GnvFileVersionToStr(Version: TGnvFileVersion): string;
procedure GnvFileVersionToStream(Version: TGnvFileVersion; Stream: TStream);
function GnvGetFileVersion(const FileName: string): TGnvFileVersion;

function GnvMessageQuery(const Msg: string; Arguments: array of const;
  Flags: LongInt): Integer; overload;
function GnvMessageQuery(const Data: TGnvMsgData;  Arguments: array of const):
  Integer; overload;

implementation

uses
  Math;

function GnvGetCurrentUserName : string;
const
  MaxLength = 254;
var
  Name: string;
  L: DWord;
begin
  L := MaxLength - 1;
  SetLength(Name, MaxLength);
  GetUserName(PChar(Name), L);
  SetLength(Name, L);
  Result := Name;
end;

function GnvGetVersionInfo(const FileName, Key: string): string;
var
  Name: array[0..255] of Char;
  P: Pointer;
  Value: Pointer;
  Len: UINT;
  Translation: string;
  Valid: Boolean;
  Size: DWORD;
  Handle: DWORD;
  Buffer: PChar;
begin
  Result := '';
  Buffer := nil;
  Size := 0;

  try
    Valid := False;

    Size := GetFileVersionInfoSize(PWideChar(FileName), Handle);
    if Size > 0 then
    try
      GetMem(Buffer, Size);
      Valid := GetFileVersionInfo(PWideChar(FileName), Handle, Size, Buffer);
    except
      Valid := False;
    end;

    P := nil;
    if Valid then
      VerQueryValue(Buffer, '\VarFileInfo\Translation', P, Len);

    if Assigned(P) then
      Translation := IntToHex(MakeLong(HiWord(Longint(P^)),
        LoWord(Longint(P^))), 8);

    if Valid then
    begin
      StrPCopy(Name, '\StringFileInfo\' + Translation + '\' + Key);
      if VerQueryValue(Buffer, Name, Value, Len) then
        Result := StrPas(PChar(Value));
    end;
  finally
    if Assigned(Buffer) then FreeMem(Buffer, Size);
  end;
end;

// SampleWav := GetResourceAsPointer('SampleWav', 'wave', Size);
// SndPlaySound(SampleWav, SND_MEMORY or SND_NODEFAULT or SND_ASYNC);
function GnvGetResourceAsPointer(ResName: PChar; ResType: PChar; out Size: LongWord): Pointer;
var
  InfoBlock: HRSRC;
  GlobalMemoryBlock: HGLOBAL;
begin
  InfoBlock := FindResource(HInstance, ResName, ResType);

  if InfoBlock = 0 then
    raise Exception.Create(SysErrorMessage(GetLastError));

  Size := SizeOfResource(HInstance, InfoBlock);

  if Size = 0 then
    raise Exception.Create(SysErrorMessage(GetLastError));

  GlobalMemoryBlock := LoadResource(HInstance, InfoBlock);

  if GlobalMemoryBlock = 0 then
    raise Exception.Create(SysErrorMessage(GetLastError));

  Result := LockResource(GlobalMemoryBlock);

  if Result = nil then
    raise Exception.Create(SysErrorMessage(GetLastError));
end;

function GnvGetResourceAsString(ResName: string; ResType: PChar): string;
var
  Stream: TResourceStream;
  Strings: TStrings;
begin
  Stream := TResourceStream.Create(HInstance, ResName, ResType);
  Strings := TStringList.Create;
  try
    Strings.LoadFromStream(Stream);
    Result := Strings.Text;
  finally
    Stream.Free;
    Strings.Free;
  end;
end;

// There are some resources (like fonts and animated cursors) that can't be used
// from memory. We necessarily have to save these resources to a temporary disk
// file and load them from there. The following function saves a resource to a file
procedure GnvSaveResourceAsFile(const ResName: string; ResType: PChar; const FileName: string);
begin
  with TResourceStream.Create(hInstance, ResName, ResType) do
  try
    SaveToFile(FileName);
  finally
    Free;
  end;
end;


function GnvCompareFileVersion(Version1, Version2: TGnvFileVersion): Integer;
begin
  Result := CompareValue(Version1.Major, Version2.Major);
  if Result = 0 then Result := CompareValue(Version1.Minor, Version2.Minor);
  if Result = 0 then Result := CompareValue(Version1.Release, Version2.Release);
  if Result = 0 then Result := CompareValue(Version1.Build, Version2.Build);
end;

function GnvFileVersion(Major, Minor, Release, Build: Word): TGnvFileVersion;
begin
  Result.Major := Major;
  Result.Minor := Minor;
  Result.Release := Release;
  Result.Build := Build;
end;

function GnvFileVersionFromStream(Stream: TStream): TGnvFileVersion;
begin
  Stream.Read(Result.Major, 2);
  Stream.Read(Result.Minor, 2);
  Stream.Read(Result.Release, 2);
  Stream.Read(Result.Build, 2);
end;

function GnvFileVersionToStr(Version: TGnvFileVersion): string;
begin
  Result := Format('%u.%u.%u.%u', [Version.Major, Version.Minor, Version.Release, Version.Build]);
end;

procedure GnvFileVersionToStream(Version: TGnvFileVersion; Stream: TStream);
begin
  Stream.Write(Version.Major, 2);
  Stream.Write(Version.Minor, 2);
  Stream.Write(Version.Release, 2);
  Stream.Write(Version.Build, 2);
end;

function GnvGetFileVersion(const FileName: string): TGnvFileVersion;
var
  VerInfoSize, VerValueSize, Dummy: Cardinal;
  PVerInfo: Pointer;
  PVerValue: PVSFixedFileInfo;
begin
  Result := GnvFileVersion(0, 0, 0, 0);
  VerInfoSize := GetFileVersionInfoSize(PChar(FileName), Dummy);
  GetMem(PVerInfo, VerInfoSize);
  try
    if GetFileVersionInfo(PChar(FileName), 0, VerInfoSize, PVerInfo) then
      if VerQueryValue(PVerInfo, '\', Pointer(PVerValue), VerValueSize) then
      begin
        Result.Major := HiWord(PVerValue^.dwFileVersionMS);
        Result.Minor := LoWord(PVerValue^.dwFileVersionMS);
        Result.Release := HiWord(PVerValue^.dwFileVersionLS);
        Result.Build := LoWord(PVerValue^.dwFileVersionLS);
      end;
  finally
    FreeMem(PVerInfo, VerInfoSize);
  end;
end;

function GnvMessageQuery(const Msg: string; Arguments: array of const;
  Flags: LongInt): Integer;
var
  S: string;
begin
  S := Format(Msg, Arguments);
  Result := MessageBox(Application.Handle, PChar(S), PChar(Application.Title), Flags);
end;

function GnvMessageQuery(const Data: TGnvMsgData; Arguments: array of const): Integer;
begin
  Result := GnvMessageQuery(Data.Msg, Arguments, Data.Flags);
end;

end.
