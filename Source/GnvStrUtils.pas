unit GnvStrUtils;

interface

uses
  Classes, SysUtils;

const
  GNV_STRING_FILTER_CARDINAL  = '0123456789';
  GNV_STRING_FILTER_INTEGER   = GNV_STRING_FILTER_CARDINAL + '-';
  GNV_STRING_FILTER_FILENAME  = '/*?"<>|';

var
  CodePage: Integer;

procedure GnvCopyCharCase(var ToChar: WideChar; FromChar: WideChar);
function GnvEntryCountStr(const Str: string; const SubStr: string): Cardinal;
function GnvEntryCountText(const Text: string; const SubText: string): Cardinal;
function GnvFilterText(const Text, Filter: string; Exclude: Boolean = False): string;
function GnvFilterStr(const Str, Filter: string; Exclude: Boolean = False): string;
function GnvCreateGUIDStr(UpperCase: Boolean = False;
  Hyphen: Boolean = False; Brackets: Boolean = False): string;
function GnvGUIDToStr(GUID: TGUID; UpperCase: Boolean = False;
  Hyphen: Boolean = False; Brackets: Boolean = False): string;
function GnvIsASCIIStr(const Str: UnicodeString): Boolean;
function GnvIsFileNameStr(const Str: string): Boolean; inline;
function GnvIsValidInput(const Key: Char; const Filter: string;
  Exclude: Boolean = False): Boolean;
function GnvIsValidStr(const Str, Filter: string; Exclude: Boolean = False): Boolean;
function GnvIsValidText(const Text, Filter: string; Exclude: Boolean = False): Boolean;
function GnvPosText(const SubText, Text: string): Integer;
function GnvPosTextEx(const SubText, Text: string; Offset: Integer = 1): Integer;
function GnvStrToGUID(const Str: string; RemoveSeparators: Boolean = False): TGUID;
function GnvTrimLeft(const Str: AnsiString; const TrimStr: AnsiString): AnsiString; overload;
function GnvTrimLeft(const Str: string; const TrimStr: string): string; overload;
function GnvTrimRight(const Str: AnsiString; const TrimStr: AnsiString): AnsiString; overload;
function GnvTrimRight(const Str: string; const TrimStr: string): string; overload;
function GnvExtractStr(const Str, Delims: string; Index: Integer): string;
procedure GnvExtractStrings(const Separators, WhiteSpace, Content: string; Strings: TStrings; IncludeEmptyStrings: Boolean = False); overload;
function GnvLongestStr(const Str1, Str2: string): string; inline;
function GnvCapitalizeStr(const Str: string): string; inline;
function GnvNumberedFormat(const Format: string; const Arguments: array of const): string;
function GnvPluralize(const Value: Integer; const Forms: array of string; const LocaleName: string = ''): string;

implementation

uses
  Windows, StrUtils, AnsiStrings, RTLConsts, Math, Variants;

procedure GnvCopyCharCase(var ToChar: WideChar; FromChar: WideChar);
begin
  if WideUpperCase(FromChar) <> WideLowerCase(FromChar) then
  begin
    if WideUpperCase(FromChar) = FromChar then
      ToChar := WideUpperCase(ToChar)[1]
    else
      ToChar := WideLowerCase(ToChar)[1];
  end;
end;

function GnvEntryCountStr(const Str: string; const SubStr: string): Cardinal;
var
  I: Integer;
begin
  Result := 0;

  I := 1;
  while I <= Length(Str) do
    if MidStr(Str, I, Length(SubStr)) = SubStr then
    begin
      Inc(Result);
      I := I + Length(SubStr);
    end
    else
      I := I + 1;
end;

function GnvEntryCountText(const Text: string; const SubText: string): Cardinal;
begin
  Result := GnvEntryCountStr(WideUpperCase(Text), WideUpperCase(SubText));
end;

function GnvFilterStr(const Str, Filter: string; Exclude: Boolean): string;
var
  P: Integer;
  I: Integer;
