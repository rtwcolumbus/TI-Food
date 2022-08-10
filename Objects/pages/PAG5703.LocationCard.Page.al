page 5703 "Location Card"
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   Add controls for normal starting and ending time
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Add controls for Catch Alt. Qtys. on Whse. Pick
    // 
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 05 SEP 06
    //   Staging Bin Code
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 10 JUL 07
    //   Sample Staging Bin Code, Replenishment
    // 
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Add tab for setup options associated with delivery trips
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   Fix control placement (Catch Alt. Qtys. on Whse. Pick) on Warehouse tab
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    //   Add Central Container Bin
    // 
    // PRW16.00.01
    // P8000666, VerticalSoft, Jack Reynolds, 27 JAN 09
    //   Restore the control and code for Container Bin Code
    // 
    // PRW16.00.02
    // P8000761, VerticalSoft, MMAS, 29 JAN 10
    //   Code changed in UpdateEnabled() method to be correctly transformed into 2009.
    // 
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // P8001082, Columbus IT, Rick Tweedle, 25 JUL 12
    //   Added action to setup Pre-Processing Staging Areas
    // 
    // PRW16.00.06
    // P8001119, Columbus IT, Jack Reynolds, 19 NOV 12
    //   Time zone support
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.10.02
    // P8001277, Columbus IT, Jack Reynolds, 03 FEB 14
    //   Allow Delivery Trips by order type
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup obsolete container functionality
    //   Cleanup old delivery trips
    // 
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // P80039780, To-Increase, Jack Reynolds, 01 DEC 17
    //   Warehouse Receiving process
    // 
    // PRW111.00.01
    // P80058367, To-Increase, Dayakar Battini, 05 MAY 18
    //   Added DistPlanningInstalled check for license issues
    // 
    // P80059686, To-Increase, Dayakar Battini, 31 MAY 18
    //   Added VisProdSequencerInstalled for license issues
    // 
    // P80056710, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - create production container from pick
    //
    // PRW117.00.03
    // P800110480, To-Increase, Gangabhushan, 25 MAR 21
    //   Container Pick and Ship
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Updating time Zone Management codeunit         

    Caption = 'Location Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Location';
    SourceTable = Location;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Location;
                    Importance = Promoted;
                    ToolTip = 'Specifies a location code for the warehouse or distribution center where your items are handled and stored before being sold.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the name or address of the location.';
                }
                field("Use As In-Transit"; Rec."Use As In-Transit")
                {
                    ApplicationArea = Location;
                    Editable = EditInTransit;
                    ToolTip = 'Specifies that this location is an in-transit location.';

                    trigger OnValidate()
                    begin
                        UpdateEnabled();
                    end;
                }
                field("Do Not Use For Tax Calculation"; "Do Not Use For Tax Calculation")
                {
                    ApplicationArea = SalesTax;
                    Caption = 'Exclude from Tax Calculation';
                    ToolTip = 'Specifies whether the tax information included on this location record will be used for Sales Tax calculations on purchase documents.';
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = SalesTax;
                    Editable = NOT "Do Not Use For Tax Calculation";
                    ToolTip = 'Specifies the tax area code for this location.';
                }
                field("Tax Exemption No."; "Tax Exemption No.")
                {
                    ApplicationArea = SalesTax;
                    Editable = NOT "Do Not Use For Tax Calculation";
                    ToolTip = 'Specifies if the company''s tax exemption number. If the company has been registered exempt for sales and use tax this number would have been assigned by the taxing authority.';
                }
                field("Provincial Tax Area Code"; "Provincial Tax Area Code")
                {
                    ApplicationArea = BasicCA;
                    Editable = NOT "Do Not Use For Tax Calculation";
                    ToolTip = 'Specifies the tax area code for self assessed Provincial Sales Tax for the company.';
                }
            }
            group("Address & Contact")
            {
                Caption = 'Address & Contact';
                group(AddressDetails)
                {
                    Caption = 'Address';
                    field(Address; Rec.Address)
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies the location address.';
                    }
                    field("Address 2"; Rec."Address 2")
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field(City; Rec.City)
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies the city of the location.';
                    }
                    field(County; Rec.County)
                    {
                        ApplicationArea = Location;
                        Caption = 'State / ZIP Code';
                        ToolTip = 'Specifies the state or postal code for the location.';
                    }
                    field("Post Code"; Rec."Post Code")
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Country/Region Code"; Rec."Country/Region Code")
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies the country/region of the address.';
                    }
                    field("Time Zone"; "Time Zone")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(ShowMap; ShowMapLbl)
                    {
                        ApplicationArea = Location;
                        Editable = false;
                        ShowCaption = false;
                        Style = StrongAccent;
                        StyleExpr = TRUE;
                        ToolTip = 'Specifies the address of the location on your preferred map website.';

                        trigger OnDrillDown()
                        begin
                            CurrPage.Update();
                            Rec.DisplayMap();
                        end;
                    }
                }
                group(ContactDetails)
                {
                    Caption = 'Contact';
                    field(Contact; Rec.Contact)
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies the name of the contact person at the location';
                    }
                    field("Phone No."; Rec."Phone No.")
                    {
                        ApplicationArea = Location;
                        Importance = Promoted;
                        ToolTip = 'Specifies the telephone number of the location.';
                    }
                    field("Fax No."; Rec."Fax No.")
                    {
                        ApplicationArea = Location;
                        Importance = Additional;
                        ToolTip = 'Specifies the fax number of the location.';
                    }
                    field("E-Mail"; Rec."E-Mail")
                    {
                        ApplicationArea = Location;
                        ExtendedDatatype = EMail;
                        ToolTip = 'Specifies the email address of the location.';
                    }
                    field("Home Page"; Rec."Home Page")
                    {
                        ApplicationArea = Location;
                        ToolTip = 'Specifies the location''s web site.';
                    }
                }
                group(ElectronicDocument)
                {
                    Caption = 'Electronic Document';
                    field("SAT State Code"; "SAT State Code")
                    {
                        ApplicationArea = Location, BasicMX;
                        Importance = Additional;
                        ToolTip = 'Specifies the state, entity, region, community, or similar definitions where the domicile of the origin and / or destination of the goods or merchandise that are moved in the different means of transport is located.';
                    }
                    field("SAT Municipality Code"; "SAT Municipality Code")
                    {
                        ApplicationArea = Location, BasicMX;
                        Importance = Additional;
                        ToolTip = 'Specifies the municipality, delegation or mayoralty, county, or similar definitions where the destination address of the goods or merchandise that are moved in the different means of transport is located.';
                    }
                    field("SAT Locality Code"; "SAT Locality Code")
                    {
                        ApplicationArea = Location, BasicMX;
                        Importance = Additional;
                        ToolTip = 'Specifies the city, town, district, or similar definition where the domicile of origin and / or destination of the goods or merchandise that are moved in the different means of transport is located.';
                    }
                    field("SAT Suburb Code"; SATSuburb."Suburb Code")
                    {
                        ApplicationArea = Location, BasicMX;
                        Caption = 'SAT Suburb Code';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the SAT suburb code where the domicile of the origin or destination of the goods or merchandise that are moved in the different means of transport is located.';

                        trigger OnAssistEdit()
                        var
                            SATSuburbList: Page "SAT Suburb List";
                        begin
                            SATSuburbList.SetRecord(SATSuburb);
                            SATSuburbList.LookupMode := true;
                            if SATSuburbList.RunModal() = ACTION::LookupOK then begin
                                SATSuburbList.GetRecord(SATSuburb);
                                "SAT Suburb ID" := SATSuburb.ID;
                                Modify();
                            end;
                        end;
                    }
                    field("SAT Postal Code"; SATSuburb."Postal Code")
                    {
                        ApplicationArea = Location, BasicMX;
                        Caption = 'SAT Postal Code';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the SAT postal code where the domicile of the origin or destination of the goods or merchandise that are moved in the different means of transport is located.';
                    }
                    field("ID Ubicacion"; Rec."ID Ubicacion")
                    {
                        ApplicationArea = Location, BasicMX;
                        Caption = 'ID Ubicacion';
                        ToolTip = 'Specifies a code for the point of departure or entry of this transport in six numerical digits that are assigned by the taxpayer who issues the voucher for identification.';
                    }
                }
            }
            group(Warehouse)
            {
                Caption = 'Warehouse';
                field("Require Receive"; Rec."Require Receive")
                {
                    ApplicationArea = Warehouse;
                    Enabled = RequireReceiveEnable;
                    ToolTip = 'Specifies if the location requires a receipt document when receiving items.';

                    trigger OnValidate()
                    begin
                        UpdateEnabled();
                    end;
                }
                field("Require Shipment"; Rec."Require Shipment")
                {
                    ApplicationArea = Warehouse;
                    Enabled = RequireShipmentEnable;
                    ToolTip = 'Specifies if the location requires a shipment document when shipping items.';

                    trigger OnValidate()
                    begin
                        UpdateEnabled();
                    end;
                }
                field("Require Put-away"; Rec."Require Put-away")
                {
                    ApplicationArea = Warehouse;
                    Enabled = RequirePutAwayEnable;
                    Importance = Promoted;
                    ToolTip = 'Specifies if the location requires a dedicated warehouse activity when putting items away.';

                    trigger OnValidate()
                    begin
                        UpdateEnabled();
                    end;
                }
                field("Use Put-away Worksheet"; Rec."Use Put-away Worksheet")
                {
                    ApplicationArea = Warehouse;
                    Enabled = UsePutAwayWorksheetEnable;
                    ToolTip = 'Specifies if put-aways for posted warehouse receipts must be created with the put-away worksheet. If the check box is not selected, put-aways are created directly when you post a warehouse receipt.';
                }
                field("Require Pick"; Rec."Require Pick")
                {
                    ApplicationArea = Warehouse;
                    Enabled = RequirePickEnable;
                    Importance = Promoted;
                    ToolTip = 'Specifies if the location requires a dedicated warehouse activity when picking items.';

                    trigger OnValidate()
                    begin
                        UpdateEnabled();
                    end;
                }
                field("Bin Mandatory"; Rec."Bin Mandatory")
                {
                    ApplicationArea = Warehouse;
                    Enabled = BinMandatoryEnable;
                    Importance = Promoted;
                    ToolTip = 'Specifies if the location requires that a bin code is specified on all item transactions.';

                    trigger OnValidate()
                    begin
                        UpdateEnabled();
                    end;
                }
                field("Directed Put-away and Pick"; Rec."Directed Put-away and Pick")
                {
                    ApplicationArea = Warehouse;
                    Enabled = DirectedPutawayandPickEnable;
                    ToolTip = 'Specifies if the location requires advanced warehouse functionality, such as calculated bin suggestion.';

                    trigger OnValidate()
                    begin
                        UpdateEnabled();
                    end;
                }

                field("Container Pick and Ship"; "Container Pick and Ship")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Combine Reg. Whse. Activities"; "Combine Reg. Whse. Activities")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Use ADCS"; "Use ADCS")
                {
                    ApplicationArea = Warehouse;
                    Enabled = UseADCSEnable;
                    ToolTip = 'Specifies the automatic data capture system that warehouse employees must use to keep track of items within the warehouse.';
                    Visible = false;
                }
                field("Default Bin Selection"; Rec."Default Bin Selection")
                {
                    ApplicationArea = Warehouse;
                    Enabled = DefaultBinSelectionEnable;
                    ToolTip = 'Specifies the method used to select the default bin.';
                }
                field("Outbound Whse. Handling Time"; Rec."Outbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    Enabled = OutboundWhseHandlingTimeEnable;
                    ToolTip = 'Specifies a date formula for the time it takes to get items ready to ship from this location. The time element is used in the calculation of the delivery date as follows: Shipment Date + Outbound Warehouse Handling Time = Planned Shipment Date + Shipping Time = Planned Delivery Date.';
                }
                field("Inbound Whse. Handling Time"; Rec."Inbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    Enabled = InboundWhseHandlingTimeEnable;
                    ToolTip = 'Specifies the time it takes to make items part of available inventory, after the items have been posted as received.';
                }
                field("Base Calendar Code"; Rec."Base Calendar Code")
                {
                    ApplicationArea = Warehouse;
                    Enabled = BaseCalendarCodeEnable;
                    ToolTip = 'Specifies a customizable calendar for planning that holds the location''s working days and holidays.';
                }
                field("Customized Calendar"; format(CalendarMgmt.CustomizedChangesExist(Rec)))
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Customized Calendar';
                    Editable = false;
                    ToolTip = 'Specifies if the location has a customized calendar with working days that are different from those in the company''s base calendar.';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        Rec.TestField("Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(Rec);
                    end;
                }
                field("Use Cross-Docking"; Rec."Use Cross-Docking")
                {
                    ApplicationArea = Warehouse;
                    Enabled = UseCrossDockingEnable;
                    ToolTip = 'Specifies if the location supports movement of items directly from the receiving dock to the shipping dock.';

                    trigger OnValidate()
                    begin
                        UpdateEnabled();
                    end;
                }
                field("Cross-Dock Due Date Calc."; Rec."Cross-Dock Due Date Calc.")
                {
                    ApplicationArea = Warehouse;
                    Enabled = CrossDockDueDateCalcEnable;
                    ToolTip = 'Specifies the cross-dock due date calculation.';
                }
                field("Catch Alt. Qtys. On Whse. Pick"; "Catch Alt. Qtys. On Whse. Pick")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = CatchAltQtysOnWhsePickEnable;
                }
            }
            group(Bins)
            {
                Caption = 'Bins';
                group(Receipt)
                {
                    Caption = 'Receipt';
                    field("Receipt Bin Code"; Rec."Receipt Bin Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = ReceiptBinCodeEnable;
                        Importance = Promoted;
                        ToolTip = 'Specifies the default receipt bin code.';
                    }
                }
                group(Shipment)
                {
                    Caption = 'Shipment';
                    field("Shipment Bin Code"; Rec."Shipment Bin Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = ShipmentBinCodeEnable;
                        Importance = Promoted;
                        ToolTip = 'Specifies the default shipment bin code.';
                    }
                }
                group(Production)
                {
                    Caption = 'Production';
                    field("Open Shop Floor Bin Code"; Rec."Open Shop Floor Bin Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = OpenShopFloorBinCodeEnable;
                        ToolTip = 'Specifies the bin that functions as the default open shop floor bin.';
                    }
                    field("To-Production Bin Code"; Rec."To-Production Bin Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = ToProductionBinCodeEnable;
                        ToolTip = 'Specifies the bin in the production area where components picked for production are placed by default, before they can be consumed.';
                    }
                    field("From-Production Bin Code"; Rec."From-Production Bin Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = FromProductionBinCodeEnable;
                        ToolTip = 'Specifies the bin in the production area, where finished end items are taken from by default, when the process involves warehouse activity.';
                    }
                }
                group(Adjustment)
                {
                    Caption = 'Adjustment';
                    field("Adjustment Bin Code"; Rec."Adjustment Bin Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = AdjustmentBinCodeEnable;
                        ToolTip = 'Specifies the code of the bin in which you record observed differences in inventory quantities.';
                    }
                }
                group("Cross-Dock")
                {
                    Caption = 'Cross-Dock';
                    field("Cross-Dock Bin Code"; Rec."Cross-Dock Bin Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = CrossDockBinCodeEnable;
                        ToolTip = 'Specifies the bin code that is used by default for the receipt of items to be cross-docked.';
                    }
                }
                group(Assembly)
                {
                    Caption = 'Assembly';
                    field("To-Assembly Bin Code"; Rec."To-Assembly Bin Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = ToAssemblyBinCodeEnable;
                        ToolTip = 'Specifies the bin in the assembly area where components are placed by default before they can be consumed in assembly.';
                    }
                    field("From-Assembly Bin Code"; Rec."From-Assembly Bin Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = FromAssemblyBinCodeEnable;
                        ToolTip = 'Specifies the bin in the assembly area where finished assembly items are posted to when they are assembled to stock.';
                    }
                    field("Asm.-to-Order Shpt. Bin Code"; Rec."Asm.-to-Order Shpt. Bin Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = AssemblyShipmentBinCodeEnable;
                        ToolTip = 'Specifies the bin where finished assembly items are posted to when they are assembled to a linked sales order.';
                    }
                }
                group(Job)
                {
                    Caption = 'Job';
                    field("To-Job Bin Code"; Rec."To-Job Bin Code")
                    {
                        ApplicationArea = Jobs, Warehouse;
                        Enabled = ToJobBinCodeEnable;
                        ToolTip = 'Specifies the bin where an item will be put away or picked in warehouse and inventory processes at this location. For example, when you choose this location on a job planning line, this bin will be suggested.';
                    }
                }
            }
            group("Bin Policies")
            {
                Caption = 'Bin Policies';
                field("Special Equipment"; Rec."Special Equipment")
                {
                    ApplicationArea = Warehouse;
                    Enabled = SpecialEquipmentEnable;
                    ToolTip = 'Specifies where the program will first looks for special equipment designated for warehouse activities.';
                }
                field("Bin Capacity Policy"; Rec."Bin Capacity Policy")
                {
                    ApplicationArea = Warehouse;
                    Enabled = BinCapacityPolicyEnable;
                    Importance = Promoted;
                    ToolTip = 'Specifies how bins are automatically filled, according to their capacity.';
                }
                field("Allow Breakbulk"; Rec."Allow Breakbulk")
                {
                    ApplicationArea = Warehouse;
                    Enabled = AllowBreakbulkEnable;
                    ToolTip = 'Specifies that an order can be fulfilled with items stored in alternate units of measure, if an item stored in the requested unit of measure is not found.';
                }
                field("Replenishment Zone Code"; "Replenishment Zone Code")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = "Replenishment Zone CodeEnable";
                }
                field("Require Replenishment Area"; "Require Replenishment Area")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = RequireReplenishmentAreaEnable;
                }
                field("Def. Replenishment Area Code"; "Def. Replenishment Area Code")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = DefReplenishmentAreaCodeEnable;
                }
                field("Require Production Picking"; "Require Production Picking")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = RequireProductionPickingEnable;
                }
                field("Staging Bin Code"; "Staging Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = "Staging Bin CodeEnable";
                }
                field("Sample Staging Bin Code"; "Sample Staging Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = "Sample Staging Bin CodeEnable";
                }
                group("Put-away")
                {
                    Caption = 'Put-away';
                    field("Put-away Template Code"; Rec."Put-away Template Code")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = PutAwayTemplateCodeEnable;
                        ToolTip = 'Specifies the put-away template to be used at this location.';
                    }
                    field("Always Create Put-away Line"; Rec."Always Create Put-away Line")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = AlwaysCreatePutawayLineEnable;
                        ToolTip = 'Specifies that a put-away line is created, even if an appropriate zone and bin in which to place the items cannot be found.';
                    }
                }
                group(Pick)
                {
                    Caption = 'Pick';
                    field("Always Create Pick Line"; Rec."Always Create Pick Line")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = AlwaysCreatePickLineEnable;
                        ToolTip = 'Specifies that a pick line is created, even if an appropriate zone and bin from which to pick the item cannot be found.';
                    }
                    field("Pick According to FEFO"; Rec."Pick According to FEFO")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = PickAccordingToFEFOEnable;
                        Importance = Promoted;
                        ToolTip = 'Specifies whether to use the First-Expired-First-Out (FEFO) method to determine which items to pick, according to expiration dates.';
                    }
                    field("Pick Production by Line"; "Pick Production by Line")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
            }
            group("Delivery Trips")
            {
                Caption = 'Delivery Trips';
                field("Use Delivery Trips (Sales)"; "Use Delivery Trips (Sales)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Use Delivery Trips (Purchase)"; "Use Delivery Trips (Purchase)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Use Delivery Trips (Transfer)"; "Use Delivery Trips (Transfer)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("1-Doc")
            {
                Caption = '1-Doc';
                field("Receipt Bin Code (1-Doc)"; "Receipt Bin Code (1-Doc)")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = "Receipt Bin Code (1-Doc)Enable";
                }
                field("Shipment Bin Code (1-Doc)"; "Shipment Bin Code (1-Doc)")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = ShipmentBinCode1DocEnable;
                }
            }
            group(Commodities)
            {
                Caption = 'Commodities';
                field("Comm. Manifest Bin Code"; "Comm. Manifest Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Comm. Manifest Item No."; "Comm. Manifest Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Production Planning")
            {
                Caption = 'Production Planning';
                field("Normal Starting Time"; "Normal Starting Time")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Normal Ending Time"; "Normal Ending Time")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Location")
            {
                Caption = '&Location';
                Image = Warehouse;
                action("&Resource Locations")
                {
                    ApplicationArea = Location;
                    Caption = '&Resource Locations';
                    Image = Resource;
                    RunObject = Page "Resource Locations";
                    RunPageLink = "Location Code" = FIELD(Code);
                    ToolTip = 'View or edit information about where resources are located. In this window, you can assign resources to locations.';
                }
                action("&Zones")
                {
                    ApplicationArea = Warehouse;
                    Caption = '&Zones';
                    Image = Zones;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page Zones;
                    RunPageLink = "Location Code" = FIELD(Code);
                    ToolTip = 'View or edit information about zones that you use at this location to structure your bins.';
                }
                action("&Bins")
                {
                    ApplicationArea = Warehouse;
                    Caption = '&Bins';
                    Image = Bins;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page Bins;
                    RunPageLink = "Location Code" = FIELD(Code);
                    ToolTip = 'View or edit information about bins that you use at this location to hold items.';
                }
                action(DataCollectionLines)
                {
                    AccessByPermission = TableData "Data Collection Line" = R;
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Collection Lines';
                    Image = EditLines;
                    RunObject = Page "Data Collection Lines";
                    RunPageLink = "Source ID" = CONST(14),
                                  "Source Key 1" = FIELD(Code);
                }
                action("Replenishment &Areas")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Replenishment &Areas';
                    Image = View;
                    RunObject = Page "Replenishment Areas";
                    RunPageLink = "Location Code" = FIELD(Code),
                                  "Pre-Process Repl. Area" = CONST(false);
                }
                action("I&tem Replenishment Areas")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'I&tem Replenishment Areas';
                    Image = ItemAvailbyLoc;
                    RunObject = Page "Item Replenishment Areas";
                    RunPageLink = "Location Code" = FIELD(Code);
                    RunPageView = SORTING("Location Code", "Replenishment Area Code");
                }
                action("Pre-Process Repl. Areas")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pre-Process Repl. Areas';
                    Image = Allocations;
                    RunObject = Page "Pre-Process Repl. Areas";
                    RunPageLink = "Location Code" = FIELD(Code),
                                  "Pre-Process Repl. Area" = CONST(true);
                }
                action("Item &Fixed Prod. Bins")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item &Fixed Prod. Bins';
                    Image = Bins;
                    RunObject = Page "Item Fixed Prod. Bins";
                    RunPageLink = "Location Code" = FIELD(Code);
                    RunPageView = SORTING("Location Code", "Bin Code");
                }
                action("Inventory Posting Setup")
                {
                    ApplicationArea = Location;
                    Caption = 'Inventory Posting Setup';
                    Image = PostedInventoryPick;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    RunObject = Page "Inventory Posting Setup";
                    RunPageLink = "Location Code" = FIELD(Code);
                    ToolTip = 'Set up links between inventory posting groups, inventory locations, and general ledger accounts to define where transactions for inventory items are recorded in the general ledger.';
                }
                action("Warehouse Employees")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Warehouse Employees';
                    Image = WarehouseSetup;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "Warehouse Employees";
                    RunPageLink = "Location Code" = FIELD(Code);
                    ToolTip = 'View the warehouse employees that exist in the system.';
                }
                action("Online Map")
                {
                    ApplicationArea = Location;
                    Caption = 'Online Map';
                    Image = Map;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'View the address on an online map.';

                    trigger OnAction()
                    begin
                        Rec.DisplayMap();
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = const(14),
                                  "No." = field(Code);
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateEnabled();
        TransitValidation;
        Clear(SATSuburb);
        if SATSuburb.Get("SAT Suburb ID") then;
    end;

    trigger OnInit()
    begin
        UseCrossDockingEnable := true;
        UsePutAwayWorksheetEnable := true;
        BinMandatoryEnable := true;
        RequireShipmentEnable := true;
        RequireReceiveEnable := true;
        RequirePutAwayEnable := true;
        RequirePickEnable := true;
        DefaultBinSelectionEnable := true;
        UseADCSEnable := true;
        ShipmentBinCode1DocEnable := true;
        "Receipt Bin Code (1-Doc)Enable" := true;
        RequireProductionPickingEnable := true;
        DefReplenishmentAreaCodeEnable := true;
        RequireReplenishmentAreaEnable := true;
        "Replenishment Zone CodeEnable" := true;
        DirectedPutawayandPickEnable := true;
        CrossDockBinCodeEnable := true;
        PickAccordingToFEFOEnable := true;
        AdjustmentBinCodeEnable := true;
        CatchAltQtysOnWhsePickEnable := true;
        "Sample Staging Bin CodeEnable" := true;
        "Staging Bin CodeEnable" := true;
        ShipmentBinCodeEnable := true;
        ReceiptBinCodeEnable := true;
        FromProductionBinCodeEnable := true;
        ToProductionBinCodeEnable := true;
        OpenShopFloorBinCodeEnable := true;
        ToAssemblyBinCodeEnable := true;
        ToJobBinCodeEnable := true;
        FromAssemblyBinCodeEnable := true;
        AssemblyShipmentBinCodeEnable := true;
        CrossDockDueDateCalcEnable := true;
        AlwaysCreatePutawayLineEnable := true;
        AlwaysCreatePickLineEnable := true;
        PutAwayTemplateCodeEnable := true;
        AllowBreakbulkEnable := true;
        SpecialEquipmentEnable := true;
        BinCapacityPolicyEnable := true;
        BaseCalendarCodeEnable := true;
        InboundWhseHandlingTimeEnable := true;
        OutboundWhseHandlingTimeEnable := true;
        EditInTransit := true;
    end;

    var
        SATSuburb: Record "SAT Suburb";
        CalendarMgmt: Codeunit "Calendar Management";
        [InDataSet]
        OutboundWhseHandlingTimeEnable: Boolean;
        [InDataSet]
        InboundWhseHandlingTimeEnable: Boolean;
        [InDataSet]
        BaseCalendarCodeEnable: Boolean;
        [InDataSet]
        BinCapacityPolicyEnable: Boolean;
        [InDataSet]
        SpecialEquipmentEnable: Boolean;
        [InDataSet]
        AllowBreakbulkEnable: Boolean;
        [InDataSet]
        PutAwayTemplateCodeEnable: Boolean;
        [InDataSet]
        AlwaysCreatePickLineEnable: Boolean;
        [InDataSet]
        AlwaysCreatePutawayLineEnable: Boolean;
        [InDataSet]
        CrossDockDueDateCalcEnable: Boolean;
        [InDataSet]
        OpenShopFloorBinCodeEnable: Boolean;
        [InDataSet]
        ToProductionBinCodeEnable: Boolean;
        [InDataSet]
        FromProductionBinCodeEnable: Boolean;
        [InDataSet]
        AdjustmentBinCodeEnable: Boolean;
        [InDataSet]
        ToAssemblyBinCodeEnable: Boolean;
        [InDataSet]
        ToJobBinCodeEnable: Boolean;
        [InDataSet]
        FromAssemblyBinCodeEnable: Boolean;
        AssemblyShipmentBinCodeEnable: Boolean;
        [InDataSet]
        PickAccordingToFEFOEnable: Boolean;
        [InDataSet]
        CrossDockBinCodeEnable: Boolean;
        [InDataSet]
        DirectedPutawayandPickEnable: Boolean;
        [InDataSet]
        DefaultBinSelectionEnable: Boolean;
        [InDataSet]
        RequirePickEnable: Boolean;
        [InDataSet]
        RequirePutAwayEnable: Boolean;
        [InDataSet]
        RequireReceiveEnable: Boolean;
        [InDataSet]
        RequireShipmentEnable: Boolean;
        [InDataSet]
        BinMandatoryEnable: Boolean;
        [InDataSet]
        UsePutAwayWorksheetEnable: Boolean;
        [InDataSet]
        UseCrossDockingEnable: Boolean;
        [InDataSet]
        EditInTransit: Boolean;
        [InDataSet]
        "Staging Bin CodeEnable": Boolean;
        [InDataSet]
        "Sample Staging Bin CodeEnable": Boolean;
        [InDataSet]
        CatchAltQtysOnWhsePickEnable: Boolean;
        [InDataSet]
        "Replenishment Zone CodeEnable": Boolean;
        [InDataSet]
        RequireReplenishmentAreaEnable: Boolean;
        [InDataSet]
        DefReplenishmentAreaCodeEnable: Boolean;
        [InDataSet]
        RequireProductionPickingEnable: Boolean;
        [InDataSet]
        "Receipt Bin Code (1-Doc)Enable": Boolean;
        [InDataSet]
        ShipmentBinCode1DocEnable: Boolean;
        ShowMapLbl: Label 'Show on Map';

    protected var
        [InDataSet]
        ReceiptBinCodeEnable: Boolean;
        [InDataSet]
        ShipmentBinCodeEnable: Boolean;
        [InDataSet]
        UseADCSEnable: Boolean;

    procedure UpdateEnabled()
    begin
        RequirePickEnable := not Rec."Use As In-Transit" and not Rec."Directed Put-away and Pick";
        RequirePutAwayEnable := not Rec."Use As In-Transit" and not Rec."Directed Put-away and Pick";
        RequireReceiveEnable := not Rec."Use As In-Transit" and not Rec."Directed Put-away and Pick";
        RequireShipmentEnable := not Rec."Use As In-Transit" and not Rec."Directed Put-away and Pick";
        OutboundWhseHandlingTimeEnable := not Rec."Use As In-Transit";
        InboundWhseHandlingTimeEnable := not Rec."Use As In-Transit";
        BinMandatoryEnable := not Rec."Use As In-Transit" and not Rec."Directed Put-away and Pick";
        DirectedPutawayandPickEnable := not Rec."Use As In-Transit" and Rec."Bin Mandatory";
        BaseCalendarCodeEnable := not Rec."Use As In-Transit";

        BinCapacityPolicyEnable := Rec."Directed Put-away and Pick";
        SpecialEquipmentEnable := Rec."Directed Put-away and Pick";
        AllowBreakbulkEnable := Rec."Directed Put-away and Pick";
        PutAwayTemplateCodeEnable := Rec."Directed Put-away and Pick";
        UsePutAwayWorksheetEnable :=
          Rec."Directed Put-away and Pick" or (Rec."Require Put-away" and Rec."Require Receive" and not Rec."Use As In-Transit");
        AlwaysCreatePickLineEnable := Rec."Directed Put-away and Pick";
        AlwaysCreatePutawayLineEnable := Rec."Directed Put-away and Pick";

        UseCrossDockingEnable :=
            not Rec."Use As In-Transit" and Rec."Require Receive" and Rec."Require Shipment" and Rec."Require Put-away" and Rec."Require Pick";
        CrossDockDueDateCalcEnable := Rec."Use Cross-Docking";

        OpenShopFloorBinCodeEnable := Rec."Bin Mandatory";
        ToProductionBinCodeEnable := Rec."Bin Mandatory";
        FromProductionBinCodeEnable := Rec."Bin Mandatory";
        ReceiptBinCodeEnable := Rec."Bin Mandatory" and Rec."Require Receive";
        ShipmentBinCodeEnable := Rec."Bin Mandatory" and Rec."Require Shipment";
        AdjustmentBinCodeEnable := Rec."Directed Put-away and Pick";
        CrossDockBinCodeEnable := Rec."Bin Mandatory" and Rec."Use Cross-Docking";
        ToAssemblyBinCodeEnable := Rec."Bin Mandatory";
        ToJobBinCodeEnable := Rec."Bin Mandatory" and not Rec."Directed Put-away and Pick";
        FromAssemblyBinCodeEnable := Rec."Bin Mandatory";
        AssemblyShipmentBinCodeEnable := Rec."Bin Mandatory" and not ShipmentBinCodeEnable;
        DefaultBinSelectionEnable := Rec."Bin Mandatory" and not Rec."Directed Put-away and Pick";
        UseADCSEnable := not "Use As In-Transit" and "Directed Put-away and Pick";
        PickAccordingToFEFOEnable := Rec."Require Pick" and Rec."Bin Mandatory";

        CatchAltQtysOnWhsePickEnable := "Require Shipment" and "Require Pick"; // P8000282A

        "Staging Bin CodeEnable" := "Directed Put-away and Pick"; // P8000322A
        "Sample Staging Bin CodeEnable" := "Directed Put-away and Pick"; // P8000466A

        // P8000466A
        "Replenishment Zone CodeEnable" := not "Use As In-Transit" and "Bin Mandatory";
        RequireReplenishmentAreaEnable := not "Use As In-Transit" and "Bin Mandatory";
        DefReplenishmentAreaCodeEnable := not "Use As In-Transit" and "Bin Mandatory";
        RequireProductionPickingEnable := not "Use As In-Transit" and "Bin Mandatory";
        // P8000466A

        // P8000631A
        "Receipt Bin Code (1-Doc)Enable" := "Bin Mandatory" and not "Directed Put-away and Pick";
        ShipmentBinCode1DocEnable := "Bin Mandatory" and not "Directed Put-away and Pick";
        // P8000631A
        OnAfterUpdateEnabled(Rec);
    end;

    local procedure TransitValidation()
    var
        TransferHeader: Record "Transfer Header";
    begin
        TransferHeader.SetRange("In-Transit Code", Code);
        EditInTransit := TransferHeader.IsEmpty;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterUpdateEnabled(Location: Record Location)
    begin
    end;
}

