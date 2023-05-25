codeunit 37002871 "Data Collection Generate Alert"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection


    trigger OnRun()
    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetLine: Record "Data Sheet Line";
        DataSheetLineDetail: Record "Data Sheet Line Detail";
        DataCollectionAlert: Record "Data Collection Alert";
        Location: Record Location;
        SchedDateTime: DateTime;
        AlertDateTime: DateTime;
    begin
        DataSheetHeader.SetRange(Status, DataSheetHeader.Status::"In Progress");
        if DataSheetHeader.FindSet then
            repeat
                if not Location.Get(DataSheetHeader."Location Code") then
                    Clear(Location);

                DataSheetLine.SetRange("Data Sheet No.", DataSheetHeader."No.");
                DataSheetLine.SetRange(Recurrence, DataSheetLine.Recurrence::Scheduled);
                DataSheetLine.SetFilter("Schedule DateTime", '<>%1', 0DT);
                DataSheetLine.SetFilter(Result, '=%1', '');
                if DataSheetLine.FindSet then
                    repeat
                        DataSheetLineDetail.SetRange("Data Sheet No.", DataSheetLine."Data Sheet No.");
                        DataSheetLineDetail.SetRange("Prod. Order Line No.", DataSheetLine."Prod. Order Line No.");
                        DataSheetLineDetail.SetRange("Data Element Code", DataSheetLine."Data Element Code");
                        DataSheetLineDetail.SetRange("Line No.", DataSheetLine."Line No.");
                        DataSheetLineDetail.SetRange("Instance No.", DataSheetLine."Instance No.");
                        DataSheetLineDetail.SetFilter("Missed Collection Alert Group", '<>%1', '');
                        DataSheetLineDetail.SetRange("Alert Entry No. (Missed)", 0);
                        if DataSheetLineDetail.FindSet(true) then begin
                            repeat
                                AlertDateTime := DataSheetLine."Schedule DateTime" + DataSheetLineDetail."Grace Period";
                                if AlertDateTime <= CurrentDateTime then begin
                                    DataSheetLineDetail.CreateAlert(DataCollectionAlert."Alert Type"::Missed, Location,
                                      DataSheetLineDetail."Missed Collection Alert Group", 0D, 0T, AlertDateTime,
                                      DataSheetLineDetail."Alert Entry No. (Missed)");
                                    DataSheetLineDetail.Modify;
                                end;
                            until DataSheetLineDetail.Next = 0;
                        end;
                    until DataSheetLine.Next = 0;

                DataCollectionAlert.SetCurrentKey("Data Sheet No.");
                DataCollectionAlert.SetRange("Data Sheet No.", DataSheetHeader."No.");
                DataCollectionAlert.SetRange(Critical, true);
                DataCollectionAlert.SetRange(Status, DataCollectionAlert.Status::Open);
                DataCollectionAlert.SetRange(Elevated, false);
                if DataCollectionAlert.FindSet(true) then
                    repeat
                        if DataCollectionAlert.AlertIsElevated then
                            DataCollectionAlert.Modify(true);
                    until DataCollectionAlert.Next = 0;
            until DataSheetHeader.Next = 0;
    end;
}

