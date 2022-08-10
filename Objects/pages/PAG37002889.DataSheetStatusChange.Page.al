page 37002889 "Data Sheet Status Change"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Data Sheet Status Change';
    InstructionalText = 'Do you want to change the status on the data sheet?';
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            field("DataSheetHeader.Status"; DataSheetHeader.Status)
            {
                ApplicationArea = FOODBasic;
                Caption = 'New Status';
                Editable = false;
            }
            field(StartDate; StartDate)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Start Date';
                Editable = NOT Stop;
            }
            field(StartTime; StartTime)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Start Time';
                Editable = NOT Stop;
            }
            field(EndDate; EndDate)
            {
                ApplicationArea = FOODBasic;
                Caption = 'End Date';
                Visible = Stop;
            }
            field(EndTime; EndTime)
            {
                ApplicationArea = FOODBasic;
                Caption = 'End Time';
                Visible = Stop;
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        DataSheetLine: Record "Data Sheet Line";
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        if CloseAction = ACTION::Yes then begin
            if (not Stop) then begin
                if (StartDate = 0D) or (StartTime = 0T) then
                    Error(Text001);
                StartDateTime := TimeZoneMgmt.CreateUTC(StartDate, StartTime, Location."Time Zone");
            end else begin
                if (EndDate = 0D) or (EndTime = 0T) then
                    Error(Text002);
                EndDateTime := TimeZoneMgmt.CreateUTC(EndDate, EndTime, Location."Time Zone");
                if EndDateTime < DataSheetHeader."Start DateTime" then
                    Error(Text003);
                if DataSheetHeader.Type = DataSheetHeader.Type::Production then begin
                    DataSheetLine.SetRange("Data Sheet No.", DataSheetHeader."No.");
                    DataSheetLine.SetFilter("Prod. Order Line No.", '>0');
                    DataSheetLine.SetRange("Data Element Code", '');
                    DataSheetLine.SetRange("Hide Line", false);
                    DataSheetLine.SetFilter("Stop DateTime", '>%1', EndDateTime);
                    if DataSheetLine.FindFirst then
                        Error(Text004, DataSheetLine."Prod. Order Line No.");
                end;
                DataCollectionMgmt.CheckOKToComplete(DataSheetHeader."No.", 0, EndDateTime);
            end;
        end;
    end;

    var
        DataSheetHeader: Record "Data Sheet Header";
        Location: Record Location;
        TimeZoneMgmt: Codeunit "Time Zone Management";
        NewStatus: Text[20];
        StartDate: Date;
        StartTime: Time;
        StartDateTime: DateTime;
        EndDate: Date;
        EndTime: Time;
        EndDateTime: DateTime;
        [InDataSet]
        Stop: Boolean;
        Text001: Label 'Start date and time must be entered.';
        Text002: Label 'End date and time must be entered.';
        Text003: Label 'End date and time must be after start date and time.';
        Text004: Label 'Production order line %1 completed after stop date and time.';

    procedure Set(Rec: Record "Data Sheet Header")
    begin
        DataSheetHeader := Rec;
        if Location.Get(DataSheetHeader."Location Code") then;
        DataSheetHeader.Status += 1;
        case DataSheetHeader.Status of
            DataSheetHeader.Status::"In Progress":
                begin
                    Stop := false;
                    StartDateTime := CreateDateTime(WorkDate, Time);
                    TimeZoneMgmt.UTC2DateAndTime(StartDateTime, Location."Time Zone", StartDate, StartTime);
                end;
            DataSheetHeader.Status::Complete:
                begin
                    Stop := true;
                    StartDate := DataSheetHeader."Start Date";
                    StartTime := DataSheetHeader."Start Time";
                    EndDateTime := CreateDateTime(WorkDate, Time);
                    TimeZoneMgmt.UTC2DateAndTime(EndDateTime, Location."Time Zone", EndDate, EndTime);
                end;
        end;
    end;

    procedure GetDateTime(var Date: Date; var Time: Time; var DateTime: DateTime)
    begin
        if (not Stop) then begin
            Date := StartDate;
            Time := StartTime;
            DateTime := StartDateTime;
        end else begin
            Date := EndDate;
            Time := EndTime;
            DateTime := EndDateTime;
        end;
    end;
}

