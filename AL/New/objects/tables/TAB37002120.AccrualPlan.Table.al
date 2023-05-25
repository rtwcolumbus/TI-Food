table 37002120 "Accrual Plan"
{
    // PR3.70.03
    // 
    // PR3.70.07
    // P8000119A, Myers Nissi, Don Bresee, 20 SEP 04
    //   Accruals update/fixes
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00
    // P8000252A, Myers Nissi, Jack Reynolds, 20 OCT 05
    //   All specification of minimum value to use when creating plan lines
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Change dimension code processing to with respect to MODIFY to be in line with similar changes in the
    //     standard tables for SP1
    // 
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan
    // 
    // PR4.00.02
    // P8000311A, VerticalSoft, Jack Reynolds, 21 MAR 06
    //   Changed due to renumbering of reports to define views for customers, vendors, items
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add support for accrual groups
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.02
    // P8000757, VerticalSoft, Jack Reynolds, 08 JAN 10
    //  Change GetPostedPaymentAmount to ignore payee
    // 
    // PRW16.00.04
    // P8000850, VerticalSoft, Jack Reynolds, 23 JUL 10
    //   Rename "Exclude Promo/Rebate" to "Include Promo/Rebate"
    // 
    // PRW17.00.01
    // P8001173, Columbus IT, Jack Reynolds, 20 JUN 13
    //   Support for Apply Template on the cards for accrual plans
    // 
    // PRW17.10
    // P8001236, Columbus IT, Don Bresee, 31 OCT 13
    //   Add "Payment Posting Options" field and related logic
    // 
    // PRW18.00.02
    // P8003887, To-Increase, Jack Reynolds, 23 Sep 15
    //   Fix problem with suggest payemnts with payment posting level
    // 
    // P8002741, To-Increase, Jack Reynolds, 30 Sep 15
    //   Option to create accrual payment documents
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management, rewrite view handling functions
    //   Fix problem with wrong dates (posting date vs. order date)
    // 
    // PRW19.00.01
    // P8006605, To-Increase, Dayakar Battini, 07 NOV 16
    //   Delete Accrual Charge Line for Plan deletion.
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 06 DEC 16
    //   Item Category/Product Group
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.02
    // P80072277, To Increase, Jack Reynolds, 21 MAR 19
    //   Fix InitValue for Include in Promo/Rebate
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW118.00.05
    // P800138545, To-Increase, Gangabhushan 19 JAN 22
    //   CS00201718 | Customer Rebate not calculated on credit memo when date type = Order date
    //
    // P800149934, To-Increase, Gangabhushan, 04 AUG 22
    //   CS00221921 | Customer Rebates not calculation based on Order date on Sales Credit Memo

    Caption = 'Accrual Plan';
    DataCaptionFields = "No.", Name;
    DrillDownPageID = "Accrual Plan List";
    LookupPageID = "Accrual Plan List";
    Permissions = TableData "Accrual Ledger Entry" = r;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if ("No." <> xRec."No.") then begin
                    AccrualSetup.Get;
                    NoSeriesMgt.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                if ("Search Name" = UpperCase(xRec.Name)) or ("Search Name" = '') then
                    "Search Name" := Name;
            end;
        }
        field(4; "Search Name"; Code[100])
        {
            Caption = 'Search Name';
        }
        field(5; "Plan Type"; Option)
        {
            Caption = 'Plan Type';
            OptionCaption = 'Promo/Rebate,Commission,Reporting';
            OptionMembers = "Promo/Rebate",Commission,Reporting;

            trigger OnValidate()
            begin
                Validate("Include Promo/Rebate", "Plan Type" = "Plan Type"::Commission);
                Validate("Post Accrual w/ Document", "Plan Type" = "Plan Type"::Commission);
                Validate("Edit Accrual on Document", "Plan Type" = "Plan Type"::Commission);
                case "Plan Type" of
                    "Plan Type"::Commission:
                        if ("Payment Code" = '') then
                            Validate("Payment Type", "Payment Type"::Vendor);
                    "Plan Type"::Reporting:
                        begin
                            Validate("Accrual Posting Group", '');
                            Validate("Payment Type", "Payment Type"::"Manual/None");
                        end;
                end;
            end;
        }
        field(6; "Start Date"; Date)
        {
            Caption = 'Start Date';

            trigger OnValidate()
            begin
                if ("End Date" <> 0D) and ("Start Date" > "End Date") then
                    Error(Text004, FieldCaption("Start Date"), FieldCaption("End Date"));
            end;
        }
        field(7; "End Date"; Date)
        {
            Caption = 'End Date';

            trigger OnValidate()
            begin
                if ("End Date" <> 0D) and ("Start Date" > "End Date") then
                    Error(Text004, FieldCaption("Start Date"), FieldCaption("End Date"));
            end;
        }
        field(8; "Date Type"; Option)
        {
            Caption = 'Date Type';
            OptionCaption = 'Posting Date,Order Date';
            OptionMembers = "Posting Date","Order Date";
        }
        field(9; "Source Selection Type"; Option)
        {
            Caption = 'Source Selection Type';
            OptionCaption = 'Bill-to/Pay-to,Sell-to/Buy-from,Sell-to/Ship-to';
            OptionMembers = "Bill-to/Pay-to","Sell-to/Buy-from","Sell-to/Ship-to";

            trigger OnValidate()
            begin
                if ("Source Selection Type" <> xRec."Source Selection Type") then begin
                    if (("Source Selection Type" = "Source Selection Type"::"Sell-to/Ship-to") or
                        (xRec."Source Selection Type" = "Source Selection Type"::"Sell-to/Ship-to"))
                    then
                        ErrorIfSourceLinesExist(FieldCaption("Source Selection Type"));

                    if ("Source Selection Type" = "Source Selection Type"::"Sell-to/Ship-to") then
                        Validate("Source Selection", "Source Selection"::Specific);

                    UpdateSourceLines(FieldNo("Source Selection Type"));
                end;
            end;
        }
        field(10; "Source Selection"; Option)
        {
            Caption = 'Source Selection';
            InitValue = Specific;
            OptionCaption = 'All,Specific,Price Group,Accrual Group';
            OptionMembers = All,Specific,"Price Group","Accrual Group";

            trigger OnValidate()
            begin
                if ("Source Selection Type" = "Source Selection Type"::"Sell-to/Ship-to") then
                    TestField("Source Selection", "Source Selection"::Specific);

                if ("Source Selection" <> xRec."Source Selection") then begin
                    if (xRec."Source Selection" = "Source Selection"::All) then
                        DeleteSourceLines;

                    ErrorIfSourceLinesExist(FieldCaption("Source Selection"));

                    if ("Source Selection" = "Source Selection"::All) then
                        InsertSourceLine;
                end;
            end;
        }
        field(11; "Source Code"; Code[20])
        {
            Caption = 'Source Code';
            TableRelation = IF (Type = CONST(Sales),
                                "Source Selection" = CONST(Specific)) Customer
            ELSE
            IF (Type = CONST(Sales),
                                         "Source Selection" = CONST("Price Group")) "Customer Price Group"
            ELSE
            IF (Type = CONST(Sales),
                                                  "Source Selection" = CONST("Accrual Group")) "Accrual Group".Code WHERE(Type = CONST(Customer))
            ELSE
            IF (Type = CONST(Purchase),
                                                           "Source Selection" = CONST(Specific)) Vendor
            ELSE
            IF (Type = CONST(Purchase),
                                                                    "Source Selection" = CONST("Accrual Group")) "Accrual Group".Code WHERE(Type = CONST(Vendor));
        }
        field(12; "Source Ship-to Code"; Code[10])
        {
            Caption = 'Source Ship-to Code';
            TableRelation = IF (Type = CONST(Sales),
                                "Source Selection Type" = CONST("Sell-to/Ship-to"),
                                "Source Selection" = CONST(Specific)) "Ship-to Address".Code WHERE("Customer No." = FIELD("Source Code"));
        }
        field(14; "Item Selection"; Option)
        {
            Caption = 'Item Selection';
            InitValue = "Specific Item";
            OptionCaption = 'All Items,Specific Item,Item Category,Manufacturer,Vendor No.,Item Group';
            OptionMembers = "All Items","Specific Item","Item Category",Manufacturer,"Vendor No.","Accrual Group";

            trigger OnValidate()
            begin
                if ("Item Selection" <> xRec."Item Selection") then
                    ErrorIfPlanLinesExist(FieldCaption("Item Selection"));
            end;
        }
        field(15; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            TableRelation = IF ("Item Selection" = CONST("Specific Item")) Item
            ELSE
            IF ("Item Selection" = CONST("Item Category")) "Item Category"
            ELSE
            IF ("Item Selection" = CONST(Manufacturer)) Manufacturer
            ELSE
            IF ("Item Selection" = CONST("Vendor No.")) Vendor
            ELSE
            IF ("Item Selection" = CONST("Accrual Group")) "Accrual Group".Code WHERE(Type = CONST(Item));
        }
        field(16; Accrue; Option)
        {
            Caption = 'Accrue';
            OptionCaption = 'Invoices/CMs,Shipments/Receipts,Paid Invoices/CMs';
            OptionMembers = "Invoices/CMs","Shipments/Receipts","Paid Invoices/CMs";

            trigger OnValidate()
            begin
                if (Accrue <> Accrue::"Invoices/CMs") then begin
                    TestField("Post Accrual w/ Document", false);
                    if (Accrue = Accrue::"Shipments/Receipts") then
                        TestField("Exclude Upcharges", false);
                    TestField("Payment Posting Options", "Payment Posting Options"::Immediate); // P8001236
                end;
            end;
        }
        field(17; "Computation Level"; Option)
        {
            Caption = 'Computation Level';
            Editable = false;
            OptionCaption = 'Document Line,Document,Plan';
            OptionMembers = "Document Line",Document,Plan;

            trigger OnValidate()
            begin
                case "Computation Level" of
                    "Computation Level"::"Document Line":
                        begin
                            Validate("Accrual Posting Level", "Accrual Posting Level"::"Document Line");
                            Validate("Payment Posting Level", "Payment Posting Level"::"Document Line");
                        end;
                    "Computation Level"::Document:
                        begin
                            TestField("Price Impact", "Price Impact"::None);
                            if ("G/L Posting Level" > "G/L Posting Level"::Document) then
                                FieldError("G/L Posting Level");
                            Validate("Accrual Posting Level", "Accrual Posting Level"::Document);
                            Validate("Payment Posting Level", "Payment Posting Level"::Document);
                        end;
                    "Computation Level"::Plan:
                        begin
                            TestField("Price Impact", "Price Impact"::None);
                            TestField("Post Accrual w/ Document", false);
                            if ("G/L Posting Level" > "G/L Posting Level"::Source) then
                                FieldError("G/L Posting Level");
                            Validate("Accrual Posting Level", "Accrual Posting Level"::Plan);
                            Validate("Payment Posting Level", "Payment Posting Level"::Plan);
                        end;
                end;
            end;
        }
        field(18; "Minimum Value Type"; Option)
        {
            Caption = 'Minimum Value Type';
            InitValue = Quantity;
            OptionCaption = 'Amount,Quantity';
            OptionMembers = Amount,Quantity;
        }
        field(19; "Computation UOM"; Code[10])
        {
            Caption = 'Computation UOM';
            TableRelation = "Unit of Measure";
        }
        field(20; "Computation Group"; Code[10])
        {
            Caption = 'Computation Group';
            TableRelation = "Accrual Computation Group";
        }
        field(21; "Price Impact"; Option)
        {
            Caption = 'Price Impact';
            OptionCaption = 'None,Exclude from Price,Include in Price';
            OptionMembers = "None","Exclude from Price","Include in Price";

            trigger OnValidate()
            begin
                Validate("Post Accrual w/ Document", "Price Impact" <> "Price Impact"::None);
                if ("Price Impact" <> "Price Impact"::None) then
                    TestField("Computation Level", "Computation Level"::"Document Line");
            end;
        }
        field(22; Closed; Boolean)
        {
            Caption = 'Closed';
        }
        field(23; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(24; "Accrual Posting Group"; Code[20])
        {
            Caption = 'Accrual Posting Group';
            TableRelation = "Accrual Posting Group";

            trigger OnValidate()
            begin
                if ("Accrual Posting Group" <> '') and ("Plan Type" = "Plan Type"::Reporting) then
                    FieldError("Plan Type");
            end;
        }
        field(25; "Payment Type"; Option)
        {
            Caption = 'Payment Type';
            OptionCaption = 'Source Bill-to/Pay-to,Customer,Vendor,G/L Account,Payment Group,Manual/None';
            OptionMembers = "Source Bill-to/Pay-to",Customer,Vendor,"G/L Account","Payment Group","Manual/None";

            trigger OnValidate()
            begin
                if ("Payment Type" <> xRec."Payment Type") then
                    Validate("Payment Code", '');

                if ("Plan Type" = "Plan Type"::Reporting) and
                   ("Payment Type" <> "Payment Type"::"Manual/None")
                then
                    FieldError("Plan Type");

                if ("Payment Posting Level" = "Payment Posting Level"::Plan) and
                   ("Payment Type" = "Payment Type"::"Source Bill-to/Pay-to")
                then
                    FieldError("Payment Posting Level");
            end;
        }
        field(26; "Payment Code"; Code[20])
        {
            Caption = 'Payment Code';
            TableRelation = IF ("Payment Type" = CONST(Customer)) Customer
            ELSE
            IF ("Payment Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Payment Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Payment Type" = CONST("Payment Group")) "Accrual Payment Group";

            trigger OnValidate()
            begin
                if ("Payment Type" in ["Payment Type"::"Source Bill-to/Pay-to", "Payment Type"::"Manual/None"]) then
                    TestField("Payment Code", '');
            end;
        }
        field(27; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
                Modify; // P8000267B
            end;
        }
        field(28; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
                Modify; // P8000267B
            end;
        }
        field(29; "Source Filter"; Code[20])
        {
            Caption = 'Source Filter';
            FieldClass = FlowFilter;
            TableRelation = IF (Type = CONST(Sales)) Customer
            ELSE
            IF (Type = CONST(Purchase)) Vendor;
        }
        field(30; "Item Filter"; Code[20])
        {
            Caption = 'Item Filter';
            FieldClass = FlowFilter;
            TableRelation = Item;
        }
        field(31; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(32; "Accrual Amount"; Decimal)
        {
            CalcFormula = Sum("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = FIELD(Type),
                                                                   "Accrual Plan No." = FIELD("No."),
                                                                   "Entry Type" = CONST(Accrual),
                                                                   "Source No." = FIELD("Source Filter"),
                                                                   "Item No." = FIELD("Item Filter"),
                                                                   "Posting Date" = FIELD("Date Filter")));
            Caption = 'Accrual Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(33; "Payment Amount"; Decimal)
        {
            CalcFormula = Sum("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = FIELD(Type),
                                                                   "Accrual Plan No." = FIELD("No."),
                                                                   "Entry Type" = CONST(Payment),
                                                                   "Source No." = FIELD("Source Filter"),
                                                                   "Item No." = FIELD("Item Filter"),
                                                                   "Posting Date" = FIELD("Date Filter")));
            Caption = 'Payment Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(34; Balance; Decimal)
        {
            CalcFormula = Sum("Accrual Ledger Entry".Amount WHERE("Accrual Plan Type" = FIELD(Type),
                                                                   "Accrual Plan No." = FIELD("No."),
                                                                   "Source No." = FIELD("Source Filter"),
                                                                   "Item No." = FIELD("Item Filter")));
            Caption = 'Balance';
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Edit Accrual on Document"; Boolean)
        {
            Caption = 'Edit Accrual on Document';

            trigger OnValidate()
            begin
                if "Edit Accrual on Document" then
                    Validate("Post Accrual w/ Document", true);
                if "Edit Accrual on Document" and ("Payment Posting Options" = "Payment Posting Options"::"Partially Paid") then // P8001236
                    FieldError("Payment Posting Options");
            end;
        }
        field(36; "Post Accrual w/ Document"; Boolean)
        {
            Caption = 'Post Accrual w/ Document';

            trigger OnValidate()
            begin
                if not "Post Accrual w/ Document" then begin
                    TestField("Price Impact", "Price Impact"::None);
                    Validate("Post Payment w/ Document", false);
                    Validate("Edit Accrual on Document", false);
                end else begin
                    if ("Accrual Posting Level" < "Accrual Posting Level"::Document) then
                        FieldError("Accrual Posting Level");
                    TestField(Accrue, Accrue::"Invoices/CMs");
                    TestField("Use Accrual Schedule", false);
                end;
            end;
        }
        field(37; "G/L Posting Level"; Option)
        {
            Caption = 'G/L Posting Level';
            OptionCaption = 'Summarized,Plan,Source,Document,Document Line';
            OptionMembers = Summarized,Plan,Source,Document,"Document Line";

            trigger OnValidate()
            begin
                case "Computation Level" of
                    "Computation Level"::Document:
                        if ("G/L Posting Level" > "G/L Posting Level"::Document) then
                            FieldError("Computation Level");
                    "Computation Level"::Plan:
                        if ("G/L Posting Level" > "G/L Posting Level"::Source) then
                            FieldError("Computation Level");
                end;
            end;
        }
        field(38; "Post Payment w/ Document"; Boolean)
        {
            Caption = 'Post Payment w/ Document';

            trigger OnValidate()
            begin
                if "Post Payment w/ Document" then begin
                    TestField("Create Payment Documents", false); // P8002741
                    if ("Payment Posting Level" < "Payment Posting Level"::Document) then
                        FieldError("Payment Posting Level");
                    TestField("Payment Posting Options", "Payment Posting Options"::Immediate); // P8001236
                    Validate("Post Accrual w/ Document", true);
                end;
            end;
        }
        field(39; "Exclude Upcharges"; Boolean)
        {
            Caption = 'Exclude Upcharges';

            trigger OnValidate()
            begin
                if "Exclude Upcharges" then begin
                    TestField(Type, Type::Sales);
                    if (Accrue = Accrue::"Shipments/Receipts") then
                        FieldError(Accrue);
                end;
            end;
        }
        field(40; "Include Promo/Rebate"; Boolean)
        {
            Caption = 'Include Promo/Rebate';
            InitValue = false;

            trigger OnValidate()
            begin
                if "Include Promo/Rebate" then begin
                    TestField("Plan Type", "Plan Type"::Commission);
                    if (Accrue = Accrue::"Shipments/Receipts") then
                        FieldError(Accrue);
                end;
            end;
        }
        field(41; "Source View"; BLOB)
        {
            Caption = 'Source View';
        }
        field(42; "Item View"; BLOB)
        {
            Caption = 'Item View';
        }
        field(43; "Use Accrual Schedule"; Boolean)
        {
            Caption = 'Use Accrual Schedule';

            trigger OnValidate()
            begin
                if "Use Accrual Schedule" then begin
                    TestField("Post Accrual w/ Document", false);
                    Validate("Accrual Posting Level", "Accrual Posting Level"::Plan);
                end else begin
                    DeleteScheduleLines(0);
                    Validate("Accrual Posting Level", "Accrual Posting Level"::"Document Line");
                end;
            end;
        }
        field(44; "Estimated Accrual Amount"; Decimal)
        {
            CalcFormula = Sum("Accrual Plan Line"."Estimated Accrual Amount" WHERE("Accrual Plan Type" = FIELD(Type),
                                                                                    "Accrual Plan No." = FIELD("No.")));
            Caption = 'Estimated Accrual Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(45; "Scheduled Accrual Amount"; Decimal)
        {
            CalcFormula = Sum("Accrual Plan Schedule Line".Amount WHERE("Accrual Plan Type" = FIELD(Type),
                                                                         "Accrual Plan No." = FIELD("No."),
                                                                         "Entry Type" = CONST(Accrual),
                                                                         "Scheduled Date" = FIELD("Date Filter")));
            Caption = 'Scheduled Accrual Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(46; "Use Payment Schedule"; Boolean)
        {
            Caption = 'Use Payment Schedule';

            trigger OnValidate()
            begin
                if "Use Payment Schedule" then
                    Validate("Payment Posting Level", "Payment Posting Level"::Plan)
                else begin
                    DeleteScheduleLines(1);
                    if ("Accrual Posting Level" <> "Accrual Posting Level"::Plan) then
                        Validate("Payment Posting Level", "Accrual Posting Level");
                end;
            end;
        }
        field(47; "Scheduled Payment Amount"; Decimal)
        {
            CalcFormula = Sum("Accrual Plan Schedule Line".Amount WHERE("Accrual Plan Type" = FIELD(Type),
                                                                         "Accrual Plan No." = FIELD("No."),
                                                                         "Entry Type" = CONST(Payment),
                                                                         "Scheduled Date" = FIELD("Date Filter")));
            Caption = 'Scheduled Payment Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(48; "Accrual Charge Amount"; Decimal)
        {
            CalcFormula = Sum("Accrual Charge Line".Amount WHERE("Accrual Plan Type" = FIELD(Type),
                                                                  "Accrual Plan No." = FIELD("No.")));
            Caption = 'Accrual Charge Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(49; "Accrual Posting Level"; Option)
        {
            Caption = 'Accrual Posting Level';
            Editable = false;
            InitValue = "Document Line";
            OptionCaption = 'Plan,Source,Document,Document Line';
            OptionMembers = Plan,Source,Document,"Document Line";

            trigger OnValidate()
            begin
                if TypeEntriesExist(0) then
                    Error(Text001, Type, TableCaption, "No.");

                if ("Accrual Posting Level" <> "Accrual Posting Level"::Plan) then
                    TestField("Use Accrual Schedule", false);
                case "Computation Level" of
                    "Computation Level"::Document:
                        if ("Accrual Posting Level" > "Accrual Posting Level"::Document) then
                            FieldError("Computation Level");
                    "Computation Level"::Plan:
                        if ("Accrual Posting Level" > "Accrual Posting Level"::Source) then
                            FieldError("Computation Level");
                end;
                if ("Accrual Posting Level" < "Accrual Posting Level"::Document) then        // P8001236
                    TestField("Payment Posting Options", "Payment Posting Options"::Immediate); // P8001236
                if ("Accrual Posting Level" < "Accrual Posting Level"::Document) then
                    Validate("Post Accrual w/ Document", false);
                if ("Accrual Posting Level" < "Payment Posting Level") then
                    Validate("Payment Posting Level", "Accrual Posting Level");
            end;
        }
        field(50; "Payment Posting Level"; Option)
        {
            Caption = 'Payment Posting Level';
            InitValue = "Document Line";
            OptionCaption = 'Plan,Source,Document,Document Line';
            OptionMembers = Plan,Source,Document,"Document Line";

            trigger OnValidate()
            begin
                if TypeEntriesExist(1) then
                    Error(Text001, Type, TableCaption, "No.");

                if ("Payment Posting Level" <> "Payment Posting Level"::Plan) then
                    TestField("Use Payment Schedule", false);
                if ("Accrual Posting Level" < "Payment Posting Level") then
                    FieldError("Accrual Posting Level");
                case "Computation Level" of
                    "Computation Level"::Document:
                        if ("Payment Posting Level" > "Payment Posting Level"::Document) then
                            FieldError("Computation Level");
                    "Computation Level"::Plan:
                        if ("Payment Posting Level" > "Payment Posting Level"::Source) then
                            FieldError("Computation Level");
                end;
                if ("Payment Posting Level" < "Payment Posting Level"::Document) then
                    Validate("Post Payment w/ Document", false);
                if ("Payment Posting Level" = "Payment Posting Level"::Plan) and
                   ("Payment Type" = "Payment Type"::"Source Bill-to/Pay-to")
                then
                    Validate("Payment Type", "Payment Type"::"Manual/None");
                // P8001236
                if ("Payment Posting Level" = "Payment Posting Level"::"Document Line") and
                   ("Payment Posting Options" = "Payment Posting Options"::"Partially Paid")
                then
                    FieldError("Payment Posting Options");
                // P8001236
            end;
        }
        field(51; "Payment Posting Options"; Option)
        {
            Caption = 'Payment Posting Options';
            OptionCaption = 'Immediate,Partially Paid,Completely Paid';
            OptionMembers = Immediate,"Partially Paid","Completely Paid";

            trigger OnValidate()
            begin
                // P8001236
                if ("Payment Posting Options" <> "Payment Posting Options"::Immediate) then begin
                    TestField(Type, Type::Sales);
                    TestField(Accrue, Accrue::"Invoices/CMs");
                    TestField("Post Payment w/ Document", false);
                    if ("Accrual Posting Level" < "Accrual Posting Level"::Document) then
                        FieldError("Accrual Posting Level");
                    if ("Payment Posting Options" = "Payment Posting Options"::"Partially Paid") then begin
                        if ("Payment Posting Level" = "Payment Posting Level"::"Document Line") then
                            FieldError("Payment Posting Level");
                        TestField("Edit Accrual on Document", false);
                    end;
                end;
            end;
        }
        field(52; "Create Payment Documents"; Boolean)
        {
            Caption = 'Create Payment Documents';

            trigger OnValidate()
            begin
                // P8002741
                Validate("Post Payment w/ Document", false);
            end;
        }
        field(53; "Purchase Document Lines"; Integer)
        {
            CalcFormula = Count("Purchase Line" WHERE(Type = CONST(FOODAccrualPlan),
                                                       "Accrual Plan Type" = FIELD(Type),
                                                       "No." = FIELD("No.")));
            Caption = 'Purchase Document Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(54; "Sales Document Lines"; Integer)
        {
            CalcFormula = Count("Sales Line" WHERE(Type = CONST(FOODAccrualPlan),
                                                    "Accrual Plan Type" = FIELD(Type),
                                                    "No." = FIELD("No.")));
            Caption = 'Sales Document Lines';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Type, "No.")
        {
        }
        key(Key2; "Search Name")
        {
        }
        key(Key3; Type, "Plan Type")
        {
        }
        key(Key4; Type, "Plan Type", "Computation Level", "Date Type", "Start Date", "End Date", "Source Selection Type", "Source Selection", "Source Code", "Source Ship-to Code", "Item Selection", "Item Code")
        {
        }
        key(Key5; "Plan Type", "Payment Type", "Payment Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Name)
        {
        }
    }

    trigger OnDelete()
    begin
        if AnyEntriesExist() then                    // P8000119A
            Error(Text001, Type, TableCaption, "No."); // P8000119A

        SearchMgmt.DeletePlan(Rec);

        DeletePlanLines;
        DeleteSourceLines;
        DeleteScheduleLines(0);
        DeleteScheduleLines(1);

        DeleteChargeLines;  // P8006605

        DimMgt.DeleteDefaultDim(DATABASE::"Accrual Plan", "No.");
    end;

    trigger OnInsert()
    begin
        if ("No." = '') then begin
            AccrualSetup.Get;
            TestNoSeries;
            NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", 0D, "No.", "No. Series");
        end;

        case Type of
            Type::Sales:
                if AccrualPlan.Get(Type::Purchase, "No.") then
                    Error(Text000, AccrualPlan.Type, TableCaption, "No.");
            Type::Purchase:
                if AccrualPlan.Get(Type::Sales, "No.") then
                    Error(Text000, AccrualPlan.Type, TableCaption, "No.");
        end;

        AccrualSetup.Get;                                                      // P8002741
        "Create Payment Documents" := AccrualSetup."Create Payment Documents"; // P8002741

        DimMgt.UpdateDefaultDim(
          DATABASE::"Accrual Plan", "No.",
          "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    trigger OnModify()
    begin
        SearchMgmt.ModifyPlan(Rec, xRec);
    end;

    trigger OnRename()
    begin
        DimMgt.RenameDefaultDim(DATABASE::"Accrual Plan", xRec."No.", "No."); // P80073095
    end;

    var
        AccrualSetup: Record "Accrual Setup";
        AccrualPlan: Record "Accrual Plan";
        AccrualGroup: Record "Accrual Group";
        Item: Record Item;
        SearchMgmt: Codeunit "Accrual Search Management";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        Text000: Label '%1 %2 %3 already exists.';
        Text001: Label 'Ledger Entries exist for %1 %2 %3.';
        Text002: Label '%1 cannot be changed when plan lines exist.';
        Text003: Label '%1 cannot be changed when source lines exist.';
        Text004: Label '%1 is after %2.';
        Text005: Label 'Are you sure you want to clear the %1?';
        Text006: Label 'The view is not defined.';
        Text007: Label 'There are no %1s in the %2.';
        Text008: Label 'Are you sure you want to add %1s to %2 %3?';
        Text009: Label 'Define %1 View';

    procedure AssistEdit(OldAccrualPlan: Record "Accrual Plan"): Boolean
    begin
        with AccrualPlan do begin
            AccrualPlan := Rec;
            AccrualSetup.Get;
            TestNoSeries;
            if NoSeriesMgt.SelectSeries(GetNoSeriesCode(), OldAccrualPlan."No. Series", "No. Series") then begin
                AccrualSetup.Get;
                TestNoSeries;
                NoSeriesMgt.SetSeries("No.");
                Rec := AccrualPlan;
                exit(true);
            end;
        end;
        exit(false);
    end;

    local procedure TestNoSeries()
    begin
        case Type of
            Type::Sales:
                begin
                    if ("Plan Type" = "Plan Type"::Commission) then
                        if (AccrualSetup."Sales Commission Plan Nos." <> '') then
                            exit;
                    AccrualSetup.TestField("Sales Promo/Rebate Plan Nos.");
                end;
            Type::Purchase:
                AccrualSetup.TestField("Purchase Accrual Plan Nos.");
        end;
    end;

    local procedure GetNoSeriesCode(): Code[20]
    begin
        // P80053245 - Enlarge result
        case Type of
            Type::Sales:
                begin
                    if ("Plan Type" = "Plan Type"::Commission) then
                        if (AccrualSetup."Sales Commission Plan Nos." <> '') then
                            exit(AccrualSetup."Sales Commission Plan Nos.");
                    exit(AccrualSetup."Sales Promo/Rebate Plan Nos.");
                end;
            Type::Purchase:
                exit(AccrualSetup."Purchase Accrual Plan Nos.");
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"Accrual Plan", "No.", FieldNumber, ShortcutDimCode);
        Modify;
    end;

    procedure ShowCard()
    var
        PageManagement: Codeunit "Page Management";
    begin
        // P8004516
        PageManagement.PageRunModal(Rec);
    end;

    procedure GetTransactionDateFilter(): Text[250]
    begin
        if ("Start Date" <> 0D) and ("End Date" <> 0D) then
            exit(StrSubstNo('%1..%2', "Start Date", "End Date"));
        if ("Start Date" <> 0D) then
            exit(StrSubstNo('%1..', "Start Date"));
        if ("End Date" <> 0D) then
            exit(StrSubstNo('..%1', "End Date"));
        exit('');
    end;

    procedure GetCombinedDateFilter(var AccrualSourceLine: Record "Accrual Plan Source Line"; StartDate: Date; EndDate: Date): Text[250]
    begin
        // P8000274A
        if ("Computation Level" = "Computation Level"::Plan) then
            StartDate := GetStartDate(AccrualSourceLine, 0D)
        else
            StartDate := GetStartDate(AccrualSourceLine, StartDate);
        exit(StrSubstNo('%1..%2', StartDate, GetEndDate(AccrualSourceLine, EndDate)));
    end;

    procedure GetEndDate(var AccrualSourceLine: Record "Accrual Plan Source Line"; TransactionDate: Date): Date
    begin
        // P8000274A
        exit(MinDate2("End Date", MinDate2(AccrualSourceLine."End Date", TransactionDate)));
    end;

    procedure GetStartDate(var AccrualSourceLine: Record "Accrual Plan Source Line"; TransactionDate: Date): Date
    begin
        // P8000274A
        exit(MaxDate2("Start Date", MaxDate2(AccrualSourceLine."Start Date", TransactionDate)));
    end;

    local procedure MinDate2(Date1: Date; Date2: Date): Date
    begin
        // P8000274A
        if (Date1 = 0D) then
            exit(Date2);
        if (Date2 = 0D) then
            exit(Date1);
        if (Date1 < Date2) then
            exit(Date1);
        exit(Date2);
    end;

    local procedure MaxDate2(Date1: Date; Date2: Date): Date
    begin
        // P8000274A
        if (Date1 = 0D) then
            exit(Date2);
        if (Date2 = 0D) then
            exit(Date1);
        if (Date1 > Date2) then
            exit(Date1);
        exit(Date2);
    end;

    procedure GetPlanSource(BillToPayToNo: Code[20]; SellToBuyFromNo: Code[20]): Code[20]
    begin
        if ("Source Selection Type" = "Source Selection Type"::"Bill-to/Pay-to") then
            exit(BillToPayToNo);
        exit(SellToBuyFromNo);
    end;

    procedure IsSourceInPlan(BillToPayToNo: Code[20]; SellToBuyFromNo: Code[20]; TransactionDate: Date): Boolean
    var
        AccrualSourceLine: Record "Accrual Plan Source Line";
        Customer: Record Customer;
    begin
        // P8000274A - add parameter for TransactionDate
        AccrualSourceLine.SetRange("Accrual Plan Type", Type);
        AccrualSourceLine.SetRange("Accrual Plan No.", "No.");
        case "Source Selection" of
            "Source Selection"::Specific:
                AccrualSourceLine.SetFilter(
                  "Source Code", '%1', GetPlanSource(BillToPayToNo, SellToBuyFromNo));
            "Source Selection"::"Price Group":
                begin
                    Customer.Get(GetPlanSource(BillToPayToNo, SellToBuyFromNo));
                    AccrualSourceLine.SetFilter("Source Code", '%1', Customer."Customer Price Group");
                end;
        end;
        // P8000274A
        if (TransactionDate <> 0D) then begin
            AccrualSourceLine.SetFilter("Start Date", '..%1', TransactionDate);
            AccrualSourceLine.SetFilter("End Date", '%1|%2..', 0D, TransactionDate);
        end;
        // P8000274A

        // P8000355A
        //EXIT(AccrualSourceLine.FIND('-'));
        if not AccrualSourceLine.Find('-') then
            exit(false);
        if "Source Selection" <> "Source Selection"::"Accrual Group" then
            exit(true);

        exit(AccrualGroup.IsMemberOfSourceGroup(Type, AccrualSourceLine."Source Code", GetPlanSource(BillToPayToNo, SellToBuyFromNo)));
        // P8000355A
    end;

    procedure IsShipToInPlan(SourceCode: Code[20]; ShipToCode: Code[20]; TransactionDate: Date): Boolean
    var
        AccrualSourceLine: Record "Accrual Plan Source Line";
    begin
        // P8000274A - add parameter for TransactionDate
        if ("Source Selection Type" <> "Source Selection Type"::"Sell-to/Ship-to") then
            exit(true);
        AccrualSourceLine.SetRange("Accrual Plan Type", Type);
        AccrualSourceLine.SetRange("Accrual Plan No.", "No.");
        AccrualSourceLine.SetFilter("Source Code", '%1', SourceCode);
        AccrualSourceLine.SetFilter("Source Ship-to Code", '%1', ShipToCode);
        // P8000274A
        if (TransactionDate <> 0D) then begin
            AccrualSourceLine.SetFilter("Start Date", '..%1', TransactionDate);
            AccrualSourceLine.SetFilter("End Date", '%1|%2..', 0D, TransactionDate);
        end;
        // P8000274A
        exit(AccrualSourceLine.Find('-'));
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if (ItemNo <> Item."No.") then
            Item.Get(ItemNo);
    end;

    procedure IsItemInPlan(ItemNo: Code[20]; TransactionDate: Date): Boolean
    var
        AccrualPlanLine: Record "Accrual Plan Line";
    begin
        // P8000274A - add parameter for TransactionDate
        exit(GetItemInPlan(ItemNo, AccrualPlanLine, TransactionDate, false, 0)); // P8000274A
    end;

    procedure CalcAccrualQuantity(ItemNo: Code[20]; TransactionDate: Date; BaseQty: Decimal; AltQty: Decimal): Decimal
    var
        AccrualPlanLine: Record "Accrual Plan Line";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        AltUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // P8000274A - add parameter for TransactionDate
        if TransactionDate = 0D then // P8005495
            exit(0);                   // P8005495
        if GetItemInPlan(ItemNo, AccrualPlanLine, TransactionDate, false, 0) then // P8000274A
            if (AccrualPlanLine."Computation UOM" <> '') then
                if ItemUnitOfMeasure.Get(ItemNo, AccrualPlanLine."Computation UOM") then begin
                    GetItem(ItemNo);
                    if Item.TrackAlternateUnits() then begin
                        ItemUnitOfMeasure.CalcFields(Type);
                        AltUnitOfMeasure.Get(ItemNo, Item."Alternate Unit of Measure");
                        AltUnitOfMeasure.CalcFields(Type);
                        if (ItemUnitOfMeasure.Type = AltUnitOfMeasure.Type) then
                            BaseQty := AltQty * AltUnitOfMeasure."Qty. per Unit of Measure";
                    end;
                    ItemUnitOfMeasure.TestField("Qty. per Unit of Measure");
                    exit(BaseQty / ItemUnitOfMeasure."Qty. per Unit of Measure");
                end;
        exit(0);
    end;

    procedure CalcAccrualAmount(ItemNo: Code[20]; TransactionDate: Date; Amount: Decimal; Cost: Decimal; Quantity: Decimal): Decimal
    var
        AccrualPlanLine: Record "Accrual Plan Line";
        ReferenceValue: Decimal;
    begin
        // P8000274A - add parameter for TransactionDate
        if TransactionDate = 0D then // P8005495
            exit(0);                   // P8005495
        case "Minimum Value Type" of
            "Minimum Value Type"::Amount:
                if not GetItemInPlan(ItemNo, AccrualPlanLine, TransactionDate, true, Amount) then // P8000274A
                    exit(0);
            "Minimum Value Type"::Quantity:
                if not GetItemInPlan(ItemNo, AccrualPlanLine, TransactionDate, true, Quantity) then // P8000274A
                    exit(0);
        end;
        case AccrualPlanLine."Reference Value" of
            AccrualPlanLine."Reference Value"::Price:
                ReferenceValue := Amount;
            AccrualPlanLine."Reference Value"::Cost:
                ReferenceValue := Cost;
            AccrualPlanLine."Reference Value"::Profit:
                ReferenceValue := Amount - Cost;
            AccrualPlanLine."Reference Value"::Quantity:
                ReferenceValue := Quantity;
        end;
        ReferenceValue := ReferenceValue - AccrualPlanLine."Over Reference Value";
        if (ReferenceValue < 0) then
            exit(0);
        case AccrualPlanLine."Multiplier Type" of
            AccrualPlanLine."Multiplier Type"::Percentage:
                ReferenceValue := ReferenceValue * (AccrualPlanLine."Multiplier Value" / 100);
            AccrualPlanLine."Multiplier Type"::"Unit Amount":
                ReferenceValue := ReferenceValue * AccrualPlanLine."Multiplier Value";
        end;
        exit(Round(AccrualPlanLine."Accrual Amount" + ReferenceValue));
    end;

    local procedure SetPlanFilters(var AccrualLedgEntry: Record "Accrual Ledger Entry")
    begin
        AccrualLedgEntry.SetCurrentKey(
          "Accrual Plan Type", "Accrual Plan No.", "Entry Type", "Source No.", Type, "No.",
          "Source Document Type", "Source Document No.", "Source Document Line No.",
          "Item No.", "Posting Date");
        AccrualLedgEntry.SetRange("Accrual Plan Type", Type);
        AccrualLedgEntry.SetRange("Accrual Plan No.", "No.");
    end;

    local procedure SetPlanEntryTypeFilters(var AccrualLedgEntry: Record "Accrual Ledger Entry"; EntryType: Integer)
    begin
        SetPlanFilters(AccrualLedgEntry);
        AccrualLedgEntry.SetRange("Entry Type", EntryType);
    end;

    local procedure SetSourceDocFilters(var AccrualLedgEntry: Record "Accrual Ledger Entry"; SourceNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer)
    begin
        AccrualLedgEntry.SetFilter("Source No.", '%1', SourceNo);
        if (SourceDocType <> 0) then begin
            AccrualLedgEntry.SetRange("Source Document Type", SourceDocType);
            if (SourceDocNo <> '') then begin
                AccrualLedgEntry.SetRange("Source Document No.", SourceDocNo);
                if (SourceDocLineNo <> 0) then
                    AccrualLedgEntry.SetRange("Source Document Line No.", SourceDocLineNo);
            end;
        end;
    end;

    procedure GetPostedAccrualAmount(SourceNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer): Decimal
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        SetPlanEntryTypeFilters(AccrualLedgEntry, AccrualLedgEntry."Entry Type"::Accrual);
        SetSourceDocFilters(AccrualLedgEntry, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo);
        AccrualLedgEntry.SetRange(Type, Type);
        AccrualLedgEntry.CalcSums(Amount);
        exit(AccrualLedgEntry.Amount);
    end;

    procedure GetPostedPaymentAmount(SourceNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer; PaymentType: Integer; PaymentNo: Code[20]): Decimal
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        // P8000757 - remove parameters for PaymentType and PaymentNo
        // P8003887 Restored parameters
        SetPlanEntryTypeFilters(AccrualLedgEntry, AccrualLedgEntry."Entry Type"::Payment);
        SetSourceDocFilters(AccrualLedgEntry, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo);
        AccrualLedgEntry.SetRange(Type, PaymentType); // P8000757, P8003887
        AccrualLedgEntry.SetRange("No.", PaymentNo);  // P8000757, P8003887
        AccrualLedgEntry.CalcSums(Amount);
        exit(AccrualLedgEntry.Amount);
    end;

    procedure GetPostingLevel(EntryType: Integer): Integer
    var
        AccrualJnlLine: Record "Accrual Journal Line";
    begin
        case EntryType of
            AccrualJnlLine."Entry Type"::Accrual:
                exit("Accrual Posting Level");
            AccrualJnlLine."Entry Type"::Payment:
                exit("Payment Posting Level");
        end;
    end;

    procedure PostingLevelError(EntryType: Integer)
    var
        AccrualJnlLine: Record "Accrual Journal Line";
    begin
        case EntryType of
            AccrualJnlLine."Entry Type"::Accrual:
                FieldError("Accrual Posting Level");
            AccrualJnlLine."Entry Type"::Payment:
                FieldError("Payment Posting Level");
        end;
    end;

    procedure CheckPostingLevel(EntryType: Integer; MinLevelAllowed: Integer)
    var
        AccrualJnlLine: Record "Accrual Journal Line";
    begin
        if (GetPostingLevel(EntryType) < MinLevelAllowed) then
            PostingLevelError(EntryType);
    end;

    procedure EntriesExist(SourceNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer; ItemNo: Code[20]): Boolean
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        SetPlanFilters(AccrualLedgEntry);
        if (SourceNo <> '') then
            SetSourceDocFilters(AccrualLedgEntry, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo);
        if (ItemNo <> '') then
            AccrualLedgEntry.SetRange("Item No.", ItemNo);
        exit(AccrualLedgEntry.Find('-'));
    end;

    procedure TypeEntriesExist(EntryType: Integer): Boolean
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        SetPlanEntryTypeFilters(AccrualLedgEntry, EntryType);
        exit(AccrualLedgEntry.Find('-'));
    end;

    procedure AnyEntriesExist(): Boolean
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        SetPlanFilters(AccrualLedgEntry);
        exit(AccrualLedgEntry.Find('-'));
    end;

    local procedure ErrorIfPlanLinesExist(FldCaption: Text[250])
    var
        AccrualPlanLine: Record "Accrual Plan Line";
    begin
        AccrualPlanLine.Reset;
        AccrualPlanLine.SetRange("Accrual Plan Type", Type);
        AccrualPlanLine.SetRange("Accrual Plan No.", "No.");
        if AccrualPlanLine.Find('-') then
            Error(Text002, FldCaption);
    end;

    local procedure GetItemInPlan(ItemNo: Code[20]; var AccrualPlanLine: Record "Accrual Plan Line"; TransactionDate: Date; UseMinimumValue: Boolean; Value: Decimal): Boolean
    var
        ItemCategory: Record "Item Category";
        PlanLineFound: Boolean;
    begin
        // P8000274A - add parameter for TransactionDate
        AccrualPlanLine.Reset;
        AccrualPlanLine.SetRange("Accrual Plan Type", Type);
        AccrualPlanLine.SetRange("Accrual Plan No.", "No.");
        if ("Item Selection" > "Item Selection"::"Specific Item") then
            GetItem(ItemNo);
        case "Item Selection" of
            "Item Selection"::"All Items":
                AccrualPlanLine.SetFilter("Item Code", '%1', '');
            "Item Selection"::"Specific Item":
                AccrualPlanLine.SetFilter("Item Code", '%1', ItemNo);
            "Item Selection"::"Item Category":
                // P8007749
                if Item."Item Category Code" <> '' then begin
                    ItemCategory.Get(Item."Item Category Code");
                    AccrualPlanLine.SetFilter("Item Code", ItemCategory.GetAncestorFilterString(true));
                end else
                    AccrualPlanLine.SetRange("Item Code", '');
            // P8007749
            "Item Selection"::Manufacturer:
                AccrualPlanLine.SetFilter("Item Code", '%1', Item."Manufacturer Code");
            "Item Selection"::"Vendor No.":
                AccrualPlanLine.SetFilter("Item Code", '%1', Item."Vendor No.");
        end;
        // P8000274A
        if (TransactionDate <> 0D) then begin
            AccrualPlanLine.SetFilter("Start Date", '..%1', TransactionDate);
            AccrualPlanLine.SetFilter("End Date", '%1|%2..', 0D, TransactionDate);
        end;
        // P8000274A

        // P8000355A
        if not UseMinimumValue then
            PlanLineFound := AccrualPlanLine.Find('-')
        else begin
            ;
            AccrualPlanLine.SetFilter("Minimum Value", '<=%1', Value);
            PlanLineFound := AccrualPlanLine.Find('+');
        end;
        if "Item Selection" <> "Item Selection"::"Accrual Group" then
            exit(PlanLineFound);

        exit(AccrualGroup.IsMemberOfItemGroup(AccrualPlanLine."Item Code", ItemNo));
        // P8000355A
    end;

    local procedure DeletePlanLines()
    var
        AccrualPlanLine: Record "Accrual Plan Line";
    begin
        AccrualPlanLine.SetRange("Accrual Plan Type", Type);
        AccrualPlanLine.SetRange("Accrual Plan No.", "No.");
        AccrualPlanLine.DeleteAll(true);
    end;

    local procedure ErrorIfSourceLinesExist(FldCaption: Text[250])
    var
        AccrualSourceLine: Record "Accrual Plan Source Line";
    begin
        AccrualSourceLine.SetRange("Accrual Plan Type", Type);
        AccrualSourceLine.SetRange("Accrual Plan No.", "No.");
        if AccrualSourceLine.Find('-') then
            Error(Text003, FldCaption);
    end;

    local procedure UpdateSourceLines(FldNo: Integer)
    var
        AccrualSourceLine: Record "Accrual Plan Source Line";
    begin
        AccrualSourceLine.SetRange("Accrual Plan Type", Type);
        AccrualSourceLine.SetRange("Accrual Plan No.", "No.");
        if AccrualSourceLine.Find('-') then
            repeat
                case FldNo of
                    FieldNo("Source Selection Type"):
                        AccrualSourceLine."Source Selection Type" := "Source Selection Type";
                end;
                AccrualSourceLine.Modify(true);
            until (AccrualSourceLine.Next = 0);
    end;

    local procedure DeleteSourceLines()
    var
        AccrualSourceLine: Record "Accrual Plan Source Line";
    begin
        AccrualSourceLine.SetRange("Accrual Plan Type", Type);
        AccrualSourceLine.SetRange("Accrual Plan No.", "No.");
        AccrualSourceLine.DeleteAll(true);
    end;

    local procedure InsertSourceLine()
    var
        AccrualSourceLine: Record "Accrual Plan Source Line";
    begin
        if "No." = '' then // P8001173
            exit;            // P8001173

        AccrualSourceLine."Accrual Plan Type" := Type;
        AccrualSourceLine."Accrual Plan No." := "No.";
        AccrualSourceLine."Source Selection Type" := "Source Selection Type";
        AccrualSourceLine."Source Selection" := "Source Selection";
        AccrualSourceLine.Insert(true);
    end;

    local procedure ViewToTable(FldNo: Integer): Integer
    begin
        // P8004516
        case FldNo of
            FieldNo("Source View"):
                case Type of
                    Type::Sales:
                        exit(DATABASE::Customer);
                    Type::Purchase:
                        exit(DATABASE::Vendor);
                end;
            FieldNo("Item View"):
                exit(DATABASE::Item);
        end;
    end;

    procedure ReadView(FldNo: Integer) ViewText: Text
    var
        ViewStream: InStream;
    begin
        // P8004516
        ViewText := '';
        case FldNo of
            FieldNo("Source View"):
                begin
                    CalcFields("Source View");
                    if "Source View".HasValue then begin
                        "Source View".CreateInStream(ViewStream);
                        ViewStream.ReadText(ViewText);
                    end;
                end;

            FieldNo("Item View"):
                begin
                    CalcFields("Item View");
                    if "Item View".HasValue then begin
                        "Item View".CreateInStream(ViewStream);
                        ViewStream.ReadText(ViewText);
                    end;
                end;
        end;
    end;

    local procedure WriteView(FldNo: Integer; ViewText: Text)
    var
        ViewStream: OutStream;
    begin
        // P8004516
        case FldNo of
            FieldNo("Source View"):
                begin
                    Clear("Source View");
                    if (ViewText <> '') then begin
                        "Source View".CreateOutStream(ViewStream);
                        ViewStream.WriteText(ViewText);
                    end;
                end;
            FieldNo("Item View"):
                begin
                    Clear("Item View");
                    if (ViewText <> '') then begin
                        "Item View".CreateOutStream(ViewStream);
                        ViewStream.WriteText(ViewText);
                    end;
                end;
        end;
    end;

    procedure ClearView(FldNo: Integer)
    begin
        // P8004516
        case FldNo of
            FieldNo("Source View"):
                begin
                    CalcFields("Source View");
                    if "Source View".HasValue then
                        if Confirm(Text005, false, FieldCaption("Source View")) then begin
                            Clear("Source View");
                            Modify(true);
                        end;
                end;
            FieldNo("Item View"):
                begin
                    CalcFields("Item View");
                    if "Item View".HasValue then
                        if Confirm(Text005, false, FieldCaption("Item View")) then begin
                            Clear("Item View");
                            Modify(true);
                        end;
                end;
        end;
    end;

    procedure DefineView(FldNo: Integer)
    var
        "Table": RecordRef;
        "Key": KeyRef;
        Fld: FieldRef;
        FilterPage: FilterPageBuilder;
        SortingText: Text;
        ViewText: Text;
        FldCnt: Integer;
        Index: Integer;
    begin
        // P8004516
        Table.Open(ViewToTable(FldNo));

        FilterPage.PageCaption := StrSubstNo(Text009, Table.Caption);
        FilterPage.AddTable(Table.Caption, Table.Number);
        Key := Table.KeyIndex(1);
        SortingText := 'SORTING(';
        for FldCnt := 1 to Key.FieldCount do begin
            Fld := Key.FieldIndex(FldCnt);
            FilterPage.AddFieldNo(Table.Caption, Fld.Number);
            SortingText := SortingText + Fld.Name + ',';
        end;
        SortingText[StrLen(SortingText)] := ')';

        ViewText := ReadView(FldNo);
        if ViewText <> '' then
            FilterPage.SetView(Table.Caption, ReadView(FldNo));
        if FilterPage.RunModal then begin
            ViewText := FilterPage.GetView(Table.Caption);
            Index := StrPos(ViewText, SortingText);
            if Index = 1 then
                ViewText := DelChr(CopyStr(ViewText, StrLen(SortingText) + 1), '<');
            WriteView(FldNo, ViewText);
        end;
    end;

    procedure ShowView(FldNo: Integer)
    var
        "Table": RecordRef;
        TableVariant: Variant;
        PageManagement: Codeunit "Page Management";
        ViewText: Text;
    begin
        // P8004516
        ViewText := ReadView(FldNo);
        if ViewText = '' then
            Error(Text006);

        Table.Open(ViewToTable(FldNo));
        Table.SetView(ViewText);
        TableVariant := Table;
        PAGE.RunModal(PageManagement.GetDefaultLookupPageID(Table.Number), TableVariant);
    end;

    procedure AddViewToPlan(FldNo: Integer)
    var
        Item: Record Item;
        SourceLine: Record "Accrual Plan Source Line";
        PlanLine: Record "Accrual Plan Line";
        "Table": RecordRef;
        Fld: FieldRef;
        AddItemToPlan: Page "Add Items to Accrual Plan";
        ViewText: Text;
        SourceCode: Code[20];
        MinValue: Decimal;
    begin
        // P8004516
        ViewText := ReadView(FldNo);
        if ViewText = '' then
            Error(Text006, FieldCaption("Source View"));
        case FldNo of
            FieldNo("Source View"):
                begin
                    TestField("Source Selection", "Source Selection"::Specific);
                    Table.Open(ViewToTable(FldNo));
                    Table.SetView(ViewText);
                    if not Table.FindSet then
                        Error(Text007, Table.Caption, FieldCaption("Source View"));
                    if Confirm(Text008, false, Table.Caption, TableCaption, "No.") then begin
                        SourceLine.SetRange("Accrual Plan Type", Type);
                        SourceLine.SetRange("Accrual Plan No.", "No.");
                        repeat
                            Fld := Table.Field(1); // No. is field 1 for both customer and vendors
                            SourceCode := Fld.Value;
                            SourceLine.SetRange("Source Code", SourceCode);
                            if SourceLine.IsEmpty then begin
                                SourceLine.Init;
                                SourceLine."Accrual Plan Type" := Type;
                                SourceLine."Accrual Plan No." := "No.";
                                SourceLine."Source Code" := '';
                                SourceLine."Source Ship-to Code" := '';
                                SourceLine.SetUpNewLine(SourceLine);
                                SourceLine.Validate("Source Code", SourceCode);
                                SourceLine.Insert(true);
                            end;
                        until Table.Next = 0;
                    end;
                end;

            FieldNo("Item View"):
                begin
                    TestField("Item Selection", "Item Selection"::"Specific Item");
                    Item.SetView(ViewText);
                    if not Item.FindSet then
                        Error(Text007, Item.TableCaption, FieldCaption("Item View"));
                    if AddItemToPlan.RunModal = ACTION::OK then begin
                        MinValue := AddItemToPlan.GetMinValue;
                        repeat
                            if not PlanLine.Get(Type, "No.", Item."No.", MinValue) then begin
                                PlanLine.Init;
                                PlanLine."Accrual Plan Type" := Type;
                                PlanLine."Accrual Plan No." := "No.";
                                PlanLine."Item Code" := '';
                                PlanLine."Minimum Value" := MinValue;
                                PlanLine.SetUpNewLine(PlanLine);
                                PlanLine.Validate("Item Code", Item."No.");
                                PlanLine.Insert(true);
                            end;
                        until (Item.Next = 0);
                    end;
                end;
        end;
    end;

    procedure LoadCustomerView(var Customer: Record Customer) ViewExists: Boolean
    var
        CustomerViewText: Text;
    begin
        Customer.Reset;
        CustomerViewText := ReadView(FieldNo("Source View")); // P8004516
        if (CustomerViewText = '') then
            exit(false);
        Customer.SetView(CustomerViewText);
        exit(true);
    end;

    procedure LoadVendorView(var Vendor: Record Vendor) ViewExists: Boolean
    var
        VendorViewText: Text;
    begin
        Vendor.Reset;
        VendorViewText := ReadView(FieldNo("Source View")); // P8004516
        if (VendorViewText = '') then
            exit(false);
        Vendor.SetView(VendorViewText);
        exit(true);
    end;

    procedure LoadItemView(var Item: Record Item): Boolean
    var
        ItemViewText: Text;
    begin
        Item.Reset;
        ItemViewText := ReadView(FieldNo("Item View")); // P8004516
        if (ItemViewText = '') then
            exit(false);
        Item.SetView(ItemViewText);
        exit(true);
    end;

    local procedure DeleteScheduleLines(EntryType: Integer)
    var
        AccrualSchdLine: Record "Accrual Plan Schedule Line";
    begin
        AccrualSchdLine.SetRange("Accrual Plan Type", Type);
        AccrualSchdLine.SetRange("Accrual Plan No.", "No.");
        AccrualSchdLine.SetRange("Entry Type", EntryType);
        AccrualSchdLine.DeleteAll(true);
    end;

    procedure GetEstimatedAccrualAmount(): Decimal
    begin
        exit("Estimated Accrual Amount" + "Accrual Charge Amount");
    end;

    procedure GetEstimatedTotals(AccrualPlanType: Integer; AccrualPlanNo: Code[20]): Boolean
    begin
        if not Get(AccrualPlanType, AccrualPlanNo) then begin
            Init;
            exit(false);
        end;
        CalcEstimatedTotals;
        exit(true);
    end;

    procedure CalcEstimatedTotals()
    begin
        CalcFields("Accrual Charge Amount");
        CalcFields("Estimated Accrual Amount");
        CalcFields("Scheduled Accrual Amount");
        CalcFields("Scheduled Payment Amount");
    end;

    procedure EstimatedTotalsMatch(AccrualPlanType: Integer; AccrualPlanNo: Code[20]; EntryType: Integer): Boolean
    var
        AccrualSchdLine: Record "Accrual Plan Schedule Line";
    begin
        if not GetEstimatedTotals(AccrualPlanType, AccrualPlanNo) then
            exit(false);
        if (EntryType = AccrualSchdLine."Entry Type"::Accrual) then
            exit(GetEstimatedAccrualAmount() = "Scheduled Accrual Amount");
        exit(GetEstimatedAccrualAmount() = "Scheduled Payment Amount");
    end;

    procedure ShowScheduleLines(EntryType: Integer)
    var
        AccrualSchdLine: Record "Accrual Plan Schedule Line";
    begin
        if (EntryType = AccrualSchdLine."Entry Type"::Accrual) then
            TestField("Use Accrual Schedule", true)
        else
            TestField("Use Payment Schedule", true);
        AccrualSchdLine.ShowSchedule(Type, "No.", EntryType, '', true);
        if (EntryType = AccrualSchdLine."Entry Type"::Accrual) then
            CalcFields("Scheduled Accrual Amount")
        else
            CalcFields("Scheduled Payment Amount");
    end;

    procedure GetDocumentTransactionDate(DocHeader: Variant): Date
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        ReturnReceiptHeader: Record "Return Receipt Header";
        DocHeaderRecRef: RecordRef;
        PostingDate: Date;
        OrderDate: Date;
    begin
        // P8005495
        DocHeaderRecRef.GetTable(DocHeader);
        case DocHeaderRecRef.Number of
            DATABASE::"Sales Header":
                begin
                    SalesHeader := DocHeader;
                    PostingDate := SalesHeader."Posting Date";
                    if SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"] then
                        OrderDate := SalesHeader."Order Date";
                    // P800138545
                    if SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"] then
                        OrderDate := SalesHeader."Document Date"; // P800149934
                    // P800138545                        
                end;
            DATABASE::"Purchase Header":
                begin
                    PurchaseHeader := DocHeader;
                    PostingDate := PurchaseHeader."Posting Date";
                    if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::"Return Order"] then
                        OrderDate := PurchaseHeader."Order Date";
                    // P800138545
                    if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Invoice, PurchaseHeader."Document Type"::"Credit Memo"] then
                        OrderDate := PurchaseHeader."Document Date"; // P800149934
                    // P800138545
                end;
            DATABASE::"Sales Shipment Header":
                begin
                    SalesShipmentHeader := DocHeader;
                    PostingDate := SalesShipmentHeader."Posting Date";
                    OrderDate := SalesShipmentHeader."Order Date";
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    SalesInvoiceHeader := DocHeader;
                    PostingDate := SalesInvoiceHeader."Posting Date";
                    OrderDate := SalesInvoiceHeader."Order Date";
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader := DocHeader;
                    PostingDate := SalesCrMemoHeader."Posting Date";
                    OrderDate := SalesCrMemoHeader.GetOrderDate;
                end;
            DATABASE::"Return Receipt Header":
                begin
                    ReturnReceiptHeader := DocHeader;
                    PostingDate := ReturnReceiptHeader."Posting Date";
                    OrderDate := ReturnReceiptHeader."Order Date";
                end;
            DATABASE::"Purch. Rcpt. Header":
                begin
                    PurchRcptHeader := DocHeader;
                    PostingDate := PurchRcptHeader."Posting Date";
                    OrderDate := PurchRcptHeader."Order Date";
                end;
            DATABASE::"Purch. Inv. Header":
                begin
                    PurchInvHeader := DocHeader;
                    PostingDate := PurchInvHeader."Posting Date";
                    OrderDate := PurchInvHeader."Order Date";
                end;
            DATABASE::"Purch. Cr. Memo Hdr.":
                begin
                    PurchCrMemoHdr := DocHeader;
                    PostingDate := PurchCrMemoHdr."Posting Date";
                    OrderDate := PurchCrMemoHdr.GetOrderDate(); // P800149934
                end;
            DATABASE::"Return Shipment Header": // P80073095
                begin
                    ReturnShipmentHeader := DocHeader;
                    PostingDate := ReturnShipmentHeader."Posting Date";
                    OrderDate := ReturnShipmentHeader."Document Date"; // P800149934
                end;
        end;

        if "Date Type" = "Date Type"::"Posting Date" then
            exit(PostingDate)
        else
            exit(OrderDate);
    end;

    local procedure DeleteChargeLines()
    var
        AccrualChargeLine: Record "Accrual Charge Line";
    begin
        // P8006605
        AccrualChargeLine.SetRange("Accrual Plan Type", Type);
        AccrualChargeLine.SetRange("Accrual Plan No.", "No.");
        AccrualChargeLine.DeleteAll(true);
        // P8006605
    end;
}

