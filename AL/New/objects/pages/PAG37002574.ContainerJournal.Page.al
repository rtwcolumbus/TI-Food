page 37002574 "Container Journal"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Standard journal form for the container journal
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" and related logic
    // 
    // PRW16.00.02
    // P8000782, VerticalSoft, Rick Tweedle, 02 MAR 10
    //   Transformed to Page using transfor tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
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
    Caption = 'Container Journals';
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Container Journal Line";
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
                    ContJnlMgt.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    ContJnlMgt.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali;
                end;
            }
            repeater(Control37002001)
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
                    OptionCaption = 'Acquisition,,Transfer,,Return,Adjust Tare,Disposal';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Container Item No."; "Container Item No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Container Serial No."; "Container Serial No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if Confirm(Text000) then
                            AssignSerialNo;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SerialNo: Record "Serial No. Information";
                        SerialLookup: Page "Serial Nos.";
                    begin
                        SerialNo.SetRange("Item No.", "Container Item No.");
                        SerialNo.SetRange("Variant Code", '');
                        SerialLookup.LookupMode(true);
                        SerialLookup.SetTableView(SerialNo);
                        if Text <> '' then
                            if SerialNo.Get("Container Item No.", '', Text) then
                                SerialLookup.SetRecord(SerialNo);
                        if SerialLookup.RunModal = ACTION::LookupOK then begin
                            SerialLookup.GetRecord(SerialNo);
                            Text := SerialNo."Serial No.";
                            exit(true);
                        end;
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
                    ShowCaption = false;
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
                    ShowCaption = false;
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
                    ShowCaption = false;
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
                    ShowCaption = false;
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
                    ShowCaption = false;
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
                    ShowCaption = false;
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Container ID"; "Container ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("New Location Code"; "New Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("New Bin Code"; "New Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit Amount"; "Unit Amount")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Tare Weight"; "Tare Weight")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Tare Unit of Measure"; "Tare Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
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
            group("&Container")
            {
                Caption = '&Container';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page Container;
                    RunPageLink = ID = FIELD("Container ID");
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
                        ReportPrint.PrintContainerJnlLine(Rec);
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
                        CODEUNIT.Run(CODEUNIT::"Container Jnl.-Post", Rec);
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
                        CODEUNIT.Run(CODEUNIT::"Container Jnl.-Post+Print", Rec);
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
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        // P8004516
        if IsOpenedFromBatch then begin
            CurrentJnlBatchName := "Journal Batch Name";
            ContJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        // P8004516
        ContJnlMgt.TemplateSelection(PAGE::"Container Journal", Rec, JnlSelected); // PR4.00
        if not JnlSelected then                                                  // PR4.00
            Error('');                                                             // PR4.00
        ContJnlMgt.OpenJnl(CurrentJnlBatchName, Rec);
        SetDimensionVisibility; // P80073095
    end;

    var
        ContJnlMgt: Codeunit ContainerJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        CurrentJnlBatchName: Code[10];
        Text000: Label 'Assign serial number?';

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

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord;
        ContJnlMgt.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;

    local procedure SetDimensionVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        // P80073095
        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
    end;
}

