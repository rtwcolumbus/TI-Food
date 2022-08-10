page 37002099 "Lot Tracing Dest. Subpage"
{
    // PRW16.00.05
    // P8000979, Columbus IT, Don Bresee, 09 SEP 11
    //   Add Lot Tracing to Enhanced Lot Tracking granule
    // 
    // P8000984, Columbus IT, Don Bresee, 18 OCT 11
    //   Modify Lot Tracing Action for Multiple Lot Trace
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Lot Tracing Source Subpage';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Lot Tracing Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002007)
            {
                ShowCaption = false;
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
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
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        LotTracingMgmt.Navigate(Rec);
                    end;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Name"; "Source Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        LotTracingMgmt.ShowRelatedEntries(Rec);
                    end;
                }
                field("LotTracingMgmt.GetTraceUOMCode(""Item No."")"; LotTracingMgmt.GetTraceUOMCode("Item No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unit of Measure Code';
                    TableRelation = "Unit of Measure";
                }
                field("Trace Quantity"; "Trace Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Trace Lot Qty.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Trace")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Trace';
                Image = Trace;
                ShortCutKey = 'Ctrl+T';

                trigger OnAction()
                begin
                    OpenLotTracing;
                end;
            }
            separator(Separator37002018)
            {
            }
            action("&Navigate")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Find entries...';
                Image = Navigate;
                ShortCutKey = 'Shift+Ctrl+I';

                trigger OnAction()
                begin
                    LotTracingMgmt.Navigate(Rec);
                end;
            }
            action("&Lot Entries")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Lot Entries';
                Image = LotInfo;
                ShortCutKey = 'Ctrl+O';

                trigger OnAction()
                begin
                    LotTracingMgmt.ShowLotEntries(Rec);
                end;
            }
            action("&Related Entries")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Related Entries';
                Image = Entries;
                ShortCutKey = 'Ctrl+R';

                trigger OnAction()
                begin
                    LotTracingMgmt.ShowRelatedEntries(Rec);
                end;
            }
        }
    }

    var
        LotTracingMgmt: Codeunit "Lot Tracing Management";

    procedure SetData(var TempBuf: Record "Item Tracing Buffer" temporary)
    begin
        // LotTracingMgmt.CopyTempPageBuf(Rec, TempBuf);
        // CurrPage.Update(false);
    end;

    procedure SetData(var TempBuf: Record "Lot Tracing Buffer" temporary)
    begin
        LotTracingMgmt.CopyTempPageBuf(Rec, TempBuf);
        CurrPage.Update(false);
    end;

    local procedure OpenLotTracing()
    var
        OldRec: Record "Lot Tracing Buffer";
        LotTracingPage: Page "Lot Tracing";
        MultLotTracePage: Page "Multiple Lot Trace";
    begin
        // P8000984
        OldRec.Copy(Rec);
        CurrPage.SetSelectionFilter(Rec);
        SetFilter("Lot No.", '<>%1', '');
        if (Count > 1) then begin
            MultLotTracePage.SetTraceFromItemTracingBuf(Rec);
            MultLotTracePage.Run;
        end else begin
            LotTracingPage.SetTraceLot("Item No.", "Variant Code", "Lot No.");
            LotTracingPage.Run;
        end;
        Copy(OldRec);
    end;
}

