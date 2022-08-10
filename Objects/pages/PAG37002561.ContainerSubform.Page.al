page 37002561 "Container Subform"
{
    // PRW16.00.02
    // P8000782, VerticalSoft, Rick Tweedle, 02 MAR 10
    //   Transformed to Page using transfor tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW18.00.02
    // P8004266, To-Increase, Jack Reynolds, 06 OCT 15
    //   Split containers
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0.02
    // P80039780, To-Increase, Jack Reynolds, 01 DEC 17
    //   Warehouse Receiving process
    // 
    // PRW111.0.02
    // P80068487, To-Increase, Gangabhushan, 18 DEC 18
    //   TI-12540 - Blank Container Lines are Created and Left Behind
    //        DelayedInsert property changed to 'Yes'

    AutoSplitKey = true;
    Caption = 'Container Subform';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Container Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(0, 0, "Item No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(0, 0, "Item No.");
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        LotNoAssistEdit; // P80039780
                    end;
                }
                field(LotStatus; LotStatus)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Status';
                    Visible = false;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("DisplayWeight(""Weight (Base)"")"; DisplayWeight("Weight (Base)"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Net Weight';
                    DecimalPlaces = 0 : 3;
                }
                field("DisplayWeight(""Tare Weight (Base)"")"; DisplayWeight("Tare Weight (Base)"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Tare Weight';
                    DecimalPlaces = 0 : 3;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("Assign Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Assign Lot No.';

                    trigger OnAction()
                    begin
                        AssignLotNo;
                    end;
                }
            }
        }
    }

    var
        AllergenManagement: Codeunit "Allergen Management";

    procedure GetSelectedLines(var ContainerLine: Record "Container Line")
    begin
        // P8004266
        CurrPage.SetSelectionFilter(ContainerLine);
    end;
}

