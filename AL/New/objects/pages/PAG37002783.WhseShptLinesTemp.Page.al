page 37002783 "Whse. Shipment Lines Temporary"
{
    // PRW120.4
    // P800158446, To-Increase, Gangabhushan, 20 OCT 22
    //   CS00222757 | Warehouse shipment - Use filters to get source docs is not working properly
    //   New page is created to avoid error while copying records from 'Run and Select' function

    Caption = 'Whse. Shipment Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Warehouse Shipment Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Source Document"; Rec."Source Document")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the type of document that the line relates to.';
                    Visible = false;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                }
                field("Destination Type"; Rec."Destination Type")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the type of destination associated with the warehouse shipment line.';
                    Visible = false;
                }
                field("Destination No."; Rec."Destination No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the customer, vendor, or location to which the items should be shipped.';
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the item that should be shipped.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the description of the item in the line.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that should be shipped.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the date when the related warehouse activity, such as a pick, must be completed to ensure items can be shipped by the shipment date.';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                }
            }
        }
    }

    procedure SetSource(var WhseShipmentLine: Record "Warehouse Shipment Line" temporary)
    var
        AllObj: Record AllObj;
    begin
        Rec.Copy(WhseShipmentLine, true);
    end;

    procedure GetSource(var WhseShipmentLine: Record "Warehouse Shipment Line" temporary)
    begin
        CurrPage.SetSelectionFilter(Rec);
        WhseShipmentLine.Copy(Rec, true);
    end;
}

