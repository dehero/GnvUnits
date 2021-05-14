unit GnvGraphics;

interface

uses
  Graphics;

function GnvBlend(Color1, Color2: TColor; Value: Byte = 127): TColor;
function GnvBrighten(Color: TColor; Percent: Single): TColor;
function GnvDarken(Color: TColor; Percent: Single): TColor;
function GnvColorToHex(Color: TColor): string;
function GnvHexToColor(Hex: string; Default: TColor = clDefault): TColor;

implementation

uses
  SysUtils, Windows, GraphUtil, Math, Dialogs,
  GnvStrUtils;

function GnvBrighten(Color: TColor; Percent: Single): TColor;
var
  H, L, S: Word;
begin
  ColorRGBToHLS(Color, H, L, S);
  Result := ColorHLSToRGB(H, Min(Round(L * (1 + Abs(Percent) / 100)), 255), S);
end;

function GnvDarken(Color: TColor; Percent: Single): TColor;
var
  H, L, S: Word;
begin
  ColorRGBToHLS(Color, H, L, S);
  Result := ColorHLSToRGB(H, Max(Round(L * (1 - Abs(Percent) / 100)), 0), S);
end;

function GnvBlend(Color1, Color2: TColor; Value: Byte = 127): TColor;
var
  C1, C2: LongInt;
  R, R1, R2, G, G1, G2, B, B1, B2: Byte;
begin
  C1 := ColorToRGB(Color1);
  C2 := ColorToRGB(Color2);

  R1 := GetRValue(C1);
  G1 := GetGValue(C1);
  B1 := GetBValue(C1);
  R2 := GetRValue(C2);
  G2 := GetGValue(C2);
  B2 := GetBValue(C2);

  R := R2 + (R1 - R2) * Value div 256;
  G := G2 + (G1 - G2) * Value div 256;
  B := B2 + (B1 - B2) * Value div 256;

  Result := RGB(R, G, B);
end;

function GnvColorToHex(Color: TColor): string;
begin
  Result :=
    IntToHex(GetRValue(Color), 2) +
    IntToHex(GetGValue(Color), 2) +
    IntToHex(GetBValue(Color), 2) ;
end;

function GnvHexToColor(Hex: string; Default: TColor = clDefault): TColor;
var
  S: string;
begin
  Result := Default;

  S := GnvTrimLeft(Hex, '#');

  if (Length(S) = 6) then
  begin
    // TColor is BGR not RGB
    S := '$00' + Copy(S, 5, 2) + Copy(S, 3, 2) + Copy(S, 1, 2);
    Result := StrToInt(S);
  end;
end;

end.
