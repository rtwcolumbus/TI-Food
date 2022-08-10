page 37002485 "Package BOM Lines Subpage"
{
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.04
    // P8000853, VerticalSoft, Jack Reynolds, 05 AUG 10
    //   Lookup for No. fixed
    // 
    // PRW16.00.06
    // P8001008, Columbus IT, Jack Reynolds, 22 DEC 11
    //   Fix problem with client crash when attempting to copy rows
    // 
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001082, Columbus IT, Rick Tweedle, 29 JUN 12
    //   Added Pre-Process fields
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    AutoSplitKey = true;
    Caption = 'Package BOM Lines Subpage';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Production BOM Line";

    layout
    {
        area(content)
        {
            repeater(Control37002006)
            {
                FreezeColumn = Description;
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;

                    trigger OnValidate()
                    begin
                        UpdateEditable;
                    end;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        // P8000853
                        if NoLookup then begin
                            Text := "No.";
                            exit(true);
                        end else
                            exit(false);
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Step Code"; "Step Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Pre-Process Type Code"; "Pre-Process Type Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pre-Process Lead Time (Days)"; "Pre-Process Lead Time (Days)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                }
                field("Quantity per"; "Quantity per")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Unit Cost (Costing Units)"; "Unit Cost (Costing Units)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Extended Cost"; "Extended Cost")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    HideValue = TypeIsText;
                }
                field("Auto Plan if Component"; "Auto Plan if Component")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                }
                field("Routing Link Code"; "Routing Link Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Co&mments")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Co&mments';
                Image = Comment;

                trigger OnAction()
                begin
                    ShowComment;
                end;
            }
            action("Where-Used")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Where-Used';
                Image = "Where-Used";

                trigger OnAction()
                begin
                    ShowWhereUsed;
                end;
            }
            action("Lot Preferences")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Preferences';
                Image = NewLotProperties;

                trigger OnAction()
                begin
                    ShowLotPreferences;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        BOMHeader: Record "Production BOM Header";
    begin
        UpdateEditable;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if ("Production BOM No." = xRec."Production BOM No.") and ("Version Code" = xRec."Version Code") then begin
            Type := xRec.Type;
            "Step Code" := xRec."Step Code";
        end else
            Type := Type::Item;

        UpdateEditable;
    end;

    var
        [InDataSet]
        VersionEditable: Boolean;
        [InDataSet]
        VersionEditable2: Boolean;
        [InDataSet]
        TypeIsText: Boolean;

    procedure SetEditable(Flag: Boolean)
    begin
        VersionEditable := Flag;
    end;

    local procedure UpdateEditable()
    begin
        TypeIsText := (Type = 0);
        VersionEditable2 := VersionEditable and (not TypeIsText);
    end;

    procedure ShowComment()
    var
        ProdOrderCompComment: Record "Production BOM Comment Line";
    begin
        ProdOrderCompComment.SetRange("Production BOM No.", "Production BOM No.");
        ProdOrderCompComment.SetRange("BOM Line No.", "Line No.");
        ProdOrderCompComment.SetRange("Version Code", "Version Code");

        PAGE.Run(PAGE::"Prod. Order BOM Cmt. Sheet", ProdOrderCompComment);
    end;

    procedure ShowWhereUsed()
    var
        Item: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersion: Record "Production BOM Version";
        ProdBOMWhereUsed: Page "Prod. BOM Where-Used";
    begin
        if Type = Type::" " then
            exit;

        ProdBOMVersion.Get("Production BOM No.", "Version Code");
        case Type of
            Type::Item:
                begin
                    Item.Get("No.");
                    ProdBOMWhereUsed.SetItem(Item, ProdBOMVersion."Starting Date");
                end;
            Type::"Production BOM":
                begin
                    ProdBOMHeader.Get("No.");
                    ProdBOMWhereUsed.SetProdBOM(ProdBOMHeader, ProdBOMVersion."Starting Date");
                end;
        end;
        ProdBOMWhereUsed.Run;
    end;

    procedure ShowLotPreferences()
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        BOMLine: Record "Production BOM Line";
        LotPreferences: Page "BOM Line Lot Preferences";
    begin
        TestField(Type, Type::Item);
        Item.Get("No.");
        Item.TestField("Item Tracking Code");
        ItemTrackingCode.Get(Item."Item Tracking Code");
        ItemTrackingCode.TestField("Lot Specific Tracking", true);

        BOMLine := Rec;
        BOMLine.SetRecFilter;
        LotPreferences.SetTableView(BOMLine);
        LotPreferences.RunModal;
    end;
}

