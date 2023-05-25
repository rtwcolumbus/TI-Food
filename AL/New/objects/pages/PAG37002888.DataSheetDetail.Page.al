page 37002888 "Data Sheet Detail"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001160, Columbus IT, Jack Reynolds, 23 MAY 13
    //   Add entity key field(s) to display
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Sheet Detail';
    PageType = ListPart;
    SourceTable = "Data Sheet Line Detail";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(SourceType; SourceType)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Type';
                    Style = Attention;
                    StyleExpr = StyleOn;
                }
                field(SourceKey; SourceKey)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    Style = Attention;
                    StyleExpr = StyleOn;
                }
                field(TargetValue; TargetValue)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Target Value';
                    Style = Attention;
                    StyleExpr = StyleOn;
                }
                field(Critical; Critical)
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = StyleOn;
                }
            }
            field(SourceDescription; SourceDescription)
            {
                ApplicationArea = FOODBasic;
                ShowCaption = false;
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
        DataCollectionMgmt.SourceDescription("Source ID", "Source Key 1", "Source Key 2", SourceType, SourceDesc1, SourceDesc2);
        // P8001160
        if "Source Key 2" = '' then begin // xxx
            SourceKey := "Source Key 1";
            SourceDescription := SourceDesc1;
        end else begin
            SourceKey := StrSubstNo(Text001, "Source Key 1", "Source Key 2");
            SourceDescription := StrSubstNo(Text001, SourceDesc1, SourceDesc2);
        end;
        // P8001160

        StyleOn := ("Alert Entry No. (Target)" <> 0) or ("Alert Entry No. (Missed)" <> 0);
    end;

    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
        SourceType: Text[50];
        Text001: Label '%1 • %2';
        SourceKey: Text[50];
        SourceDescription: Text[120];
        [InDataSet]
        StyleOn: Boolean;
}

