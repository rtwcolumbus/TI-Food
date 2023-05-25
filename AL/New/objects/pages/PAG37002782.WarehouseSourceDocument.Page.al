page 37002782 "Warehouse Source Document"
{
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Warehouse Source Document';
    Editable = false;
    PageType = List;
    SourceTable = "Warehouse Request";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Type';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document No.';
                }
                field("Destination Type"; "Destination Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Destination No."; "Destination No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(DestinationName; DestinationName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Destination Name';
                }
            }
        }
    }

    actions
    {
    }

    procedure SetSource(var SourceDocument: Record "Warehouse Request" temporary)
    begin
        Rec.Copy(SourceDocument, true);
    end;

    local procedure DestinationName(): Text[100]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Location: Record Location;
    begin
        case "Destination Type" of
            "Destination Type"::Customer:
                if Customer.Get("Destination No.") then
                    exit(Customer.Name);
            "Destination Type"::Vendor:
                if Vendor.Get("Destination No.") then
                    exit(Vendor.Name);
            "Destination Type"::Location:
                if Location.Get("Destination No.") then
                    exit(Location.Name);
        end;
    end;
}

