page 37002829 "Maintenance Material Journal"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard journal style form for maintenance journal (material)
    // 
    // PRW15.00.01
    // P8000517A, VerticalSoft, Jack Reynolds, 13 SEP 07
    //   Provide lookup in spares list
    // 
    // PRW16.00.20
    // P8000672, VerticalSoft, Jack Reynolds, 03 FEB 09
    //   Support for opening from batch form
    // 
    // P8000664, VerticalSoft, Jack Reynolds, 02 FEB 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Lookup of Shortcut Dimensions, Standardize OpenedFromBatch
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    AutoSplitKey = true;
    Caption = 'Maintenance Material Journals';
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Maintenance Journal Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord;
                    MaintJnlMgt.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                    MaintJnlMgt.CheckName(CurrentJnlBatchName, Rec);
                end;

                trigger OnValidate()
                begin
                    MaintJnlMgt.CheckName(CurrentJnlBatchName, Rec);
                    CurrPage.SaveRecord;
                    MaintJnlMgt.SetName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                end;
            }
            repeater(Control37002003)
            {
                ShowCaption = false;
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = FOODBasic;
                    OptionCaption = ',Stock,Nonstock';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Work Order No."; "Work Order No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(MaintMgt.WorkOrderGracePeriodLookup(Text)); // P8000335A
                    end;

                    trigger OnValidate()
                    begin
                        MaintJnlMgt.GetWorkOrder("Work Order No.", AssetDescription);
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DimVisible2;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupItem(Text)); // P8000517A
                    end;
                }
                field("Part No."; "Part No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnAssistEdit()
                    begin
                        LotNoAssistEdit;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LotNoLookup(Text));
                    end;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnAssistEdit()
                    begin
                        SerialNoAssistEdit;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(SerialNoLookup(Text));
                    end;
                }
                field("Applies-to Entry"; "Applies-to Entry")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Control37002018)
            {
                ShowCaption = false;
                fixed(Control37002000)
                {
                    ShowCaption = false;
                    group("Asset Description")
                    {
                        Caption = 'Asset Description';
                        field(AssetDescription; AssetDescription)
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                            ShowCaption = false;
                        }
                    }
                    group("Item Description")
                    {
                        Caption = 'Item Description';
                        field(ItemDescription; ItemDescription)
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                            ShowCaption = false;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(DimensionSetEntriesFactBox; "Dimension Set Entries FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Dimension Set ID" = FIELD("Dimension Set ID");
                Visible = false;
            }
            systempart(Control1900000004; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000005; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions;      // P8001133
                        CurrPage.SaveRecord; // P8001133
                    end;
                }
            }
            group("&Work Order")
            {
                Caption = '&Work Order';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Work Order";
                    RunPageLink = "No." = FIELD("Work Order No.");
                    ShortCutKey = 'Shift+F7';
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                action("Test Report")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintMaintJnlLine(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Image = Post;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Maint. Jnl.-Post", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Maint. Jnl.-Post+Print", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Post)
            {
                Caption = 'Post';
                ShowAs = SplitButton;

                actionref(Post_Promoted; "P&ost")
                {
                }
                actionref(PostAndPrint_Promoted; "Post and &Print")
                {
                }
            }
            actionref(Dimensions_Promoted; Dimensions)
            {
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        MaintJnlMgt.GetWorkOrder("Work Order No.", AssetDescription);
        MaintJnlMgt.GetItem("Item No.", ItemDescription);
    end;

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
        if xRec."Entry Type" = "Entry Type"::"Material-Nonstock" then
            Validate("Entry Type", "Entry Type"::"Material-Nonstock")
        else
            Validate("Entry Type", "Entry Type"::"Material-Stock");
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        SetDimensionVisibility; // P80073095
        // P8000672
        if IsOpenedFromBatch then begin // P8004516
            CurrentJnlBatchName := "Journal Batch Name";
            MaintJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        // P8000672
        MaintJnlMgt.TemplateSelection(PAGE::"Maintenance Material Journal", 1, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        MaintJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
    end;

    var
        MaintJnlMgt: Codeunit "Maintenance Journal Management";
        MaintMgt: Codeunit "Maintenance Management";
        ReportPrint: Codeunit "Test Report-Print";
        CurrentJnlBatchName: Code[10];
        AssetDescription: Text[100];
        ItemDescription: Text[100];

    protected var
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P80073095
        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
    end;
}

