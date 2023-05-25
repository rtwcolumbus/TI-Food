page 37002493 "Item Process Version"
{
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW18.00.01
    // P8001384, Columbus IT, Jack Reynolds, 08 MAY 15
    //   Fix wrong link for Comments action
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Item Process Version';
    DataCaptionExpression = SetCaption;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "Production BOM Version";
    SourceTableView = WHERE(Type = CONST(Process));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Version Code"; "Version Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Importance = Promoted;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Importance = Promoted;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field(Allergens; ("Direct Allergen Set ID" <> 0) or ("Indirect Allergen Set ID" <> 0))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        SetEditable;
                        CurrPage.Update;
                    end;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Lines; "Production Lines Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Production BOM No." = FIELD("Production BOM No."),
                              "Version Code" = FIELD("Version Code");
            }
            part(Equipment; "Production Equipment Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Equipment';
                SubPageLink = "Production Bom No." = FIELD("Production BOM No."),
                              "Version Code" = FIELD("Version Code");
            }
            part(Costs; "Production Costs Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Costs';
                SubPageLink = "Production Bom No." = FIELD("Production BOM No."),
                              "Version Code" = FIELD("Version Code");
            }
            group(Detail)
            {
                Caption = 'Detail';
                field("Production Sequence Code"; "Production Sequence Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Proper Shipping Name"; "Proper Shipping Name")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
            }
        }
        area(factboxes)
        {
            part(AllergenFactbox; "Allergen Factbox")
            {
                ApplicationArea = FOODBasic;
                Provider = Lines;
                SubPageLink = "Table No. Filter" = CONST(99000772),
                              "Type Filter" = FIELD(Type),
                              "No. Filter" = FIELD("No.");
                Visible = false;
            }
            part("Item Process Batch Size"; "Production Batch Size FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Process Batch Size';
                SubPageLink = "Production BOM No." = FIELD("Production BOM No."),
                              "Version Code" = FIELD("Version Code");
            }
            part("Item Process Cost (by Weight)"; "Production Cost FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Process Cost (by Weight)';
                SubPageLink = "Production BOM No." = FIELD("Production BOM No."),
                              "Version Code" = FIELD("Version Code");
            }
            part(ActiveVersionItemProcessCost; "Production Cost FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Process Cost (Active Version)';
                SubPageLink = "Production BOM No." = FIELD("Production BOM No.");
            }
            systempart(Control37002033; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002034; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Item Process")
            {
                Caption = '&Item Process';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Manufacturing Comment Sheet";
                    RunPageLink = "Table Name" = CONST("Production BOM Header"),
                                  "No." = FIELD("Production BOM No.");
                }
                action("Ma&trix per Version")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ma&trix per Version';
                    Image = ProdBOMMatrixPerVersion;

                    trigger OnAction()
                    var
                        ProdBOM: Record "Production BOM Header";
                        BOMMatrixForm: Page "Prod. BOM Matrix per Version";
                    begin
                        ProdBOM.Get("Production BOM No.");
                        BOMMatrixForm.Set(ProdBOM);
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
                        ProdBOM: Record "Production BOM Header";
                        WhereUsedPage: Page "Prod. BOM Where-Used";
                    begin
                        ProdBOM.Get("Production BOM No.");
                        WhereUsedPage.SetType(Format(ProdBOM."Mfg. BOM Type"));
                        WhereUsedPage.SetProdBOM(ProdBOM, WorkDate);
                        WhereUsedPage.Run;
                    end;
                }
                action(Allergens)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Image = Properties;
                    ObsoleteReason = 'Replaced by ShowAllergens action';
                    ObsoleteState = Pending;
                    ObsoleteTag = 'FOOD-22';
                    Visible = false;

                    trigger OnAction()
                    begin
                        // P8006959
                        ShowAllergens;
                    end;
                }
                action(ShowAllergens)
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
                action(AllergenHistory)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergen History';
                    Image = History;
                    RunObject = Page "Allergen Set History";
                    RunPageLink = "Table No." = CONST(99000779),
                                  "Code 1" = FIELD("Production BOM No."),
                                  "Code 2" = FIELD("Version Code");
                }
                action(AllergenDetail)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergen Detail';
                    Image = Properties;

                    trigger OnAction()
                    begin
                        // P8006959
                        ShowAllergenDetail;
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Copy &Item Process Version")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Copy &Item Process Version';
                    Image = Copy;

                    trigger OnAction()
                    var
                        BOMVersion: Record "Production BOM Version";
                        "Production BOM-Copy": Codeunit "Production BOM-Copy";
                    begin
                        BOMVersion := Rec;
                        BOMVersion.SetRange("Production BOM No.", "Production BOM No.");
                        "Production BOM-Copy".CopyFromVersion(BOMVersion);
                        CurrPage.Update(false);
                    end;
                }
            }
            action(Print)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print';
                Ellipsis = true;
                Image = Print;

                trigger OnAction()
                var
                    BOMVersion: Record "Production BOM Version";
                begin
                    BOMVersion := Rec;
                    BOMVersion.SetRecFilter;
                    REPORT.Run(REPORT::"Process Version Details", true, false, BOMVersion);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetEditable;
    end;

    trigger OnOpenPage()
    begin
        CurrPage.ActiveVersionItemProcessCost.PAGE.SetActiveVersionMode;
    end;

    var
        [InDataSet]
        VersionEditable: Boolean;
        Text000: Label 'Formula is certified.';

    procedure SetEditable()
    begin
        VersionEditable := not (Status in [Status::Certified, Status::Closed]);
        CurrPage.Lines.PAGE.SetEditable(VersionEditable);
        CurrPage.Equipment.PAGE.SetEditable(VersionEditable);
        CurrPage.Costs.PAGE.SetEditable(VersionEditable);
    end;

    procedure SetCaption(): Text[250]
    var
        BOMHeader: Record "Production BOM Header";
    begin
        BOMHeader.Get("Production BOM No.");
        exit(StrSubstNo('%1 - %2 - %3', "Production BOM No.", BOMHeader.Description, "Version Code"));
    end;
}

