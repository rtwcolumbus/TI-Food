page 37002604 "Supply Driven Package Subform"
{
    // PRW16.00.03
    // P8000793, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001092, Columbus IT, Don Bresee, 11 SEP 12
    //   Add Variant Code and Demand Qty.
    //   Change page source from the Production BOM Line table to temp table (Process Order Request Line)
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Supply Driven Package Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Process Order Request Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Package BOM No."; "Package BOM No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    LookupPageID = "Package BOM List";
                    Visible = false;
                }
                field("Item No."; "Finished Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item No.';
                    Editable = false;
                    TableRelation = Item WHERE("Item Type" = CONST("Finished Good"));
                }
                field("Variant Code"; "Finished Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant Code';
                    Editable = false;
                    Visible = false;
                }
                field("Item Description"; "Finished Item Description")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Description';
                    DrillDown = false;
                    Editable = false;
                }
                field("Maximum Quantity"; MaxReqQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maximum Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("Quantity to Package"; CurrReqQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity to Package';
                    DecimalPlaces = 0 : 12;
                    MinValue = 0;

                    trigger OnValidate()
                    begin
                        if (CurrReqQty > MaxReqQty) then
                            Error(Text001, MaxReqQty);
                        SDPMgmt.SavePackagePageQty(Rec, CurrReqQty);
                        CurrPage.Update;
                    end;
                }
                field("Demand Quantity"; DemandQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Demand Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = false;
                }
                field("Remaining Demand Qty."; RemDemandQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Remaining Demand Qty.';
                    DecimalPlaces = 0 : 5;
                    DrillDown = false;
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
        // EXIT(SDPMgmt.PackagePageFind(Rec,Which)); // P8001092
        exit(SDPMgmt.PackagePageBuild(Rec, Which));   // P8001092
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        // EXIT(SDPMgmt.PageNext(Rec,Steps)); // P8001092
        exit(Next(Steps));                    // P8001092
    end;

    var
        MaxReqQty: Decimal;
        CurrReqQty: Decimal;
        ItemNo: Code[20];
        ItemDescription: Text[100];
        Text001: Label 'Quantity to Package cannot be greater than %1.';
        SDPMgmt: Codeunit "Supply Driven Planning Mgmt.";
        VariantCode: Code[10];
        DemandQty: Decimal;
        RemDemandQty: Decimal;

    procedure SetSDPMgmt(var ParentSDPMgmt: Codeunit "Supply Driven Planning Mgmt.")
    begin
        SDPMgmt := ParentSDPMgmt;
    end;

    local procedure UpdateQuantities()
    begin
        // P8001092, P8001132
        // SDPMgmt.GetPackagePageQtys(Rec,ItemNo,ItemDescription,CurrReqQty,MaxReqQty);
        SDPMgmt.GetPackagePageQtys(Rec, CurrReqQty, MaxReqQty);
        DemandQty := SDPMgmt.CalcPackageDemandQty("Finished Item No.", "Finished Variant Code");
        CalcFields("Total Finished Quantity");
        RemDemandQty := DemandQty - "Total Finished Quantity";
        if (RemDemandQty < 0) then
            RemDemandQty := 0;
    end;
}

