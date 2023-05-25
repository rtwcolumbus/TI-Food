page 37002116 "Lot Numbers by Bin and UOM FB"
{
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot Numbers by Bin';
    PageType = ListPart;
    SourceTable = "Lot Bin Buffer-Food";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control7)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
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
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        FillTempTable;
        exit(Find(Which));
    end;

    local procedure FillTempTable()
    var
        LotNosByBinUOM: Query "Lot Numbers by Bin and UOM";
    begin
        LotNosByBinUOM.SetRange(Item_No, GetRangeMin("Item No."));
        LotNosByBinUOM.SetRange(Variant_Code, GetRangeMin("Variant Code"));
        LotNosByBinUOM.SetRange(Location_Code, GetRangeMin("Location Code"));
        LotNosByBinUOM.SetRange(Bin_Code, GetRangeMin("Bin Code"));
        LotNosByBinUOM.SetRange(UOM, GetRangeMin("Unit of Measure Code"));
        LotNosByBinUOM.Open;

        DeleteAll;

        while LotNosByBinUOM.Read do begin
            Init;
            "Item No." := LotNosByBinUOM.Item_No;
            "Variant Code" := LotNosByBinUOM.Variant_Code;
            "Location Code" := LotNosByBinUOM.Location_Code;
            "Bin Code" := LotNosByBinUOM.Bin_Code;
            "Lot No." := LotNosByBinUOM.Lot_No;
            "Unit of Measure Code" := LotNosByBinUOM.UOM;
            Quantity := LotNosByBinUOM.Quantity;
            Insert;
        end;
    end;
}

