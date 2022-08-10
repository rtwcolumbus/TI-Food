page 37002960 "Quality Control Sample Lines"
{
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Quality Control Sample";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Sample)
            {
                field("Test Code"; Rec."Test Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Test Description"; Rec."Test Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Rec."Sample Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Posted(Line)"; Rec."Quantity Posted (Line)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity Posted';
                }
                field("Qty. to Post"; Rec."Quanity to Post")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; Rec."Quantity to Post (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = AltQtyVisible;
                }
            }
        }
    }


    trigger OnOpenPage()
    var
        Item: Record Item;
    begin
        Item.Get(Rec."Item No.");
        if Item."Alternate Unit of Measure" <> '' then
            if Item."Catch Alternate Qtys." and P800Functions.AltQtyInstalled() then
                AltQtyVisible := true;
    end;

    var
        QCSampleHeader: Record "Quality Control Sample";
        P800Functions: Codeunit "Process 800 Functions";
        AltQtyVisible: Boolean;

    procedure SetSampleData(var QCSample: Record "Quality Control Sample" temporary)
    begin
        Rec.Copy(QCSample, true);
    end;
}