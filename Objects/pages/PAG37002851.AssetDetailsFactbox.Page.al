page 37002851 "Asset Details Factbox"
{
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 04 FEB 09
    //   Standard fact box for asset details
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013

    Caption = 'Asset Details';
    PageType = CardPart;
    SourceTable = Asset;

    layout
    {
        area(content)
        {
            field("No."; "No.")
            {
                ApplicationArea = FOODBasic;

                trigger OnDrillDown()
                begin
                    ShowDetails;
                end;
            }
            group(Control37002018)
            {
                ShowCaption = false;
                Visible = showequipment;
                field(ManufacturerCode; "Manufacturer Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(ModelNo; "Model No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(VendorNo; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Control37002020)
            {
                ShowCaption = false;
                Visible = showvehicle;
                field(ManufacturerCode2; "Manufacturer Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(ModelNo2; "Model No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Model Year"; "Model Year")
                {
                    ApplicationArea = FOODBasic;
                }
                field(VIN; VIN)
                {
                    ApplicationArea = FOODBasic;
                }
                field(VendorNo2; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Registration No."; "Registration No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Registration Expiration Date"; "Registration Expiration Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Gross Weight"; "Gross Weight")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Gross Weight Unit of Measure"; "Gross Weight Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Control37002024)
            {
                ShowCaption = false;
                Visible = showfacility;
                field("Area"; Area)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Area Unit of Measure"; "Area Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Control37002019)
            {
                ShowCaption = false;
                Visible = showdates;
                field(ManufacturerCode3; "Manufacture Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Purchase Date"; "Purchase Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Installation Date"; "Installation Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Overhaul Date"; "Overhaul Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Warranty Date"; "Warranty Date")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        ShowEquipment := Type = Type::Equipment;
        ShowVehicle := Type = Type::Vehicle;
        ShowFacility := Type = Type::Facility;
        ShowDates := ShowEquipment or ShowVehicle;
    end;

    var
        [InDataSet]
        ShowEquipment: Boolean;
        [InDataSet]
        ShowVehicle: Boolean;
        [InDataSet]
        ShowFacility: Boolean;
        [InDataSet]
        ShowDates: Boolean;

    procedure ShowDetails()
    begin
        PAGE.Run(PAGE::"Asset Card", Rec);
    end;

    procedure ShowGroups()
    begin
    end;
}

