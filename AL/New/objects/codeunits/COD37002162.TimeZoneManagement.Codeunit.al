codeunit 37002162 "Time Zone Management"
{
    // PRW16.00.06
    // P8001119, Columbus IT, Jack Reynolds, 19 NOV 12
    //   Time zone support
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001197, Columbus IT, Jack Reynolds, 22 AUG 13
    //   Change to TimeZone DLL
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //    Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 31 MAR 16
    //   Update add-in assembly version references
    // 
    // PRW10.0
    // P8007755, To-Increase, Jack Reynolds, 22 NOV 16
    //   Update add-in assembly version references
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 04 FEB 19
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Updating time Zone Management codeunit   


    trigger OnRun()
    begin
    end;

    // P800144605
    procedure CreateUTC(Date: Date; Time: Time; TimeZoneID: Text[50]) DateTime: DateTime
    var
        Settings: SessionSettings;
        TimeZoneInfo: DotNet TimeZoneInfo;
        Adjustment: Duration;
    begin
        DateTime := CreateDateTime(Date, Time);
        if TimeZoneID = '' then
            exit;

        Settings.Init();
        TimeZoneInfo := TimeZoneInfo.FindSystemTimeZoneById(Settings.TimeZone);
        Adjustment := TimeZoneInfo.BaseUtcOffset;
        TimeZoneInfo := TimeZoneInfo.FindSystemTimeZoneById(TimeZoneID);
        Adjustment -= TimeZoneInfo.BaseUtcOffset;
        DateTime += Adjustment;
    end;

    // P800144605
    procedure UTC2DateAndTime(DateTime: DateTime; TimeZoneID: Text[50]; var Date: Date; var Time: Time)
    var
        Settings: SessionSettings;
        TimeZoneInfo: DotNet TimeZoneInfo;
        Adjustment: Duration;
    begin
        if TimeZoneID <> '' then begin
            Settings.Init();
            TimeZoneInfo := TimeZoneInfo.FindSystemTimeZoneById(Settings.TimeZone);
            Adjustment := TimeZoneInfo.BaseUtcOffset;
            TimeZoneInfo := TimeZoneInfo.FindSystemTimeZoneById(TimeZoneID);
            Adjustment -= TimeZoneInfo.BaseUtcOffset;
        end;

        DateTime -= Adjustment;
        Date := DT2Date(DateTime);
        Time := DT2Time(DateTime);
    end;
}

