page 37002540 "Pre-Process Activity Subpage"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00.01
    // P80057829, To-Increase, Dayakar Battini, 27 APR 18
    //   Provide Container handling for non blending pre-process activities

    AutoSplitKey = true;
    Caption = 'Pre-Process Activity Subpage';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Pre-Process Activity Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(0, 0, "Item No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(0, 0, "Item No.");
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = lotEditable;
                    Lookup = false;

                    trigger OnAssistEdit()
                    begin
                        if IsLotTracked() then
                            if AssistEditLotNo() then
                                CurrPage.Update;
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("From Container License Plate"; "From Container License Plate")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(ContainerFns.LookupContainerOnWhseLine(Rec, FieldNo("From Container License Plate"), Text));
                    end;
                }
                field("To Container License Plate"; "To Container License Plate")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(ContainerFns.LookupContainerOnWhseLine(Rec, FieldNo("To Container License Plate"), Text));
                    end;
                }
                field("Qty. to Process"; "Qty. to Process")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Qty. to Process (Base)"; "Qty. to Process (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Quantity Processed"; "Quantity Processed")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Processed (Base)"; "Qty. Processed (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Warehouse Entries")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Warehouse Entries';
                Image = BinLedger;
                RunObject = Page "Warehouse Entries";
                RunPageLink = "Source No." = FIELD("Activity No."),
                              "Source Line No." = FIELD("Line No.");
                RunPageView = SORTING("Source Type", "Source Subtype", "Source No.")
                              WHERE("Source Type" = CONST(37002494),
                                    "Source Subtype" = CONST("0"));
            }
            action("New Container")
            {
                ApplicationArea = FOODBasic;
                AccessByPermission = TableData "Container Header" = R;
                Caption = 'New Container';
                Enabled = NewContainerEnabled;
                Image = NewItem;

                trigger OnAction()
                begin
                    // P80057829
                    ContainerFns.NewContainerOnWhsePreProcessActivityLine(Rec);
                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetControlProperties;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        InitRecord;
    end;

    var
        item: Record Item;
        [InDataSet]
        qtyAltEditable: Boolean;
        [InDataSet]
        lotEditable: Boolean;
        AllergenManagement: Codeunit "Allergen Management";
        [InDataSet]
        NewContainerEnabled: Boolean;
        ContainerFns: Codeunit "Container Functions";

    procedure SetControlProperties()
    begin
        if item."No." <> "Item No." then
            item.Get("Item No.");

        qtyAltEditable := item."Catch Alternate Qtys.";
        lotEditable := IsLotTracked();
        NewContainerEnabled := 0 <= "Qty. to Process";
    end;
}

