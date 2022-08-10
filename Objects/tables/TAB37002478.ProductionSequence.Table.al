table 37002478 "Production Sequence"
{
    // PR4.00
    // P8000259A, VerticalSoft, Jack Reynolds, 28 OCT 05
    //   List of codes used to specify sequencing requirements for production orders
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Production Sequence';
    LookupPageID = "Production Sequence Codes";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Display Bold"; Boolean)
        {
            Caption = 'Display Bold';
        }
        field(4; "Sequence Value"; Integer)
        {
            Caption = 'Sequence Value';

            trigger OnValidate()
            begin
                if "Sequence Value" <> xRec."Sequence Value" then begin
                    ProdOrder.SetFilter(Status, '<>%1', ProdOrder.Status::Finished);
                    ProdOrder.SetRange("Production Sequence Code", Code);
                    if ProdOrder.Find('-') then
                        repeat
                            ProdOrder."Production Sequence Value" := "Sequence Value";
                            ProdOrder.Modify;
                        until ProdOrder.Next = 0;
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Sequence Value")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ProdBOMVersion.SetRange("Production Sequence Code", Code);
        if ProdBOMVersion.Find('-') then
            Error(Text001, TableCaption, Code, ProdBOMVersion.TableCaption);

        ProdOrder.SetFilter(Status, '<>%1', ProdOrder.Status::Finished);
        ProdOrder.SetRange("Production Sequence Code", Code);
        if ProdOrder.Find('-') then
            Error(Text001, TableCaption, Code, ProdOrder.TableCaption);
    end;

    var
        ProdBOMVersion: Record "Production BOM Version";
        ProdOrder: Record "Production Order";
        Text001: Label 'You cannot delete %1 %2 because there is at least one %3 that includes this item.';
}