begin
  Result := '';
  if Filter <> '' then
    for I := 1 to Length(Str) do
    begin
      P := Pos(Str[I], Filter);

      if ((P > 0) and not Exclude) or ((P = 0) and Exclude) then
        Result := Result + Str[I];
    end
  else
    Result := Str;
end;

function GnvFilterText(const Text, Filter: string; Exclude: Boolean): string;
begin
  Result := GnvFilterStr(WideUpperCase(Text), WideUpperCase(Filter), Exclude);
end;

function GnvCreateGUIDStr(UpperCase: Boolean = False;
	Hyphen: Boolean = False; Brackets: Boolean = False): string;
const
	Chars = '0123456789abcdef';
var
//	I: Integer;
	GUID: TGUID;
begin
	CreateGUID(GUID);
	Result := GUIDToString(GUID);

	if not Hyphen then
		Result := Copy(Result, 1, 9) + Copy(Result, 11, 4) + Copy(Result, 16, 4) + Copy(Result, 21, 4) + Copy(Result, 26, 12);

	if not Brackets then Result := Copy(Result, 2, Length(Result) - 1);
{
	Randomize;
	SetLength(Result, 36);
	for I := 1 to 36 do
		Result[I] := Chars[Random(16) + 1];
}
end;

function GnvGUIDToStr(GUID: TGUID; UpperCase: Boolean = False;
  Hyphen: Boolean = False; Brackets: Boolean = False): string;
begin
	Result := GUIDToString(GUID);

	if not Hyphen then
		Result := Copy(Result, 1, 9) + Copy(Result, 11, 4) + Copy(Result, 16, 4) + Copy(Result, 21, 4) + Copy(Result, 26, 12);

	if not Brackets then Result := Copy(Result, 2, Length(Result) - 2);

	if not UpperCase then Result := LowerCase(Result);


(*
	if Hyphen then
		Result :=
			Format('%0.8x-%0.4x-%0.4x-%0.2x%0.2x-%0.2x%0.2x%0.2x%0.2x%0.2x%0.2x', [
				GUID.D1, GUID.D2, GUID.D3,
				GUID.D4[0], GUID.D4[1], GUID.D4[2], GUID.D4[3],
				GUID.D4[4], GUID.D4[5], GUID.D4[6], GUID.D4[7]])
	else
		Result :=
			Format('%0.8x%0.4x%0.4x%0.2x%0.2x%0.2x%0.2x%0.2x%0.2x%0.2x%0.2x', [
				GUID.D1, GUID.D2, GUID.D3,
				GUID.D4[0], GUID.D4[1], GUID.D4[2], GUID.D4[3],
				GUID.D4[4], GUID.D4[5], GUID.D4[6], GUID.D4[7]]);

	if not UpperCase then Result := LowerCase(Result);

	if Brackets then Result := '{' + Result + '}';
*)
end;

function GnvIsASCIIStr(const Str: UnicodeString): Boolean;
var
  P: PByte;
  I: Integer;
begin
  Result := True;
  P := PByte(PWideChar(Str));
  for I := 1 to Length(Str) do
    // Detecting if two-byte character symbol part is in standart ASCII table
    // and code part defines English codepage
    if (Ord(PChar(P)^) >= 128) or (PByte(P + 1)^ <> 0) then
    begin
      Result := False;
      Exit;
    end
    else
      P := P + 2;
end;

function GnvIsFileNameStr(const Str: string): Boolean;
begin
  Result := GnvIsValidStr(Str, GNV_STRING_FILTER_FILENAME, True);
end;

function GnvIsValidInput(const Key: Char; const Filter: string;
  Exclude: Boolean): Boolean;
