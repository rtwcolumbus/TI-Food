page 37002524 "Batch Planning - Pkg. by Batch"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Packaage order sub-pages for the Batch Planning - Plan Item page
    // 
    // PRW16.00.06
    // P8001089, Columbus IT, Jack Reynolds, 15 AUG 12
    //   Fix page update issue (always moving to first record)
    // 
    // PRW17.00.01
    // P8001182, Columbus IT, Jack Reynolds, 18 JUL 13
    //   Modify to use signalling instead of SENDKEYS to trigger an action
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Batch Planning - Pkg. by Batch';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Batch Planning - Package";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Batch No.", "Equipment Code", "Item No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Equipment Code"; "Equipment Code")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = NOT SummaryRec;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field("""Package Time (Hours)"" + ""Other Time (Hours)"""; "Package Time (Hours)" + "Other Time (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Time (Hours)';
                    DecimalPlaces = 0 : 5;
                    HideValue = NOT SummaryRec;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field("Additional Quantity Possible"; "Additional Quantity Possible")
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = HighlightRec;

                    trigger OnValidate()
                    begin
                        if BatchPlanningFns.ModifyPackages(Rec, true) then
                            CurrPage.Update(false);
                    end;
                }
                field("Production Time (Hours)"; "Production Time (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = HighlightRec;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Pack Additional Quantity")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Pack Additional Quantity';
                Image = Inventory;
                ShortCutKey = 'Shift+F11';

                trigger OnAction()
                begin
                    ApplyAdditionalQty;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SummaryRec := Summary;
        HighlightRec := Highlight;
    end;

    var
        PackageOrder: Record "Batch Planning - Package" temporary;
        BatchPlanningFns: Codeunit "Batch Planning Functions";
        [InDataSet]
        SummaryRec: Boolean;
        [InDataSet]
        HighlightRec: Boolean;

    procedure SetSharedCU(var CU: Codeunit "Batch Planning Functions")
    begin
        BatchPlanningFns := CU;
    end;

    procedure ApplyAdditionalQty()
    var
        PackageOrder2: Record "Batch Planning - Package" temporary;
    begin
        CurrPage.SetSelectionFilter(PackageOrder);
        if PackageOrder.FindSet then
            repeat
                PackageOrder2 := PackageOrder;
                PackageOrder2.Insert;
            until PackageOrder.Next = 0;

        if PackageOrder2.FindSet then begin
            repeat
                PackageOrder.Get(PackageOrder2."Batch No.", PackageOrder2."Equipment Code",
                  PackageOrder2."Item No.", PackageOrder2."Variant Code");
                if PackageOrder."Additional Quantity Possible" > 0 then begin
                    PackageOrder.Quantity += PackageOrder."Additional Quantity Possible";
                    BatchPlanningFns.ModifyPackages(PackageOrder, false);
                    UpdateRecords;
                end;
            until PackageOrder2.Next = 0;
            BatchPlanningFns.TriggerUpdate(2, 'PACKAGE QUANTITY');
            CurrPage.Update(false);
        end;
    end;

    procedure UpdateRecords()
    var
        Package: Record "Batch Planning - Package" temporary;
        PackageFilters: Record "Batch Planning - Package";
        CurrentRec: Record "Batch Planning - Package";
    begin
        CurrentRec := Rec; // P8001089
        PackageFilters.CopyFilters(Rec);
        Reset;
        DeleteAll;
        Rec.CopyFilters(PackageFilters);
        SetCurrentKey("Batch No.", "Equipment Code");

        PackageOrder.Reset;
        PackageOrder.DeleteAll;

        BatchPlanningFns.GetPackages(Package, 'BATCH');
        if Package.FindSet then
            repeat
                Rec := Package;
                Insert;
                PackageOrder := Package;
                PackageOrder.Insert;
            until Package.Next = 0;

        if not Get(CurrentRec."Batch No.", CurrentRec."Equipment Code", CurrentRec."Item No.", CurrentRec."Variant Code") then // P8001089
            if not FindFirst then;

        CurrPage.Update(false); // P8001182
    end;

    procedure UpdateDisplay()
    begin
        UpdateRecords;
        CurrPage.Update(false);
    end;
}

