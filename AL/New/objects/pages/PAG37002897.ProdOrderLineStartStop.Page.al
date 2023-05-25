page 37002897 "Prod. Order Line Start/Stop"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001149, Columbus IT, Don Bresee, 26 APR 13
    //   Change calling of page to use lookup mode

    Caption = 'Prod. Order Line';
    DataCaptionExpression = PageCaption;

    layout
    {
        area(content)
        {
            field(PODate; PODate)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Date';
            }
            field(POTime; POTime)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Time';
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // IF CloseAction <> ACTION::OK THEN    // P8001149
        if CloseAction <> ACTION::LookupOK then // P8001149
            exit(true);

        if PODate = 0D then
            Error(Text004);
        if POTime = 0T then
            Error(Text005);
        PODateTime := TimeZoneMgmt.CreateUTC(PODate, POTime, Location."Time Zone");

        if DataSheetLine."Actual Date" = 0D then begin
            if PODateTime < DataSheetHeader."Start DateTime" then
                Error(Text003);
        end else begin
            if PODateTime < DataSheetLine."Actual DateTime" then
                Error(Text006)
            else
                DataCollectionMgmt.CheckOKToComplete(DataSheetLine."Data Sheet No.", DataSheetLine."Prod. Order Line No.", PODateTime);
        end;
        exit(true);
    end;

    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetLine: Record "Data Sheet Line";
        Location: Record Location;
        DataCollectionMgmt: Codeunit "Data Collection Management";
        TimeZoneMgmt: Codeunit "Time Zone Management";
        PageCaption: Text[30];
        PODate: Date;
        POTime: Time;
        Text001: Label 'Start';
        Text002: Label 'Stop';
        Text003: Label 'Start date and time must not be before start date and time for the data sheet.';
        Text004: Label 'Date must be entered.';
        Text005: Label 'Time must be entered.';
        Text006: Label 'Stop date and time must not be before start date and time for the line.';
        PODateTime: DateTime;

    procedure SetData(Rec: Record "Data Sheet Line")
    begin
        DataSheetLine := Rec;
        DataSheetHeader.Get(DataSheetLine."Data Sheet No.");
        if Location.Get(DataSheetHeader."Location Code") then;

        PODateTime := CreateDateTime(WorkDate, Time);
        TimeZoneMgmt.UTC2DateAndTime(PODateTime, Location."Time Zone", PODate, POTime);

        if DataSheetLine."Actual Date" = 0D then
            PageCaption := Text001
        else
            PageCaption := Text002;
    end;

    procedure GetDateTime(var Date: Date; var Time: Time; var DateTime: DateTime)
    begin
        Date := PODate;
        Time := POTime;
        DateTime := PODateTime;
    end;
}

