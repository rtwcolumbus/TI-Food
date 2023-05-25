page 37002594 "Container Quantity to Handle"
{
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work

    Caption = 'Container Quantity to Handle';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = StandardDialog;
    SourceTable = "Container Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control37002012)
            {
                ShowCaption = false;
                field(TotalQuantity; TotalQuantity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field(TotalQtyToHandle; TotalQtyToHandle)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Qty. to Handle';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("TotalQuantity - TotalQtyToHandle"; TotalQuantity - TotalQtyToHandle)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Remaining Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
            }
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(QtyToHandle; QtyToHandle)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Qty. to Handle';
                    DecimalPlaces = 0 : 5;
                    Editable = QtyEditable;
                    MinValue = 0;

                    trigger OnValidate()
                    begin
                        if Quantity < QtyToHandle then
                            Error(Text001);

                        TotalQtyToHandle += QtyToHandle - "Weight (Base)";
                        if TotalQuantity < TotalQtyToHandle then
                            Error(Text002);

                        "Quantity (Base)" := Round(QtyToHandle * "Qty. per Unit of Measure", 0.00001);

                        if QtyToHandle = Quantity then
                            QtyToHandleAlt := "Quantity (Alt.)"
                        else
                            if (Item."Alternate Unit of Measure" <> '') and (not Item."Catch Alternate Qtys.") then
                                QtyToHandleAlt := Round("Quantity (Base)" * Item.AlternateQtyPerBase, 0.00001)
                            else
                                QtyToHandleAlt := 0;

                        "Weight (Base)" := QtyToHandle;
                        "Tare Weight (Base)" := QtyToHandleAlt;

                        CurrPage.Update(true);

                        AltQtyEditable := CatchAltQty and (QtyToHandle <> 0) and (QtyToHandle <> Quantity);
                    end;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = CatchAltQty;
                }
                field(QtyToHandleAlt; QtyToHandleAlt)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Qty. to Handle (Alt.)';
                    DecimalPlaces = 0 : 5;
                    Editable = AltQtyEditable;
                    MinValue = 0;
                    Visible = CatchAltQty;

                    trigger OnValidate()
                    var
                        AltQtyMgmt: Codeunit "Alt. Qty. Management";
                    begin
                        if "Quantity (Alt.)" < QtyToHandleAlt then
                            Error(Text003);

                        Item.TestField("Catch Alternate Qtys.", true);
                        AltQtyMgmt.CheckTolerance("Item No.", Text004, "Quantity (Base)", QtyToHandleAlt);

                        "Tare Weight (Base)" := QtyToHandleAlt;

                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        QtyToHandle := "Weight (Base)";
        QtyToHandleAlt := "Tare Weight (Base)";

        AltQtyEditable := CatchAltQty and (QtyToHandle <> 0) and (QtyToHandle <> Quantity);
    end;

    trigger OnInit()
    begin
        QtyEditable := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (CloseAction = ACTION::OK) and (TotalQtyToHandle < TotalQuantity) then
            if Confirm(Text000, false) then
                exit(true)
            else
                exit(false);
    end;

    var
        Item: Record Item;
        TotalQuantity: Decimal;
        TotalQtyToHandle: Decimal;
        QtyToHandle: Decimal;
        Text000: Label 'Quantity to handle is less than total quantity.\Close anyway?';
        Text001: Label 'Qty. to Handle may not exceed Quantity.';
        Text002: Label 'Qty. to Handle may not exceed Total Quantity.';
        QtyToHandleAlt: Decimal;
        Text003: Label 'Alternate Qty. to Handle may not exceed Alternate Quantity.';
        [InDataSet]
        CatchAltQty: Boolean;
        [InDataSet]
        QtyEditable: Boolean;
        [InDataSet]
        AltQtyEditable: Boolean;
        Text004: Label 'Alternate Qty. to Handle';

    procedure SetSource(var TempContainerLine: Record "Container Line" temporary; TotalQty: Decimal)
    begin
        TotalQuantity := TotalQty;

        if TempContainerLine.FindSet then begin
            repeat
                Rec := TempContainerLine;
                "Weight (Base)" := 0;
                "Tare Weight (Base)" := 0;
                Insert;
            until TempContainerLine.Next = 0;

            Item.Get("Item No.");
            CatchAltQty := Item."Catch Alternate Qtys.";
            if 1 = Count then begin
                QtyEditable := false;
                "Weight (Base)" := TotalQuantity;
                "Quantity (Base)" := Round(TotalQuantity * "Qty. per Unit of Measure", 0.00001);
                Modify;

                TotalQtyToHandle := TotalQuantity;
            end;
        end;

        if FindFirst then;
    end;

    procedure GetSource(var TempContainerLine: Record "Container Line" temporary)
    begin
        TempContainerLine.Reset;
        TempContainerLine.DeleteAll;

        Reset;
        if FindSet then
            repeat
                if 0 < "Weight (Base)" then begin
                    TempContainerLine := Rec;
                    TempContainerLine.Quantity := "Weight (Base)";
                    TempContainerLine."Quantity (Alt.)" := "Tare Weight (Base)";
                    TempContainerLine.Insert;
                end;
            until Next = 0;
    end;
}

