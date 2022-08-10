table 311 "Sales & Receivables Setup"
{
    // PR3.60
    //   New Fields
    //     Standing Order Nos.
    //     Copy Cmts Standing to Order
    // 
    // PR3.70.01
    //   New Fields
    //     Recent Sales Calculation
    // 
    // PR3.70.07
    // P8000126A, Myers Nissi, Steve Post, 07 OCT 04
    //   Support for minimum order
    // 
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // P8000185B, Myers Nissi, Jack Reynolds, 16 FEB 05
    //   Change Minimum Order Basis to remove None as an option
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Support for trip management
    // 
    // PRW15.00.03
    // P8000644, VerticalSoft, Jack Reynolds, 25 NOV 08
    //   Add fields for Delivery Trip Unit of Weight and Volume
    // 
    // PRW16.00.04
    // P8000885, VerticalSoft, Ron Davidson, 27 DEC 10
    //   Added new field to control Sales Contract Nos
    // 
    // PRW16.00.05
    // P8000921, Columbus IT, Don Bresee, 07 APR 11
    //   Add Delivered Pricing fields and logic
    // 
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // P8000944, Columbus IT, Jack Reynolds, 23 MAY 11
    //   Field for terminal market item availability detail level
    // 
    // PRW16.00.06
    // P8001026, Columbus IT, Jack Reynolds, 26 JAN 12
    //   Option to use Sell-to Customer Price Group
    // 
    // PRW18.00.02
    // P8002750, to-Increase, Jack Reynolds, 26 OCT 15
    //   Allow option to keep deductions with original customer
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Change TableRelation references to Object table
    // 
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    //   Correct misspellings
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Sales & Receivables Setup';
    DrillDownPageID = "Sales & Receivables Setup";
    LookupPageID = "Sales & Receivables Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Discount Posting"; Option)
        {
            Caption = 'Discount Posting';
            OptionCaption = 'No Discounts,Invoice Discounts,Line Discounts,All Discounts';
            OptionMembers = "No Discounts","Invoice Discounts","Line Discounts","All Discounts";

            trigger OnValidate()
            var
                DiscountNotificationMgt: Codeunit "Discount Notification Mgt.";
            begin
                DiscountNotificationMgt.NotifyAboutMissingSetup(RecordId, '', "Discount Posting", 0);
            end;
        }
        field(4; "Credit Warnings"; Option)
        {
            Caption = 'Credit Warnings';
            OptionCaption = 'Both Warnings,Credit Limit,Overdue Balance,No Warning';
            OptionMembers = "Both Warnings","Credit Limit","Overdue Balance","No Warning";
        }
        field(5; "Stockout Warning"; Boolean)
        {
            Caption = 'Stockout Warning';
            InitValue = true;
        }
        field(6; "Shipment on Invoice"; Boolean)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Shipment on Invoice';
        }
        field(7; "Invoice Rounding"; Boolean)
        {
            Caption = 'Invoice Rounding';
        }
        field(8; "Ext. Doc. No. Mandatory"; Boolean)
        {
            Caption = 'Ext. Doc. No. Mandatory';
        }
        field(9; "Customer Nos."; Code[20])
        {
            Caption = 'Customer Nos.';
            TableRelation = "No. Series";
        }
        field(10; "Quote Nos."; Code[20])
        {
            Caption = 'Quote Nos.';
            TableRelation = "No. Series";
        }
        field(11; "Order Nos."; Code[20])
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Order Nos.';
            TableRelation = "No. Series";
        }
        field(12; "Invoice Nos."; Code[20])
        {
            Caption = 'Invoice Nos.';
            TableRelation = "No. Series";
        }
        field(13; "Posted Invoice Nos."; Code[20])
        {
            Caption = 'Posted Invoice Nos.';
            TableRelation = "No. Series";
        }
        field(14; "Credit Memo Nos."; Code[20])
        {
            Caption = 'Credit Memo Nos.';
            TableRelation = "No. Series";
        }
        field(15; "Posted Credit Memo Nos."; Code[20])
        {
            Caption = 'Posted Credit Memo Nos.';
            TableRelation = "No. Series";
        }
        field(16; "Posted Shipment Nos."; Code[20])
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Posted Shipment Nos.';
            TableRelation = "No. Series";
        }
        field(17; "Reminder Nos."; Code[20])
        {
            Caption = 'Reminder Nos.';
            TableRelation = "No. Series";
        }
        field(18; "Issued Reminder Nos."; Code[20])
        {
            Caption = 'Issued Reminder Nos.';
            TableRelation = "No. Series";
        }
        field(19; "Fin. Chrg. Memo Nos."; Code[20])
        {
            Caption = 'Fin. Chrg. Memo Nos.';
            TableRelation = "No. Series";
        }
        field(20; "Issued Fin. Chrg. M. Nos."; Code[20])
        {
            Caption = 'Issued Fin. Chrg. M. Nos.';
            TableRelation = "No. Series";
        }
        field(21; "Posted Prepmt. Inv. Nos."; Code[20])
        {
            Caption = 'Posted Prepmt. Inv. Nos.';
            TableRelation = "No. Series";
        }
        field(22; "Posted Prepmt. Cr. Memo Nos."; Code[20])
        {
            Caption = 'Posted Prepmt. Cr. Memo Nos.';
            TableRelation = "No. Series";
        }
        field(23; "Blanket Order Nos."; Code[20])
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Blanket Order Nos.';
            TableRelation = "No. Series";
        }
        field(24; "Calc. Inv. Discount"; Boolean)
        {
            Caption = 'Calc. Inv. Discount';
        }
        field(25; "Appln. between Currencies"; Option)
        {
            AccessByPermission = TableData Currency = R;
            Caption = 'Appln. between Currencies';
            OptionCaption = 'None,EMU,All';
            OptionMembers = "None",EMU,All;
        }
        field(26; "Copy Comments Blanket to Order"; Boolean)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Copy Comments Blanket to Order';
            InitValue = true;
        }
        field(27; "Copy Comments Order to Invoice"; Boolean)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Copy Comments Order to Invoice';
            InitValue = true;
        }
        field(28; "Copy Comments Order to Shpt."; Boolean)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Copy Comments Order to Shpt.';
            InitValue = true;
        }
        field(29; "Allow VAT Difference"; Boolean)
        {
            Caption = 'Allow VAT Difference';
        }
        field(30; "Calc. Inv. Disc. per VAT ID"; Boolean)
        {
            Caption = 'Calc. Inv. Disc. per VAT ID';
        }
        field(31; "Logo Position on Documents"; Option)
        {
            Caption = 'Logo Position on Documents';
            OptionCaption = 'No Logo,Left,Center,Right';
            OptionMembers = "No Logo",Left,Center,Right;
        }
        field(32; "Check Prepmt. when Posting"; Boolean)
        {
            Caption = 'Check Prepmt. when Posting';
        }
        field(33; "Prepmt. Auto Update Frequency"; Option)
        {
            Caption = 'Prepmt. Auto Update Frequency';
            DataClassification = SystemMetadata;
            OptionCaption = 'Never,Daily,Weekly';
            OptionMembers = Never,Daily,Weekly;

            trigger OnValidate()
            var
                PrepaymentMgt: Codeunit "Prepayment Mgt.";
            begin
                if "Prepmt. Auto Update Frequency" = xRec."Prepmt. Auto Update Frequency" then
                    exit;

                PrepaymentMgt.CreateAndStartJobQueueEntrySales("Prepmt. Auto Update Frequency");
            end;
        }
        field(35; "Default Posting Date"; Enum "Default Posting Date")
        {
            Caption = 'Default Posting Date';
        }
        field(36; "Default Quantity to Ship"; Option)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            Caption = 'Default Quantity to Ship';
            OptionCaption = 'Remainder,Blank';
            OptionMembers = Remainder,Blank;
        }
        field(37; "Archive Quotes and Orders"; Boolean)
        {
            Caption = 'Archive Quotes and Orders';
            ObsoleteReason = 'Replaced by new fields Archive Quotes and Archive Orders';
            ObsoleteState = Removed;
            ObsoleteTag = '18.0';
        }
        field(38; "Post with Job Queue"; Boolean)
        {
            Caption = 'Post with Job Queue';

            trigger OnValidate()
            begin
                if not "Post with Job Queue" then
                    "Post & Print with Job Queue" := false;
            end;
        }
        field(39; "Job Queue Category Code"; Code[10])
        {
            Caption = 'Job Queue Category Code';
            TableRelation = "Job Queue Category";
        }
        field(40; "Job Queue Priority for Post"; Integer)
        {
            Caption = 'Job Queue Priority for Post';
            InitValue = 1000;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Job Queue Priority for Post" < 0 then
                    Error(Text001);
            end;
        }
        field(41; "Post & Print with Job Queue"; Boolean)
        {
            Caption = 'Post & Print with Job Queue';

            trigger OnValidate()
            begin
                if "Post & Print with Job Queue" then
                    "Post with Job Queue" := true;
            end;
        }
        field(42; "Job Q. Prio. for Post & Print"; Integer)
        {
            Caption = 'Job Q. Prio. for Post & Print';
            InitValue = 1000;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Job Queue Priority for Post" < 0 then
                    Error(Text001);
            end;
        }
        field(43; "Notify On Success"; Boolean)
        {
            Caption = 'Notify On Success';
        }
        field(44; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            TableRelation = "VAT Business Posting Group";
        }
        field(45; "Direct Debit Mandate Nos."; Code[20])
        {
            Caption = 'Direct Debit Mandate Nos.';
            TableRelation = "No. Series";
        }
        field(46; "Allow Document Deletion Before"; Date)
        {
            Caption = 'Allow Document Deletion Before';
        }
        field(47; "Report Output Type"; Option)
        {
            Caption = 'Report Output Type';
            DataClassification = CustomerContent;
            OptionCaption = 'PDF,,,Print';
            OptionMembers = PDF,,,Print;

            trigger OnValidate()
            var
                EnvironmentInformation: Codeunit "Environment Information";
            begin
                if "Report Output Type" = "Report Output Type"::Print then
                    if EnvironmentInformation.IsSaaS then
                        TestField("Report Output Type", "Report Output Type"::PDF);
            end;
        }
        field(49; "Document Default Line Type"; Enum "Sales Line Type")
        {
            Caption = 'Document Default Line Type';
        }
        field(50; "Default Item Quantity"; Boolean)
        {
            Caption = 'Default Item Quantity';
        }
        field(51; "Create Item from Description"; Boolean)
        {
            Caption = 'Create Item from Description';
        }
        field(52; "Archive Quotes"; Option)
        {
            Caption = 'Archive Quotes';
            OptionCaption = 'Never,Question,Always';
            OptionMembers = Never,Question,Always;
        }
        field(53; "Archive Orders"; Boolean)
        {
            Caption = 'Archive Orders';
        }
        field(54; "Archive Blanket Orders"; Boolean)
        {
            Caption = 'Archive Blanket Orders';
        }
        field(55; "Archive Return Orders"; Boolean)
        {
            Caption = 'Archive Return Orders';
        }
        field(57; "Create Item from Item No."; Boolean)
        {
            Caption = 'Create Item from Item No.';
        }
        field(58; "Copy Customer Name to Entries"; Boolean)
        {
            Caption = 'Copy Customer Name to Entries';

            trigger OnValidate()
            var
                UpdateNameInLedgerEntries: Codeunit "Update Name In Ledger Entries";
            begin
                if "Copy Customer Name to Entries" then
                    UpdateNameInLedgerEntries.NotifyAboutBlankNamesInLedgerEntries(RecordId);
            end;
        }
        field(60; "Batch Archiving Quotes"; Boolean)
        {
            Caption = 'Batch Archiving Quotes';
        }
        field(61; "Ignore Updated Addresses"; Boolean)
        {
            Caption = 'Ignore Updated Addresses';
        }
        field(65; "Skip Manual Reservation"; Boolean)
        {
            Caption = 'Skip Manual Reservation';
            DataClassification = SystemMetadata;
        }
        field(170; "Insert Std. Sales Lines Mode"; Option)
        {
            Caption = 'Insert Std. Sales Lines Mode';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Not needed after refactoring';
            ObsoleteState = Removed;
            OptionCaption = 'Manual,Automatic,Always Ask';
            OptionMembers = Manual,Automatic,"Always Ask";
            ObsoleteTag = '18.0';
        }
        field(171; "Insert Std. Lines on Quotes"; Boolean)
        {
            Caption = 'Insert Std. Lines on Quotes';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Not needed after refactoring';
            ObsoleteState = Removed;
            ObsoleteTag = '18.0';
        }
        field(172; "Insert Std. Lines on Orders"; Boolean)
        {
            Caption = 'Insert Std. Lines on Orders';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Not needed after refactoring';
            ObsoleteState = Removed;
            ObsoleteTag = '18.0';
        }
        field(173; "Insert Std. Lines on Invoices"; Boolean)
        {
            Caption = 'Insert Std. Lines on Invoices';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Not needed after refactoring';
            ObsoleteState = Removed;
            ObsoleteTag = '18.0';
        }
        field(174; "Insert Std. Lines on Cr. Memos"; Boolean)
        {
            Caption = 'Insert Std. Lines on Cr. Memos';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Not needed after refactoring';
            ObsoleteState = Removed;
            ObsoleteTag = '18.0';
        }
        field(200; "Quote Validity Calculation"; DateFormula)
        {
            Caption = 'Quote Validity Calculation';
            DataClassification = SystemMetadata;
        }
        field(210; "Copy Line Descr. to G/L Entry"; Boolean)
        {
            Caption = 'Copy Line Descr. to G/L Entry';
            DataClassification = SystemMetadata;
        }
        field(393; "Canceled Issued Reminder Nos."; Code[20])
        {
            Caption = 'Canceled Issued Reminder Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(395; "Canc. Iss. Fin. Ch. Mem. Nos."; Code[20])
        {
            Caption = 'Canceled Issued Fin. Charge Memo Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(810; "Invoice Posting Setup"; Enum "Sales Invoice Posting")
        {
            Caption = 'Invoice Posting Setup';

            trigger OnValidate()
            var
                AllObjWithCaption: Record AllObjWithCaption;
                EnvironmentInfo: Codeunit "Environment Information";
                InvoicePostingInterface: Interface "Invoice Posting";
            begin
                if "Invoice Posting Setup" <> "Sales Invoice Posting"::"Invoice Posting (Default)" then begin
                    if EnvironmentInfo.IsProduction() then
                        error(InvoicePostingNotAllowedErr);

                    AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Codeunit, "Invoice Posting Setup".AsInteger());
                    InvoicePostingInterface := "Invoice Posting Setup";
                    InvoicePostingInterface.Check(Database::"Sales Header");
                end;
            end;
        }
        field(5329; "Write-in Product Type"; Option)
        {
            Caption = 'Write-in Product Type';
            OptionCaption = 'Item,Resource';
            OptionMembers = Item,Resource;
        }
        field(5330; "Write-in Product No."; Code[20])
        {
            Caption = 'Write-in Product No.';
            TableRelation = IF ("Write-in Product Type" = CONST(Item)) Item."No." WHERE(Type = FILTER(Service | "Non-Inventory"))
            ELSE
            IF ("Write-in Product Type" = CONST(Resource)) Resource."No.";

            trigger OnValidate()
            var
                Item: Record Item;
                Resource: Record Resource;
                CRMIntegrationRecord: Record "CRM Integration Record";
                CRMProductName: Codeunit "CRM Product Name";
                RecId: RecordId;
            begin
                case "Write-in Product Type" of
                    "Write-in Product Type"::Item:
                        begin
                            if not Item.Get("Write-in Product No.") then
                                exit;
                            RecId := Item.RecordId();
                        end;
                    "Write-in Product Type"::Resource:
                        begin
                            if not Resource.Get("Write-in Product No.") then
                                exit;
                            RecId := Resource.RecordId();
                        end;
                end;
                if CRMIntegrationRecord.FindByRecordID(RecId) then
                    Error(ProductCoupledErr, CRMProductName.Short());
            end;
        }
        field(5800; "Posted Return Receipt Nos."; Code[20])
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            Caption = 'Posted Return Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(5801; "Copy Cmts Ret.Ord. to Ret.Rcpt"; Boolean)
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            Caption = 'Copy Cmts Ret.Ord. to Ret.Rcpt';
            InitValue = true;
        }
        field(5802; "Copy Cmts Ret.Ord. to Cr. Memo"; Boolean)
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            Caption = 'Copy Cmts Ret.Ord. to Cr. Memo';
            InitValue = true;
        }
        field(6600; "Return Order Nos."; Code[20])
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            Caption = 'Return Order Nos.';
            TableRelation = "No. Series";
        }
        field(6601; "Return Receipt on Credit Memo"; Boolean)
        {
            AccessByPermission = TableData "Return Receipt Header" = R;
            Caption = 'Return Receipt on Credit Memo';
        }
        field(6602; "Exact Cost Reversing Mandatory"; Boolean)
        {
            Caption = 'Exact Cost Reversing Mandatory';
        }
        field(7000; "Price Calculation Method"; Enum "Price Calculation Method")
        {
            Caption = 'Price Calculation Method';
            InitValue = "Lowest Price";

            trigger OnValidate()
            var
                PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
                PriceType: Enum "Price Type";
            begin
                PriceCalculationMgt.VerifyMethodImplemented("Price Calculation Method", PriceType::Sale);
            end;
        }
        field(7001; "Price List Nos."; Code[20])
        {
            Caption = 'Price List Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(7002; "Allow Editing Active Price"; Boolean)
        {
            Caption = 'Allow Editing Active Price';
            DataClassification = SystemMetadata;
        }
        field(7003; "Default Price List Code"; Code[20])
        {
            Caption = 'Default Price List Code';
            TableRelation = "Price List Header" where("Price Type" = Const(Sale), "Source Group" = Const(Customer), "Allow Updating Defaults" = const(true));
            DataClassification = CustomerContent;
            trigger OnLookup()
            var
                PriceListHeader: Record "Price List Header";
            begin
                if Page.RunModal(Page::"Sales Price Lists", PriceListHeader) = Action::LookupOK then begin
                    PriceListHeader.TestField("Allow Updating Defaults");
                    Validate("Default Price List Code", PriceListHeader.Code);
                end;
            end;
        }
        field(7101; "Customer Group Dimension Code"; Code[20])
        {
            Caption = 'Customer Group Dimension Code';
            TableRelation = Dimension;
        }
        field(7102; "Salesperson Dimension Code"; Code[20])
        {
            Caption = 'Salesperson Dimension Code';
            TableRelation = Dimension;
        }
        field(7103; "Freight G/L Acc. No."; Code[20])
        {
            Caption = 'Freight G/L Account No.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAccPostingTypeBlockedAndGenProdPostingType("Freight G/L Acc. No.");
            end;
        }
        field(37002000; "Minimum Order Basis"; Option)
        {
            Caption = 'Minimum Order Basis';
            Description = 'P8000126A';
            OptionCaption = ' ,,Amount,Weight,Quantity';
            OptionMembers = " ",,Amount,Weight,Quantity;

            trigger OnValidate()
            begin
                // P8000126A
                if ("Minimum Order Basis" <> xRec."Minimum Order Basis") or
                   ("Minimum Order Basis" = "Minimum Order Basis"::" ") then begin  // P8000185B
                    "Minimum Order Unit of Measure" := '';
                    "Minimum Order Amount" := 0;
                end;
            end;
        }
        field(37002001; "Minimum Order Amount"; Decimal)
        {
            Caption = 'Minimum Order Amount';
            DecimalPlaces = 0 : 5;
            Description = 'P8000126A';
        }
        field(37002002; "Minimum Order Unit of Measure"; Code[10])
        {
            Caption = 'Minimum Order Unit of Measure';
            Description = 'P8000126A';
            TableRelation = IF ("Minimum Order Basis" = CONST(Weight)) "Unit of Measure" WHERE(Type = CONST(Weight));

            trigger OnValidate()
            begin
                // P8000126A
                if "Minimum Order Unit of Measure" <> '' then
                    TestField("Minimum Order Basis", "Minimum Order Basis"::Weight);
            end;
        }
        field(37002040; "Default Customer Price Group"; Option)
        {
            Caption = 'Default Customer Price Group';
            OptionCaption = 'Bill-to,Sell-to';
            OptionMembers = "Bill-to","Sell-to";
        }
        field(37002049; "Delivered Pricing Calc. Method"; Option)
        {
            Caption = 'Delivered Pricing Calc. Method';
            OptionCaption = 'None,Header,Line';
            OptionMembers = "None",Header,Line;

            trigger OnValidate()
            begin
                // P8000921
                if ("Delivered Pricing Calc. Method" <> xRec."Delivered Pricing Calc. Method") then
                    Validate("Del. Pricing Calc. Codeunit ID", 0);
                "Calc. Freight on Release/Post" := ("Delivered Pricing Calc. Method" = "Delivered Pricing Calc. Method"::Header);
            end;
        }
        field(37002050; "Del. Pricing Calc. Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Del. Pricing Calc. Codeunit ID';
            MinValue = 0;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));

            trigger OnValidate()
            var
                Process800Utility: Codeunit "Process 800 Utility Functions";
                CodeunitDescription: Label 'Delivered Pricing Calculation';
            begin
                // P8000921
                if ("Del. Pricing Calc. Codeunit ID" <> 0) then
                    TestField("Delivered Pricing Calc. Method");
                case "Delivered Pricing Calc. Method" of
                    "Delivered Pricing Calc. Method"::Header:
                        Process800Utility.CheckCodeunitTable("Del. Pricing Calc. Codeunit ID", Database::"Sales Header", CodeunitDescription);
                    "Delivered Pricing Calc. Method"::Line:
                        Process800Utility.CheckCodeunitTable("Del. Pricing Calc. Codeunit ID", Database::"Sales Line", CodeunitDescription);
                end;
            end;
        }
        field(37002051; "Calc. Freight on Release/Post"; Boolean)
        {
            Caption = 'Calc. Freight on Release/Post';
        }
        field(37002060; "Standing Order Nos."; Code[20])
        {
            Caption = 'Standing Order Nos.';
            Description = 'PR3.60';
            TableRelation = "No. Series";
        }
        field(37002061; "Copy Cmts Standing to Order"; Boolean)
        {
            Caption = 'Copy Cmts Standing to Order';
            Description = 'PR3.60';
            InitValue = true;
        }
        field(37002190; "Deduction Management Cust. No."; Code[20])
        {
            Caption = 'Deduction Management Cust. No.';
            Description = 'PR3.70.08';
            TableRelation = Customer;

            trigger OnValidate()
            var
                CustLedgerEntry: Record "Cust. Ledger Entry";
            begin
                // P8002750
                if ("Deduction Management Cust. No." = '') and (xRec."Deduction Management Cust. No." <> '') then begin
                    CustLedgerEntry.SetRange("Customer No.", xRec."Deduction Management Cust. No.");
                    CustLedgerEntry.SetRange(Open, true);
                    if not CustLedgerEntry.IsEmpty then
                        Error(Text37002000, xRec."Deduction Management Cust. No.");
                    "Resolve Ded. With Orig. Cust." := false;
                end else
                    if ("Deduction Management Cust. No." <> '') and (xRec."Deduction Management Cust. No." = '') then begin
                        CustLedgerEntry.SetRange("Unresolved Deduction", true);
                        if not CustLedgerEntry.IsEmpty then
                            Error(Text37002001);
                    end;
                // P8002750
            end;
        }
        field(37002191; "Deduction Management Doc. Nos."; Code[20])
        {
            Caption = 'Deduction Management Doc. Nos.';
            Description = 'PR3.70.08';
            TableRelation = "No. Series";
        }
        field(37002192; "Resolve Ded. With Orig. Cust."; Boolean)
        {
            Caption = 'Resolve Ded. With Orig. Cust.';
            Description = 'PR3.70.08';

            trigger OnValidate()
            begin
                // P8002750
                TestField("Deduction Management Cust. No.");
                // P8002750
            end;
        }
        field(37002660; "Recent Sales Calculation"; DateFormula)
        {
            Caption = 'Recent Sales Calculation';
            Description = 'PR3.70.01';
        }
        field(37002661; "Sales Contract Nos."; Code[20])
        {
            Caption = 'Sales Contract Nos.';
            Description = 'PRW16.00.04';
            TableRelation = "No. Series";
        }
        field(37002662; "Sales Contracts Mandatory"; Boolean)
        {
            Caption = 'Sales Contracts Mandatory';
            Description = 'PRW16.00.04';
        }
        field(37002671; "Sales Payment Nos."; Code[20])
        {
            Caption = 'Sales Payment Nos.';
            TableRelation = "No. Series";
        }
        field(37002672; "Posted Sales Payment Nos."; Code[20])
        {
            Caption = 'Posted Sales Payment Nos.';
            TableRelation = "No. Series";
        }
        field(37002673; "Terminal Market Item Level"; Option)
        {
            Caption = 'Terminal Market Item Level';
            OptionCaption = 'Lot,Item/Variant/Country of Origin,Item/Variant';
            OptionMembers = Lot,"Item/Variant/Country of Origin","Item/Variant";
        }
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
        Text001: Label 'Job Queue Priority must be zero or positive.';
        ProductCoupledErr: Label 'You must choose a record that is not coupled to a product in %1.', Comment = '%1 - Dynamics 365 Sales product name';
        InvoicePostingNotAllowedErr: Label 'Use of alternative invoice posting interfaces in production environment is currently not allowed.';
        RecordHasBeenRead: Boolean;
        Text37002000: Label 'Open entries for Customer "%1" must be resolved.';
        Text37002001: Label 'Unresolved deductions exist.';

    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        Get;
        RecordHasBeenRead := true;
    end;

    procedure GetLegalStatement(): Text
    begin
        exit('');
    end;

    procedure JobQueueActive(): Boolean
    begin
        Get;
        exit("Post with Job Queue" or "Post & Print with Job Queue");
    end;

    local procedure CheckGLAccPostingTypeBlockedAndGenProdPostingType(AccNo: Code[20])
    var
        GLAcc: Record "G/L Account";
    begin
        if AccNo <> '' then begin
            GLAcc.Get(AccNo);
            GLAcc.CheckGLAcc;
        end;
    end;
}

