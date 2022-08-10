codeunit 3002 DotNet_CultureInfo
{
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    var
        DotNetCultureInfo: DotNet CultureInfo;

    procedure GetCultureInfoByName(CultureName: Text)
    begin
        DotNetCultureInfo := DotNetCultureInfo.GetCultureInfo(CultureName)
    end;

    procedure GetCultureInfoById(LanguageId: Integer)
    begin
        DotNetCultureInfo := DotNetCultureInfo.GetCultureInfo(LanguageId)
    end;

    procedure CurrentCulture()
    begin
        // P80073095
        DotNetCultureInfo := DotNetCultureInfo.CurrentCulture;
    end;

    procedure InvariantCulture()
    begin
        DotNetCultureInfo := DotNetCultureInfo.InvariantCulture
    end;

    procedure Name(): Text
    begin
        exit(DotNetCultureInfo.Name)
    end;

    procedure CurrentCultureName(): Text
    begin
        Clear(DotNetCultureInfo);
        exit(DotNetCultureInfo.CurrentCulture.Name)
    end;

    procedure ToString(): Text
    begin
        exit(DotNetCultureInfo.ToString)
    end;

    procedure TwoLetterISOLanguageName(): Text
    begin
        exit(DotNetCultureInfo.TwoLetterISOLanguageName)
    end;

    procedure ThreeLetterWindowsLanguageName(): Text
    begin
        exit(DotNetCultureInfo.ThreeLetterWindowsLanguageName)
    end;

    procedure DateTimeFormat(var DotNet_DateTimeFormatInfo: Codeunit DotNet_DateTimeFormatInfo)
    begin
        DotNet_DateTimeFormatInfo.SetDateTimeFormatInfo(DotNetCultureInfo.DateTimeFormat)
    end;

    [Scope('OnPrem')]
    procedure GetCultureInfo(var DotNetCultureInfo2: DotNet CultureInfo)
    begin
        DotNetCultureInfo2 := DotNetCultureInfo
    end;

    [Scope('OnPrem')]
    procedure SetCultureInfo(DotNetCultureInfo2: DotNet CultureInfo)
    begin
        DotNetCultureInfo := DotNetCultureInfo2
    end;
}

