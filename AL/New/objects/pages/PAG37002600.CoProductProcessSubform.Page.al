page 37002600 "Co-Product Process Subform"
{
    // PR3.70.03
    //   Renamed from Generic Process Subform
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   Resize to fit subform control on parent form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001031, Columbus IT, Jack Reynolds, 31 JAN 12
    //   Fix problem with editable property of Output FastTab on Co/By-Product Card
    // 
    // PRW16.00.06
    // P8001092, Columbus IT, Don Bresee, 17 AUG 12
    //   Add "Variant Code", "Primary Co-Product", and "Co-Product Cost Share" fields
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    AutoSplitKey = true;
    Caption = 'Co-Product Process Subform';
    DelayedInsert = true;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "Family Line";

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
                    Editable = VersionEditable;

                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        ProcessOrderMgmt.CheckFamilyLineUnitType(Rec, VersionCode); // P8001031
                        // P800155629
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(true, Rec."Item No.");
                        // P800155629
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    ShowMandatory = VersionEditable and VariantCodeMandatory;
                    Visible = false;

                    // P800155629
                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(true, Rec."Item No.");
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Visible = false;
                }
                field("By-Product"; "By-Product")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8001092
                    end;
                }
                field("Primary Co-Product"; "Primary Co-Product")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8001092
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Cost Amount"; "Cost Amount")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Co-Product Cost Share"; "Co-Product Cost Share")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
            }
        }
    }

    actions
    {
    }

    // P800155629
    trigger OnAfterGetRecord()
    var
        Item: Record "Item";
    begin
        if Rec."Variant Code" = '' then
            VariantCodeMandatory := Item.IsVariantMandatory(true, Rec."Item No.");
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        exit(VersionEditable); // P8001031
    end;

    // P800155629
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        VariantCodeMandatory := false;
    end;

    var
        ProcessOrderMgmt: Codeunit "Process Order Management";
        VersionCode: Code[20];
        [InDataSet]
        VersionEditable: Boolean;
        VariantCodeMandatory: Boolean;


    procedure SetVersion("Code": Code[20])
    begin
        // P8001031
        VersionCode := Code;
    end;

    procedure SetEditable(Flag: Boolean)
    begin
        // P8001031
        VersionEditable := Flag;
    end;
}

