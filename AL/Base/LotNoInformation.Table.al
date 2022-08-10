table 6505 "Lot No. Information"
{
    // PR3.60.02
    //   Prohibit renaming of records
    // 
    // PR3.61.01
    //   Add permission to modify item ledger
    // 
    // PR3.70.01
    //   New Fields
    //     Receiving Reason Code
    //     Farm
    //     Brand
    //     Created From Repack
    //   Add function
    //     SourceName
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Add field for production date, item category, and alternate quantity
    //   Functions to support shortcut lot specifications
    // 
    // PR3.70.08
    // P8000165A, Myers Nissi, Jack Reynolds, 11 FEB 05
    //   Field 37002035 - Reserved Quantity - Decimal
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Expand result of SourceName function to 50 characters
    // 
    // P8000507A, VerticalSoft, Jack Reynolds, 27 AUG 07
    //   Set description from the item description
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add field for coutry/region of origin
    // 
    // PRW16.00.01
    // P8000730, VerticalSoft, Don Bresee, 24 SEP 09
    //   Add key for FEFO using Expiration Date
    // 
    // PRW16.00.04
    // P8000899, Columbus IT, Ron Davidson, 28 FEB 11
    //   Added Freshness Date field and it's calculation.
    // 
    // PRW16.00.05
    // P8000994, Columbus IT, Jack Reynolds, 04 NOV 11
    //   Update Expiration Date on Warehouse Entries
    // 
    // PRW16.00.06
    // P8001062, Columbus IT, Jack Reynolds, 26 APR 12
    //   Rename Production Date to Creation Date
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00
    // P8001132, Columbus IT, Don Bresee, 28 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.10
    // P8001201, Columbus IT, Jack Reynolds, 27 AUG 13
    //   Grant permission to modify warehouse entries
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00.01
    // P8007523, To-Increase, Dayakar Battini, 02 AUG 16
    //   Enabling "Expiration Date" updation.
    // 
    // P8007841, To-Increase, Dayakar Battini, 12 OCT 16
    //   Enabling Lot Creation and Freshness dates updation.
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW110.0.01
    // P80043725 To-Increase, Dayakar Battini, 17 JUL 17
    //   Item information updation on item validation.
    // 
    // PRW110.0.02
    // P80039780, To-Increase, Jack Reynolds, 01 DEC 17
    //   Warehouse Receiving process
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot No. Information';
    DataCaptionFields = "Item No.", "Variant Code", "Lot No.", Description;
    DrillDownPageID = "Lot No. Information List";
    LookupPageID = "Lot No. Information List";
    Permissions = TableData "Item Ledger Entry" = m,
                  TableData "Warehouse Entry" = m;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;

            trigger OnValidate()
            begin
                Item.Get("Item No.");            // P8000507A
                Description := Item.Description; // P8000507A
                "Item Category Code" := Item."Item Category Code"; // P80043725
            end;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(11; "Test Quality"; Option)
        {
            Caption = 'Test Quality';
            OptionCaption = ' ,Good,Average,Bad';
            OptionMembers = " ",Good,"Average",Bad;
        }
        field(12; "Certificate Number"; Code[20])
        {
            Caption = 'Certificate Number';
        }
        field(13; Blocked; Boolean)
        {
            Caption = 'Blocked';

            trigger OnValidate()
            begin
                if Blocked and ("Lot Status Code" <> '') then // P8001132
                    FieldError("Lot Status Code");              // P8001132
            end;
        }
        field(14; Comment; Boolean)
        {
            CalcFormula = Exist("Item Tracking Comment" WHERE(Type = CONST("Lot No."),
                                                               "Item No." = FIELD("Item No."),
                                                               "Variant Code" = FIELD("Variant Code"),
                                                               "Serial/Lot No." = FIELD("Lot No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Variant Code" = FIELD("Variant Code"),
                                                                  "Lot No." = FIELD("Lot No."),
                                                                  "Location Code" = FIELD("Location Filter")));
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(22; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(23; "Bin Filter"; Code[20])
        {
            Caption = 'Bin Filter';
            FieldClass = FlowFilter;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Filter"));
        }
        field(24; "Expired Inventory"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" WHERE("Item No." = FIELD("Item No."),
                                                                              "Variant Code" = FIELD("Variant Code"),
                                                                              "Lot No." = FIELD("Lot No."),
                                                                              "Location Code" = FIELD("Location Filter"),
                                                                              "Expiration Date" = FIELD("Date Filter"),
                                                                              Open = CONST(true),
                                                                              Positive = CONST(true)));
            Caption = 'Expired Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002020; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Description = 'PR2.00';
            Editable = false;
        }
        field(37002021; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Description = 'PR2.00';
            Editable = false;
        }
        field(37002022; "Expected Release Date"; Date)
        {
            Caption = 'Expected Release Date';
            Description = 'PR2.00';
        }
        field(37002023; "Release Date"; Date)
        {
            Caption = 'Release Date';
            Description = 'PR2.00';
            Editable = false;

            trigger OnValidate()
            begin
                // PR3.60 Begin
                ItemLedgerEntry.Reset;
                ItemLedgerEntry.SetCurrentKey("Item No.", "Variant Code", "Lot No.");
                ItemLedgerEntry.SetRange("Item No.", "Item No.");
                ItemLedgerEntry.SetRange("Variant Code", "Variant Code");
                ItemLedgerEntry.SetRange("Lot No.", "Lot No.");
                ItemLedgerEntry.SetRange(Positive, true);
                ItemLedgerEntry.ModifyAll("Release Date", "Release Date");
                // PR3.60 End
            end;
        }
        field(37002024; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            Description = 'PR2.00';

            trigger OnValidate()
            var
                WhseEntry: Record "Warehouse Entry";
                ItemTrackingCode: Record "Item Tracking Code";
            begin
                if "Expiration Date" = xRec."Expiration Date" then // P8000994
                    exit;                                            // P8000994


                // P8007523
                Item.Get("Item No.");
                ItemTrackingCode.Get(Item."Item Tracking Code");
                if ItemTrackingCode."Man. Expir. Date Entry Reqd." then
                    TestField("Expiration Date");

                if ("Creation Date" <> 0D) and ("Expiration Date" <> 0D) and ("Expiration Date" < "Creation Date") then
                    Error(BeforeDateErrorText, FieldCaption("Expiration Date"), FieldCaption("Creation Date"));

                if (GuiAllowed) and (CurrFieldNo = FieldNo("Expiration Date")) then
                    if not Confirm(ConfirmDateChangeTxt, false, FieldCaption("Expiration Date"), xRec."Expiration Date", "Expiration Date") then
                        Error(UpdateInterruptErrorText);
                // P8007523

                // PR3.60 Begin
                ItemLedgerEntry.Reset;
                ItemLedgerEntry.SetCurrentKey("Item No.", "Variant Code", "Lot No.");
                ItemLedgerEntry.SetRange("Item No.", "Item No.");
                ItemLedgerEntry.SetRange("Variant Code", "Variant Code");
                ItemLedgerEntry.SetRange("Lot No.", "Lot No.");
                ItemLedgerEntry.SetRange(Positive, true);
                ItemLedgerEntry.ModifyAll("Expiration Date", "Expiration Date");
                // PR3.60 End

                // P8000994
                WhseEntry.Reset;
                WhseEntry.SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.");
                WhseEntry.SetRange("Item No.", "Item No.");
                WhseEntry.SetRange("Variant Code", "Variant Code");
                WhseEntry.SetRange("Lot No.", "Lot No.");
                if not WhseEntry.IsEmpty then
                    WhseEntry.ModifyAll("Expiration Date", "Expiration Date");
                // P8000994
            end;
        }
        field(37002025; "Lot Strength Percent"; Decimal)
        {
            Caption = 'Lot Strength Percent';
            Description = 'PR2.00';
            Editable = false;
            InitValue = 100;
            MinValue = 0;
        }
        field(37002026; "Supplier Lot No."; Code[50])
        {
            Caption = 'Supplier Lot No.';
            Description = 'PR2.00';
        }
        field(37002027; "Source Type"; Option)
        {
            Caption = 'Source Type';
            Description = 'PR2.00';
            Editable = false;
            OptionCaption = ' ,Customer,Vendor,Item';
            OptionMembers = " ",Customer,Vendor,Item;
        }
        field(37002028; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Description = 'PR2.00';
            Editable = false;
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor;
        }
        field(37002029; "Lot Specifications"; Boolean)
        {
            CalcFormula = Exist ("Lot Specification" WHERE("Item No." = FIELD("Item No."),
                                                           "Variant Code" = FIELD("Variant Code"),
                                                           "Lot No." = FIELD("Lot No.")));
            Caption = 'Lot Specifications';
            Description = 'PR2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002030; Posted; Boolean)
        {
            Caption = 'Posted';
            Description = 'PR2.00';
            Editable = false;
        }
        field(37002031; Committed; Decimal)
        {
            Caption = 'Committed';
            Description = 'PR2.00';
        }
        field(37002032; "Quantity to Use"; Decimal)
        {
            Caption = 'Quantity to Use';
            Description = 'PR2.00';
        }
        field(37002033; "Creation Date"; Date)
        {
            Caption = 'Creation Date';

            trigger OnValidate()
            begin
                // P8000153A
                if GuiAllowed then // P80039780
                    xRec.TestField("Creation Date", 0D);
                //TESTFIELD(Posted,TRUE); // P80039780
                if "Creation Date" > Today then
                    FieldError("Creation Date", Text37002001);

                // P8007841
                if ("Document Date" <> 0D) and ("Creation Date" > "Document Date") then // P80039780
                    Error(BeforeDateErrorText, FieldCaption("Document Date"), FieldCaption("Creation Date"));

                if (GuiAllowed) and (CurrFieldNo = FieldNo("Creation Date")) then
                    if not Confirm(ConfirmDateChangeTxt, false, FieldCaption("Creation Date"), xRec."Creation Date", "Creation Date") then
                        Error(UpdateInterruptErrorText);
                // P8007841

                "Freshness Date" := P800ItemTrack.CalcFreshDate(Rec); // P8000899
            end;
        }
        field(37002034; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            Editable = false;
            TableRelation = "Item Category";
        }
        field(37002035; "Reserved Quantity"; Decimal)
        {
            CalcFormula = Sum ("Reservation Entry"."Quantity (Base)" WHERE("Reservation Status" = CONST(Reservation),
                                                                           "Item No." = FIELD("Item No."),
                                                                           "Variant Code" = FIELD("Variant Code"),
                                                                           "Lot No." = FIELD("Lot No."),
                                                                           "Source Type" = CONST(32),
                                                                           "Location Code" = FIELD("Location Filter")));
            Caption = 'Reserved Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002036; "Lot Status Code"; Code[10])
        {
            Caption = 'Lot Status Code';
            TableRelation = "Lot Status Code";

            trigger OnValidate()
            var
                InvSetup: Record "Inventory Setup";
            begin
                // P8001083
                if CurrFieldNo = FieldNo("Lot Status Code") then begin
                    InvSetup.Get;
                    if InvSetup."Quarantine Lot Status" = '' then
                        exit;
                    if xRec."Lot Status Code" = InvSetup."Quarantine Lot Status" then
                        FieldError("Lot Status Code", StrSubstNo(Text37002002, InvSetup."Quarantine Lot Status"));
                    if Rec."Lot Status Code" = InvSetup."Quarantine Lot Status" then
                        FieldError("Lot Status Code", StrSubstNo(Text37002003, InvSetup."Quarantine Lot Status"));
                end;
                if Blocked and ("Lot Status Code" <> '') then // P8001132
                    FieldError(Blocked);                        // P8001132
            end;
        }
        field(37002050; "Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            CalcFormula = Sum ("Item Ledger Entry"."Quantity (Alt.)" WHERE("Item No." = FIELD("Item No."),
                                                                           "Variant Code" = FIELD("Variant Code"),
                                                                           "Lot No." = FIELD("Lot No."),
                                                                           "Location Code" = FIELD("Location Filter")));
            CaptionClass = StrSubstNo('37002080,0,0,%1', "Item No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002540; "Quality Control"; Boolean)
        {
            CalcFormula = Exist ("Quality Control Header" WHERE("Item No." = FIELD("Item No."),
                                                                "Variant Code" = FIELD("Variant Code"),
                                                                "Lot No." = FIELD("Lot No.")));
            Caption = 'Quality Control';
            Description = 'PR2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002660; "Receiving Reason Code"; Code[10])
        {
            Caption = 'Receiving Reason Code';
            Description = 'PR3.70.01';
            TableRelation = "Reason Code";
        }
        field(37002661; Farm; Text[30])
        {
            Caption = 'Farm';
            Description = 'PR3.70.01';
        }
        field(37002662; Brand; Text[30])
        {
            Caption = 'Brand';
            Description = 'PR3.70.01';
        }
        field(37002663; "Created From Repack"; Boolean)
        {
            Caption = 'Created From Repack';
            Description = 'PR3.70.01';
        }
        field(37002664; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                // P8000624A
                if "Country/Region of Origin Code" = '' then begin
                    Item.Get("Item No.");
                    if Item."Country/Region of Origin Reqd." then
                        TestField("Country/Region of Origin Code");
                end;
            end;
        }
        field(37002665; "Freshness Date"; Date)
        {
            Caption = 'Freshness Date';

            trigger OnValidate()
            begin
                // P8007841
                TestField("Creation Date");
                if "Creation Date" > "Freshness Date" then
                    Error(BeforeDateErrorText, FieldCaption("Freshness Date"), FieldCaption("Creation Date"));

                if (GuiAllowed) and (CurrFieldNo = FieldNo("Freshness Date")) then
                    if not Confirm(ConfirmDateChangeTxt, false, FieldCaption("Freshness Date"), xRec."Freshness Date", "Freshness Date") then
                        Error(UpdateInterruptErrorText);
                // P8007841
            end;
        }
        field(37002760; "Inventory (Warehouse)"; Decimal)
        {
            CalcFormula = Sum ("Warehouse Entry"."Qty. (Base)" WHERE("Item No." = FIELD("Item No."),
                                                                     "Variant Code" = FIELD("Variant Code"),
                                                                     "Unit of Measure Code" = FIELD("Unit of Measure Filter"),
                                                                     "Lot No." = FIELD("Lot No."),
                                                                     "Location Code" = FIELD("Location Filter"),
                                                                     "Bin Code" = FIELD("Bin Filter")));
            Caption = 'Inventory (Warehouse)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002761; "Unit of Measure Filter"; Code[10])
        {
            Caption = 'Unit of Measure Filter';
            FieldClass = FlowFilter;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Lot No.")
        {
            Clustered = true;
        }
        key(Key2; "Lot No.")
        {
            Enabled = false;
        }
        key(Key3; "Document No.")
        {
        }
        key(Key4; "Item Category Code", "Item No.", "Creation Date", "Variant Code", "Lot No.")
        {
        }
        key(Key5; "Item No.", "Variant Code", "Expiration Date")
        {
        }
        key(Key6; "Lot Status Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Item No.", "Variant Code", "Lot No.")
        {
        }
    }

    trigger OnDelete()
    begin
        ItemTrackingComment.SetRange(Type, ItemTrackingComment.Type::"Lot No.");
        ItemTrackingComment.SetRange("Item No.", "Item No.");
        ItemTrackingComment.SetRange("Variant Code", "Variant Code");
        ItemTrackingComment.SetRange("Serial/Lot No.", "Lot No.");
        ItemTrackingComment.DeleteAll();
    end;

    trigger OnModify()
    begin
        LotStatusMgmt.ChangeLotStatus(xRec, Rec); // P8001083
    end;

    trigger OnRename()
    begin
        Error(Text37002000, TableCaption); // PR3.60.02
    end;

    var
        ItemTrackingComment: Record "Item Tracking Comment";
        ItemLedgerEntry: Record "Item Ledger Entry";
        LotSpecFns: Codeunit "Lot Specification Functions";
        Text37002000: Label 'You cannot rename a %1.';
        Text37002001: Label 'may not be in the future';
        Item: Record Item;
        P800ItemTrack: Codeunit "Process 800 Item Tracking";
        LotStatusMgmt: Codeunit "Lot Status Management";
        Text37002002: Label 'may not be changed from %1';
        Text37002003: Label 'may not be changed to %1';
        ConfirmDateChangeTxt: Label 'Do you want to change the %1 from %2 to %3?.';
        UpdateInterruptErrorText: Label 'The update has been interrupted to respect the warning.';
        BeforeDateErrorText: Label '%1 may not be before %2.';

    procedure Navigate()
    var
        NavigateForm: Page Navigate;
    begin
        // PR2.00 Begin
        NavigateForm.SetDoc("Document Date", "Document No.");
        NavigateForm.Run;
        // PR2.00 End
    end;

    procedure SourceName(): Text[100]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
    begin
        // PR3.70.01
        // P8000466A - expand result to TEXT50
        case "Source Type" of
            "Source Type"::Customer:
                begin
                    if Customer.Get("Source No.") then
                        exit(Customer.Name);
                end;
            "Source Type"::Vendor:
                begin
                    if Vendor.Get("Source No.") then
                        exit(Vendor.Name);
                end;
            "Source Type"::Item:
                begin
                    if Item.Get("Source No.") then
                        exit(Item.Description);
                end;
        end;
    end;

    procedure ShowShortcutLotSpec(var ShortcutLotSpec: array[5] of Code[50])
    begin
        // P8000153A
        LotSpecFns.ShowShortcutLotSpec("Item No.", "Variant Code", "Lot No.", ShortcutLotSpec);
    end;

    procedure SetDefaultStatus(ItemJnlLine: Record "Item Journal Line")
    begin
        // P8001083
        if "Lot Status Code" <> '' then
            exit;

        LotStatusMgmt.SetDefaultStatusForLot(Rec, ItemJnlLine);
    end;

    procedure ActivityCount(ReTest: Boolean): Integer
    var
        QCHeader: Record "Quality Control Header";
    begin
        QCHeader.SetRange("Item No.",Rec."Item No.");
        QCHeader.SetRange("Variant Code",Rec."Variant Code");
        QCHeader.SetRange("Lot No.",Rec."Lot No.");
        // QCHeader.SetRecFilter();
        QCHeader.SetRange("Re-Test", ReTest);
        exit(QCHeader.Count())
    end;
}

