page 37002603 "Supply Driven Output Subform"
{
    // PRW16.00.03
    // P8000793, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001092, Columbus IT, Don Bresee, 17 SEP 12
    //   Add Variant Code
    //   Change page source from the Family Line table to temp table (Process Order Request Line)
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW10.0
    // P8007748, To-Increase, Jack Reynolds, 06 DEC 16
    //   NAV 2017 upgrade

    Caption = 'Supply Driven Output Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Process Order Request Line";
    SourceTableTemporary = true;

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
                    Caption = 'Item No.';
                    Editable = false;
                    TableRelation = Item;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant Code';
                    Editable = false;
                    Visible = false;
                }
                field("FamilyLine.Description"; FamilyLine.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    Editable = false;
                }
                field("FamilyLine.""By-Product"""; FamilyLine."By-Product")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'By-Product';
                    Editable = false;
                    Visible = false;
                }
                field("Maximum Quantity"; MaxReqQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maximum Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unit of Measure Code';
                    Editable = false;
                }
                field("Quantity to Package"; CurrReqQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity to Package';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateQuantities; // P8001132
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateQuantities; // P8001132
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        // EXIT(SDPMgmt.OutputPageFind(Rec,Which)); // P8001092
        exit(SDPMgmt.OutputPageBuild(Rec, Which));   // P8001092
    end;

    var
        SDPMgmt: Codeunit "Supply Driven Planning Mgmt.";
        CurrReqQty: Decimal;
        MaxReqQty: Decimal;
        FamilyLine: Record "Family Line";

    procedure SetSDPMgmt(var ParentSDPMgmt: Codeunit "Supply Driven Planning Mgmt.")
    begin
        SDPMgmt := ParentSDPMgmt;
    end;

    local procedure UpdateQuantities()
    begin
        // P8001092, P8001132
        // SDPMgmt.GetOutputPageQtys(Rec,CurrReqQty,MaxReqQty);
        if not FamilyLine.Get("Process BOM No.", "Output Family Line No.") then // P8007748
            exit;                                                                // P8007748
        SDPMgmt.GetOutputPageQtys(FamilyLine, CurrReqQty, MaxReqQty);
    end;
}

