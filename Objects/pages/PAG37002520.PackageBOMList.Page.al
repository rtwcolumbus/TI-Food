page 37002520 "Package BOM List"
{
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Package BOMs';
    CardPageID = "Package BOM";
    Editable = false;
    PageType = List;
    SourceTable = "Production BOM Header";
    SourceTableView = WHERE("Mfg. BOM Type" = CONST(BOM));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Search Name"; "Search Name")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Versions; "Production Version Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Versions';
                SubPageLink = "Production BOM No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            part(ProductionCostFactBox; "Production Cost FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Package BOM Cost';
                Provider = Versions;
                SubPageLink = "Production BOM No." = FIELD("Production BOM No."),
                              "Version Code" = FIELD("Version Code");
                Visible = false;
            }
            part(ActiveVersionProductionCostFactBox; "Production Cost FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Package BOM Cost (Active Version)';
                Provider = Versions;
                SubPageLink = "Production BOM No." = FIELD("Production BOM No.");
                Visible = false;
            }
            systempart(Control37002009; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002010; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Package BOM")
            {
                Caption = '&Package BOM';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Manufacturing Comment Sheet";
                    RunPageLink = "Table Name" = CONST("Production BOM Header"),
                                  "No." = FIELD("No.");
                }
                action("Ma&trix per Version")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ma&trix per Version';
                    Image = ProdBOMMatrixPerVersion;

                    trigger OnAction()
                    var
                        BOMMatrixForm: Page "Prod. BOM Matrix per Version";
                    begin
                        BOMMatrixForm.Set(Rec);
                        BOMMatrixForm.Run;
                    end;
                }
                action("Where-used")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Where-used';
                    Image = "Where-Used";

                    trigger OnAction()
                    var
                        WhereUsedPage: Page "Prod. BOM Where-Used";
                    begin
                        WhereUsedPage.SetType(Format("Mfg. BOM Type"));
                        WhereUsedPage.SetProdBOM(Rec, WorkDate);
                        WhereUsedPage.Run;
                    end;
                }
                action(Allergens)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Image = Properties;

                    trigger OnAction()
                    begin
                        // P8006959
                        ShowAllergens;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.ProductionCostFactBox.PAGE.SetTotalsOnlyMode;

        CurrPage.ActiveVersionProductionCostFactBox.PAGE.SetTotalsOnlyMode;
        CurrPage.ActiveVersionProductionCostFactBox.PAGE.SetActiveVersionMode;
    end;

    var
        ProdBOMWhereUsed: Page "Prod. BOM Where-Used";
}

