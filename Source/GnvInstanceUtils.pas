unit GnvInstanceUtils;

interface

uses
  Windows, SysUtils;

function GnvGetRunningInstance: THandle;
procedure GnvSetRunningInstance(const Handle: THandle);
procedure GnvClearRunningInstance;
procedure GnvRestoreRunningInstance(Msg: LongWord = 0);
procedure GnvSendParamStrings(Handle: HWND);

var
  GnvInstanceName : string;

implementation

uses
  Messages;

var
  InstanceMapHandle: THandle;
  InstanceHandle: PHandle;

function GnvGetRunningInstance: THandle;
begin
  Result := 0;
  InstanceMapHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar(GnvInstanceName));
  if InstanceMapHandle <> 0 then
  begin
    InstanceHandle := MapViewOfFile(InstanceMapHandle, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(THandle));
    Result := InstanceHandle^;
  end;
end;

procedure GnvSetRunningInstance(const Handle: THandle);
begin
  InstanceMapHandle := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, SizeOf(THandle), PChar(GnvInstanceName));
  if (InstanceMapHandle <> 0) then
  begin
    InstanceHandle := MapViewOfFile(InstanceMapHandle, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(THandle));
    InstanceHandle^ := Handle;
  end;
end;

procedure GnvClearRunningInstance;
begin
  if Assigned(InstanceHandle) then UnmapViewOfFile(InstanceHandle);
  if InstanceMapHandle <> 0 then CloseHandle(InstanceMapHandle);
end;

procedure GnvRestoreRunningInstance(Msg: LongWord = 0);
begin
  InstanceMapHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar(GnvInstanceName));
  if InstanceMapHandle <> 0 then
  begin
		InstanceHandle := MapViewOfFile(InstanceMapHandle, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(THandle));
		PostMessage(InstanceHandle^, Msg, 0, 0);
		if IsIconic(InstanceHandle^) then ShowWindow(InstanceHandle^, SW_RESTORE);
    SetForegroundWindow(InstanceHandle^);
  end;
end;

procedure GnvSendParamStrings(Handle: HWND);

// Function to get sent parameters inside another instance's form is below
{
  procedure WMCopyData(var Msg : TWMCopyData); message WM_COPYDATA;
  var
    FileName: string;
  begin
    // Getting filename being opened and fixing its length
    FileName := string(PChar(Msg.CopyDataStruct.lpData));
    SetLength(FileName, Msg.CopyDataStruct.dwData);
    Msg.Result := 1;
  end;
}

var
  S: string;
  CopyDataStruct: TCopyDataStruct;
  I: Integer;
begin
  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);

    CopyDataStruct.dwData := Length(S);
    CopyDataStruct.cbData := Length(S) * 2;
    CopyDataStruct.lpData := PWideChar(S);

    SendMessage(Handle, WM_COPYDATA, Integer(Handle), Integer(@CopyDataStruct));
  end;
end;

initialization

  GnvInstanceName := StringReplace(ParamStr(0), '\', '', [rfReplaceAll, rfIgnoreCase]);

end.
