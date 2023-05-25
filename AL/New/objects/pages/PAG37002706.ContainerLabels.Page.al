page 37002706 "Container Labels"
{
    // PRW16.00.06
    // P8001123, Columbus IT, Jack Reynolds, 19 DEC 12
    //   Move Item table Label Code fields to Item Label table
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order

    Caption = 'Container Labels';
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
                    OptionCaption = ' ,,Container,,,,,,,Shipping Container,Production Container';

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
        LabelType: Option None,,Container,,,,,,,ShippingContainer,ProductionContainer;

    trigger OnAfterGetRecord()
    begin
        LabelType := "Label Type".AsInteger();
    end;
}

