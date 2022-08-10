page 909 "Assembly Line Avail."
{
    Caption = 'Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Assembly Line";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Document Type", "Document No.", Type)
                      ORDER(Ascending)
                      WHERE("Document Type" = CONST(Order),
                            Type = CONST(Item),
                            "No." = FILTER(<> ''));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Inventory';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the assembly component are in inventory.';
                    Visible = false;
                }
                field(GrossRequirement; GrossRequirement)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Gross Requirement';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the total demand for the assembly component.';
                }
                field(ScheduledReceipt; ScheduledRcpt)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Scheduled Receipt';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the assembly component are inbound on orders.';
                }
                field(ExpectedAvailableInventory; ExpectedInventory)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Expected Available Inventory';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the assembly component are available for the current assembly order on the due date.';
                    Visible = true;
                }
                field(CurrentQuantity; "Remaining Quantity")
                {
                    ApplicationArea = Assembly;
                    Caption = 'Current Quantity';
                    ToolTip = 'Specifies how many units of the component are required on the assembly order line.';
                }
                field("Quantity per"; "Quantity per")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies how many units of the assembly component are required to assemble one assembly item.';
                }
                field("Reserved Quantity"; "Reserved Quantity")
                {
                    ApplicationArea = Reservation;
                    Caption = 'Current Reserved Quantity';
                    ToolTip = 'Specifies how many units of the assembly component have been reserved for this assembly order line.';
                    Visible = false;
                }
                field(EarliestAvailableDate; EarliestDate)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Earliest Available Date';
                    ToolTip = 'Specifies the late arrival date of an inbound supply order that can cover the needed quantity of the assembly component.';
                }
                field(AbleToAssemble; AbleToAssemble)
                {
                    ApplicationArea = Assembly;
                    Caption = 'Able to Assemble';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the assembly item on the assembly order header can be assembled, based on the availability of the component.';
                }
                field("Lead-Time Offset"; "Lead-Time Offset")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies the lead-time offset that is defined for the assembly component on the assembly BOM.';
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the location from which you want to post consumption of the assembly component.';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Substitution Available"; "Substitution Available")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies if a substitute is available for the item on the assembly order line.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetItemFilter(Item);
        CalcAvailToAssemble(
          AssemblyHeader,
          Item,
          GrossRequirement,
          ScheduledRcpt,
          ExpectedInventory,
          Inventory,
          EarliestDate,
          AbleToAssemble);
    end;

    trigger OnInit()
    begin
        SetItemFilter(Item);
    end;

    trigger OnOpenPage()
    begin
        Reset;
        SetRange(Type, Type::Item);
        SetFilter("No.", '<>%1', '');
        SetFilter("Quantity per", '<>%1', 0);
    end;

    var
        AssemblyHeader: Record "Assembly Header";
        Item: Record Item;
        ExpectedInventory: Decimal;
        GrossRequirement: Decimal;
        ScheduledRcpt: Decimal;
        Inventory: Decimal;
        EarliestDate: Date;
        AbleToAssemble: Decimal;

    procedure SetLinesRecord(var AssemblyLine: Record "Assembly Line")
    begin
        Copy(AssemblyLine, true);
    end;

    procedure SetHeader(AssemblyHeader2: Record "Assembly Header")
    begin
        AssemblyHeader := AssemblyHeader2;
    end;
}

