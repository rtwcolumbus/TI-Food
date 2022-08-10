query 37002562 "Container Physical Detail"
{
    // PRW17.10.03
    // P8001337, Columbus IT, Dayakar Battini, 06 Aug 14
    //    Container Visibilty with Bin Status.

    Caption = 'Containers by Bin';
    OrderBy = Ascending(Bin_Code);

    elements
    {
        dataitem(Container_Line; "Container Line")
        {
            column(Location_Code; "Location Code")
            {
            }
            column(Item_No; "Item No.")
            {
            }
            column(Variant_Code; "Variant Code")
            {
            }
            column(Bin_Code; "Bin Code")
            {
            }
            column(Lot_No; "Lot No.")
            {
            }
            column(Serial_No; "Serial No.")
            {
            }
            column(Container_ID; "Container ID")
            {
            }
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            {
            }
            column(Sum_Quantity; Quantity)
            {
                Method = Sum;
            }
            column(Sum_Quantity_Base; "Quantity (Base)")
            {
                ColumnFilter = Sum_Quantity_Base = FILTER(<> 0);
                Method = Sum;
            }
            column(Sum_Quantity_Alt; "Quantity (Alt.)")
            {
                Method = Sum;
            }
            dataitem(Container_Header; "Container Header")
            {
                DataItemLink = ID = Container_Line."Container ID";
                column(License_Plate; "License Plate")
                {
                }
                column(Document_Type; "Document Type")
                {
                }
                filter(Inbound; Inbound)
                {
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin
        SetRange(Inbound, false);
    end;
}

