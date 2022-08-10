table 37002465 "Unapproved Item"
{
    // PR1.00, Myers Nissi, Jack Reynolds, 30 JUL 00, PR007
    //   Field 1 - No. - Code 20
    //   Field 2 - Description - Text 30
    //   Field 3 - Description 2 - Text 30
    //   Field 4 - Search Description - Code 30
    //   Field 5 - Base Unit of Measure - Code 10 - relate to Unapproved Item Unit
    //     of Measure
    //   Field 6 - Weight UOM - Code 10 - relate to Unapproved Item Unit
    //     of Measure
    //   Field 7 - Volume UOM - Code 10 - relate to Unapproved Item Unit
    //     of Measure
    //   Field 8 - Unit Cost - Decimal
    //   Field 9 - Comment - Boolean - FlowField (if any coments exist)
    //   Field 10 - Last Date Modified - Date
    //   Field 11 - No. Series - Code 10 - relate to No. Series
    //   PrimaryKey - No.
    //   LookupformID - Unapproved Item List
    // 
    // PR1.10.04
    //   Set DataCaptionFields
    // 
    // PR2.00
    //   Text constants
    // 
    // PR3.70
    //   Unapplied in Table Name on Comment Line table has changed
    // 
    // PRW15.00.01
    // P8000559A, VerticalSoft, Jack Reynolds, 18 JAN 08
    //   Fix incorrect reference when deleting comment lines
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.04
    // P8000868, VerticalSoft, Rick Tweedle, 13 SEP 10
    //   Added Genesis Enhancements
    // 
    // PRW17.10
    // P8001220, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Change table relation on Base Unit of Measure
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 07 FEB 19
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW117.3
    // P80096165, To Increase, Jack Reynolds, 02 FEB 21
    //   Rename Comment Lines

    Caption = 'Unapproved Item';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Unapproved Item List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    InvtSetup.Get;
                    NoSeriesMgt.TestManual(InvtSetup."Unapproved Item Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
                    "Search Description" := Description;
            end;
        }
        field(3; "Description 2"; Text[30])
        {
            Caption = 'Description 2';
        }
        field(4; "Search Description"; Code[100])
        {
            Caption = 'Search Description';
        }
        field(5; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            TableRelation = "Unit of Measure".Code;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                UnapprItemUOMLookup(FieldNo("Base Unit of Measure"));
            end;

            trigger OnValidate()
            var
                UnitOfMeasure: Record "Unit of Measure";
            begin
                // P8001220
                if "Base Unit of Measure" <> xRec."Base Unit of Measure" then
                    if "Base Unit of Measure" <> '' then begin
                        UnitOfMeasure.Get("Base Unit of Measure");

                        if not UnapprItemUnitOfMeasure.Get("No.", "Base Unit of Measure") then begin
                            UnapprItemUnitOfMeasure.Init;
                            UnapprItemUnitOfMeasure.Validate("Unapproved Item No.", "No.");
                            UnapprItemUnitOfMeasure.Validate(Code, "Base Unit of Measure");
                            UnapprItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
                            UnapprItemUnitOfMeasure.Insert;
                        end else
                            UnapprItemUnitOfMeasure.TestField("Qty. per Unit of Measure", 1);
                    end;
                // P8001220
            end;
        }
        field(6; "Weight UOM"; Code[10])
        {
            Caption = 'Weight UOM';
            TableRelation = "Unappr. Item Unit of Measure".Code WHERE("Unapproved Item No." = FIELD("No."),
                                                                       Type = CONST(Weight));

            trigger OnLookup()
            begin
                UnapprItemUOMLookup(FieldNo("Weight UOM"));
            end;
        }
        field(7; "Volume UOM"; Code[10])
        {
            Caption = 'Volume UOM';
            TableRelation = "Unappr. Item Unit of Measure".Code WHERE("Unapproved Item No." = FIELD("No."),
                                                                       Type = CONST(Volume));

            trigger OnLookup()
            begin
                UnapprItemUOMLookup(FieldNo("Volume UOM"));
            end;
        }
        field(8; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(9; Comment; Boolean)
        {
            CalcFormula = Exist ("Comment Line" WHERE("Table Name" = CONST(FOODUnapprovedItem),
                                                      "No." = FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(11; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(12; "Specific Gravity"; Decimal)
        {
            Caption = 'Specific Gravity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Specific Gravity" <> 0 then
                    AdjustUnapprItemUOM
                else
                    FieldError("Specific Gravity", Text000);
            end;
        }
        field(37002862; "Ingredient Weight"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
        }
        field(37002863; "Ingredient Measure"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
            OptionMembers = " ","Ounce-weight",Pound,Microgram,Milligram,Gram,Kilogram;
        }
        field(37002920; "Allergen Set ID"; Integer)
        {
            Caption = 'Allergen Set ID';
            Editable = false;
        }
        field(37002921; "Old Allergen Set ID"; Integer)
        {
            Caption = 'Old Allergen Set ID';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, "Base Unit of Measure", "Unit Cost")
        {
        }
    }

    trigger OnDelete()
    begin
        CommentLine.SetRange("Table Name", CommentLine."Table Name"::FOODUnapprovedItem);
        CommentLine.SetRange("No.", "No.");
        CommentLine.DeleteAll;

        UnapprItemUnitOfMeasure.SetRange("Unapproved Item No.", "No.");
        UnapprItemUnitOfMeasure.DeleteAll;
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            InvtSetup.Get;
            InvtSetup.TestField("Unapproved Item Nos.");
            NoSeriesMgt.InitSeries(InvtSetup."Unapproved Item Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
    end;

    trigger OnRename()
    begin      
        CommentLine.RenameCommentLine(CommentLine."Table Name"::FOODUnapprovedItem, xRec."No.", "No."); // P80096165

        "Last Date Modified" := Today;
    end;

    var
        InvtSetup: Record "Inventory Setup";
        UnapprItem: Record "Unapproved Item";
        CommentLine: Record "Comment Line";
        UnapprItemUnitOfMeasure: Record "Unappr. Item Unit of Measure";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text000: Label 'must be greater than zero';
        AllergenManagement: Codeunit "Allergen Management";

    procedure AssistEdit(OldItem: Record "Unapproved Item"): Boolean
    begin
        with UnapprItem do begin
            UnapprItem := Rec;
            InvtSetup.Get;
            InvtSetup.TestField("Unapproved Item Nos.");
            if NoSeriesMgt.SelectSeries(InvtSetup."Unapproved Item Nos.", OldItem."No. Series", "No. Series") then begin
                InvtSetup.Get;
                InvtSetup.TestField("Unapproved Item Nos.");
                NoSeriesMgt.SetSeries("No.");
                Rec := UnapprItem;
                exit(true);
            end;
        end;
    end;

    procedure AdjustUnapprItemUOM()
    var
        UOM: Record "Unit of Measure";
        UnapprItemUOM: Record "Unappr. Item Unit of Measure";
        UnapprItemUOM2: Record "Unappr. Item Unit of Measure";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        AdjUnit: array[2] of Integer;
        Factor: Decimal;
    begin
        if "Specific Gravity" = 0 then exit;

        if "Base Unit of Measure" <> '' then begin
            UOM.Get("Base Unit of Measure");
            if not (UOM.Type in [2, 3]) then
                UOM.Type := UOM.Type::Volume; // reference will be unit of volume
        end;

        UnapprItemUOM.SetRange("Unapproved Item No.", "No.");
        UnapprItemUOM.SetRange(Type, UOM.Type);
        if not UnapprItemUOM.Find('-') then exit; // Find reference unit

        UnapprItemUOM2.SetRange("Unapproved Item No.", "No.");
        if UOM.Type = UOM.Type::Volume then
            UnapprItemUOM2.SetRange(Type, UOM.Type::Weight)
        else
            UnapprItemUOM2.SetRange(Type, UOM.Type::Volume);
        if UnapprItemUOM2.Find('-') then
            repeat
                UnapprItemUOM2."Qty. per Unit of Measure" :=
                  P800UOMFns.ConvertUOMWithSpecGravity(UnapprItemUOM."Qty. per Unit of Measure",
                  UnapprItemUOM.Code, UnapprItemUOM2.Code, "Specific Gravity");
                UnapprItemUOM2.Modify;
            until UnapprItemUOM2.Next = 0;
    end;

    procedure UnapprItemUOMLookup(FldNo: Integer)
    var
        UnapprItemUOM: Record "Unappr. Item Unit of Measure";
        UnapprItemUOMForm: Page "Unappr Item Units of Measure";
        UOM: Code[10];
        SpecGravity: Decimal;
    begin
        UnapprItemUOM.FilterGroup(4);
        UnapprItemUOM.SetRange("Unapproved Item No.", "No.");
        case FldNo of
            FieldNo("Base Unit of Measure"):
                UOM := "Base Unit of Measure";
            FieldNo("Weight UOM"):
                begin
                    UnapprItemUOM.SetRange(Type, UnapprItemUOM.Type::Weight);
                    UOM := "Weight UOM";
                end;

            FieldNo("Volume UOM"):
                begin
                    UnapprItemUOM.SetRange(Type, UnapprItemUOM.Type::Volume);
                    UOM := "Volume UOM";
                end;
        end;
        UnapprItemUOM.FilterGroup(0);

        UnapprItemUOMForm.SetTableView(UnapprItemUOM);
        UnapprItemUOMForm.LookupMode(true);
        if (UOM <> '') and UnapprItemUOM.Get("No.", UOM) then;
        UnapprItemUOMForm.SetRecord(UnapprItemUOM);
        if UnapprItemUOMForm.RunModal = ACTION::LookupOK then begin
            UnapprItemUOMForm.GetRecord(UnapprItemUOM);
            case FldNo of
                FieldNo("Base Unit of Measure"):
                    Validate("Base Unit of Measure", UnapprItemUOM.Code);
                FieldNo("Weight UOM"):
                    Validate("Weight UOM", UnapprItemUOM.Code);
                FieldNo("Volume UOM"):
                    Validate("Volume UOM", UnapprItemUOM.Code);
            end;
        end;

        // Because unit of measure can be deleted and modified during lookup
        UnapprItemUOM.Reset;
        if ("Base Unit of Measure" <> '') and (not UnapprItemUOM.Get("No.", "Base Unit of Measure")) then
            Validate("Base Unit of Measure", '');
        if ("Weight UOM" <> '') and (not UnapprItemUOM.Get("No.", "Weight UOM")) then
            Validate("Weight UOM", '');
        if ("Volume UOM" <> '') and (not UnapprItemUOM.Get("No.", "Volume UOM")) then
            Validate("Volume UOM", '');
        if UnapprItemUOM.CalcSpecGravity("No.", SpecGravity) then
            "Specific Gravity" := SpecGravity;
    end;

    procedure ShowAllergens()
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P8006959
        "Allergen Set ID" := AllergenManagement.ShowAllergenSet(Rec);
    end;
}

