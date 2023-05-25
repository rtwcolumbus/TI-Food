page 37002893 "Data Collection Alert Detail"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Collection Alert Detail';
    PageType = CardPart;
    SourceTable = "Data Collection Alert";

    layout
    {
        area(content)
        {
            field("DataSheetLine.Description"; DataSheetLine.Description)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Description';
            }
            field("DataSheetLine.""Data Element Type"""; DataSheetLine."Data Element Type")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Type';
                HideValue = HideType;
            }
            field("DataSheetLine.Result"; DataSheetLine.Result)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Result';
            }
            field(SourceType; SourceType)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Source Type';
            }
            field(SourceDescription; SourceDescription)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Source Description';
            }
            field("DataSheetLineDetail.TargetValue()"; DataSheetLineDetail.TargetValue())
            {
                ApplicationArea = FOODBasic;
                Caption = 'Target';
            }
            field("DataSheetLineDetail.""Numeric Low-Low Value"""; DataSheetLineDetail."Numeric Low-Low Value")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Low-Low';
                HideValue = HideValue;
                Visible = false;
            }
            field("DataSheetLineDetail.""Numeric Low Value"""; DataSheetLineDetail."Numeric Low Value")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Low';
                HideValue = HideValue;
                Visible = false;
            }
            field("DataSheetLineDetail.""Numeric High Value"""; DataSheetLineDetail."Numeric High Value")
            {
                ApplicationArea = FOODBasic;
                Caption = 'High';
                HideValue = HideValue;
                Visible = false;
            }
            field("DataSheetLineDetail.""Numeric High-High Value"""; DataSheetLineDetail."Numeric High-High Value")
            {
                ApplicationArea = FOODBasic;
                Caption = 'High-High';
                HideValue = HideValue;
                Visible = false;
            }
            field("Close Date"; "Close Date")
            {
                ApplicationArea = FOODBasic;
            }
            field("Close Time"; "Close Time")
            {
                ApplicationArea = FOODBasic;
            }
            field("Closed By"; "Closed By")
            {
                ApplicationArea = FOODBasic;
            }
            field(Comments; Comments)
            {
                ApplicationArea = FOODBasic;
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
        DataSheetLine.Get("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Instance No.");
        DataSheetLineDetail.Get("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.",
          "Source ID", "Source Key 1", "Source Key 2", "Instance No.");

        DataCollectionMgmt.SourceDescription("Source ID", "Source Key 1", "Source Key 2", SourceType, SourceDesc1, SourceDesc2);
        if "Source Key 2" = '' then
            SourceDescription := SourceDesc1
        else
            SourceDescription := StrSubstNo(Text001, SourceDesc1, SourceDesc2);

        HideType := "Data Element Code" = '';
        HideValue := DataSheetLine."Data Element Type" <> DataSheetLine."Data Element Type"::Numeric;
    end;

    trigger OnInit()
    begin
        HideType := true;
    end;

    var
        DataSheetLine: Record "Data Sheet Line";
        DataSheetLineDetail: Record "Data Sheet Line Detail";
        DataCollectionMgmt: Codeunit "Data Collection Management";
        SourceType: Text[50];
        SourceDescription: Text[120];
        Text001: Label '%1 • %2';
        [InDataSet]
        HideType: Boolean;
        [InDataSet]
        HideValue: Boolean;
}

