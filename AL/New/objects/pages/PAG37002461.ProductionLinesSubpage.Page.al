page 37002461 "Production Lines Subpage"
{
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.04
    // P8000853, VerticalSoft, Jack Reynolds, 05 AUG 10
    //   Lookup for No. fixed
    // 
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // P8000868, VerticalSoft, Rick Tweedle, 15 SEP 10
    //   Added Genesis Enhancements
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
    // 
    // PRW19.00.01
    // P8007746, To-Increase, Dayakar Battini, 10 OCT 16
    //   Cleanup % Total field calculations.
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    AutoSplitKey = true;
    Caption = 'Production Lines Subpage';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Production BOM Line";

    layout
    {
        area(content)
        {
            repeater(Control37002007)
            {
                FreezeColumn = Description;
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;

                    trigger OnValidate()
                    begin
                        UpdateEditable;
                    end;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        // P8000853
                        if Rec.NoLookup then begin
                            Text := Rec."No.";
                            exit(true);
                        end else
                            exit(false);
                    end;

                    // P800155629
                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, "No.");
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = VariantCodeMandatory;
                    Visible = false;

                    // P800155629
                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, "No.");
                    end;
                }
                field("Step Code"; Rec."Step Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Batch Quantity"; Rec."Batch Quantity")
                {
                    ApplicationArea = FOODBasic;
                    DecimalPlaces = 0 : 5;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Quantity (Alt.)"; Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("% of Total"; Rec."% of Total")
                {
                    ApplicationArea = FOODBasic;
                    DecimalPlaces = 1 : 1;
                    Editable = false;
                    HideValue = TypeIsText;
                }
                field("Commodity Class Code"; Rec."Commodity Class Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Pre-Process Type Code"; Rec."Pre-Process Type Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pre-Process Lead Time (Days)"; Rec."Pre-Process Lead Time (Days)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Unit Cost (Costing Units)"; Rec."Unit Cost (Costing Units)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Extended Cost"; Rec."Extended Cost")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    HideValue = TypeIsText;
                }
                field("Yield % (Weight)"; Rec."Yield % (Weight)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Yield % (Volume)"; Rec."Yield % (Volume)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                    HideValue = TypeIsText;
                }
                field("Auto Plan if Component"; Rec."Auto Plan if Component")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable2;
                }
                field("Routing Link Code"; Rec."Routing Link Code")
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
        Item: Record "Item";
    begin
        UpdateEditable;
        // P800155629
        if Rec."Variant Code" = '' then
            VariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, Rec."No.");
        // P800155629
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if (Rec."Production BOM No." = xRec."Production BOM No.") and (Rec."Version Code" = xRec."Version Code") then begin
            Rec.Type := xRec.Type;
            Rec."Step Code" := xRec."Step Code";
        end else
            Rec.Type := Rec.Type::Item;

        UpdateEditable;
        VariantCodeMandatory := false; // P800155629
    end;

    var
        Item: Record Item;
        [InDataSet]
        VersionEditable: Boolean;
        [InDataSet]
        VersionEditable2: Boolean;
        [InDataSet]
        TypeIsText: Boolean;
        VariantCodeMandatory: Boolean;

    procedure SetFormulaMode()
    begin
    end;

    procedure SetEditable(Flag: Boolean)
    begin
        VersionEditable := Flag;
    end;

    local procedure UpdateEditable()
    begin
        TypeIsText := (Rec.Type = Rec.Type::" ");
        VersionEditable2 := VersionEditable and (not TypeIsText);
    end;

    procedure ShowComment()
    var
        ProdOrderCompComment: Record "Production BOM Comment Line";
    begin
        ProdOrderCompComment.SetRange("Production BOM No.", Rec."Production BOM No.");
        ProdOrderCompComment.SetRange("BOM Line No.", Rec."Line No.");
        ProdOrderCompComment.SetRange("Version Code", Rec."Version Code");

        PAGE.Run(PAGE::"Prod. Order BOM Cmt. Sheet", ProdOrderCompComment);
    end;

    procedure ShowWhereUsed()
    var
        Item: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersion: Record "Production BOM Version";
        ProdBOMWhereUsed: Page "Prod. BOM Where-Used";
    begin
        if Rec.Type = Rec.Type::" " then
            exit;

        ProdBOMVersion.Get("Production BOM No.", "Version Code");
        case Rec.Type of
            Rec.Type::Item:
                begin
                    Item.Get("No.");
                    ProdBOMWhereUsed.SetItem(Item, ProdBOMVersion."Starting Date");
                end;
            Rec.Type::"Production BOM":
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
        Rec.TestField(Type, Rec.Type::Item);
        Item.Get(Rec."No.");
        Item.TestField("Item Tracking Code");
        ItemTrackingCode.Get(Item."Item Tracking Code");
        ItemTrackingCode.TestField("Lot Specific Tracking", true);

        BOMLine := Rec;
        BOMLine.SetRecFilter;
        LotPreferences.SetTableView(BOMLine);
        LotPreferences.RunModal;
    end;
}

