report 37002871 "Completed Data Sheet"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW111.00.01
    // P80063138, To Increase, Jack Reynolds, 13 AUG 18
    //   Fix problem hiding "Critical" field in report layout
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/CompletedDataSheet.rdlc';

    Caption = 'Completed Data Sheet';

    dataset
    {
        dataitem("Data Sheet Header"; "Data Sheet Header")
        {
            DataItemTableView = WHERE(Status = CONST(Complete));
            RequestFilterFields = "No.", "Location Code", Type;
            column(SheetNo; "No.")
            {
                IncludeCaption = true;
            }
            column(SheetDesc; Description)
            {
                IncludeCaption = true;
            }
            column(SheetLocation; "Location Code")
            {
                IncludeCaption = true;
            }
            column(SheetReferenceType; StrSubstNo('%1 %2', "Reference Type", "Reference ID"))
            {
            }
            column(SheetDocDate; "Document Date")
            {
                IncludeCaption = true;
            }
            column(SheetDocNo; "Document No.")
            {
                IncludeCaption = true;
            }
            column(SheetStartDate; "Start Date")
            {
                IncludeCaption = true;
            }
            column(SheetStartTime; "Start Time")
            {
                IncludeCaption = true;
            }
            column(SheetEndDate; "End Date")
            {
                IncludeCaption = true;
            }
            column(SheetEndTime; "End Time")
            {
                IncludeCaption = true;
            }
            column(SheetReferenceName; ReferenceName)
            {
            }
            dataitem(ProdOrderLineData; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(ProdOrderNo; DataSheetLineTemp."Prod. Order Line No.")
                {
                }
                column(ProdOrderStopDate; DataSheetLineTemp."Stop Date")
                {
                }
                column(ProdOrderStopTime; DataSheetLineTemp."Stop Time")
                {
                }
                column(ProdOrderStartDate; DataSheetLineTemp."Actual Date")
                {
                }
                column(ProdOrderStartTime; DataSheetLineTemp."Actual Time")
                {
                }
                column(ProdOrderDescription; LineDescription)
                {
                }
                dataitem("Data Sheet Line"; "Data Sheet Line")
                {
                    DataItemTableView = SORTING("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Instance No.") WHERE("Data Element Code" = FILTER(<> ''));
                    column(LineDataElement; "Data Element Code")
                    {
                    }
                    column(LineInstance; "Instance No.")
                    {
                    }
                    column(LineDescription; Description)
                    {
                    }
                    column(LineSchedDate; "Schedule Date")
                    {
                    }
                    column(LineSchedTime; "Schedule Time")
                    {
                    }
                    column(LineActualDate; "Actual Date")
                    {
                    }
                    column(LineActualTime; "Actual Time")
                    {
                    }
                    column(LineResult; Result)
                    {
                        IncludeCaption = true;
                    }
                    column(LineUserID; "User ID")
                    {
                        IncludeCaption = true;
                    }
                    column(LineLineNo; "Line No.")
                    {
                    }
                    dataitem("Data Sheet Line Detail"; "Data Sheet Line Detail")
                    {
                        DataItemLink = "Data Sheet No." = FIELD("Data Sheet No."), "Prod. Order Line No." = FIELD("Prod. Order Line No."), "Data Element Code" = FIELD("Data Element Code"), "Line No." = FIELD("Line No."), "Instance No." = FIELD("Instance No.");
                        DataItemTableView = SORTING("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Source ID", "Source Key 1", "Source Key 2", "Instance No.");
                        column(DetailCritical; Critical)
                        {
                            IncludeCaption = true;
                        }
                        column(DetailSourceType; SourceType)
                        {
                        }
                        column(DetailSourceDesc; SourceDescription)
                        {
                        }
                        column(DetailTargetValue; TargetValue)
                        {
                        }
                        column(DetailSourceID; "Source ID")
                        {
                        }
                        column(DetailSourceKey1; "Source Key 1")
                        {
                        }
                        column(DetailSourceKey2; "Source Key 2")
                        {
                        }
                        dataitem("Data Collection Alert"; "Data Collection Alert")
                        {
                            DataItemLink = "Data Sheet No." = FIELD("Data Sheet No."), "Prod. Order Line No." = FIELD("Prod. Order Line No."), "Data Element Code" = FIELD("Data Element Code"), "Line No." = FIELD("Line No."), "Instance No." = FIELD("Instance No."), "Source ID" = FIELD("Source ID"), "Source Key 1" = FIELD("Source Key 1"), "Source Key 2" = FIELD("Source Key 2");
                            DataItemTableView = SORTING("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Source ID", "Source Key 1", "Source Key 2", "Instance No.");
                            column(AlertType; "Alert Type")
                            {
                            }
                            column(AlertOrigDate; "Origination Date")
                            {
                            }
                            column(AlertOrigTime; "Origination Time")
                            {
                            }
                            column(AlertCloseDate; "Close Date")
                            {
                            }
                            column(AlertCloseTime; "Close Time")
                            {
                            }
                            column(AlertClosedBy; "Closed By")
                            {
                            }
                            column(AlertComments; Comments)
                            {
                            }
                            column(AlertElevated; Elevated)
                            {
                                IncludeCaption = true;
                            }
                        }

                        trigger OnAfterGetRecord()
                        var
                            SourceDesc1: Text[100];
                            SourceDesc2: Text[100];
                        begin
                            DataCollectionMgmt.SourceDescription("Source ID", "Source Key 1", "Source Key 2", SourceType, SourceDesc1, SourceDesc2);
                            if "Source Key 2" = '' then
                                SourceDescription := SourceDesc1
                            else
                                SourceDescription := StrSubstNo(Text001, SourceDesc1, SourceDesc2);
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        SetRange("Data Sheet No.", DataSheetLineTemp."Data Sheet No.");
                        SetRange("Prod. Order Line No.", DataSheetLineTemp."Prod. Order Line No.");
                        SetFilter("Data Element Code", '<>%1', '');
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    ProdOrderLine: Record "Prod. Order Line";
                begin
                    if Number = 1 then
                        DataSheetLineTemp.Find('-')
                    else
                        DataSheetLineTemp.Next;
                    if DataSheetLineTemp."Prod. Order Line No." <> 0 then begin
                        ProdOrderLine.Get(ProdOrderLine.Status::Finished, "Data Sheet Header"."Document No.", DataSheetLineTemp."Prod. Order Line No.");
                        LineDescription := ProdOrderLine.Description;
                    end else
                        LineDescription := '';
                end;

                trigger OnPreDataItem()
                var
                    DataSheetLine: Record "Data Sheet Line";
                begin
                    DataSheetLineTemp.Reset;
                    DataSheetLineTemp.DeleteAll;

                    if "Data Sheet Header".Type = "Data Sheet Header".Type::Production then begin
                        DataSheetLine.SetRange("Data Sheet No.", "Data Sheet Header"."No.");
                        DataSheetLine.SetRange("Data Element Code", '');
                        if DataSheetLine.FindSet then
                            repeat
                                DataSheetLineTemp := DataSheetLine;
                                DataSheetLineTemp.Insert;
                            until DataSheetLine.Next = 0;
                    end else begin
                        DataSheetLineTemp."Data Sheet No." := "Data Sheet Header"."No.";
                        DataSheetLineTemp.Insert;
                    end;

                    SetRange(Number, 1, DataSheetLineTemp.Count);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ReferenceName := '';
                case "Reference Type" of
                    "Reference Type"::Customer:
                        if Customer.Get("Reference ID") then
                            ReferenceName := Customer.Name;
                    "Reference Type"::Vendor:
                        if Vendor.Get("Reference ID") then
                            ReferenceName := Vendor.Name;
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        SheetReferenceTypeCaption = 'Reference';
        SheetReferenceNameCaption = 'Reference Name';
        Title = 'Data Sheet';
        ProdOrderNoCaption = 'Line';
        ProdOrderStopCaption = 'Stop';
        ProdOrderStartCaption = 'Start';
        LineDataElementCaption = 'Data Element';
        LineInstanceCaption = 'Instance';
        LineSchedDateCaption = 'Schedule';
        LineActualDateCaption = 'Actual';
        DetailTargetValueCaption = 'Target';
        AlertTypeCaption = 'Alert:';
        AlertOrigDateCaption = 'Origination';
        AlertCloseDateCaption = 'Close';
    }

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        DataSheetLineTemp: Record "Data Sheet Line" temporary;
        DataCollectionMgmt: Codeunit "Data Collection Management";
        ReferenceName: Text[100];
        Text001: Label '%1 • %2';
        SourceType: Text[50];
        SourceDescription: Text[110];
        LineDescription: Text[100];
}

