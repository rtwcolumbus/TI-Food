page 37002083 "Sales Order Alt. Qty. Subform"
{
    // PR3.60
    //   Create form for alternate quantity entry
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 02 JUN 04
    //    Support for easy lot tracking
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   Resize to fit subform control on parent form
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 18 NOV 09
    //   Transformed from Form
    //   Page changes made after transformation
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 10 JUN 10
    //   Rework code after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW111.00.03
    // P80080576, To-Increase, Gangabhushan, 19 AUG 19
    //   CS00073003 - Fix for case CS00071299 has broken the ability to do multiple items
    // 
    // P80085559, To-Increase, Gangabhushan, 30 OCT 19
    //   CS00079256 - New scenario causing issue after implementing change for CS00076976
    // 
    // P80087817, To-Increase, Gangabhushan, 21 NOV 19
    //   In SO - Alternative Qty is not allowing for detail Setup & for multiple UOM Items.
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Sales Order Alt. Qty. Lines';
    DelayedInsert = true;
    PageType = ListPart;
    PopulateAllFields = true;
    SourceTable = "Alternate Quantity Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Item No."; GetItemNo())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item No.';
                    Editable = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SalesLine2: Record "Sales Line";
                    begin
                        GetSalesLine(Rec, SalesLine2);
                        SalesLine2.SetRange("Document Type", SalesLine2."Document Type"::Order);
                        SalesLine2.SetRange("Document No.", "Document No.");
                        SalesLine2.SetRange(Type, SalesLine2.Type::Item);
                        PAGE.RunModal(0, SalesLine2);
                    end;
                }
                field(Description; GetItemDescription())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    Editable = false;
                }
                field("Unit of Measure Code"; GetItemUOM())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unit of Measure Code';
                    Editable = false;
                }
                field("Line No."; SeqNo)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Line No.';
                    Editable = false;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    var
                        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
                    begin
                        AltQtyTracking.AssistEditSerialNo(Rec);
                    end;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    var
                        AltQtyTracking: Codeunit "Alt. Qty. Tracking Management";
                    begin
                        AltQtyTracking.AssistEditLotNo(Rec);
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        ValidateBaseQty;
                        CurrPage.Update; // P8000828
                        UpdateSalesLine;
                    end;
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateBaseQty;
                        CurrPage.Update; // P8000828
                        UpdateSalesLine;
                    end;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8000828
                        UpdateSalesLine;
                    end;
                }
                field("Invoiced Qty. (Base)"; "Invoiced Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Invoiced Qty. (Alt.)"; "Invoiced Qty. (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        ClearSource;
    end;

    trigger OnAfterGetRecord()
    begin
        if ("Source Line No." = 0) then
            SeqNo := 0
        else
            SeqNo := GetSeqNo("Line No.");
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        "Quantity (Base)" := 0;
        "Quantity (Alt.)" := 0;
        Modify;
        UpdateSalesLine;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        GetSalesLine(Rec, SalesLine);
        AltQtyMgmt.AssignNewTransactionNo(SalesLine."Alt. Qty. Transaction No.");
        Item.Get(SalesLine."No.");
        SalesLine.Modify;

        // "Alt. Qty. Transaction No." := SalesLine."Alt. Qty. Transaction No."; // P8000828
        // "Line No." := GetNewLineNo(BelowxRec);                                // P8000828
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        xRecForInsert := xRec;
        FindSalesLine(BelowxRec);
    end;

    var
        SeqNo: Integer;
        xRecForInsert: Record "Alternate Quantity Line";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        Text001: Label '%1 %2 cannot exceed %3.';
        Text002: Label 'All Alternate Quantities have been entered.';

    local procedure GetSalesLine(AltQtyLine: Record "Alternate Quantity Line"; var SalesLine: Record "Sales Line")
    begin
        // GetSalesLine
        with AltQtyLine do
            if not SalesLine.Get("Document Type", "Document No.", "Source Line No.") then
                Clear(SalesLine);
    end;

    local procedure GetItemNo(): Code[20]
    var
        SalesLine: Record "Sales Line";
    begin
        // GetItemNo
        GetSalesLine(Rec, SalesLine);
        exit(SalesLine."No.");
    end;

    local procedure GetItemDescription(): Text[100]
    var
        SalesLine: Record "Sales Line";
    begin
        // GetItemDescription
        GetSalesLine(Rec, SalesLine);
        exit(SalesLine.Description);
    end;

    local procedure GetItemUOM(): Code[10]
    var
        SalesLine: Record "Sales Line";
    begin
        // GetItemUOM
        GetSalesLine(Rec, SalesLine);
        exit(SalesLine."Unit of Measure Code");
    end;

    local procedure GetNewLineNo(BelowxRec: Boolean): Integer
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // GetNewLineNo
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
        if BelowxRec or ("Alt. Qty. Transaction No." <> xRecForInsert."Alt. Qty. Transaction No.") then begin
            if not AltQtyLine.Find('+') then
                AltQtyLine."Line No." := 0;
            exit(AltQtyLine."Line No." + 10000);
        end;
        AltQtyLine.SetFilter("Line No.", '<%1', xRecForInsert."Line No.");
        if not AltQtyLine.Find('+') then
            AltQtyLine."Line No." := 0;
        exit((AltQtyLine."Line No." + xRecForInsert."Line No.") div 2);
    end;

    local procedure GetSeqNo(CurrLineNo: Integer): Integer
    var
        SalesLine: Record "Sales Line";
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // GetSeqNo
        AltQtyLine := Rec;
        GetSalesLine(AltQtyLine, SalesLine);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", SalesLine."Alt. Qty. Transaction No.");
        if (CurrLineNo <> 0) then
            AltQtyLine.SetFilter("Line No.", '<%1', CurrLineNo);
        exit(AltQtyLine.Count + 1);
    end;

    local procedure ValidateBaseQty()
    var
        SalesLine: Record "Sales Line";
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // ValidateBaseQty
        GetSalesLine(Rec, SalesLine);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
        AltQtyLine.SetFilter("Line No.", '<>%1', "Line No.");
        AltQtyLine.CalcSums("Quantity (Base)");
        if (("Quantity (Base)" + AltQtyLine."Quantity (Base)") > (SalesLine."Qty. to Ship" * SalesLine."Qty. per Unit of Measure")) then // P80087817
            Error(Text001,
              SalesLine.TableCaption,
              SalesLine.FieldCaption("Qty. to Ship"),
              SalesLine."Qty. to Ship");
    end;

    local procedure UpdateSalesLine()
    var
        SalesLine: Record "Sales Line";
        AltQtyLine: Record "Alternate Quantity Line";
        OldAltQtyLine: Record "Alternate Quantity Line";
    begin
        // UpdateSalesLine
        GetSalesLine(Rec, SalesLine);
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
        AltQtyLine.SetFilter("Line No.", '<>%1', "Line No.");
        AltQtyLine.CalcSums("Quantity (Alt.)");
        SalesLine.Validate("Qty. to Ship (Alt.)", AltQtyLine."Quantity (Alt.)" + "Quantity (Alt.)");
        AltQtyMgmt.SetSalesLineAltQty(SalesLine);
        SalesLine.Modify(true);
    end;

    local procedure FindSalesLine(BelowAltQtyLine: Boolean)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        SalesLine: Record "Sales Line";
    begin
        // FindSalesLine
        GetSalesLine(xRec, SalesLine);
        FindAltQtySalesLine(SalesLine);
        ClearSource;

        "Alt. Qty. Transaction No." := SalesLine."Alt. Qty. Transaction No.";
        SeqNo := 0;                               // P8000828
        if (SalesLine."Line No." <> 0) then begin // P8000828
            SetUpNewLine(xRec, "Table No.", "Document Type", "Document No.", '', '',
                         SalesLine."Line No.", SalesLine."Qty. to Ship" * SalesLine."Qty. per Unit of Measure"); // P80085559
            "Line No." := GetNewLineNo(BelowAltQtyLine); // P8000828
            "Line No." := GetNewLineNo(BelowAltQtyLine); // P8000828
            if xRec."Source Line No." = SalesLine."Line No." then // P8000043A
                "Lot No." := xRec."Lot No."                         // P8000043A
            else                                                  // P8000043A
                "Lot No." := SalesLine."Lot No.";                   // P8000043A
            if ("Source Line No." = 0) then
                SeqNo := 0
            else
                if BelowAltQtyLine or ("Source Line No." <> xRec."Source Line No.") then
                    SeqNo := GetSeqNo(0)
                else
                    SeqNo := GetSeqNo(xRec."Line No.");
        end;                                      // P8000828
    end;

    local procedure FindAltQtySalesLine(var SalesLine: Record "Sales Line")
    var
        SalesLine2: Record "Sales Line";
        Item: Record Item;
    begin
        // FindAltQtySalesLine
        SalesLine2 := SalesLine;
        SalesLine2.SetRange("Document Type", "Document Type");
        SalesLine2.SetRange("Document No.", "Document No.");
        SalesLine2.SetRange(Type, SalesLine2.Type::Item);
        SalesLine2.SetFilter("No.", '<>%1', '');
        if SalesLine2.Find('-') then
            repeat
                Item.Get(SalesLine2."No.");
                if (Item."Alternate Unit of Measure" <> '') and Item."Catch Alternate Qtys." then
                    if (SalesLine2."Qty. to Ship (Base)" <>
                       Round(AltQtyMgmt.CalcAltQtyLinesQtyBase1(SalesLine2."Alt. Qty. Transaction No."), 0.00001)) // P80080576
                    then begin
                        SalesLine := SalesLine2;
                        exit;
                    end;
            until (SalesLine2.Next = 0);
        Clear(SalesLine);
    end;
}

