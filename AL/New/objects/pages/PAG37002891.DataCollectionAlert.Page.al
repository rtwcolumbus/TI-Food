page 37002891 "Data Collection Alert"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001187, Columbus IT, Jack Reynolds, 08 AUG 13
    //   Create FastTab groupings
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work

    Caption = 'Data Collection Alert';
    DataCaptionExpression = StrSubstNo(Text001, DataSheetHeader.Description, "Data Element Code");
    DelayedInsert = true;
    PageType = Card;
    SourceTable = "Data Collection Alert";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Data Sheet No."; "Data Sheet No.")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("DataSheetHeader.Description"; DataSheetHeader.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    Editable = false;
                }
                field("DataSheetHeader.""Location Code"""; DataSheetHeader."Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                    Editable = false;
                }
                field("Alert Type"; "Alert Type")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field(Critical; Critical)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Elevated; Elevated)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        Open := Status = Status::Open;
                    end;
                }
                group(Source)
                {
                    Caption = 'Source';
                    field(SourceType; SourceType)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Type';
                        Editable = false;
                    }
                    field(SourceDescription; SourceDescription)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Description';
                        Editable = false;
                    }
                }
                group("Data Element")
                {
                    Caption = 'Data Element';
                    field("Data Element Code"; "Data Element Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Code';
                        Importance = Promoted;
                    }
                    field("DataSheetLine.Description"; DataSheetLine.Description)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Description';
                        Editable = false;
                    }
                    field("DataSheetLine.""Data Element Type"""; DataSheetLine."Data Element Type")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Type';
                        Editable = false;
                    }
                }
            }
            group("Collection Data")
            {
                Caption = 'Collection Data';
                group(Dates)
                {
                    Caption = 'Dates';
                    field("DataSheetLine.""Schedule Date"""; DataSheetLine."Schedule Date")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Schedule Date';
                        Editable = false;
                    }
                    field("DataSheetLine.""Schedule Time"""; DataSheetLine."Schedule Time")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Schedule Time';
                        Editable = false;
                    }
                    field("Origination Date"; "Origination Date")
                    {
                        ApplicationArea = FOODBasic;
                        Importance = Promoted;
                    }
                    field("Origination Time"; "Origination Time")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                group(Result)
                {
                    Caption = 'Result';
                    field("DataSheetLine.Result"; DataSheetLine.Result)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Result';
                        Editable = false;
                        Importance = Promoted;
                    }
                    field("DataSheetLineDetail.TargetValue()"; DataSheetLineDetail.TargetValue())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Target';
                        Editable = HideValue;
                    }
                    field("FORMAT(DataSheetLineDetail.""Numeric Low-Low Value"")"; Format(DataSheetLineDetail."Numeric Low-Low Value"))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Low-Low';
                        Editable = HideValue;
                        HideValue = HideValue;
                    }
                    field("FORMAT(DataSheetLineDetail.""Numeric Low Value"")"; Format(DataSheetLineDetail."Numeric Low Value"))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Low';
                        Editable = HideValue;
                        HideValue = HideValue;
                    }
                    field("FORMAT(DataSheetLineDetail.""Numeric High Value"")"; Format(DataSheetLineDetail."Numeric High Value"))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'High';
                        Editable = HideValue;
                        HideValue = HideValue;
                    }
                    field("FORMAT(DataSheetLineDetail.""Numeric High-High Value"")"; Format(DataSheetLineDetail."Numeric High-High Value"))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'High-High';
                        Editable = HideValue;
                        HideValue = HideValue;
                    }
                }
            }
            group(Completion)
            {
                Caption = 'Completion';
                field("Close Date"; "Close Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Open;
                    Importance = Promoted;
                }
                field("Close Time"; "Close Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Open;
                }
                field("Closed By"; "Closed By")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field(Comments; Comments)
                {
                    ApplicationArea = FOODBasic;
                    Editable = Open;
                    MultiLine = true;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002014; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002015; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        SourceDesc1: Text[100];
        SourceDesc2: Text[100];
    begin
        DataSheetHeader.Get("Data Sheet No.");
        DataSheetLine.Get("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Instance No.");
        DataSheetLineDetail.Get("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.",
          "Source ID", "Source Key 1", "Source Key 2", "Instance No.");

        DataCollectionMgmt.SourceDescription("Source ID", "Source Key 1", "Source Key 2", SourceType, SourceDesc1, SourceDesc2);
        if "Source Key 2" = '' then
            SourceDescription := SourceDesc1
        else
            SourceDescription := StrSubstNo(Text001, SourceDesc1, SourceDesc2);

        Open := Status = Status::Open;
        HideValue := DataSheetLine."Data Element Type" <> DataSheetLine."Data Element Type"::Numeric;
    end;

    var
        DataSheetHeader: Record "Data Sheet Header";
        DataSheetLine: Record "Data Sheet Line";
        DataSheetLineDetail: Record "Data Sheet Line Detail";
        Text001: Label '%1 • %2';
        DataCollectionMgmt: Codeunit "Data Collection Management";
        SourceType: Text[50];
        SourceDescription: Text[120];
        [InDataSet]
        Open: Boolean;
        [InDataSet]
        HideValue: Boolean;
}

