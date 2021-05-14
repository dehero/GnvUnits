unit GnvVariants;

interface

uses
  Variants;

function GnvVarToBoolDef(const V: Variant; const ADefault: Boolean): Boolean;
function GnvVarToIntDef(const V: Variant; const ADefault: Integer): Integer;

implementation

function GnvVarToBoolDef(const V: Variant; const ADefault: Boolean): Boolean;
begin
  if VarIsType(V, varBoolean) then
    Result := V
  else
    Result := ADefault;
end;

function GnvVarToIntDef(const V: Variant; const ADefault: Integer): Integer;
begin
  if VarIsNumeric(V) then
    Result := V
  else
    Result := ADefault;
end;

end.
