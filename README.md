# GnvUnits

A collection of Delphi units with useful functions and classes.

Version `0.1.1`

<!-- TOC -->

- [GnvCrypt](#gnvcrypt)
    - [GnvEncryptStr](#gnvencryptstr)
    - [GnvDecryptStr](#gnvdecryptstr)
- [GnvDateUtils](#gnvdateutils)
    - [GnvIdleMilliseconds](#gnvidlemilliseconds)
    - [GnvSecondsToTime](#gnvsecondstotime)
    - [GnvDateToLongFormat](#gnvdatetolongformat)
    - [GnvDateToShortFormat](#gnvdatetoshortformat)
    - [GnvTimeToLongFormat](#gnvtimetolongformat)
    - [GnvTimeToShortFormat](#gnvtimetoshortformat)
    - [GnvFileTimeToUnix](#gnvfiletimetounix)
    - [GnvUnixToFileTime](#gnvunixtofiletime)
    - [GnvUnixToLocalDateTime](#gnvunixtolocaldatetime)
- [GnvGraphics](#gnvgraphics)
    - [GnvBlend](#gnvblend)
    - [GnvBrighten](#gnvbrighten)
    - [GnvDarken](#gnvdarken)
    - [GnvColorToHex](#gnvcolortohex)
    - [GnvHexToColor](#gnvhextocolor)
- [GnvHstry](#gnvhstry)
    - [TGnvHistory](#tgnvhistory)
        - [AddEvent](#addevent)
        - [BeginState](#beginstate)
        - [CancelState](#cancelstate)
        - [CanRedo](#canredo)
        - [CanUndo](#canundo)
        - [EndState](#endstate)
        - [Redo](#redo)
        - [Undo](#undo)
- [GnvInstanceUtils](#gnvinstanceutils)
    - [GnvGetRunningInstance](#gnvgetrunninginstance)
    - [GnvSetRunningInstance](#gnvsetrunninginstance)
    - [GnvClearRunningInstance](#gnvclearrunninginstance)
    - [GnvRestoreRunningInstance](#gnvrestorerunninginstance)
    - [GnvSendParamStrings](#gnvsendparamstrings)
- [GnvJSON](#gnvjson)
    - [TGnvJSONData](#tgnvjsondata)
        - [Detach](#detach)
        - [Merge](#merge)
        - [ItemByName](#itembyname)
        - [ToString](#tostring)
        - [ToFormattedString](#toformattedstring)
    - [TGnvJSONData.ParseString](#tgnvjsondataparsestring)
    - [TGnvJSONObject](#tgnvjsonobject)
        - [Clear](#clear)
        - [Add](#add)
        - [AddObject](#addobject)
        - [AddArray](#addarray)
        - [AddValue](#addvalue)
        - [GetUnmappedString](#getunmappedstring)
        - [IndexOfName](#indexofname)
    - [TGnvJSONArray](#tgnvjsonarray)
        - [Clear](#clear)
        - [Add](#add)
        - [AddObject](#addobject)
        - [AddArray](#addarray)
        - [AddValue](#addvalue)
    - [TGnvJSONValue](#tgnvjsonvalue)
- [GnvMenus](#gnvmenus)
    - [TGnvRecentMenuItems](#tgnvrecentmenuitems)
        - [Create](#create)
        - [Add](#add)
        - [Clear](#clear)
        - [Delete](#delete)
        - [IndexOf](#indexof)
        - [Move](#move)
- [GnvNetUtils](#gnvnetutils)
    - [GnvCompareIP4](#gnvcompareip4)
    - [GnvIP4ToStr](#gnvip4tostr)
    - [GnvIP4RangeToStr](#gnvip4rangetostr)
    - [GnvIP4RangeToStr](#gnvip4rangetostr)
    - [GnvIP4RangeToArray](#gnvip4rangetoarray)
    - [GnvIP4RangeToArray](#gnvip4rangetoarray)
    - [GnvStrToIP4](#gnvstrtoip4)
    - [GnvStrToIP4Range](#gnvstrtoip4range)
    - [GnvCompareMacAddr](#gnvcomparemacaddr)
    - [GnvMacAddrToStr](#gnvmacaddrtostr)
    - [GnvMacAddrToInt64](#gnvmacaddrtoint64)
    - [GnvStrToMacAddr](#gnvstrtomacaddr)
    - [GnvInt64ToMacAddr](#gnvint64tomacaddr)
- [GnvOptns](#gnvoptns)
    - [TGnvOptions](#tgnvoptions)
    - [TGnvOptions.BeginUpdate](#tgnvoptionsbeginupdate)
    - [TGnvOptions.EndUpdate](#tgnvoptionsendupdate)
    - [TGnvOptions.Subscribe](#tgnvoptionssubscribe)
    - [TGnvOptions.Unsubscribe](#tgnvoptionsunsubscribe)
- [GnvSerialization](#gnvserialization)
    - [GnvClearBit](#gnvclearbit)
    - [GnvToggleBit](#gnvtogglebit)
    - [GnvGetBit](#gnvgetbit)
    - [GnvSetBit](#gnvsetbit)
    - [GnvAnsiStrFromStream](#gnvansistrfromstream)
    - [GnvAnsiStrToStream](#gnvansistrtostream)
    - [GnvWideStrFromStream](#gnvwidestrfromstream)
    - [GnvWideStrToStream](#gnvwidestrtostream)
    - [GnvStrFromFile](#gnvstrfromfile)
    - [GnvStrToFile](#gnvstrtofile)
- [GnvStrUtils](#gnvstrutils)
    - [GnvCopyCharCase](#gnvcopycharcase)
    - [GnvEntryCountStr](#gnventrycountstr)
    - [GnvEntryCountText](#gnventrycounttext)
    - [GnvFilterText](#gnvfiltertext)
    - [GnvFilterStr](#gnvfilterstr)
    - [GnvCreateGUIDStr](#gnvcreateguidstr)
    - [GnvGUIDToStr](#gnvguidtostr)
    - [GnvIsASCIIStr](#gnvisasciistr)
    - [GnvIsFileNameStr](#gnvisfilenamestr)
    - [GnvIsValidInput](#gnvisvalidinput)
    - [GnvIsValidStr](#gnvisvalidstr)
    - [GnvIsValidText](#gnvisvalidtext)
    - [GnvPosText](#gnvpostext)
    - [GnvPosTextEx](#gnvpostextex)
    - [GnvStrToGUID](#gnvstrtoguid)
    - [GnvTrimLeft](#gnvtrimleft)
    - [GnvTrimRight](#gnvtrimright)
    - [GnvExtractStr](#gnvextractstr)
    - [GnvExtractStrings](#gnvextractstrings)
    - [GnvLongestStr](#gnvlongeststr)
    - [GnvCapitalizeStr](#gnvcapitalizestr)
    - [GnvNumberedFormat](#gnvnumberedformat)
    - [GnvPluralize](#gnvpluralize)
- [GnvSysUtils](#gnvsysutils)
    - [GnvReverseBytes](#gnvreversebytes)
    - [GnvGetFileChanged](#gnvgetfilechanged)
    - [GnvGetFileSize](#gnvgetfilesize)
    - [GnvExpandEnvPath](#gnvexpandenvpath)
    - [GnvExpandRelativePath](#gnvexpandrelativepath)
    - [GnvExtractRelativePath](#gnvextractrelativepath)
    - [GnvSetFileDate](#gnvsetfiledate)
    - [GnvCPToStr](#gnvcptostr)
    - [GnvStrToCP](#gnvstrtocp)
    - [GnvLocaleNameToLCID](#gnvlocalenametolcid)
    - [GnvLCIDToLocaleName](#gnvlcidtolocalename)
    - [GnvGetLocaleInfo](#gnvgetlocaleinfo)
- [GnvVariants](#gnvvariants)
    - [GnvVarToBoolDef](#gnvvartobooldef)
    - [GnvVarToIntDef](#gnvvartointdef)
- [GnvWindows](#gnvwindows)
    - [GnvGetCurrentUserName](#gnvgetcurrentusername)
    - [GnvGetVersionInfo](#gnvgetversioninfo)
    - [GnvGetResourceAsPointer](#gnvgetresourceaspointer)
    - [GnvGetResourceAsString](#gnvgetresourceasstring)
    - [GnvSaveResourceAsFile](#gnvsaveresourceasfile)
    - [GnvCompareFileVersion](#gnvcomparefileversion)
    - [GnvFileVersion](#gnvfileversion)
    - [GnvFileVersionFromStream](#gnvfileversionfromstream)
    - [GnvFileVersionToStr](#gnvfileversiontostr)
    - [GnvFileVersionToStream](#gnvfileversiontostream)
    - [GnvGetFileVersion](#gnvgetfileversion)
    - [GnvMessageQuery](#gnvmessagequery)

<!-- /TOC -->

## GnvCrypt

### GnvEncryptStr

- Data `AnsiString`
- _Result_ `AnsiString`

### GnvDecryptStr

- Data `AnsiString`
- _Result_ `AnsiString`

## GnvDateUtils

### GnvIdleMilliseconds

- _Result_ `Cardinal`

### GnvSecondsToTime

- Seconds `Integer`
- _Result_ `TTime`

### GnvDateToLongFormat

- DateTime `TDateTime`
- _Result_ `string`

### GnvDateToShortFormat

- DateTime `TDateTime`
- _Result_ `string`

### GnvTimeToLongFormat

- DateTime `TDateTime`
- _Result_ `string`

### GnvTimeToShortFormat

- DateTime `TDateTime`
- _Result_ `string`

### GnvFileTimeToUnix

- FileTime `TFileTime`
- _Result_ `Int64`

### GnvUnixToFileTime

- Unix `Int64`
- _Result_ `TFileTime`

### GnvUnixToLocalDateTime

- Unix `Int64`
- _Result_ `TDateTime`

## GnvGraphics

### GnvBlend

- Color1 `TColor`
- Color2 `TColor`
- Value `Byte` _optional_ `127`
- _Result_ `TColor`

### GnvBrighten

- Color `TColor`
- Percent `Single`
- _Result_ `TColor`

### GnvDarken

- Color `TColor`
- Percent `Single`
- _Result_ `TColor`

### GnvColorToHex

- Color `TColor`
- _Result_ `string`

### GnvHexToColor

- Hex `string`
- Default `TColor` _optional_ `clDefault`
- _Result_ `TColor`

## GnvHstry

### TGnvHistory

- ChangingState `Boolean` _readonly_
- Count `Integer` _readonly_
- OnChange `TGnvHistoryChangeEvent`
- OnFreeEvent `TGnvHistoryFreeEvent`
- OnRedoEvent `TGnvHistoryRedoEvent`
- OnUndoEvent `TGnvHistoryUndoEvent`
- State `Cardinal` _readonly_
- WritingState `Boolean` _readonly_

#### AddEvent

- Data `Pointer`

#### BeginState

#### CancelState
#### CanRedo

- _Result_ `Boolean`

#### CanUndo

- _Result_ `Boolean`

#### EndState
#### Redo

#### Undo

## GnvInstanceUtils

### GnvGetRunningInstance

- _Result_ `THandle`
### GnvSetRunningInstance

- Handle `THandle`

### GnvClearRunningInstance

### GnvRestoreRunningInstance

- Msg `LongWord` _optional_ `0`

### GnvSendParamStrings

- Handle `HWND`

## GnvJSON

### TGnvJSONData

- Arrays `TGnvJSONArray` _readonly_
  - _Name_ `Variant`
- DataType `TGnvJSONDataType` _readonly_
- Items `TGnvJSONData` _readonly_
  - _Index_ `Integer`
- ItemCount `Integer`_readonly_
- Names `string` _readonly_
  - _Index_ `Integer`
- Objects `TGnvJSONObject` _readonly_
  - _Name_ `Variant`
- Owner `TGnvJSONData` _readonly_
- Value `Variant`
- **Values** `Variant`
  - _Name_ `Variant`

#### Detach

#### Merge

- Data `TGnvJSONData`
- RemoveArrayDuplicates `Boolean` _optional_ `False`
- SkipKeys `TStrings` _optional_

#### ItemByName

- Name `Variant`
- _Result_ `TGnvJSONData`
#### ToString

- _Result_ `string`
#### ToFormattedString

- InitialTabs `Integer` _optional_ `0`
- IndentTabs `Integer` _optional_ `1`
- _Result_ `string`

### TGnvJSONData.ParseString

- Str `string`
- _Result_ `TGnvJSONData`
### TGnvJSONObject

#### Clear

#### Add

- AName `Variant`
- AValue `TGnvJSONData`

#### AddObject

- Name `Variant`
- _Result_ [`TGnvJSONObject`]

#### AddArray

- Name `Variant`
- _Result_ `TGnvJSONArray`

#### AddValue

- Name `Variant`
- _Result_ `TGnvJSONValue`

#### GetUnmappedString

- Map `TStrings`
- _Result_ `string`
#### IndexOfName

- AName `string
- _Result_ `Integer`

### TGnvJSONArray

#### Clear

#### Add

- AItem `TGnvJSONData`

#### AddObject

- _Result_ `TGnvJSONObject`

#### AddArray

- _Result_ `TGnvJSONArray`

#### AddValue

- _Result_ `TGnvJSONValue`

### TGnvJSONValue

- AsString `string`
- AsBoolean `Boolean`
- AsNumber `Double`
- IsNull `Boolean`

## GnvMenus

### TGnvRecentMenuItems

- BaseItem `TMenuItem`
- Count `Integer` _readonly_
- **MenuItems** `TMenuItem`
  - _Index_ `Integer`

#### Create

- ABaseItem `TMenuItem`

#### Add

- MenuItem `TMenuItem`
- _Result_ `Integer`

#### Clear

#### Delete

- Index `Integer`

#### IndexOf

- MenuItem `TMenuItem`
- _Result_ `Integer`

#### Move

- CurIndex `Integer`
- NewIndex `Integer`

## GnvNetUtils

### GnvCompareIP4

- IP41 `LongWord`
- IP42 `LongWord`
- _Result_ `Integer`
### GnvIP4ToStr

- IP4 `LongWord`
- _Result_ `string`
### GnvIP4RangeToStr

- Range `TGnvIP4Range`
- _Result_ `string`
### GnvIP4RangeToStr

- IP41 `LongWord`
- IP42 `LongWord`
- _Result_ `string`
### GnvIP4RangeToArray

- Range `TGnvIP4Range`
- _Result_ `TGnvIP`
### GnvIP4RangeToArray

- IP41 `LongWord`
- IP42 `LongWord`
- _Result_ `TGnvIP`
### GnvStrToIP4

- S `string`
- _Result_ `LongWord`
### GnvStrToIP4Range

- S `string`
- _Result_ `TGnvIP`

### GnvCompareMacAddr

- Mac1 `TGnvMacAddr`
- Mac2 `TGnvMacAddr`
- _Result_ `Integer`
### GnvMacAddrToStr

- Mac `TGnvMacAddr`
- _Result_ `string`
### GnvMacAddrToInt64

- Mac `TGnvMacAddr`
- _Result_ `Int`
### GnvStrToMacAddr

- S `string`
- _Result_ `TGnvMacAddr`
### GnvInt64ToMacAddr

- Value `Int64`
- _Result_ `TGnvMacAddr`

## GnvOptns

### TGnvOptions

- Updating `Boolean` _readonly_

### TGnvOptions.BeginUpdate

### TGnvOptions.EndUpdate
### TGnvOptions.Subscribe

- Proc `TGnvOptionsEvent`

### TGnvOptions.Unsubscribe

- Proc `TGnvOptionsEvent`

## GnvSerialization

### GnvClearBit

- Value `Byte`
- Bit `Byte`
- Result `Byte`

### GnvToggleBit

- Value `Byte`
- Bit `Byte`
- Flag `Boolean`
- _Result_ `Byte`

### GnvGetBit

- Value `Byte`
- Bit `Byte`
- _Result_ `Boolean`
### GnvSetBit

- Value `Byte`
- Bit `Byte`
- _Result_ `Byte`

### GnvAnsiStrFromStream

- Stream `TStream`
- Size `TStringLengthSize`
- _Result_ `AnsiString`

### GnvAnsiStrToStream

- Str `AnsiString`
- Stream `TStream`
- Size `TStringLengthSize`

### GnvWideStrFromStream

- Stream `TStream`
- Size `TStringLengthSize`
- _Result_ `UnicodeString`

### GnvWideStrToStream

- Str `UnicodeString`
- Stream `TStream`
- Size `TStringLengthSize`

### GnvStrFromFile

- FileName `string`
- DefaultEncoding `TEncoding`
- _Result_ `string`

### GnvStrToFile

- FileName `string`
- Str `string`
- Encoding `TEncoding`

## GnvStrUtils

### GnvCopyCharCase

- ToChar `WideChar` _output_
- FromChar `WideChar`

### GnvEntryCountStr

- Str `string`
- SubStr `string`
- _Result_ `Cardinal`

### GnvEntryCountText

- Text `string`
- SubText `string`
- _Result_ `Cardinal`

### GnvFilterText

- Text `string`
- Filter `string`
- Exclude `Boolean` _optional_ `False`
- _Result_ `string`

### GnvFilterStr

- Str `string`
- Filter `string`
- Replace `string` _optional_
- Exclude `Boolean` _optional_ `False`
- _Result_ `string`

### GnvCreateGUIDStr

- UpperCase `Boolean` _optional_ `False`
- Hyphen `Boolean` _optional_ `False`
- Brackets `Boolean` _optional_ `False`
- _Result_ `string`

### GnvGUIDToStr

- GUID `TGUID`
- UpperCase `Boolean` _optional_ `False`
- Hyphen `Boolean` _optional_ `False`
- Brackets `Boolean` _optional_ `False`
- _Result_ `string`

### GnvIsASCIIStr

- Str `UnicodeString`
- _Result_ `Boolean`

### GnvIsFileNameStr

- Str `string`
- _Result_ `Boolean` inline

### GnvIsValidInput

- Key `Char`
- Filter `string`
- Exclude `Boolean` _optional_ `False`
- _Result_ `Boolean`

### GnvIsValidStr

- Str `string`
- Filter `string`
- Exclude `Boolean` _optional_ `False`
- _Result_ `Boolean`

### GnvIsValidText

- Text `string`
- Filter `string`
- Exclude `Boolean` _optional_ `False`
- _Result_ `Boolean`

### GnvPosText

- SubText `string`
- Text `string`
- _Result_ `Integer`

### GnvPosTextEx

- SubText `string`
- Text `string`
- Offset `Integer` _optional_ `1`
- _Result_ `Integer`

### GnvStrToGUID

- Str `string`
- RemoveSeparators `Boolean` _optional_ `False`
- _Result_ `TGUID`

### GnvTrimLeft
- Str `string` `AnsiString`
- TrimStr `string` `AnsiString`
- _Result_ `string` `AnsiString`

### GnvTrimRight

- Str `string` `AnsiString`
- TrimStr `string` `AnsiString`
- _Result_ `string` `AnsiString`

### GnvExtractStr

- Str `string`
- Delims `string`
- Index `Integer`
- _Result_ `string`

### GnvExtractStrings

- Separators `string`
- WhiteSpace `string`
- Content `string`
- Strings `TStrings`
- IncludeEmptyStrings `Boolean` _optional_ `False`

### GnvLongestStr

- Str1 `string`
- Str2 `string`
- _Result_ `string`

### GnvCapitalizeStr

- Str `string`
- _Result_ `string`

### GnvNumberedFormat

- Format `string`
- Arguments `array of const`
- _Result_ `string`

### GnvPluralize

- Value `Integer`
- Forms `array of string`
- LocaleName `string` _optional_
- _Result_ `string`

## GnvSysUtils

### GnvReverseBytes

- Source `Pointer`
- Dest `Pointer`
- Size `Cardinal`

### GnvGetFileChanged

- FileName `string`
- _Result_ `TDateTime`

### GnvGetFileSize

- FileName `string`
- _Result_ `TFileSize`

### GnvExpandEnvPath

- Path `string`
- _Result_ `string`

### GnvExpandRelativePath

- BaseName `string`
- DestName `string`
- _Result_ `string`

### GnvExtractRelativePath

- BaseName `string`
- DestName `string`
- _Result_ `string`
### GnvSetFileDate

- FileName `string`
- Date `TDateTime`

### GnvCPToStr

- CodePage `Integer`
- _Result_ `string`

### GnvStrToCP

- Str `string`
- _Result_ `Integer`

### GnvLocaleNameToLCID

- LocaleName `string`
- _Result_ `Cardinal`

### GnvLCIDToLocaleName

- LCID `Cardinal`
- _Result_ `string`

### GnvGetLocaleInfo

- LCID `Cardinal`
- Field `Cardinal`
- _Result_ `string`

## GnvVariants

### GnvVarToBoolDef

- V `Variant`
- ADefault `Boolean`
- _Result_ `Boolean`

### GnvVarToIntDef

- V `Variant`
- ADefault `Integer`
- _Result_ `Integer`

## GnvWindows

### GnvGetCurrentUserName

- _Result_ `string`

### GnvGetVersionInfo

- FileName `string`
- Key `string`
- _Result_ `string`

### GnvGetResourceAsPointer

- ResName `PChar`
- ResType `PChar`
- Size `LongWord` _output_
- _Result_ `Pointer`

### GnvGetResourceAsString

- ResName `string`
- ResType `PChar`
- _Result_ `string`

### GnvSaveResourceAsFile

- ResName `string`
- ResType `PChar`
- FileName `string`

### GnvCompareFileVersion

- Version1 `TGnvFileVersion`
- Version2 `TGnvFileVersion`
- _Result_ `Integer`

### GnvFileVersion

- Major `Word`
- Minor `Word`
- Release `Word`
- Build `Word`
- _Result_ `TGnvFileVersion`

### GnvFileVersionFromStream

- Stream `TStream`
- _Result_ `TGnvFileVersion`

### GnvFileVersionToStr

- Version `TGnvFileVersion`
- _Result_ `string`

### GnvFileVersionToStream

- Version `TGnvFileVersion`
- Stream `TStream`

### GnvGetFileVersion

- FileName `string`
- _Result_ `TGnvFileVersion`

### GnvMessageQuery

- Msg `string`
- Arguments `array of const`
- Flags `LongInt` _optional_
- _Result_ `Integer`