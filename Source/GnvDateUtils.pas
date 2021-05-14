unit GnvDateUtils;

interface

uses
  Windows;

function GnvIdleMilliseconds: Cardinal;
function GnvSecondsToTime(Seconds: Integer): TTime;

function GnvDateToLongFormat(DateTime: TDateTime): string;
function GnvDateToShortFormat(DateTime: TDateTime): string;
function GnvTimeToLongFormat(DateTime: TDateTime): string;
function GnvTimeToShortFormat(DateTime: TDateTime): string;

function GnvFileTimeToUnix(const FileTime: TFileTime): Int64;
function GnvUnixToFileTime(const Unix: Int64): TFileTime;
function GnvUnixToLocalDateTime(const Unix: Int64): TDateTime;

function TzSpecificLocalTimeToSystemTime(lpTimeZoneInformation: PTimeZoneInformation;  var lpLocalTime, lpUniversalTime: TSystemTime): BOOL; stdcall; external kernel32 name 'TzSpecificLocalTimeToSystemTime';
function SystemTimeToTzSpecificLocalTime(lpTimeZoneInformation: PTimeZoneInformation;  var lpUniversalTime, lpLocalTime: TSystemTime): BOOL; stdcall; external kernel32 name 'SystemTimeToTzSpecificLocalTime';

implementation

uses
  SysUtils, DateUtils;

function GnvDateToLongFormat(DateTime: TDateTime): string;
var
  FormatSettings: TFormatSettings;
begin
  GetLocaleFormatSettings(GetThreadLocale, FormatSettings);
  DateTimeToString(Result, FormatSettings.LongDateFormat, DateTime, FormatSettings);
end;

function GnvDateToShortFormat(DateTime: TDateTime): string;
var
  FormatSettings: TFormatSettings;
begin
  GetLocaleFormatSettings(GetThreadLocale, FormatSettings);
  DateTimeToString(Result, FormatSettings.ShortDateFormat, DateTime, FormatSettings);
end;

function GnvTimeToLongFormat(DateTime: TDateTime): string;
var
  FormatSettings: TFormatSettings;
begin
  GetLocaleFormatSettings(GetThreadLocale, FormatSettings);
  DateTimeToString(Result, FormatSettings.LongTimeFormat, DateTime, FormatSettings);
end;

function GnvTimeToShortFormat(DateTime: TDateTime): string;
var
  FormatSettings: TFormatSettings;
begin
  GetLocaleFormatSettings(GetThreadLocale, FormatSettings);
  DateTimeToString(Result, FormatSettings.ShortTimeFormat, DateTime, FormatSettings);
end;

function GnvFileTimeToUnix(const FileTime: TFileTime): Int64;
var
  DateTime: TDateTime;
  SystemTime: TSystemTime;
begin
  FileTimeToSystemTime(FileTime, SystemTime);
  DateTime := SystemTimeToDateTime(SystemTime);
  Result := DateTimeToUnix(DateTime);
end;

function GnvUnixToFileTime(const Unix: Int64): TFileTime;
var
  DateTime: TDateTime;
  SystemTime: TSystemTime;
begin
  DateTime := UnixToDateTime(Unix);
  DateTimeToSystemTime(DateTime, SystemTime);
  SystemTimeToFileTime(SystemTime, Result);
end;

function GnvUnixToLocalDateTime(const Unix: Int64): TDateTime;
var
  TZI: TTimeZoneInformation;
  LocalTime, UniversalTime: TSystemTime;
begin
  Result := UnixToDateTime(Unix);
  GetTimeZoneInformation(TZI);
  DateTimeToSystemTime(Result, UniversalTime);
  SystemTimeToTzSpecificLocalTime(@TZI, UniversalTime, LocalTime);
  Result := SystemTimeToDateTime(LocalTime);
end;

function GnvIdleMilliseconds: Cardinal;
var
  Info: TLastInputInfo;
begin
  Info.cbSize := SizeOf(TLastInputInfo);
  GetLastInputInfo(Info);
  Result := GetTickCount - Info.dwTime;
end;

function GnvSecondsToTime(Seconds: Integer): TTime;
var
  H, M, S: Word;
begin
  Result := 0;
  if Seconds > 0 then
  begin
    H := Seconds div 3600;
    M := Seconds div 60 - H * 60;
    S := Seconds - (H * 3600 + M * 60);
    Result := EncodeTime(H, M, S, 0);
  end;
end;

end.
