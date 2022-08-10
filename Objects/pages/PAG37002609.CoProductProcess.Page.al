page 37002609 "Co-Product Process"
{
    // PRW16.00.03
    // P8000793, VerticalSoft, Don Bresee, 17 MAR 10
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

    Caption = 'Co-Product Process';
    PageType = ListPlus;
    PopulateAllFields = true;
    SourceTable = "Production BOM Header";
    SourceTableView = WHERE("Mfg. BOM Type" = CONST(Process),
                            "Output Type" = CONST(Family));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("Search Name"; "Search Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Auto Version Numbering"; "Auto Version Numbering")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Allergens; "Allergen Set ID" <> 0)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                }
            }
            part(Output; "Co-Product Process Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Output';
                SubPageLink = "Family No." = FIELD("No.");
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
            part(ProductionBatchSizeFactBox; "Production Batch Size FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Co-Product Process Batch Size';
                Provider = Versions;
                SubPageLink = "Production BOM No." = FIELD("Production BOM No."),
                              "Version Code" = FIELD("Version Code");
                Visible = false;
            }
            part(ProductionCostFactBox; "Production Cost FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Co-Product Process Cost (by Weight)';
                Provider = Versions;
                SubPageLink = "Production BOM No." = FIELD("Production BOM No."),
                              "Version Code" = FIELD("Version Code");
                Visible = false;
            }
            part(ActiveVersionProductionCostFactBox; "Production Cost FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Co-Product Process Cost (Active Version)';
                Provider = Versions;
                SubPageLink = "Production BOM No." = FIELD("Production BOM No.");
                Visible = false;
            }
            systempart(Control37002002; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002001; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Co-Product Process")
            {
                Caption = '&Co-Product Process';
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
        CurrPage.ActiveVersionProductionCostFactBox.PAGE.SetActiveVersionMode;
    end;

    var
        ProdBOMWhereUsed: Page "Prod. BOM Where-Used";
}

