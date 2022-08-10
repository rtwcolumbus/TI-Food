report 37002801 "Suggest PM Orders"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Processing only report to populate PM worksheet with suggested PM work orders
    // 
    // PRW15.00.01
    // P8000578A, VerticalSoft, Jack Reynolds, 20 FEB 08
    //   Fix problem with blank lead time on PM frequency
    // 
    // PRW16.00.20
    // P8000674, VerticalSoft, Jack Reynolds, 13 FEB 09
    //   Request page transformed
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor

    Caption = 'Suggest PM Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Asset; Asset)
        {
            RequestFilterFields = "No.", Type, "Location Code";

            trigger OnPreDataItem()
            begin
                CurrReport.Break;
            end;
        }
        dataitem("PM Frequency"; "PM Frequency")
        {
            RequestFilterFields = "Code", Type;

            trigger OnPreDataItem()
            begin
                CurrReport.Break;
            end;
        }
        dataitem("Preventive Maintenance Order"; "Preventive Maintenance Order")
        {
            DataItemTableView = SORTING("Asset No.", "Group Code", "Frequency Code") WHERE("Frequency Code" = FILTER(<> ''), "Current Work Order" = FILTER(= ''));

            trigger OnAfterGetRecord()
            begin
                Asset."No." := "Asset No.";
                if not Asset.Find then
                    CurrReport.Skip;
                "PM Frequency".Code := "Frequency Code";
                if not "PM Frequency".Find then
                    CurrReport.Skip;

                Window.Update(1, "Asset No.");
                Window.Update(2, "Frequency Code");

                if "Override Date" <> 0D then begin
                    NextDate := "Override Date";
                    CreateDate := "Override Date";
                end else begin
                    NextDate := NextPMDate;
                    if NextDate = 0D then
                        CurrReport.Skip;
                    if Format("PM Frequency"."Lead Time") = '' then // P8000578A
                        CreateDate := NextDate                        // P8000578A
                    else                                            // P8000578A
                        CreateDate := CalcDate('-' + Format("PM Frequency"."Lead Time"), NextDate);
                end;
                if CreateDate > DateLimit then
                    CurrReport.Skip;

                PMWkshTemp."Line No." += 1;
                PMWkshTemp."PM Entry No." := "Entry No.";
                PMWkshTemp."Asset No." := "Asset No.";
                PMWkshTemp."Group Code" := "Group Code";
                PMWkshTemp."Frequency Code" := "Frequency Code";
                PMWkshTemp."Last PM Date" := "Last PM Date";
                PMWkshTemp."Due Date" := NextDate;
                PMWkshTemp."Create Date" := CreateDate;
                PMWkshTemp."Days Since Last PM" := "Last PM Date" - NextDate; // Negative to sort from high to low
                PMWkshTemp."Work Requested" := "Work Requested (First Line)";
                PMWkshTemp.Insert;
            end;

            trigger OnPostDataItem()
            begin
                PMWkshTemp.SetCurrentKey("Asset No.", "Group Code", "Days Since Last PM");

                PMWksh.SetRange("PM Worksheet Name", WkshName);
                PMWksh.DeleteAll;

                PreviousAsset := '';
                PreviousGroup := '';

                if PMWkshTemp.FindFirst then
                    repeat
                        LineNo += 10000;
                        PMWksh := PMWkshTemp;
                        PMWksh."PM Worksheet Name" := WkshName;
                        PMWksh."Line No." := LineNo;
                        PMWksh."Days Since Last PM" := -PMWksh."Days Since Last PM";
                        if (PreviousAsset <> PMWksh."Asset No.") or (PreviousGroup <> PMWksh."Group Code") then begin
                            PMWksh."Master PM" := true;
                            PreviousAsset := PMWksh."Asset No.";
                            PreviousGroup := PMWksh."Group Code";
                        end else
                            PMWksh."Master PM" := PMWksh."Group Code" = '';
                        PMWksh."Create Order" := true;
                        PMWksh.Insert;
                    until PMWkshTemp.Next = 0;

                Window.Close;
            end;

            trigger OnPreDataItem()
            begin
                Window.Open('Asset No. #1#########   Frequency Code #2#####');
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DateLimit; DateLimit)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Date Limit';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        DateLimit := WorkDate;
    end;

    var
        WkshName: Code[10];
        DateLimit: Date;
        PMWksh: Record "PM Worksheet";
        PMWkshTemp: Record "PM Worksheet" temporary;
        NextDate: Date;
        CreateDate: Date;
        LineNo: Integer;
        PreviousAsset: Code[20];
        PreviousGroup: Code[10];
        Window: Dialog;

    procedure SetWkshName(Name: Code[10])
    begin
        WkshName := Name;
    end;
}

