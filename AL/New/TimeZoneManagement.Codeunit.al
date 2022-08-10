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


    trigger OnRun()
    var
        Date: Date;
        Time: Time;
        DT: DateTime;
    begin
    end;

    var
        Text001: Label 'Invalid date and time.';

    procedure TimeZoneLookup(var Text: Text[1024]): Boolean
    var
        TimeZone: Record "Time Zone";
        TimeZones: Page "Time Zones";
    begin
        // P80053245
        TimeZone.SetRange(ID, Text);
        if not TimeZone.FindFirst then begin
            TimeZone.SetRange(ID, UTCID);
            TimeZone.FindFirst;
        end;
        TimeZones.SetRecord(TimeZone);
        TimeZones.LookupMode(true);
        if TimeZones.RunModal = ACTION::LookupOK then begin
            TimeZones.GetRecord(TimeZone);
            Text := TimeZone.ID;
            exit(true);
        end;
    end;

    local procedure UTCID(): Text[50]
    var
    // TimeZoneInfo: DotNet TimeZoneInfo0;
    begin
        // exit(TimeZoneInfo.Utc.Id);
    end;

    procedure TimeZoneExists(TimeZoneID: Text[50]): Boolean
    var
        TimeZone: Record "Time Zone";
    begin
        // P80053245
        TimeZone.SetRange(ID, TimeZoneID);
        exit(not TimeZone.IsEmpty);
    end;

    procedure CreateUTC(Date: Date; Time: Time; TimeZoneID: Text[50]): DateTime
    var
        // TimeZone: DotNet TimeZone;
        Hour: Integer;
        Minute: Integer;
        Second: Integer;
        Millisecond: Integer;
    begin
        if TimeZoneID = '' then
            exit(CreateDateTime(Date, Time));

        Millisecond := Time - 000000T;
        Hour := Millisecond div 3600000;
        Millisecond := Millisecond mod 3600000;
        Minute := Millisecond div 60000;
        Millisecond := Millisecond mod 60000;
        Second := Millisecond div 1000;
        Millisecond := Millisecond mod 1000;

        // // P80053245
        // TimeZone := TimeZone.TimeZone(TimeZoneID);
        // if TimeZone.IsInvalidTime(Date2DMY(Date, 3), Date2DMY(Date, 2), Date2DMY(Date, 1), Hour, Minute, Second, Millisecond) then
        //     Error(Text001)
        // else
        //     exit(TimeZone.CreateUtc(Date2DMY(Date, 3), Date2DMY(Date, 2), Date2DMY(Date, 1), Hour, Minute, Second, Millisecond)); // P8001197
        // // P80053245
    end;

    procedure UTC2DateAndTime(DT: DateTime; TimeZoneID: Text[50]; var Date: Date; var Time: Time)
    var
        // TimeZone: DotNet TimeZone;
        DateTime: DateTime;
    begin
        if TimeZoneID = '' then begin
            Date := DT2Date(DT);
            Time := DT2Time(DT);
            exit;
        end;

        // // P80053245
        // TimeZone := TimeZone.TimeZone(TimeZoneID);
        // DateTime := TimeZone.Utc2DateAndTime(DT); // P8001197
        // // P80053245
        Date := DT2Date(DateTime);
        Time := DT2Time(DateTime);
    end;
}

