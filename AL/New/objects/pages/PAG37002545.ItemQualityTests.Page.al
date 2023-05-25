page 37002545 "Item Quality Tests"
{
    // PR1.10.01
    //   Add Test menu button for Comments
    // 
    // PR1.10.02
    //   Add menu button access to item test results
    // 
    // PR1.10.03
    //   Fix glue problem
    // 
    // PR2.00
    //   Item Tracking
    // 
    // PR2.00.04
    //   Document Management
    // 
    // PR3.70
    //   Update Item menu button to match Item List
    // 
    // PR3.70.02
    //   Change key on Item Tests
    // 
    // PR3.70.07
    // P8000119A, Myers Nissi, Jack Reynolds, 24 SEP 04
    //   Add Accrual Groups option
    // 
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Add menu item to get list of serial numbers
    // 
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Rename Test menu item to Quality Tests
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 13 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 01 MAY 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001194, Columbus IT, Jack Reynolds, 27 AUG 13
    //    Fix promoted action categories
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW119.03
    // P800139946, To-Increase, Gangabhushan, 24 FEB 22
    //   Copy QC test-templates to Item Quality Tests
    //
    // P800144674, To-Increase, Gangabhushan, 01 JUN 22
    //   Q/C templates can be added to Items without Item Tracking Code

    ApplicationArea = FOODBasic;
    Caption = 'Item Quality Tests';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = Item;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            field(BlnDisplaySorting; BlnDisplaySorting)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Item Type"; Rec."Item Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Item Tracking Code"; Rec."Item Tracking Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot Nos."; Rec."Lot Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quarantine Calculation"; Rec."Quarantine Calculation")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Expiration Calculation"; Rec."Expiration Calculation")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot Strength"; Rec."Lot Strength")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Tests; "Item Quality Tests Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Source Key 1" = FIELD("No.");
            }
        }
        area(factboxes)
        {
            part(ItemInvoicingFactBox; "Item Invoicing FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
                Visible = false;
            }
            part(ItemReplenishmentFactBox; "Item Replenishment FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
                Visible = false;
            }
            part(ItemPlanningFactBox; "Item Planning FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
                Visible = false;
            }
            part(ItemWarehouseFactBox; "Item Warehouse FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
                Visible = false;
            }
            part(ItemAltQuantityFactBox; "Item Alt. Quantity FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
                Visible = false;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Item")
            {
                Caption = '&Item';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Item Card";
                    RunPageOnRec = true;
                    ShortCutKey = 'Return';
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(Item),
                                  "No." = FIELD("No.");
                }
                action("Quality &Tests")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quality &Tests';
                    Image = CheckRulesSyntax;

                    // P800144674
                    trigger OnAction()
                    var
                        DataCollectionLine: Record "Data Collection Line";
                        ItemTests: Page "Item Tests";
                    begin
                        if Rec.CheckQualityAllowed(Rec."No.") then begin
                            DataCollectionLine.SetRange("Source Key 1", Rec."No.");
                            ItemTests.SetTableView(DataCollectionLine);
                            ItemTests.RunModal();
                        end else
                            Error(QCTemplateError, Rec."No.")
                    end;
                    // P800144674
                }
                action(ToggleTest)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sort on Test';
                    Image = SortAscending;
                    Visible = BlnDisplaySorting;
                    trigger OnAction()
                    begin
                        // P800139946
                        BlnDisplaySorting := not BlnDisplaySorting;
                        CurrPage.Tests.Page.SetSortingPrefference(BlnDisplaySorting, true);
                    end;

                }
                action(ToggleTemplate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sort on Template';
                    Image = SortAscending;
                    Visible = not BlnDisplaySorting;
                    trigger OnAction()
                    begin
                        // P800139946
                        BlnDisplaySorting := not BlnDisplaySorting;
                        CurrPage.Tests.Page.SetSortingPrefference(BlnDisplaySorting, true);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ToggleTest_Promoted; ToggleTest)
                {
                }
                actionref(ToggleTemplate_Promoted; ToggleTemplate)
                {
                }
            }
            group(Category_Item)
            {
                Caption = 'Item';

                actionref(Card_Promoted; Card)
                {
                }
                actionref(Comments_Promoted; "Co&mments")
                {
                }
                actionref(QualityTests_Promoted; "Quality &Tests")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // P800139946
        CurrPage.Tests.Page.SetSortingPrefference(BlnDisplaySorting, false);
    end;

    var
        TblshtgHeader: Record "Troubleshooting Header";
        SkilledResourceList: Page "Skilled Resource List";
        CalculateStdCost: Codeunit "Calculate Standard Cost";
        Text000: Label 'Quality Tests for %1 %2';
        BlnDisplaySorting: Boolean;
        QCTemplateError: Label 'Item %1 should be Lot tracked'; // P800144674
}

