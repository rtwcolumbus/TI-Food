page 37002115 "Containers by Bin FactBox"
{
    // PRW17.10.03
    // P8001337, Columbus IT, Dayakar Battini, 06 Aug 14
    //    Container Visibilty with Bin Status.

    Caption = 'Containers by Bin';
    PageType = ListPart;
    SourceTable = "Container Line";
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
                    Visible = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'License Plate';
                }
                field("Quantity (Base)"; "Quantity (Base)")
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

    procedure FillTempTable()
    var
        Location: Record Location;
        ContainersByBinCode: Query "Containers by Bin";
        LineNo: Integer;
    begin
        FilterGroup(4);
        Location.Get(GetRangeMin("Location Code"));

        ContainersByBinCode.SetRange(Item_No, GetRangeMin("Item No."));
        ContainersByBinCode.SetRange(Variant_Code, GetRangeMin("Variant Code"));
        ContainersByBinCode.SetRange(Location_Code, GetRangeMin("Location Code"));
        ContainersByBinCode.SetRange(Bin_Code, GetRangeMin("Bin Code"));
        if GetFilter("Lot No.") <> '' then
            ContainersByBinCode.SetRange(Lot_No, GetFilter("Lot No."));
        if Location."Directed Put-away and Pick" then
            ContainersByBinCode.SetRange(Unit_of_Measure_Code, GetRangeMin("Unit of Measure Code"));
        FilterGroup(0);

        ContainersByBinCode.Open;
        Reset;
        DeleteAll;
        while ContainersByBinCode.Read do begin
            Init;
            "Line No." := "Line No." + 10000;
            "Item No." := ContainersByBinCode.Item_No;
            "Variant Code" := ContainersByBinCode.Variant_Code;
            "Bin Code" := ContainersByBinCode.Bin_Code;
            "Location Code" := ContainersByBinCode.Location_Code;
            "Lot No." := ContainersByBinCode.Lot_No;
            "Container ID" := ContainersByBinCode.Container_ID;
            Description := ContainersByBinCode.License_Plate;
            "Quantity (Base)" := ContainersByBinCode.Sum_Quantity_Base;
            "Unit of Measure Code" := ContainersByBinCode.Unit_of_Measure_Code;
            Insert;
        end;
    end;
}

