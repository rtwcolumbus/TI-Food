page 37002216 "Finished Repack Order Subform"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 24 JUL 07
    //   Standard subform for finshed repack orders
    // 
    // PR5.00
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 15 JAN 10
    //   Change Form Caption
    // 
    // P8000664, VerticalSoft, Jimmy Abidi, 15 JAN 10
    //   Transformed from Form
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds 17 NOV 13
    //   Cleanup dimensions

    Caption = 'Lines';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Repack Order Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Source Location"; "Source Location")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LotNoLookup(Text));
                    end;
                }
                field("Quantity Transferred"; "Quantity Transferred")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Transferred (Alt.)"; "Quantity Transferred (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        AltQtyMgmt.ShowRepackLineAltQtyEntries(Rec, FieldNo("Quantity Transferred (Alt.)")); // P8000504A
                    end;
                }
                field("Quantity Consumed"; "Quantity Consumed")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Consumed (Alt.)"; "Quantity Consumed (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        AltQtyMgmt.ShowRepackLineAltQtyEntries(Rec, FieldNo("Quantity Consumed (Alt.)")); // P8000504A
                    end;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
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
                        ShowDimensions; // P8004516
                    end;
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not IsOpenForm then begin
            IsOpenForm := true;
        end;
        exit(Find(Which));
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Type := xRec.Type;
    end;

    var
        ShortcutDimCode: array[8] of Code[20];
        ProcessFns: Codeunit "Process 800 Functions";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        IsOpenForm: Boolean;
}

