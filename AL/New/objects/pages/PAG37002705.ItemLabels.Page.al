page 37002705 "Item Labels"
{
    // PRW16.00.06
    // P8001123, Columbus IT, Jack Reynolds, 19 DEC 12
    //   Move Item table Label Code fields to Item Label table

    Caption = 'Item Labels';
    DataCaptionFields = "Source No.";
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Label Selection";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Label Type"; LabelType)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Label Type';
                    OptionCaption = ' ,Case,,Pre-Process';

                    trigger OnValidate()
                    begin
                        "Label Type" := Enum::"Label Type".FromInteger(LabelType);
                    end;
                }
                field("Label Code"; "Label Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    var
        [InDataSet]
        LabelType: Option None,Case,,PreProcess;

    trigger OnAfterGetRecord()
    begin
        LabelType := "Label Type".AsInteger();
    end;
}

