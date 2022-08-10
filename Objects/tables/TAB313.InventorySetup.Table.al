table 313 "Inventory Setup"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Field 37002562 - Container Usage Doc. Nos. - Code 10
    // 
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Add shortcut lot specification category fields
    // 
    // PR4.00
    // P8000260A, Myers Nissi, Jack Reynolds, 27 OCT 05
    //   Add field Production Costing Method to control when production output is costed
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Remove field "Production Costing Method"
    // 
    // PR4.00.04
    // P8000375A, VerticalSoft, Jack Reynolds, 07 SEP 06
    //   New field ABC Detail Posting to control posting of ABC detail
    // 
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Add fields for repack order numbers and default repack location
    // 
    // PRW15.00.01
    // P8000548A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add new field - Near-Zero Qty. Value
    // 
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW16.00.05
    // P8000979, Columbus IT, Don Bresee, 08 NOV 11
    //   Add Lot Trace Summary Level
    // 
    // PRW16.00.06
    // P8001070, Columbus IT, Jack Reynolds, 16 MAY 12
    //   Lot Preference Enforcement Level
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.10
    // P8001224, Columbus IT, Jack Reynolds, 27 SEP 13
    //   Move Last Alt. Qty. Transaction No. from Inventory Setup
    // 
    // P8001227, Columbus IT, Don Bresee, 03 OCT 13
    //   Add new fields for Adjust Cost Job options
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Assign new activity no. to Q/C activities
    // 
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples, new field added

    Caption = 'Inventory Setup';
    Permissions = TableData "Inventory Adjmt. Entry (Order)" = m;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Automatic Cost Posting"; Boolean)
        {
            Caption = 'Automatic Cost Posting';
        }
        field(3; "Location Mandatory"; Boolean)
        {
            AccessByPermission = TableData Location = R;
            Caption = 'Location Mandatory';
        }
        field(4; "Item Nos."; Code[20])
        {
            Caption = 'Item Nos.';
            TableRelation = "No. Series";
        }
        field(30; "Automatic Cost Adjustment"; Enum "Automatic Cost Adjustment Type")
        {
            Caption = 'Automatic Cost Adjustment';

            trigger OnValidate()
            begin
                if "Automatic Cost Adjustment" <> "Automatic Cost Adjustment"::Never then begin
                    Item.SetCurrentKey("Cost is Adjusted", "Allow Online Adjustment");
                    Item.SetRange("Cost is Adjusted", false);
                    Item.SetRange("Allow Online Adjustment", false);

                    UpdateInvtAdjmtEntryOrder;

                    InvtAdjmtEntryOrder.SetCurrentKey("Cost is Adjusted", "Allow Online Adjustment");
                    InvtAdjmtEntryOrder.SetRange("Cost is Adjusted", false);
                    InvtAdjmtEntryOrder.SetRange("Allow Online Adjustment", false);
                    InvtAdjmtEntryOrder.SetRange("Is Finished", true);

                    if not (Item.IsEmpty and InvtAdjmtEntryOrder.IsEmpty) then
                        Message(Text000);
                end;
            end;
        }
        field(40; "Prevent Negative Inventory"; Boolean)
        {
            Caption = 'Prevent Negative Inventory';
        }
        field(50; "Skip Prompt to Create Item"; Boolean)
        {
            Caption = 'Skip Prompt to Create Item';
            DataClassification = SystemMetadata;
        }
        field(51; "Copy Item Descr. to Entries"; Boolean)
        {
            Caption = 'Copy Item Descr. to Entries';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                UpdateNameInLedgerEntries: Codeunit "Update Name In Ledger Entries";
            begin
                if "Copy Item Descr. to Entries" then
                    UpdateNameInLedgerEntries.NotifyAboutBlankNamesInLedgerEntries(RecordId);
            end;
        }
        field(180; "Invt. Cost Jnl. Template Name"; Code[10])
        {
            Caption = 'Invt. Cost Jnl. Template Name';
            TableRelation = "Gen. Journal Template";

            trigger OnValidate()
            begin
                if "Invt. Cost Jnl. Template Name" = '' then
                    "Invt. Cost Jnl. Batch Name" := '';
            end;
        }
        field(181; "Invt. Cost Jnl. Batch Name"; Code[10])
        {
            Caption = 'Jnl. Batch Name Cost Posting';
            TableRelation = IF ("Invt. Cost Jnl. Template Name" = FILTER(<> '')) "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Invt. Cost Jnl. Template Name"));

            trigger OnValidate()
            begin
                TestField("Invt. Cost Jnl. Template Name");
            end;
        }
        field(5700; "Transfer Order Nos."; Code[20])
        {
            AccessByPermission = TableData "Transfer Header" = R;
            Caption = 'Transfer Order Nos.';
            TableRelation = "No. Series";
        }
        field(5701; "Posted Transfer Shpt. Nos."; Code[20])
        {
            AccessByPermission = TableData "Transfer Header" = R;
            Caption = 'Posted Transfer Shpt. Nos.';
            TableRelation = "No. Series";
        }
        field(5702; "Posted Transfer Rcpt. Nos."; Code[20])
        {
            AccessByPermission = TableData "Transfer Header" = R;
            Caption = 'Posted Transfer Rcpt. Nos.';
            TableRelation = "No. Series";
        }
        field(5703; "Copy Comments Order to Shpt."; Boolean)
        {
            AccessByPermission = TableData "Transfer Header" = R;
            Caption = 'Copy Comments Order to Shpt.';
            InitValue = true;
        }
        field(5704; "Copy Comments Order to Rcpt."; Boolean)
        {
            AccessByPermission = TableData "Transfer Header" = R;
            Caption = 'Copy Comments Order to Rcpt.';
            InitValue = true;
        }
        field(5718; "Nonstock Item Nos."; Code[20])
        {
            AccessByPermission = TableData "Nonstock Item" = R;
            Caption = 'Catalog Item Nos.';
            TableRelation = "No. Series";
        }
        field(5725; "Use Item References"; Boolean)
        {
            AccessByPermission = TableData "Item Reference" = R;
            Caption = 'Use Item References';
            ObsoleteReason = 'Replaced by default visibility for Item Reference''s fields and actions.';
#if not CLEAN19
            ObsoleteState = Pending;
            ObsoleteTag = '19.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '22.0';
#endif
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
        field(5800; "Expected Cost Posting to G/L"; Boolean)
        {
            Caption = 'Expected Cost Posting to G/L';

            trigger OnValidate()
            var
                ChangeExpCostPostToGL: Codeunit "Change Exp. Cost Post. to G/L";
            begin
                if "Expected Cost Posting to G/L" <> xRec."Expected Cost Posting to G/L" then
                    if ItemLedgEntry.FindFirst() then begin
                        ChangeExpCostPostToGL.ChangeExpCostPostingToGL(Rec, "Expected Cost Posting to G/L");
                        Find;
                    end;
            end;
        }
        field(5801; "Default Costing Method"; Enum "Costing Method")
        {
            Caption = 'Default Costing Method';
        }
        field(5804; "Average Cost Calc. Type"; Enum "Average Cost Calculation Type")
        {
            Caption = 'Average Cost Calc. Type';
            InitValue = "Item & Location & Variant";
            NotBlank = true;

            trigger OnValidate()
            begin
                TestField("Average Cost Calc. Type");
                if "Average Cost Calc. Type" <> xRec."Average Cost Calc. Type" then
                    UpdateAvgCostItemSettings(FieldCaption("Average Cost Calc. Type"), Format("Average Cost Calc. Type"));
            end;
        }
        field(5805; "Average Cost Period"; Option)
        {
            Caption = 'Average Cost Period';
            InitValue = Day;
            NotBlank = true;
            OptionCaption = ' ,Day,Week,Month,Quarter,Year,Accounting Period';
            OptionMembers = " ",Day,Week,Month,Quarter,Year,"Accounting Period";

            trigger OnValidate()
            begin
                TestField("Average Cost Period");
                if "Average Cost Period" <> xRec."Average Cost Period" then
                    UpdateAvgCostItemSettings(FieldCaption("Average Cost Period"), Format("Average Cost Period"));
            end;
        }
        field(5849; "Allow Invt. Doc. Reservation"; Boolean)
        {
            Caption = 'Allow Invt. Doc. Reservation';
        }
        field(5850; "Invt. Receipt Nos."; Code[20])
        {
            Caption = 'Invt. Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(5851; "Posted Invt. Receipt Nos."; Code[20])
        {
            Caption = 'Posted Invt. Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(5852; "Invt. Shipment Nos."; Code[20])
        {
            Caption = 'Invt. Shipment Nos.';
            TableRelation = "No. Series";
        }
        field(5853; "Posted Invt. Shipment Nos."; Code[20])
        {
            Caption = 'Posted Invt. Shipment Nos.';
            TableRelation = "No. Series";
        }
        field(5854; "Copy Comments to Invt. Doc."; Boolean)
        {
            Caption = 'Copy Comments to Invt. Doc.';
        }
        field(5855; "Direct Transfer Posting"; Option)
        {
            Caption = 'Direct Transfer Posting';
            OptionCaption = 'Receipt and Shipment,Direct Transfer';
            OptionMembers = "Receipt and Shipment","Direct Transfer";
        }
        field(5856; "Posted Direct Trans. Nos."; Code[20])
        {
            Caption = 'Posted Direct Trans. Nos.';
            TableRelation = "No. Series";
        }
        field(5860; "Package Nos."; Code[20])
        {
            Caption = 'Package Nos.';
            TableRelation = "No. Series";
        }
        field(5875; "Phys. Invt. Order Nos."; Code[20])
        {
            AccessByPermission = TableData "Phys. Invt. Order Header" = R;
            Caption = 'Phys. Invt. Order Nos.';
            TableRelation = "No. Series";
        }
        field(5876; "Posted Phys. Invt. Order Nos."; Code[20])
        {
            AccessByPermission = TableData "Phys. Invt. Order Header" = R;
            Caption = 'Posted Phys. Invt. Order Nos.';
            TableRelation = "No. Series";
        }
        field(6500; "Package Caption"; Text[30])
        {
            Caption = 'Package Caption';
        }
        field(7101; "Item Group Dimension Code"; Code[20])
        {
            Caption = 'Item Group Dimension Code';
            TableRelation = Dimension;
        }
        field(7300; "Inventory Put-away Nos."; Code[20])
        {
            AccessByPermission = TableData "Posted Invt. Put-away Header" = R;
            Caption = 'Inventory Put-away Nos.';
            TableRelation = "No. Series";
        }
        field(7301; "Inventory Pick Nos."; Code[20])
        {
            AccessByPermission = TableData "Posted Invt. Pick Header" = R;
            Caption = 'Inventory Pick Nos.';
            TableRelation = "No. Series";
        }
        field(7302; "Posted Invt. Put-away Nos."; Code[20])
        {
            AccessByPermission = TableData "Posted Invt. Put-away Header" = R;
            Caption = 'Posted Invt. Put-away Nos.';
            TableRelation = "No. Series";
        }
        field(7303; "Posted Invt. Pick Nos."; Code[20])
        {
            AccessByPermission = TableData "Posted Invt. Pick Header" = R;
            Caption = 'Posted Invt. Pick Nos.';
            TableRelation = "No. Series";
        }
        field(7304; "Inventory Movement Nos."; Code[20])
        {
            AccessByPermission = TableData "Whse. Internal Put-away Header" = R;
            Caption = 'Inventory Movement Nos.';
            TableRelation = "No. Series";
        }
        field(7305; "Registered Invt. Movement Nos."; Code[20])
        {
            AccessByPermission = TableData "Whse. Internal Put-away Header" = R;
            Caption = 'Registered Invt. Movement Nos.';
            TableRelation = "No. Series";
        }
        field(7306; "Internal Movement Nos."; Code[20])
        {
            AccessByPermission = TableData "Whse. Internal Put-away Header" = R;
            Caption = 'Internal Movement Nos.';
            TableRelation = "No. Series";
        }
        field(37002000; "Measuring System"; Option)
        {
            Caption = 'Measuring System';
            Description = 'PR1.00';
            OptionCaption = 'Conventional,Metric';
            OptionMembers = Conventional,Metric;

            trigger OnValidate()
            begin
                // PR3.60 Begin
                if "Measuring System" <> xRec."Measuring System" then
                    P800UOMFns.ChangeMeasuringSystem(xRec."Measuring System");
                // PR3.60 End
            end;
        }
        field(37002001; "Near-Zero Qty. Value"; Decimal)
        {
            BlankZero = true;
            Caption = 'Near-Zero Qty. Value';
            DecimalPlaces = 0 : 5;
            Description = 'P8000548A';
            MinValue = 0;
        }
        field(37002010; "Adjust Cost - Post to G/L"; Boolean)
        {
            Caption = 'Adjust Cost - Post to G/L';
        }
        field(37002011; "Adjust Cost - Lock Time (s)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Adjust Cost - Lock Time (s)';
            DecimalPlaces = 0 : 3;
            MinValue = 0;

            trigger OnValidate()
            begin
                // P8001227
                if ("Adjust Cost - Lock Time (s)" = 0) then
                    Validate("Adjust Cost - Unlock Time (ms)", 0);
            end;
        }
        field(37002012; "Adjust Cost - Unlock Time (ms)"; Integer)
        {
            BlankZero = true;
            Caption = 'Adjust Cost - Unlock Time (ms)';
            MinValue = 0;

            trigger OnValidate()
            begin
                // P8001227
                if ("Adjust Cost - Unlock Time (ms)" <> 0) then
                    TestField("Adjust Cost - Lock Time (s)");
            end;
        }
        field(37002020; "Lot Pref. Enforcement Level"; Option)
        {
            Caption = 'Lot Preference Enforcement Level';
            OptionCaption = 'Warning,Error';
            OptionMembers = Warning,Error;
        }
        field(37002021; "Shortcut Lot Spec. 1 Code"; Code[10])
        {
            Caption = 'Shortcut Lot Spec. 1 Code';
            TableRelation = "Data Collection Data Element";
        }
        field(37002022; "Shortcut Lot Spec. 2 Code"; Code[10])
        {
            Caption = 'Shortcut Lot Spec. 2 Code';
            TableRelation = "Data Collection Data Element";
        }
        field(37002023; "Shortcut Lot Spec. 3 Code"; Code[10])
        {
            Caption = 'Shortcut Lot Spec. 3 Code';
            TableRelation = "Data Collection Data Element";
        }
        field(37002024; "Shortcut Lot Spec. 4 Code"; Code[10])
        {
            Caption = 'Shortcut Lot Spec. 4 Code';
            TableRelation = "Data Collection Data Element";
        }
        field(37002025; "Shortcut Lot Spec. 5 Code"; Code[10])
        {
            Caption = 'Shortcut Lot Spec. 5 Code';
            TableRelation = "Data Collection Data Element";
        }
        field(37002030; "Chg. Lot Status Document Nos."; Code[20])
        {
            Caption = 'Change Lot Status Document Nos.';
            TableRelation = "No. Series";
        }
        field(37002031; "Quarantine Lot Status"; Code[10])
        {
            Caption = 'Quarantine Lot Status';
            TableRelation = "Lot Status Code";

            trigger OnValidate()
            begin
                // P8001083
                Validate("Quality Control Lot Status");
                Validate("Sales Lot Status");
                Validate("Purchase Lot Status");
                Validate("Output Lot Status");
                Validate("Quality Ctrl. Fail Lot Status");
            end;
        }
        field(37002032; "Quality Control Lot Status"; Code[10])
        {
            Caption = 'Quality Control Lot Status';
            TableRelation = "Lot Status Code";

            trigger OnValidate()
            begin
                // P8001083
                if ("Quarantine Lot Status" <> '') and ("Quality Control Lot Status" = "Quarantine Lot Status") then
                    FieldError("Quality Control Lot Status", StrSubstNo(Text37002001, "Quarantine Lot Status"));
            end;
        }
        field(37002033; "Sales Lot Status"; Code[10])
        {
            Caption = 'Sales Lot Status';
            TableRelation = "Lot Status Code";

            trigger OnValidate()
            begin
                // P8001083
                if ("Quarantine Lot Status" <> '') and ("Sales Lot Status" = "Quarantine Lot Status") then
                    FieldError("Sales Lot Status", StrSubstNo(Text37002001, "Quarantine Lot Status"));
            end;
        }
        field(37002034; "Purchase Lot Status"; Code[10])
        {
            Caption = 'Purchase Lot Status';
            TableRelation = "Lot Status Code";

            trigger OnValidate()
            begin
                // P8001083
                if ("Quarantine Lot Status" <> '') and ("Purchase Lot Status" = "Quarantine Lot Status") then
                    FieldError("Purchase Lot Status", StrSubstNo(Text37002001, "Quarantine Lot Status"));
            end;
        }
        field(37002035; "Output Lot Status"; Code[10])
        {
            Caption = 'Output Lot Status';
            TableRelation = "Lot Status Code";

            trigger OnValidate()
            begin
                // P8001083
                if ("Quarantine Lot Status" <> '') and ("Output Lot Status" = "Quarantine Lot Status") then
                    FieldError("Output Lot Status", StrSubstNo(Text37002001, "Quarantine Lot Status"));
            end;
        }
        field(37002036; "Quality Ctrl. Fail Lot Status"; Code[10])
        {
            Caption = 'Quality Ctrl. Fail Lot Status';
            TableRelation = "Lot Status Code";

            trigger OnValidate()
            begin
                // P8001083
                if ("Quarantine Lot Status" <> '') and ("Quality Ctrl. Fail Lot Status" = "Quarantine Lot Status") then
                    FieldError("Quality Ctrl. Fail Lot Status", StrSubstNo(Text37002001, "Quarantine Lot Status"));
            end;
        }
        field(37002040; "Def. Price Rounding Method"; Code[10])
        {
            Caption = 'Def. Price Rounding Method';
            Description = 'PR3.60';
            TableRelation = "Rounding Method";
        }
        field(37002041; "Price Selection Priority"; Option)
        {
            Caption = 'Price Selection Priority';
            Description = 'PR3.60';
            OptionCaption = 'None,Currency Only,UOM Only,Currency/UOM,UOM/Currency/Variant,Variant/UOM/Currency';
            OptionMembers = "None","Currency Only","UOM Only","Currency/UOM","UOM/Currency/Variant","Variant/UOM/Currency";
        }
        field(37002080; "Sale Alt. Qty. Default"; Option)
        {
            Caption = 'Sale Alt. Qty. Default';
            Description = 'PR3.60';
            OptionCaption = 'Summary,Detail';
            OptionMembers = Summary,Detail;
        }
        field(37002081; "Purch. Alt. Qty. Default"; Option)
        {
            Caption = 'Purch. Alt. Qty. Default';
            Description = 'PR3.60';
            OptionCaption = 'Summary,Detail';
            OptionMembers = Summary,Detail;
        }
        field(37002082; "Pos. Adj. Alt. Qty. Default"; Option)
        {
            Caption = 'Pos. Adj. Alt. Qty. Default';
            Description = 'PR3.60';
            OptionCaption = 'Summary,Detail';
            OptionMembers = Summary,Detail;
        }
        field(37002083; "Neg. Adj. Alt. Qty. Default"; Option)
        {
            Caption = 'Neg. Adj. Alt. Qty. Default';
            Description = 'PR3.60';
            OptionCaption = 'Summary,Detail';
            OptionMembers = Summary,Detail;
        }
        field(37002084; "Phys. Count Alt. Qty. Default"; Option)
        {
            Caption = 'Phys. Count Alt. Qty. Default';
            Description = 'PR3.60';
            OptionCaption = 'Summary,Detail';
            OptionMembers = Summary,Detail;
        }
        field(37002085; "Transfer Alt. Qty. Default"; Option)
        {
            Caption = 'Transfer Alt. Qty. Default';
            Description = 'PR3.60';
            OptionCaption = 'Summary,Detail';
            OptionMembers = Summary,Detail;
        }
        field(37002086; "Consumption Alt. Qty. Default"; Option)
        {
            Caption = 'Consumption Alt. Qty. Default';
            Description = 'PR3.60';
            OptionCaption = 'Summary,Detail';
            OptionMembers = Summary,Detail;
        }
        field(37002087; "Output Alt. Qty. Default"; Option)
        {
            Caption = 'Output Alt. Qty. Default';
            Description = 'PR3.60';
            OptionCaption = 'Summary,Detail';
            OptionMembers = Summary,Detail;
        }
        field(37002088; "Default Alt. Qty. Tolerance %"; Decimal)
        {
            Caption = 'Default Alt. Qty. Tolerance %';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
            MaxValue = 100;
            MinValue = 0;
        }
        field(37002090; "Blank Captions (Non Alt. Qty.)"; Boolean)
        {
            Caption = 'Blank Captions (Non Alt. Qty.)';
            Description = 'PR3.61';
        }
        field(37002091; "Lot Trace Summary Level"; Option)
        {
            Caption = 'Lot Trace Summary Level';
            OptionCaption = 'Location,Source,Document';
            OptionMembers = Location,Source,Document;
        }
        field(37002210; "Repack Order Nos."; Code[20])
        {
            Caption = 'Repack Order Nos.';
            TableRelation = "No. Series";
        }
        field(37002211; "Default Repack Location"; Code[10])
        {
            Caption = 'Default Repack Location';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                // P8000496A
                if "Default Repack Location" <> '' then begin
                    Location.Get("Default Repack Location");
                    Location.TestField("Bin Mandatory", false);
                end;
            end;
        }
        field(37002460; "Unapproved Item Nos."; Code[20])
        {
            Caption = 'Unapproved Item Nos.';
            Description = 'PR1.00';
            TableRelation = "No. Series";
        }
        field(37002461; "ABC Detail Posting"; Boolean)
        {
            Caption = 'ABC Detail Posting';

            trigger OnValidate()
            begin
                // P8000375A
                if "ABC Detail Posting" then
                    if not ProcessFns.ProcessInstalled then
                        Error(Text37002000);
            end;
        }
        field(37002540; "Add Q/C Tests for Phys. Count"; Boolean)
        {
            Caption = 'Add Q/C Tests for Phys. Count';
            Description = 'PR1.10.04';
        }
        field(37002541; "All Q/C Tests Must Be Done"; Boolean)
        {
            Caption = 'All Q/C Tests Must Be Done';
            Description = 'PR1.10';
        }
        field(37002542; "Q/C Activity Nos."; Code[20])
        {
            Caption = 'Q/C Activity Nos.';
            TableRelation = "No. Series";
        }
        field(37002560; "Container IDs"; Code[20])
        {
            Caption = 'Container IDs';
            Description = 'PR3.61';
            TableRelation = "No. Series";
        }
        field(37002561; "Offsite Cont. Location Code"; Code[10])
        {
            Caption = 'Offsite Cont. Location Code';
            Description = 'PR3.61';
            TableRelation = Location;
        }
        field(37002562; "Container Usage Doc. Nos."; Code[20])
        {
            Caption = 'Container Usage Doc. Nos.';
            Description = 'PR3.70.07';
            TableRelation = "No. Series";
        }
        field(37002563; "SSCC Extension Digit"; Code[1])
        {
            Caption = 'SSCC Extension Digit';
            InitValue = '0';
            Numeric = true;
        }
        field(37002680; "Commodity Cost by Location"; Boolean)
        {
            Caption = 'Commodity Cost by Location';

            trigger OnValidate()
            begin
                // P8000856
                if not "Commodity Cost by Location" then
                    CommItemMgmt.CheckCommCostLocations;
            end;
        }
        field(37002681; "Comm. Cost Rounding Precision"; Decimal)
        {
            BlankZero = true;
            Caption = 'Comm. Cost Rounding Precision';
            DecimalPlaces = 0 : 9;
            InitValue = 0.00001;
        }
        field(37002682; "Cost Adjust on Comm. Post"; Boolean)
        {
            Caption = 'Cost Adjust on Comm. Post';
        }
        field(37002683; "Commodity UOM Type"; Option)
        {
            Caption = 'Commodity UOM Type';
            OptionCaption = 'Weight,Volume';
            OptionMembers = Weight,Volume;

            trigger OnValidate()
            begin
                CommItemMgmt.CheckCommCostUOMTypeChg(Rec, xRec); // P8000856
            end;
        }
        field(37002685; "Commodity Manifest Nos."; Code[20])
        {
            Caption = 'Commodity Manifest Nos.';
            TableRelation = "No. Series";
        }
        field(37002686; "Posted Comm. Manifest Nos."; Code[20])
        {
            Caption = 'Posted Comm. Manifest Nos.';
            TableRelation = "No. Series";
        }
        field(37002687; "Comm. Rcpt. Lot Nos."; Code[20])
        {
            Caption = 'Comm. Rcpt. Lot Nos.';
            TableRelation = "No. Series";
        }
        field(37002920; "Allergen Cons. Enforcement Lvl"; Option)
        {
            Caption = 'Allergen Consumption Enforcement Level';
            OptionCaption = 'Warning,Error';
            OptionMembers = Warning,Error;
        }
        // P800122712
        field(37002543; "Samples Enabled"; Boolean)
        {
            Caption = 'Samples Enabled';
            trigger OnValidate()
            begin
                if not "Samples Enabled" then
                    "Suppress Sample Warning" := false;
            end;
        }
        field(37002544; "Suppress Sample Warning"; Boolean)
        {
            Caption = 'Suppress Sample Warning';
        }
        field(37002545; "Default Sample Reason Code"; Code[10])
        {
            Caption = 'Default Sample Reason Code';
            TableRelation = "Reason Code";
        }
        field(37002546; "Sample Document No. Series"; Code[20])
        {
            Caption = 'Sample Document No. Series';
            TableRelation = "No. Series";
        }
        // P800122712
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        ItemLedgEntry: Record "Item Ledger Entry";
        Text000: Label 'Some unadjusted value entries will not be covered with the new setting. You must run the Adjust Cost - Item Entries batch job once to adjust these.';
        Item: Record Item;
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
        Text004: Label 'The program has cancelled the change that would have caused an adjustment of all items.';
        Text005: Label '%1 has been changed to %2. You should now run %3.';
        ObjTransl: Record "Object Translation";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        ProcessFns: Codeunit "Process 800 Functions";
        Text37002000: Label 'Process manufacturing granule must be installed.';
        CommItemMgmt: Codeunit "Commodity Item Management";
        Text37002001: Label 'cannot be %1';
        ItemEntriesAdjustQst: Label 'If you change the %1, the program must adjust all item entries.The adjustment of all entries can take several hours.\Do you really want to change the %1?', Comment = '%1 - field caption';

    local procedure UpdateInvtAdjmtEntryOrder()
    var
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
    begin
        InvtAdjmtEntryOrder.SetCurrentKey("Cost is Adjusted", "Allow Online Adjustment");
        InvtAdjmtEntryOrder.SetRange("Cost is Adjusted", false);
        InvtAdjmtEntryOrder.SetRange("Allow Online Adjustment", false);
        InvtAdjmtEntryOrder.SetRange("Is Finished", false);
        InvtAdjmtEntryOrder.SetRange("Order Type", InvtAdjmtEntryOrder."Order Type"::Production);
        InvtAdjmtEntryOrder.ModifyAll("Allow Online Adjustment", true);
    end;

    local procedure UpdateAvgCostItemSettings(FieldCaption: Text[80]; FieldValue: Text[80])
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ConfirmManagement.GetResponseOrDefault(
             StrSubstNo(ItemEntriesAdjustQst, FieldCaption), false)
        then
            Error(Text004);

        CODEUNIT.Run(CODEUNIT::"Change Average Cost Setting", Rec);

        Message(
          Text005, FieldCaption, FieldValue,
          ObjTransl.TranslateObject(ObjTransl."Object Type"::Report, REPORT::"Adjust Cost - Item Entries"));
    end;

    procedure OptimGLEntLockForMultiuserEnv(): Boolean
    begin
        if Rec.Get() then
            if Rec."Automatic Cost Posting" then
                exit(false);

        exit(true);
    end;

    procedure AutomaticCostAdjmtRequired(): Boolean
    begin
        exit("Automatic Cost Adjustment" <> "Automatic Cost Adjustment"::Never);
    end;
}

