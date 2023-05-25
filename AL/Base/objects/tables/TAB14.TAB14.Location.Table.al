table 14 Location
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   Add fields Normal Starting Time and Normal Ending Time
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Add Catch Alt. Qtys. On Whse. Pick
    // 
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Check for assets before allowing deletion
    // 
    // P8000322A, VerticalSoft, Don Bresee, 05 SEP 06
    //   Add Staging Bin Code
    // 
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee,
    //   Add Production Bins/Replenishment
    // 
    // P8000503A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Sample Staging Bin Code
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Add fields to sp[ecify location specific defaults for trip management
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    //   Add Central Container Bin
    // 
    // PRW16.00.01
    // P8000676, VerticalSoft, Jack Reynolds, 13 FEB 09
    //   Fix permission problem with replenishment areas
    // 
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW16.00.06
    // P8001119, Columbus IT, Jack Reynolds, 19 NOV 12
    //   Time zone support
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Modify "Def. Replenishment Area Code" table relation
    // 
    // PRW17.00
    // P8001142, Columbus IT, Don Bresee, 09 MAR 13
    //   Rework Replenishment logic
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW17.10.02
    // P8001277, Columbus IT, Jack Reynolds, 03 FEB 14
    //   Allow Delivery Trips by order type
    // 
    // P8001278, Columbus IT, Jack Reynolds, 04 FEB 14
    //   Allow move list reports to suggest receiving and/or output bins
    // 
    // P8001280, Columbus IT, Don Bresee, 06 FEB 14
    //   Add "Combine Reg. Whse. Activities" field
    // 
    // PRW17.10.03
    // P8001319, Columbus IT, Jack Reynolds, 12 MAY 14
    //   Fix problem finding bin for consumption journal line
    // 
    // P8001356, Columbus IT, Jack Reynolds, 03 NOV 14
    //   Fix problem with GetFromProductionBin and GetToProductionBin
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup obsolete container functionality
    //   Cleanup old delivery trips
    // 
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW111.00.01
    // P80056710, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - create production container from pick
    // 
    // PRW111.00.02
    // P80072258, To-Increase, Jack Reynolds, 20 MAR 19
    //   Change LocationType (3 - Directed Put-away and Pick)
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW117.00.03
    // P800110480, To-Increase, Gangabhushan, 25 MAR 21
    //   Container Pick and Ship 
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Updating time Zone Management codeunit   

    Caption = 'Location';
    DataCaptionFields = "Code", Name;
    DrillDownPageID = "Location List";
    LookupPageID = "Location List";

    fields
    {
        field(37002000; "Time Zone"; Text[50])
        {
            Caption = 'Time Zone';

            // P800144605
            trigger OnLookup()
            var
                TimeZoneSelection: Codeunit "Time Zone Selection";
                TimeZoneID: Text[50];
            begin
                if TimeZoneSelection.LookupTimeZone(TimeZoneID) then
                    "Time Zone" := TimeZoneID;
            end;

            // P800144605
            trigger OnValidate()
            var
                TimeZoneSelection: Codeunit "Time Zone Selection";
            begin
                TimeZoneSelection.ValidateTimeZone("Time Zone");
            end;
        }
        field(37002063; "Use Delivery Trips (Sales)"; Boolean)
        {
            Caption = 'Use Delivery Trips (Sales)';
        }
        field(37002064; "Use Delivery Trips (Purchase)"; Boolean)
        {
            Caption = 'Use Delivery Trips (Purchase)';
        }
        field(37002065; "Use Delivery Trips (Transfer)"; Boolean)
        {
            Caption = 'Use Delivery Trips (Transfer)';
        }
        field(37002080; "Catch Alt. Qtys. On Whse. Pick"; Boolean)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Catch Alt. Qtys. On Whse. Pick';
            Description = 'PR4.00.02';

            trigger OnValidate()
            begin
                // P8000282A
                TestField("Require Shipment", true);
                TestField("Require Pick", true);
            end;
        }
        field(37002100; "Receipt Bin Code (1-Doc)"; Code[20])
        {
            Caption = 'Receipt Bin Code (1-Doc)';
            Description = 'P8000631A';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            begin
                // P8000631A
                TestField("Bin Mandatory", true);
                TestField("Directed Put-away and Pick", false);
            end;
        }
        field(37002101; "Shipment Bin Code (1-Doc)"; Code[20])
        {
            Caption = 'Shipment Bin Code (1-Doc)';
            Description = 'P8000631A';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            begin
                // P8000631A
                TestField("Bin Mandatory", true);
                TestField("Directed Put-away and Pick", false);
            end;
        }
        field(37002460; "Normal Starting Time"; Time)
        {
            Caption = 'Normal Starting Time';
        }
        field(37002461; "Normal Ending Time"; Time)
        {
            Caption = 'Normal Ending Time';
        }
        field(37002685; "Comm. Manifest Bin Code"; Code[20])
        {
            Caption = 'Comm. Manifest Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code),
                                            "Lot Combination Method" = CONST(Manual));
        }
        field(37002686; "Comm. Manifest Item No."; Code[20])
        {
            Caption = 'Comm. Manifest Item No.';
            TableRelation = Item WHERE("Catch Alternate Qtys." = CONST(false),
                                        "Comm. Manifest UOM Code" = FILTER(<> ''));
        }
        field(37002760; "Staging Bin Code"; Code[20])
        {
            Caption = 'Staging Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));
        }
        field(37002761; "Sample Staging Bin Code"; Code[20])
        {
            Caption = 'Sample Staging Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));
        }
        field(37002762; "Replenishment Zone Code"; Code[10])
        {
            Caption = 'Replenishment Zone Code';
            Description = 'P8000494A';
            TableRelation = Zone.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            var
                ReplArea: Record "Replenishment Area";
            begin
                // P8000494A
                if ("Replenishment Zone Code" <> xRec."Replenishment Zone Code") then begin
                    TestField("Directed Put-away and Pick", true); // P8000631A
                    ReplArea.SetRange("Location Code", Code);
                    if ReplArea.FindSet then
                        repeat
                            if (ReplArea."To Bin Code" <> '') or (ReplArea."From Bin Code" <> '') then
                                Error(Text37002760, FieldCaption("Replenishment Zone Code"), ReplArea.TableCaption);
                        until (ReplArea.Next = 0);
                end;
            end;
        }
        field(37002763; "Require Replenishment Area"; Boolean)
        {
            Caption = 'Require Replenishment Area';
            Description = 'P8000494A';

            trigger OnValidate()
            begin
                // P8000494A
                if "Require Replenishment Area" then
                    TestField("Require Production Picking", false);
            end;
        }
        field(37002764; "Def. Replenishment Area Code"; Code[20])
        {
            Caption = 'Def. Replenishment Area Code';
            Description = 'P8000494A';
            TableRelation = "Replenishment Area".Code WHERE("Location Code" = FIELD(Code),
                                                             "Pre-Process Repl. Area" = CONST(false));
        }
        field(37002765; "Require Production Picking"; Boolean)
        {
            Caption = 'Require Production Picking';
            Description = 'P8000494A';

            trigger OnValidate()
            begin
                // P8000494A
                if "Require Production Picking" then
                    TestField("Require Replenishment Area", false);
            end;
        }
        field(37002766; "Combine Reg. Whse. Activities"; Boolean)
        {
            Caption = 'Combine Reg. Whse. Activities';

            trigger OnValidate()
            begin
                // P8001280
                TestField("Bin Mandatory", true);
            end;
        }
        field(37002767; "Pick Production by Line"; Boolean)
        {
            Caption = 'Pick Production by Line';
        }

        field(37002768; "Container Pick and Ship"; Boolean)
        {
            Caption = 'Container Pick and Ship';
        }
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(130; "Default Bin Code"; Code[20])
        {
            Caption = 'Default Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));
        }
        field(5700; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
        }
        field(5701; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(5702; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(5703; City; Text[30])
        {
            Caption = 'City';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
                OnAfterLookupCity(Rec, PostCode);
            end;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateCity(Rec, PostCode, CurrFieldNo, IsHandled);
                if not IsHandled then
                    PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
                OnAfterValidateCity(Rec, PostCode);
            end;
        }
        field(5704; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(5705; "Phone No. 2"; Text[30])
        {
            Caption = 'Phone No. 2';
            ExtendedDatatype = PhoneNo;
        }
        field(5706; "Telex No."; Text[30])
        {
            Caption = 'Telex No.';
        }
        field(5707; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
        }
        field(5713; Contact; Text[100])
        {
            Caption = 'Contact';
        }
        field(5714; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
                OnAfterLookupPostCode(Rec, PostCode);
            end;

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidatePostCode(Rec, PostCode, CurrFieldNo, IsHandled);
                if not IsHandled then
                    PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
                OnAfterValidatePostCode(Rec, PostCode);
            end;
        }
        field(5715; County; Text[30])
        {
            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'County';
        }
        field(5718; "E-Mail"; Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                MailManagement.ValidateEmailAddressField("E-Mail");
            end;
        }
        field(5719; "Home Page"; Text[90])
        {
            Caption = 'Home Page';
            ExtendedDatatype = URL;
        }
        field(5720; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                PostCode.CheckClearPostCodeCityCounty(City, "Post Code", County, "Country/Region Code", xRec."Country/Region Code");
            end;
        }
        field(5724; "Use As In-Transit"; Boolean)
        {
            AccessByPermission = TableData "Transfer Header" = R;
            Caption = 'Use As In-Transit';

            trigger OnValidate()
            begin
                if "Use As In-Transit" then begin
                    TestField("Require Put-away", false);
                    TestField("Require Pick", false);
                    TestField("Use Cross-Docking", false);
                    TestField("Require Receive", false);
                    TestField("Require Shipment", false);
                    TestField("Bin Mandatory", false);
                end;
            end;
        }
        field(5726; "Require Put-away"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Require Put-away';

            trigger OnValidate()
            var
                WhseActivHeader: Record "Warehouse Activity Header";
                WhseRcptHeader: Record "Warehouse Receipt Header";
            begin
                WhseRcptHeader.SetRange("Location Code", Code);
                if not WhseRcptHeader.IsEmpty() then
                    Error(Text008, FieldCaption("Require Put-away"), xRec."Require Put-away", WhseRcptHeader.TableCaption());

                if not "Require Put-away" then begin
                    TestField("Directed Put-away and Pick", false);
                    WhseActivHeader.SetRange(Type, WhseActivHeader.Type::"Put-away");
                    WhseActivHeader.SetRange("Location Code", Code);
                    if not WhseActivHeader.IsEmpty() then
                        Error(Text008, FieldCaption("Require Put-away"), true, WhseActivHeader.TableCaption());
                    "Use Cross-Docking" := false;
                    "Cross-Dock Bin Code" := '';
                end else
                    CreateInboundWhseRequest();
            end;
        }
        field(5727; "Require Pick"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Require Pick';

            trigger OnValidate()
            var
                WhseActivHeader: Record "Warehouse Activity Header";
                WhseShptHeader: Record "Warehouse Shipment Header";
            begin
                WhseShptHeader.SetRange("Location Code", Code);
                if not WhseShptHeader.IsEmpty() then
                    Error(Text008, FieldCaption("Require Pick"), xRec."Require Pick", WhseShptHeader.TableCaption());

                if not "Require Pick" then begin
                    TestField("Directed Put-away and Pick", false);
                    WhseActivHeader.SetRange(Type, WhseActivHeader.Type::Pick);
                    WhseActivHeader.SetRange("Location Code", Code);
                    if not WhseActivHeader.IsEmpty() then
                        Error(Text008, FieldCaption("Require Pick"), true, WhseActivHeader.TableCaption());
                    "Use Cross-Docking" := false;
                    "Cross-Dock Bin Code" := '';
                    "Pick According to FEFO" := false;
                end;
            end;
        }
        field(5728; "Cross-Dock Due Date Calc."; DateFormula)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Cross-Dock Due Date Calc.';
        }
        field(5729; "Use Cross-Docking"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Use Cross-Docking';

            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateUseCrossDocking(Rec, xRec, CurrFieldNo, IsHandled);
                if IsHandled then
                    exit;

                if "Use Cross-Docking" then begin
                    TestField("Require Receive");
                    TestField("Require Shipment");
                    TestField("Require Put-away");
                    TestField("Require Pick");
                end else
                    "Cross-Dock Bin Code" := '';
            end;
        }
        field(5730; "Require Receive"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Receipt Header" = R;
            Caption = 'Require Receive';

            trigger OnValidate()
            var
                WhseRcptHeader: Record "Warehouse Receipt Header";
                WhseActivHeader: Record "Warehouse Activity Header";
            begin
                if not "Require Receive" then begin
                    TestField("Directed Put-away and Pick", false);
                    WhseRcptHeader.SetRange("Location Code", Code);
                    if not WhseRcptHeader.IsEmpty() then
                        Error(Text008, FieldCaption("Require Receive"), true, WhseRcptHeader.TableCaption());
                    "Receipt Bin Code" := '';
                    "Use Cross-Docking" := false;
                    "Cross-Dock Bin Code" := '';
                end else begin
                    WhseActivHeader.SetRange(Type, WhseActivHeader.Type::"Put-away");
                    WhseActivHeader.SetRange("Location Code", Code);
                    if not WhseActivHeader.IsEmpty() then
                        Error(Text008, FieldCaption("Require Receive"), false, WhseActivHeader.TableCaption());

                    CreateInboundWhseRequest();
                end;
            end;
        }
        field(5731; "Require Shipment"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Shipment Header" = R;
            Caption = 'Require Shipment';

            trigger OnValidate()
            var
                WhseShptHeader: Record "Warehouse Shipment Header";
                WhseActivHeader: Record "Warehouse Activity Header";
            begin
                if not "Require Shipment" then begin
                    TestField("Directed Put-away and Pick", false);
                    WhseShptHeader.SetRange("Location Code", Code);
                    if not WhseShptHeader.IsEmpty() then
                        Error(Text008, FieldCaption("Require Shipment"), true, WhseShptHeader.TableCaption());
                    "Shipment Bin Code" := '';
                    "Use Cross-Docking" := false;
                    "Cross-Dock Bin Code" := '';
                end else begin
                    WhseActivHeader.SetRange(Type, WhseActivHeader.Type::Pick);
                    WhseActivHeader.SetRange("Location Code", Code);
                    if not WhseActivHeader.IsEmpty() then
                        Error(Text008, FieldCaption("Require Shipment"), false, WhseActivHeader.TableCaption());
                end;
            end;
        }
        field(5732; "Bin Mandatory"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Bin Mandatory';

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
                WhseEntry: Record "Warehouse Entry";
                WhseActivHeader: Record "Warehouse Activity Header";
                WhseShptHeader: Record "Warehouse Shipment Header";
                WhseRcptHeader: Record "Warehouse Receipt Header";
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
                Window: Dialog;
            begin
                if "Bin Mandatory" and not xRec."Bin Mandatory" then begin
                    Window.Open(Text010);
                    OnValidateBinMandatoryOnBeforeItemLedgEntrySetFilters(Rec);
                    ItemLedgEntry.SetRange(Open, true);
                    ItemLedgEntry.SetRange("Location Code", Code);
                    if not ItemLedgEntry.IsEmpty() then
                        Error(Text009, FieldCaption("Bin Mandatory"));

                    "Default Bin Selection" := "Default Bin Selection"::"Fixed Bin";
                    OnValidateBinMandatoryOnAfterItemLedgEntrySetFilters(Rec);
                end;

                WhseActivHeader.SetRange("Location Code", Code);
                if not WhseActivHeader.IsEmpty() then
                    Error(Text008, FieldCaption("Bin Mandatory"), xRec."Bin Mandatory", WhseActivHeader.TableCaption());

                WhseRcptHeader.SetCurrentKey("Location Code");
                WhseRcptHeader.SetRange("Location Code", Code);
                if not WhseRcptHeader.IsEmpty() then
                    Error(Text008, FieldCaption("Bin Mandatory"), xRec."Bin Mandatory", WhseRcptHeader.TableCaption());

                WhseShptHeader.SetCurrentKey("Location Code");
                WhseShptHeader.SetRange("Location Code", Code);
                if not WhseShptHeader.IsEmpty() then
                    Error(Text008, FieldCaption("Bin Mandatory"), xRec."Bin Mandatory", WhseShptHeader.TableCaption());

                if not "Bin Mandatory" and xRec."Bin Mandatory" then begin
                    WhseEntry.SetRange("Location Code", Code);
                    OnValidateBinMandatoryOnAfterWhseEntrySetFilters(Rec, WhseEntry);
                    WhseEntry.CalcSums("Qty. (Base)");
                    if WhseEntry."Qty. (Base)" <> 0 then
                        Error(Text002, FieldCaption("Bin Mandatory"));
                end;

                if not "Bin Mandatory" then begin
                    "Open Shop Floor Bin Code" := '';
                    "To-Production Bin Code" := '';
                    "From-Production Bin Code" := '';
                    "Adjustment Bin Code" := '';
                    "Receipt Bin Code" := '';
                    "Shipment Bin Code" := '';
                    "Cross-Dock Bin Code" := '';
                    "To-Assembly Bin Code" := '';
                    "From-Assembly Bin Code" := '';
                    Rec."To-Job Bin Code" := '';
                    WhseIntegrationMgt.CheckLocationOnManufBins(Rec);
                end;
            end;
        }
        field(5733; "Directed Put-away and Pick"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Directed Put-away and Pick';

            trigger OnValidate()
            var
                WhseActivHeader: Record "Warehouse Activity Header";
                WhseShptHeader: Record "Warehouse Shipment Header";
                WhseRcptHeader: Record "Warehouse Receipt Header";
            begin
                WhseActivHeader.SetRange("Location Code", Code);
                if not WhseActivHeader.IsEmpty() then
                    Error(Text014, FieldCaption("Directed Put-away and Pick"), WhseActivHeader.TableCaption());

                WhseRcptHeader.SetCurrentKey("Location Code");
                WhseRcptHeader.SetRange("Location Code", Code);
                if not WhseRcptHeader.IsEmpty() then
                    Error(Text014, FieldCaption("Directed Put-away and Pick"), WhseRcptHeader.TableCaption());

                WhseShptHeader.SetCurrentKey("Location Code");
                WhseShptHeader.SetRange("Location Code", Code);
                if not WhseShptHeader.IsEmpty() then
                    Error(Text014, FieldCaption("Directed Put-away and Pick"), WhseShptHeader.TableCaption());

                if "Directed Put-away and Pick" then begin
                    TestField("Use As In-Transit", false);
                    TestField("Bin Mandatory");
                    Validate("Require Receive", true);
                    Validate("Require Shipment", true);
                    Validate("Require Put-away", true);
                    Validate("Require Pick", true);
                    Validate("Use Cross-Docking", true);
                    "Default Bin Selection" := "Default Bin Selection"::" ";
                    Clear(Rec."To-Job Bin Code");
                end else
                    Validate("Adjustment Bin Code", '');

                if (not "Directed Put-away and Pick") and xRec."Directed Put-away and Pick" then begin
                    "Default Bin Selection" := "Default Bin Selection"::"Fixed Bin";
                    "Use Put-away Worksheet" := false;
                    Validate("Use Cross-Docking", false);
                end;
            end;
        }
        field(5734; "Default Bin Selection"; Enum "Location Default Bin Selection")
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Default Bin Selection';

            trigger OnValidate()
            begin
                if ("Default Bin Selection" <> xRec."Default Bin Selection") and ("Default Bin Selection" = "Default Bin Selection"::" ") then
                    TestField("Directed Put-away and Pick");
            end;
        }
        field(5790; "Outbound Whse. Handling Time"; DateFormula)
        {
            AccessByPermission = TableData Location = R;
            Caption = 'Outbound Whse. Handling Time';
        }
        field(5791; "Inbound Whse. Handling Time"; DateFormula)
        {
            AccessByPermission = TableData Location = R;
            Caption = 'Inbound Whse. Handling Time';
        }
        field(7305; "Put-away Template Code"; Code[10])
        {
            Caption = 'Put-away Template Code';
            TableRelation = "Put-away Template Header";
        }
        field(7306; "Use Put-away Worksheet"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Use Put-away Worksheet';
        }
        field(7307; "Pick According to FEFO"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Pick According to FEFO';
        }
        field(7308; "Allow Breakbulk"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Allow Breakbulk';
        }
        field(7309; "Bin Capacity Policy"; Option)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Bin Capacity Policy';
            OptionCaption = 'Never Check Capacity,Allow More Than Max. Capacity,Prohibit More Than Max. Cap.';
            OptionMembers = "Never Check Capacity","Allow More Than Max. Capacity","Prohibit More Than Max. Cap.";
        }
        field(7313; "Open Shop Floor Bin Code"; Code[20])
        {
            Caption = 'Open Shop Floor Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            var
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
            begin
                WhseIntegrationMgt.CheckBinCode(Code,
                  "Open Shop Floor Bin Code",
                  FieldCaption("Open Shop Floor Bin Code"),
                  DATABASE::Location, Code);
            end;
        }
        field(7314; "To-Production Bin Code"; Code[20])
        {
            Caption = 'To-Production Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            var
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
            begin
                WhseIntegrationMgt.CheckBinCode(Code,
                  "To-Production Bin Code",
                  FieldCaption("To-Production Bin Code"),
                  DATABASE::Location, Code);
            end;
        }
        field(7315; "From-Production Bin Code"; Code[20])
        {
            Caption = 'From-Production Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            var
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
            begin
                WhseIntegrationMgt.CheckBinCode(Code,
                  "From-Production Bin Code",
                  FieldCaption("From-Production Bin Code"),
                  DATABASE::Location, Code);
            end;
        }
        field(7317; "Adjustment Bin Code"; Code[20])
        {
            Caption = 'Adjustment Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            begin
                if "Adjustment Bin Code" <> xRec."Adjustment Bin Code" then begin
                    if "Adjustment Bin Code" = '' then
                        CheckEmptyBin(
                          Rec.Code, xRec."Adjustment Bin Code", FieldCaption("Adjustment Bin Code"))
                    else
                        CheckEmptyBin(
                          Rec.Code, Rec."Adjustment Bin Code", FieldCaption("Adjustment Bin Code"));

                    CheckWhseAdjmtJnl();
                end;
            end;
        }
        field(7319; "Always Create Put-away Line"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Always Create Put-away Line';
        }
        field(7320; "Always Create Pick Line"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Always Create Pick Line';
        }
        field(7321; "Special Equipment"; Option)
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Special Equipment';
            OptionCaption = ' ,According to Bin,According to SKU/Item';
            OptionMembers = " ","According to Bin","According to SKU/Item";
        }
        field(7323; "Receipt Bin Code"; Code[20])
        {
            Caption = 'Receipt Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));
        }
        field(7325; "Shipment Bin Code"; Code[20])
        {
            Caption = 'Shipment Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            begin
                if "Shipment Bin Code" <> '' then begin
                    Bin.Get(Code, "Shipment Bin Code");
                    Bin.TestField(Dedicated, false);
                end;
            end;
        }
        field(7326; "Cross-Dock Bin Code"; Code[20])
        {
            Caption = 'Cross-Dock Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));
        }
        field(7330; "To-Assembly Bin Code"; Code[20])
        {
            Caption = 'To-Assembly Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            var
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
            begin
                WhseIntegrationMgt.CheckBinCode(Code,
                  "To-Assembly Bin Code",
                  FieldCaption("To-Assembly Bin Code"),
                  DATABASE::Location, Code);
            end;
        }
        field(7331; "From-Assembly Bin Code"; Code[20])
        {
            Caption = 'From-Assembly Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            var
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
            begin
                WhseIntegrationMgt.CheckBinCode(Code,
                  "From-Assembly Bin Code",
                  FieldCaption("From-Assembly Bin Code"),
                  DATABASE::Location, Code);
            end;
        }
        field(7332; "Asm.-to-Order Shpt. Bin Code"; Code[20])
        {
            Caption = 'Asm.-to-Order Shpt. Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            var
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
            begin
                WhseIntegrationMgt.CheckBinCode(Code,
                  "Asm.-to-Order Shpt. Bin Code",
                  FieldCaption("Asm.-to-Order Shpt. Bin Code"),
                  DATABASE::Location, Code);
            end;
        }
        field(7333; "To-Job Bin Code"; Code[20])
        {
            Caption = 'To-Job Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD(Code));

            trigger OnValidate()
            var
                WhseIntegrationMgt: Codeunit "Whse. Integration Management";
            begin
                Rec.TestField("Directed Put-away and Pick", false); //Directed Put-away and pick is not supported for Jobs.
                WhseIntegrationMgt.CheckBinCode(Rec.Code, Rec."To-Job Bin Code", CopyStr(Rec.FieldCaption(Rec."To-Job Bin Code"), 1, 30), DATABASE::Location, Rec.Code);
            end;
        }
        field(7600; "Base Calendar Code"; Code[10])
        {
            Caption = 'Base Calendar Code';
            TableRelation = "Base Calendar";
        }
        field(7700; "Use ADCS"; Boolean)
        {
            AccessByPermission = TableData "Miniform Header" = R;
            Caption = 'Use ADCS';
        }
        field(10010; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";

            trigger OnValidate()
            begin
                if "Do Not Use For Tax Calculation" then
                    "Tax Area Code" := '';
            end;
        }
        field(10015; "Tax Exemption No."; Text[30])
        {
            Caption = 'Tax Exemption No.';

            trigger OnValidate()
            begin
                if "Do Not Use For Tax Calculation" then
                    "Tax Exemption No." := '';
            end;
        }
        field(10016; "Do Not Use For Tax Calculation"; Boolean)
        {
            Caption = 'Do Not Use For Tax Calculation';

            trigger OnValidate()
            begin
                if "Do Not Use For Tax Calculation" then begin
                    "Tax Area Code" := '';
                    "Tax Exemption No." := '';
                    "Provincial Tax Area Code" := '';
                end;
            end;
        }
        field(10017; "Provincial Tax Area Code"; Code[20])
        {
            Caption = 'Provincial Tax Area Code';
            TableRelation = "Tax Area" WHERE("Country/Region" = CONST(CA));

            trigger OnValidate()
            begin
                if "Do Not Use For Tax Calculation" then
                    "Provincial Tax Area Code" := '';
            end;
        }
        field(27026; "SAT State Code"; Code[10])
        {
            Caption = 'SAT State Code';
            TableRelation = "SAT State";
        }
        field(27027; "SAT Municipality Code"; Code[10])
        {
            Caption = 'SAT Municipality Code';
            TableRelation = "SAT Municipality" WHERE(State = FIELD("SAT State Code"));
        }
        field(27028; "SAT Locality Code"; Code[10])
        {
            Caption = 'SAT Locality Code';
            TableRelation = "SAT Locality" WHERE(State = FIELD("SAT State Code"));
        }
        field(27029; "SAT Suburb ID"; Integer)
        {
            Caption = 'SAT Suburb ID';
            TableRelation = "SAT Suburb";
        }
        field(27030; "ID Ubicacion"; Integer)
        {
            Caption = 'ID Ubicacion';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; Name)
        {
        }
        key(Key3; "Use As In-Transit", "Bin Mandatory")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Name)
        {
        }
    }

    trigger OnDelete()
    var
        TransferRoute: Record "Transfer Route";
        WhseEmployee: Record "Warehouse Employee";
        WorkCenter: Record "Work Center";
        StockkeepingUnit: Record "Stockkeeping Unit";
        DimensionManagement: Codeunit DimensionManagement;
    begin
        StockkeepingUnit.SetRange("Location Code", Code);
        if not StockkeepingUnit.IsEmpty() then
            Error(CannotDeleteLocSKUExistErr, Code);

        WMSCheckWarehouse();

        TransferRoute.SetRange("Transfer-from Code", Code);
        TransferRoute.DeleteAll();
        TransferRoute.Reset();
        TransferRoute.SetRange("Transfer-to Code", Code);
        TransferRoute.DeleteAll();

        WhseEmployee.SetRange("Location Code", Code);
        WhseEmployee.DeleteAll(true);

        WorkCenter.SetRange("Location Code", Code);
        if WorkCenter.FindSet(true) then
            repeat
                WorkCenter.Validate("Location Code", '');
                WorkCenter.Modify(true);
            until WorkCenter.Next() = 0;

        CalendarManagement.DeleteCustomizedBaseCalendarData(CustomizedCalendarChange."Source Type"::Location, Code);
        DimensionManagement.DeleteDefaultDim(Database::Location, Rec.Code);
    end;

    trigger OnRename()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        CalendarManagement.RenameCustomizedBaseCalendarData(CustomizedCalendarChange."Source Type"::Location, Code, xRec.Code);
        DimensionManagement.RenameDefaultDim(Database::Location, xRec.Code, Rec.Code);
    end;

    var
        Bin: Record Bin;
        PostCode: Record "Post Code";
        WhseSetup: Record "Warehouse Setup";
        InvtSetup: Record "Inventory Setup";
        Location: Record Location;
        CustomizedCalendarChange: Record "Customized Calendar Change";
        Text000: Label 'You cannot delete the %1 %2, because they contain items.';
        Text001: Label 'You cannot delete the %1 %2, because one or more Warehouse Activity Lines exist for this %1.';
        Text002: Label '%1 must be Yes, because the bins contain items.';
        Text003: Label 'Cancelled.';
        Text004: Label 'The total quantity of items in the warehouse is 0, but the Adjustment Bin contains a negative quantity and other bins contain a positive quantity.\';
        Text005: Label 'Do you still want to delete this %1?';
        Text006: Label 'You cannot change the %1 until the inventory stored in %2 %3 is 0.';
        Text007: Label 'You have to delete all Adjustment Warehouse Journal Lines first before you can change the %1.';
        Text008: Label '%1 must be %2, because one or more %3 exist.';
        Text009: Label 'You cannot change %1 because there are one or more open ledger entries on this location.';
        Text010: Label 'Checking item ledger entries for open entries...';
        Text011: Label 'You cannot change the %1 to %2 until the inventory stored in this bin is 0.';
        Text012: Label 'Before you can use Online Map, you must fill in the Online Map Setup window.\See Setting Up Online Map in Help.';
        Text013: Label 'You cannot delete %1 because there are one or more ledger entries on this location.';
        Text014: Label 'You cannot change %1 because one or more %2 exist.';
        CannotDeleteLocSKUExistErr: Label 'You cannot delete %1 because one or more stockkeeping units exist at this location.', Comment = '%1: Field(Code)';
        Text37002000: Label 'must not be %1';
        Text37002001: Label '%1 ''%2'' does not exist.';
        Text37002760: Label 'You cannot change the %1 when %2s exist.';
        CalendarManagement: Codeunit "Calendar Management";
        UnspecifiedLocationLbl: Label '(Unspecified Location)';

    procedure RequireShipment(LocationCode: Code[10]): Boolean
    begin
        if Location.Get(LocationCode) then
            exit(Location."Require Shipment");
        WhseSetup.Get();
        exit(WhseSetup."Require Shipment");
    end;

    procedure RequirePicking(LocationCode: Code[10]): Boolean
    begin
        if Location.Get(LocationCode) then
            exit(Location."Require Pick");
        WhseSetup.Get();
        exit(WhseSetup."Require Pick");
    end;

    procedure RequireReceive(LocationCode: Code[10]): Boolean
    begin
        if Location.Get(LocationCode) then
            exit(Location."Require Receive");
        WhseSetup.Get();
        exit(WhseSetup."Require Receive");
    end;

    procedure RequirePutaway(LocationCode: Code[10]): Boolean
    begin
        if Location.Get(LocationCode) then
            exit(Location."Require Put-away");
        WhseSetup.Get();
        exit(WhseSetup."Require Put-away");
    end;

    procedure BinMandatory(LocationCode: Code[10]): Boolean
    begin
        if Location.Get(LocationCode) then
            exit(Location."Bin Mandatory");
    end;

    procedure GetLocationSetup(LocationCode: Code[10]; var Location2: Record Location): Boolean
    begin
        if not Get(LocationCode) then
            with Location2 do begin
                Init();
                WhseSetup.Get();
                InvtSetup.Get();
                Code := LocationCode;
                "Use As In-Transit" := false;
                "Require Put-away" := WhseSetup."Require Put-away";
                "Require Pick" := WhseSetup."Require Pick";
                "Outbound Whse. Handling Time" := InvtSetup."Outbound Whse. Handling Time";
                "Inbound Whse. Handling Time" := InvtSetup."Inbound Whse. Handling Time";
                "Require Receive" := WhseSetup."Require Receive";
                "Require Shipment" := WhseSetup."Require Shipment";
                OnGetLocationSetupOnAfterInitLocation(Rec, Location2);
                exit(false);
            end;

        Location2 := Rec;
        exit(true);
    end;

    local procedure WMSCheckWarehouse()
    var
        Zone: Record Zone;
        Bin: Record Bin;
        BinContent: Record "Bin Content";
        WhseActivLine: Record "Warehouse Activity Line";
        WarehouseEntry: Record "Warehouse Entry";
        WarehouseEntry2: Record "Warehouse Entry";
        WhseJnlLine: Record "Warehouse Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeWMSCheckWarehouse(Rec, IsHandled);
        if IsHandled then
            exit;

        ItemLedgerEntry.SetRange("Location Code", Code);
        ItemLedgerEntry.SetRange(Open, true);
        if not ItemLedgerEntry.IsEmpty() then
            Error(Text013, Code);

        WarehouseEntry.SetRange("Location Code", Code);
        WarehouseEntry.CalcSums("Qty. (Base)");
        if WarehouseEntry."Qty. (Base)" = 0 then begin
            if "Adjustment Bin Code" <> '' then begin
                WarehouseEntry2.SetRange("Bin Code", "Adjustment Bin Code");
                WarehouseEntry2.SetRange("Location Code", Code);
                WarehouseEntry2.CalcSums("Qty. (Base)");
                if WarehouseEntry2."Qty. (Base)" < 0 then
                    if not Confirm(Text004 + Text005, false, TableCaption) then
                        Error(Text003)
            end;
        end else
            Error(Text000, TableCaption(), Code);

        WhseActivLine.SetRange("Location Code", Code);
        WhseActivLine.SetRange("Activity Type", WhseActivLine."Activity Type"::Movement);
        WhseActivLine.SetFilter("Qty. Outstanding", '<>0');
        if not WhseActivLine.IsEmpty() then
            Error(Text001, TableCaption(), Code);

        WhseJnlLine.SetRange("Location Code", Code);
        WhseJnlLine.SetFilter(Quantity, '<>0');
        if not WhseJnlLine.IsEmpty() then
            Error(Text001, TableCaption(), Code);

        Zone.SetRange("Location Code", Code);
        Zone.DeleteAll();
        Bin.SetRange("Location Code", Code);
        Bin.DeleteAll();
        BinContent.SetRange("Location Code", Code);
        BinContent.DeleteAll();
    end;

    procedure CheckEmptyBin(LocationCode: Code[10]; BinCode: Code[20]; CaptionOfField: Text[30])
    var
        WarehouseEntry: Record "Warehouse Entry";
        WhseEntry2: Record "Warehouse Entry";
    begin
        WarehouseEntry.SetCurrentKey("Bin Code", "Location Code", "Item No.");
        WarehouseEntry.SetRange("Bin Code", BinCode);
        WarehouseEntry.SetRange("Location Code", Code);
        if WarehouseEntry.FindFirst() then
            repeat
                WarehouseEntry.SetRange("Item No.", WarehouseEntry."Item No.");

                WhseEntry2.SetCurrentKey("Item No.", "Bin Code", "Location Code");
                WhseEntry2.CopyFilters(WarehouseEntry);
                WhseEntry2.CalcSums("Qty. (Base)");
                if WhseEntry2."Qty. (Base)" <> 0 then begin
                    if (BinCode = "Adjustment Bin Code") and (xRec."Adjustment Bin Code" = '') then
                        Error(Text011, CaptionOfField, BinCode);

                    Error(Text006, CaptionOfField, Bin.TableCaption(), BinCode);
                end;

                WarehouseEntry.FindLast();
                WarehouseEntry.SetRange("Item No.");
            until WarehouseEntry.Next() = 0;
    end;

    local procedure CheckWhseAdjmtJnl()
    var
        WhseJnlTemplate: Record "Warehouse Journal Template";
        WhseJnlLine: Record "Warehouse Journal Line";
    begin
        WhseJnlTemplate.SetRange(Type, WhseJnlTemplate.Type::Item);
        if WhseJnlTemplate.Find('-') then
            repeat
                WhseJnlLine.SetRange("Journal Template Name", WhseJnlTemplate.Name);
                WhseJnlLine.SetRange("Location Code", Code);
                if not WhseJnlLine.IsEmpty() then
                    Error(
                      Text007,
                      FieldCaption("Adjustment Bin Code"));
            until WhseJnlTemplate.Next() = 0;
    end;

    procedure GetRequirementText(FieldNumber: Integer): Text[50]
    var
        Text000: Label 'Shipment,Receive,Pick,Put-Away';
    begin
        case FieldNumber of
            FieldNo("Require Shipment"):
                exit(SelectStr(1, Text000));
            FieldNo("Require Receive"):
                exit(SelectStr(2, Text000));
            FieldNo("Require Pick"):
                exit(SelectStr(3, Text000));
            FieldNo("Require Put-away"):
                exit(SelectStr(4, Text000));
        end;
    end;

    procedure DisplayMap()
    var
        OnlineMapSetup: Record "Online Map Setup";
        OnLineMapMgt: Codeunit "Online Map Management";
    begin
        OnlineMapSetup.SetRange(Enabled, true);
        if OnlineMapSetup.FindFirst() then
            OnLineMapMgt.MakeSelection(DATABASE::Location, GetPosition())
        else
            Message(Text012);
    end;

    procedure IsBWReceive(): Boolean
    begin
        exit("Bin Mandatory" and (not "Directed Put-away and Pick") and "Require Receive");
    end;

    procedure IsBWShip(): Boolean
    begin
        exit("Bin Mandatory" and (not "Directed Put-away and Pick") and "Require Shipment");
    end;

    procedure IsBinBWReceiveOrShip(BinCode: Code[20]): Boolean
    begin
        exit(("Receipt Bin Code" <> '') and (BinCode = "Receipt Bin Code") or
          ("Shipment Bin Code" <> '') and (BinCode = "Shipment Bin Code"));
    end;

    procedure IsInTransit(LocationCode: Code[10]): Boolean
    begin
        if Location.Get(LocationCode) then
            exit(Location."Use As In-Transit");
        exit(false);
    end;

    local procedure CreateInboundWhseRequest()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        WarehouseRequest: Record "Warehouse Request";
        WhseTransferRelease: Codeunit "Whse.-Transfer Release";
    begin
        TransferLine.SetRange("Transfer-to Code", Code);
        if TransferLine.FindSet() then
            repeat
                if TransferLine."Quantity Received" <> TransferLine."Quantity Shipped" then begin
                    TransferHeader.Get(TransferLine."Document No.");
                    WhseTransferRelease.InitializeWhseRequest(WarehouseRequest, TransferHeader, TransferHeader.Status);
                    WhseTransferRelease.CreateInboundWhseRequest(WarehouseRequest, TransferHeader);

                    TransferLine.SetRange("Document No.", TransferLine."Document No.");
                    TransferLine.FindLast();
                    TransferLine.SetRange("Document No.");
                end;
            until TransferLine.Next() = 0;
    end;

    procedure SetFromProductionBin(ProdOrderNo: Code[20]; ProdOrderLineNo: Integer)
    begin
        "From-Production Bin Code" := GetFromProductionBin(ProdOrderNo, ProdOrderLineNo); // P8001142
    end;

    procedure SetToProductionBin(ProdOrderNo: Code[20]; ProdOrderLineNo: Integer; ProdOrderCompLineNo: Integer)
    begin
        "To-Production Bin Code" := GetToProductionBin(ProdOrderNo, ProdOrderLineNo, ProdOrderCompLineNo, ''); // P8001142, P8001319
    end;

    procedure GetFromProductionBin(ProdOrderNo: Code[20]; ProdOrderLineNo: Integer): Code[20]
    var
        ProdOrderLine: Record "Prod. Order Line";
        ReplArea: Record "Replenishment Area";
        Item: Record Item;
        FromBinCode: Code[20];
    begin
        // P8001142
        if ProdOrderLine.Get(ProdOrderLine.Status::Released, ProdOrderNo, ProdOrderLineNo) then begin
            if GetSpecificProductionBin(ProdOrderLine."Bin Code", ProdOrderLine."Item No.", FromBinCode) then
                exit(FromBinCode);
            if "Require Replenishment Area" then
                ProdOrderLine.TestField("Replenishment Area Code");
            if (ProdOrderLine."Replenishment Area Code" <> '') then
                exit(ReplArea.GetFromBin(Code, ProdOrderLine."Replenishment Area Code"));
        end;
        exit("From-Production Bin Code"); // P8001356
    end;

    procedure GetToProductionBin(ProdOrderNo: Code[20]; ProdOrderLineNo: Integer; ProdOrderCompLineNo: Integer; ItemNo: Code[20]): Code[20]
    var
        ProdOrderComp: Record "Prod. Order Component";
        ProdOrderLine: Record "Prod. Order Line";
        ReplArea: Record "Replenishment Area";
        Item: Record Item;
        ToBinCode: Code[20];
    begin
        // P8001142
        // P8001319 - Add parameter for ItemNo
        if ProdOrderComp.Get(ProdOrderComp.Status::Released, ProdOrderNo, ProdOrderLineNo, ProdOrderCompLineNo) then begin
            if GetSpecificProductionBin(ProdOrderComp."Bin Code", ProdOrderComp."Item No.", ToBinCode) then
                exit(ToBinCode);
            if "Require Replenishment Area" then
                ProdOrderComp.TestField("Replenishment Area Code");
            if (ProdOrderComp."Replenishment Area Code" <> '') then
                exit(ReplArea.GetToBin(Code, ProdOrderComp."Replenishment Area Code"));
            // P8001319
        end else
            if ProdOrderLine.Get(ProdOrderLine.Status::Released, ProdOrderNo, ProdOrderLineNo) then begin
                if GetSpecificProductionBin('', ItemNo, ToBinCode) then
                    exit(ToBinCode);
                if "Require Replenishment Area" then
                    ProdOrderLine.TestField("Replenishment Area Code");
                if (ProdOrderLine."Replenishment Area Code" <> '') then
                    exit(ReplArea.GetToBin(Code, ProdOrderLine."Replenishment Area Code"));
                // P8001319
            end;
        exit("To-Production Bin Code"); // P8004516
    end;

    local procedure GetSpecificProductionBin(OrderBinCode: Code[20]; ItemNo: Code[20]; var ProdBinCode: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        // P8001142
        if (OrderBinCode <> '') then begin
            ProdBinCode := OrderBinCode;
            exit(true);
        end;
        Item.Get(ItemNo);
        exit(Item.GetFixedBinItem(Code, ProdBinCode));
    end;

    procedure LocationType(): Integer
    begin
        // P8000549A
        if "Directed Put-away and Pick" then // P80072258
            exit(3)
        else
            if "Require Pick" then
                exit(2)
            else
                exit(1);
    end;

    procedure Is1DocWhseBin(BinCode: Code[20]): Boolean
    begin
        // P8000631A
        if (BinCode in ["Receipt Bin Code (1-Doc)", "Shipment Bin Code (1-Doc)"]) then
            exit(false);
        exit(not IsReplenishmentBin(BinCode));
    end;

    procedure IsReplenishmentBin(BinCode: Code[20]): Boolean
    var
        ReplArea: Record "Replenishment Area";
    begin
        // P8000631A
        ReplArea.SetRange("Location Code", Code);
        if ReplArea.FindSet then
            repeat
                if (BinCode in [ReplArea."To Bin Code", ReplArea."From Bin Code"]) then
                    exit(true);
            until (ReplArea.Next = 0);
        exit(false);
    end;

    procedure IsFromBin(BinCode: Code[20]): Boolean
    var
        ReplArea: Record "Replenishment Area";
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
    begin
        // P8001278
        if BinCode = "From-Production Bin Code" then
            exit(true);

        ReplArea.SetRange("Location Code", Code);
        ReplArea.SetRange("From Bin Code", BinCode);
        if not ReplArea.IsEmpty then
            exit(true);

        WorkCenter.SetRange("Location Code", Code);
        WorkCenter.SetRange("From-Production Bin Code", BinCode);
        if not WorkCenter.IsEmpty then
            exit(true);

        MachineCenter.SetRange("Location Code", Code);
        MachineCenter.SetRange("From-Production Bin Code", BinCode);
        if not MachineCenter.IsEmpty then
            exit(true);
    end;

    procedure GetLocationsIncludingUnspecifiedLocation(IncludeOnlyUnspecifiedLocation: Boolean; ExcludeInTransitLocations: Boolean)
    var
        Location: Record Location;
    begin
        Init();
        Validate(Name, UnspecifiedLocationLbl);
        Insert();

        if not IncludeOnlyUnspecifiedLocation then begin
            if ExcludeInTransitLocations then
                Location.SetRange("Use As In-Transit", false);

            if Location.FindSet() then
                repeat
                    Init();
                    Copy(Location);
                    Insert();
                until Location.Next() = 0;
        end;

        FindFirst();
    end;

    [Scope('OnPrem')]
    procedure GetSATAddress() LocationAddress: Text
    var
        SATState: Record "SAT State";
        SATMunicipality: Record "SAT Municipality";
        SATLocality: Record "SAT Locality";
        SATSuburb: Record "SAT Suburb";
    begin
        if SATState.Get("SAT State Code") then
            LocationAddress := SATState.Description;
        if SATMunicipality.Get("SAT Municipality Code") then
            LocationAddress += ' ' + SATMunicipality.Description;
        if SATLocality.Get("SAT Locality Code") then
            LocationAddress += ' ' + SATLocality.Description;
        if SATSuburb.Get("SAT Suburb ID") then
            LocationAddress += ' ' + SATSuburb.Description;
    end;

    procedure GetSATPostalCode(): Code[20];
    var
        SATSuburb: Record "SAT Suburb";
    begin
        SATSuburb.GET("SAT Suburb ID");
        exit(SATSuburb."Postal Code");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLookupCity(var Location: Record Location; var PostCode: Record "Post Code")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLookupPostCode(var Location: Record Location; var PostCode: Record "Post Code")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateCity(var Location: Record Location; var PostCode: Record "Post Code")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidatePostCode(var Location: Record Location; var PostCode: Record "Post Code")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateUseCrossDocking(var Location: Record Location; xLocation: Record Location; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetLocationSetupOnAfterInitLocation(var Location: Record Location; var Location2: Record Location)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWMSCheckWarehouse(var Location: Record Location; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateBinMandatoryOnBeforeItemLedgEntrySetFilters(var Location: Record Location)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateBinMandatoryOnAfterItemLedgEntrySetFilters(var Location: Record Location);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateBinMandatoryOnAfterWhseEntrySetFilters(var Location: Record Location; var WhseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateCity(var Location: Record Location; var PostCode: Record "Post Code"; CurrentFieldNo: Integer; var IsHandled: Boolean);
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidatePostCode(var Location: Record Location; var PostCode: Record "Post Code"; CurrentFieldNo: Integer; var IsHandled: Boolean);
    begin
    end;
}