begin
  Result := True;
  // Ctrl+A, Ctrl+V, Ctrl+C, Ctrl+X, Ctrl+Z, Backspace
  if not CharInSet(Key, [#1, #3, #8, #22, #24, #26]) then
    Result := GnvIsValidText(Key, Filter, Exclude);
end;

function GnvIsValidStr(const Str, Filter: string; Exclude: Boolean = False): Boolean;
var
  I: Integer;
begin
  Result := True;
  if Filter <> '' then
    for I := 1 to Length(Str) do
    begin
      if Pos(Str[I], Filter) > 0 then
        Result := not Exclude
      else
        Result := Exclude;
      if Result = False then Exit;
    end;
end;

function GnvIsValidText(const Text, Filter: string; Exclude: Boolean = False): Boolean;
begin
  Result := GnvIsValidStr(WideUpperCase(Text), WideUpperCase(Filter), Exclude);
end;

function GnvPosText(const SubText, Text: string): Integer;
begin
  Result := Pos(WideUpperCase(SubText), WideUpperCase(Text));
end;

function GnvPosTextEx(const SubText, Text: string; Offset: Integer = 1): Integer;
begin
	Result := PosEx(WideUpperCase(SubText), WideUpperCase(Text), Offset);
end;

function GnvStrToGUID(const Str: string; RemoveSeparators: Boolean = False): TGUID;
var
  S: string;
  I: Integer;
begin
  if RemoveSeparators then
  begin
    S := '';
    for I := 1 to Length(Str)do
      if CharInSet(Str[I], ['0'..'9', 'A'..'F', 'a'..'f']) then
        S := S + Str[I];
  end
  else
    S := Str;

  Result.D1     := StrToInt('$' + S[1]  + S[2] + S[3] + S[4] + S[5] + S[6] + S[7] + S[8]);
  Result.D2     := StrToInt('$' + S[9]  + S[10] + S[11] + S[12]);
  Result.D3     := StrToInt('$' + S[13] + S[14] + S[15] + S[16]);
  Result.D4[0]  := StrToInt('$' + S[17] + S[18]);
  Result.D4[1]  := StrToInt('$' + S[19] + S[20]);
  Result.D4[2]  := StrToInt('$' + S[21] + S[22]);
  Result.D4[3]  := StrToInt('$' + S[23] + S[24]);
  Result.D4[4]  := StrToInt('$' + S[25] + S[26]);
  Result.D4[5]  := StrToInt('$' + S[27] + S[28]);
  Result.D4[6]  := StrToInt('$' + S[29] + S[30]);
  Result.D4[7]  := StrToInt('$' + S[31] + S[32]);
end;

function GnvTrimLeft(const Str: AnsiString; const TrimStr: AnsiString): AnsiString;
begin
  Result := Str;
  if (Str <> '') and (PosEx(Str[1], TrimStr) > 0)  then
    Result := GnvTrimLeft(RightStr(Str, Length(Str) - 1), TrimStr);
end;

function GnvTrimLeft(const Str: string; const TrimStr: string): string;
begin
  Result := Str;
  if (Str <> '') and (Pos(Str[1], TrimStr) > 0)  then
    Result := GnvTrimLeft(RightStr(Str, Length(Str) - 1), TrimStr);
end;

function GnvTrimRight(const Str: AnsiString; const TrimStr: AnsiString): AnsiString;
begin
  Result := Str;
  if (Str <> '') and (PosEx(Str[Length(Str)], TrimStr) > 0)  then
    Result := GnvTrimRight(LeftStr(Str, Length(Str) - 1), TrimStr);
end;

function GnvTrimRight(const Str: string; const TrimStr: string): string;
begin
  Result := Str;
  if (Str <> '') and (Pos(Str[Length(Str)], TrimStr) > 0) then
    Result := GnvTrimRight(LeftStr(Str, Length(Str) - 1), TrimStr);
end;

function GnvExtractStr(const Str, Delims: string; Index: Integer): string;
var
  Strings: TStrings;
begin
  Result := '';

  Strings := TStringList.Create;
  GnvExtractStrings(Delims, '', Str, Strings);

  if Index <= Strings.Count - 1 then
    Result := Strings[Index];

  Strings.Free;
end;

procedure GnvExtractStrings(const Separators, WhiteSpace, Content: string; Strings: TStrings;
  IncludeEmptyStrings: Boolean = False);
var
  S: string;
  I: Integer;
begin
  if Assigned(Strings) then
  begin
    Strings.Clear;
    S := '';

    for I := 1 to Length(Content) do
      if GnvPosText(Content[I], Separators) = 0 then
      begin
        // Excluding whitespace symbols from the beginning of the Content
        if IncludeEmptyStrings or (S <> '') or (GnvPosText(Content[I], WhiteSpace) = 0) then
          S := S + Content[I];
      end
      else if IncludeEmptyStrings or (S <> '') then
      begin
        Strings.Add(S);
        S := '';
      end;
    if S <> '' then Strings.Add(S);
  end;
end;

function GnvCapitalizeStr(const Str: string): string;
begin
	Result := '';
	if Str <> '' then
		Result := UpperCase(Str[1]) + LowerCase(MidStr(Str, 2, Length(Str) - 1));
end;

function GnvLongestStr(const Str1, Str2: string): string;
begin
	if Length(Str1) > Length(Str2) then
		Result := Str1
	else
  	Result := Str2;
end;

function GnvNumberedFormat(const Format: string; const Arguments: array of const): string;
var
  Key: string;
  I, Pos1: Integer;
  S: string;
begin
  Result := Format;

  for I := 0 to Length(Arguments) - 1 do
  begin
    Key := '%' + IntToStr(I + 1);
    Pos1 := Pos(Key, Result);
    if Pos1 > 0 then
    begin
      S := '';
      with Arguments[I] do
      try
        case VType of
            vtInteger:        S := IntToStr(VInteger);
            vtBoolean:        S := BoolToStr(VBoolean);
            vtChar:           S := string(VChar);
            vtExtended:       S := FloatToStr(VExtended^);
            vtString:         S := string(VString^);
            vtPointer:        S := IntToStr( Longint (VPointer) );
            vtPChar:          S := string(StrPas(VPChar));
            vtObject:         S := VObject.ClassName;
            vtClass:          S := VClass.ClassName;
            vtAnsiString:     S := string(VAnsiString);
            vtWideChar:       S := Char(VWideChar);
            vtPWideChar:      S := WideCharToString(VPWideChar);
            vtWideString:     S := WideCharToString(VWideString);
            vtCurrency:       S := FloatToStr(VCurrency^);
            vtInt64:          S := IntToStr(VInt64^);
            vtVariant:        S := VVariant^;
            vtUnicodeString:  S := string(VUnicodeString);
        end;
      except
        S := '';
      end;


      Result := LeftStr(Result, Pos1 - 1) + S +
        RightStr(Result, Length(Result) - Pos1 - Length(Key) + 1);
    end;
  end;
end;

function GnvPluralize(const Value: Integer; const Forms: array of string; const LocaleName: string = ''): string;
type
  TRule = record
    Language: string;
    Number: Integer;
  end;
const
  // http://docs.translatehouse.org/projects/localization-guide/en/latest/l10n/pluralforms.html?id=l10n/pluralforms
  // 0: nplurals=2; plural=(n != 1);
  // 1: nplurals=2; plural=(n > 1);
  // 2: nplurals=1; plural=0;
  // 3: nplurals=3; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);
  // 4: nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;
  // 5: nplurals=6; plural=(n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5);
  // 6: nplurals=3; plural=(n==1) ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;
  // 7: nplurals=4; plural=(n==1) ? 0 : (n==2) ? 1 : (n != 8 && n != 11) ? 2 : 3;
  // 8: nplurals=5; plural=n==1 ? 0 : n==2 ? 1 : (n>2 && n<7) ? 2 :(n>6 && n<11) ? 3 : 4;
  // 9: nplurals=4; plural=(n==1 || n==11) ? 0 : (n==2 || n==12) ? 1 : (n > 2 && n < 20) ? 2 : 3;
  // 10: nplurals=2; plural=(n%10!=1 || n%100==11);
  // 11: nplurals=2; plural=(n != 0);
  // 12: nplurals=4; plural=(n==1) ? 0 : (n==2) ? 1 : (n == 3) ? 2 : 3;
  // 13: nplurals=3; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && (n%100<10 || n%100>=20) ? 1 : 2);
  // 14: nplurals=3; plural=(n%10==1 && n%100!=11 ? 0 : n != 0 ? 1 : 2);
  // 15: nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;
  // 16: nplurals=2; plural= n==1 || n%10==1 ? 0 : 1; Can’t be correct needs a 2 somewhere
  // 17: nplurals=3; plural=(n==0 ? 0 : n==1 ? 1 : 2);
  // 18: nplurals=4; plural=(n==1 ? 0 : n==0 || ( n%100>1 && n%100<11) ? 1 : (n%100>10 && n%100<20 ) ? 2 : 3);
  // 19: nplurals=3; plural=(n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);
  // 20: nplurals=3; plural=(n==1 ? 0 : (n==0 || (n%100 > 0 && n%100 < 20)) ? 1 : 2);
  // 21: nplurals=4; plural=(n%100==1 ? 0 : n%100==2 ? 1 : n%100==3 || n%100==4 ? 2 : 3);
  Rules: array[0..142] of TRule = (
    (Language: 'en';		Number: 0),
    (Language: 'af';		Number: 0),
    (Language: 'an';		Number: 0),
    (Language: 'anp';		Number: 0),
    (Language: 'as';		Number: 0),
    (Language: 'ast';		Number: 0),
    (Language: 'az';		Number: 0),
    (Language: 'bg';		Number: 0),
    (Language: 'bn';		Number: 0),
    (Language: 'brx';		Number: 0),
    (Language: 'ca';		Number: 0),
    (Language: 'da';		Number: 0),
    (Language: 'de';		Number: 0),
    (Language: 'doi';		Number: 0),
    (Language: 'el';		Number: 0),
    (Language: 'eo';		Number: 0),
    (Language: 'es';		Number: 0),
    (Language: 'es-ar';	Number: 0),
    (Language: 'et';		Number: 0),
    (Language: 'eu';		Number: 0),
    (Language: 'ff';		Number: 0),
    (Language: 'fi';		Number: 0),
    (Language: 'fo';		Number: 0),
    (Language: 'fur';		Number: 0),
    (Language: 'fy';		Number: 0),
    (Language: 'gl';		Number: 0),
    (Language: 'gu';		Number: 0),
    (Language: 'ha';		Number: 0),
    (Language: 'he';		Number: 0),
    (Language: 'hi';		Number: 0),
    (Language: 'hne';		Number: 0),
    (Language: 'hu';		Number: 0),
    (Language: 'hy';		Number: 0),
    (Language: 'ia';		Number: 0),
    (Language: 'it';		Number: 0),
    (Language: 'kk';		Number: 0),
    (Language: 'kl';		Number: 0),
    (Language: 'kn';		Number: 0),
    (Language: 'ku';		Number: 0),
    (Language: 'ky';		Number: 0),
    (Language: 'lb';		Number: 0),
    (Language: 'mai';		Number: 0),
    (Language: 'ml';		Number: 0),
    (Language: 'mn';		Number: 0),
    (Language: 'mni';		Number: 0),
    (Language: 'mr';		Number: 0),
    (Language: 'nah';		Number: 0),
    (Language: 'nap';		Number: 0),
    (Language: 'nb';		Number: 0),
    (Language: 'ne';		Number: 0),
    (Language: 'nl';		Number: 0),
    (Language: 'nn';		Number: 0),
    (Language: 'no';		Number: 0),
    (Language: 'nso';		Number: 0),
    (Language: 'or';		Number: 0),
    (Language: 'pa';		Number: 0),
    (Language: 'pap';		Number: 0),
    (Language: 'pms';		Number: 0),
    (Language: 'ps';		Number: 0),
    (Language: 'pt';		Number: 0),
    (Language: 'rm';		Number: 0),
    (Language: 'rw';		Number: 0),
    (Language: 'sat';		Number: 0),
    (Language: 'sco';		Number: 0),
    (Language: 'sd';		Number: 0),
    (Language: 'se';		Number: 0),
    (Language: 'si';		Number: 0),
    (Language: 'so';		Number: 0),
    (Language: 'son';		Number: 0),
    (Language: 'sq';		Number: 0),
    (Language: 'sv';		Number: 0),
    (Language: 'sw';		Number: 0),
    (Language: 'ta';		Number: 0),
    (Language: 'te';		Number: 0),
    (Language: 'tk';		Number: 0),
    (Language: 'ur';		Number: 0),
    (Language: 'yo';		Number: 0),
    (Language: 'ach';		Number: 1),
    (Language: 'ak';		Number: 1),
    (Language: 'am';		Number: 1),
    (Language: 'arn';		Number: 1),
    (Language: 'br';		Number: 1),
    (Language: 'fa';		Number: 1),
    (Language: 'fil';		Number: 1),
    (Language: 'fr';		Number: 1),
    (Language: 'gun';		Number: 1),
    (Language: 'ln';		Number: 1),
    (Language: 'mfe';		Number: 1),
    (Language: 'mg';		Number: 1),
    (Language: 'mi';		Number: 1),
    (Language: 'oc';		Number: 1),
    (Language: 'pt-br';	Number: 1),
    (Language: 'tg';		Number: 1),
    (Language: 'ti';		Number: 1),
    (Language: 'tr';		Number: 1),
    (Language: 'uz';		Number: 1),
    (Language: 'wa';    Number: 1),
    (Language: 'zh';		Number: 2),
    (Language: 'ay';		Number: 2),
    (Language: 'bo';		Number: 2),
    (Language: 'cgg';		Number: 2),
    (Language: 'dz';		Number: 2),
    (Language: 'id';		Number: 2),
    (Language: 'ja';		Number: 2),
    (Language: 'jbo';		Number: 2),
    (Language: 'ka';		Number: 2),
    (Language: 'km';		Number: 2),
    (Language: 'ko';		Number: 2),
    (Language: 'lo';		Number: 2),
    (Language: 'ms';		Number: 2),
    (Language: 'my';		Number: 2),
    (Language: 'sah';		Number: 2),
    (Language: 'su';		Number: 2),
    (Language: 'th';		Number: 2),
    (Language: 'tt';		Number: 2),
    (Language: 'ug';		Number: 2),
    (Language: 'vi';		Number: 2),
    (Language: 'wo';		Number: 2),
    (Language: 'ru';		Number: 3),
    (Language: 'uk';		Number: 3),
    (Language: 'be';		Number: 3),
    (Language: 'bs';		Number: 3),
    (Language: 'hr';		Number: 3),
    (Language: 'sr';		Number: 3),
    (Language: 'cs';		Number: 4),
    (Language: 'sk';		Number: 4),
    (Language: 'ar';		Number: 5),
    (Language: 'csb';		Number: 6),
    (Language: 'cy';		Number: 7),
    (Language: 'ga';		Number: 8),
    (Language: 'gd';		Number: 9),
    (Language: 'is';		Number: 10),
    (Language: 'jv';		Number: 11),
    (Language: 'kw';		Number: 12),
    (Language: 'lt';		Number: 13),
    (Language: 'lv';		Number: 14),
    (Language: 'me';		Number: 15),
    (Language: 'mk';		Number: 16),
    (Language: 'mnk';		Number: 17),
    (Language: 'mt';		Number: 18),
    (Language: 'pl';		Number: 19),
    (Language: 'ro';		Number: 20),
    (Language: 'sl';		Number: 21)
  );
var
  I, P, N, Plural, Rule: Integer;
  Language: string;
begin
  N := Abs(Value);

  Language := LowerCase(StringReplace(LocaleName, '_', '-', [rfReplaceAll]));

  if (Language <> 'es-ar') and (Language <> 'pt-br') then
  begin
    P := Pos('-', Language);
    if P > 0 then Language := LeftStr(Language, P - 1);
  end;

  Rule := 0;
  if Language <> '' then
  begin
    for I := 0 to Length(Rules) - 1 do
      if Rules[I].Language = Language then
      begin
        Rule := Rules[I].Number;
        Break;
      end;
  end;

  Plural := 0;
  case Rule of
    0:  Plural := Integer(N <> 1);
    1:  Plural := Integer(N > 1);
    2:  Plural := 0;
    3:  Plural := IfThen((N mod 10 = 1) and (N mod 100 <> 11), 0, IfThen((N mod 10 >= 2) and (N mod 10 <= 4) and ((N mod 100 < 10) or (N mod 100 >= 20)), 1, 2));
    4:  Plural := IfThen(N = 1, 0, IfThen((N >= 2) and (N <= 4), 1, 2));
    5:  Plural := IfThen(N = 0, 0, IfThen(N = 1, 1, IfThen(N = 2, 2, IfThen((N mod 100 >= 3) and (N mod 100 <= 10), 3, IfThen(N mod 100 >= 11, 4, 5)))));
    6:  Plural := IfThen(N = 1, 0, IfThen((N mod 10 >= 2) and (N mod 10 <= 4) and ((N mod 100 < 10) or (N mod 100 >= 20)), 1, 2));
    7:  Plural := IfThen(N = 1, 0, IfThen(N = 2, 1, IfThen((N <> 8) and (N <> 11), 2, 3)));
    8:  Plural := IfThen(N = 1, 0, IfThen(N = 2, 1, IfThen((N > 2) and (N < 7), 2, IfThen((N > 6) and (N < 11), 3, 4))));
    9:  Plural := IfThen((N = 1) or (N = 11), 0, IfThen((N = 2) or (N = 12), 1, IfThen((N > 2) and (N < 20), 2, 3)));
    10: Plural := Integer((N mod 10 <> 1) or (N mod 100 <> 11));
    11: Plural := Integer(N <> 0);
    12: Plural := IfThen(N = 1, 0, IfThen(N = 2, 1, IfThen(N = 3, 2, 3)));
    13: Plural := IfThen((N mod 10 = 1) and (N mod 100 <> 11), 0, IfThen((N mod 10 >= 2) and ((N mod 100 < 10) or (N mod 100 >= 20)), 1, 2));
    14: Plural := IfThen((N mod 10 = 1) and (N mod 100 <> 11), 0, IfThen(N <> 0, 1, 2));
    15: Plural := IfThen((N mod 10 = 1) and (N mod 100 <> 11), 0, IfThen((N mod 10 >= 2) and (N mod 10 <= 4) and ((N mod 100 < 10) or (N mod 100 >= 20)), 1, 2));
    16: Plural := IfThen((N = 1) or (N mod 10 = 1), 0, 1);
    17: Plural := IfThen(N = 0, 0, IfThen(N = 1, 1, 2));
    18: Plural := IfThen(N = 1, 0, IfThen((N = 0) or ((N mod 100 > 1) and (N mod 100 < 11)), 1, IfThen((N mod 100 > 10) and (N mod 100 < 20), 2, 3)));
    19: Plural := IfThen(N = 1, 0, IfThen((N mod 10 >= 2) and (N mod 10 <= 4) and ((N mod 100 < 10) or (N mod 100 >= 20)), 1, 2));
    20: Plural := IfThen(N = 1, 0, IfThen((N = 0) or ((N mod 100 > 0) and (N mod 100 < 20)), 1, 2));
    21: Plural := IfThen(N mod 100 = 1, 0, IfThen(N mod 100 = 2, 1, IfThen((N mod 100 = 3) or (N mod 100 = 4), 2, 3)));
  end;

  if Length(Forms) > Plural then
    Result := Forms[Plural];
end;

initialization
  CodePage := DefaultSystemCodePage;

end.
