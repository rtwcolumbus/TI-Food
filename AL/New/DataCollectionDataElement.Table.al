table 37002020 "Data Collection Data Element"
{
    // PR1.10
    //   New table for lot specification categories
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Combine with quality control tests
    // 
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Maintain lot specification preferences
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001160, Columbus IT, Jack Reynolds, 23 MAY 13
    //   Field added to control creation of separate lines on data sheet
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method
    // 
    // P80037659, To-Increase, Jack Reynolds, 25 JUL 18
    //   QC-Additions: Develop average measurement
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Collection Data Element';
    LookupPageID = "Data Collection Data Elements";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Boolean,Date,Lookup,Numeric,Text';
            OptionMembers = Boolean,Date,"Lookup",Numeric,Text;

            trigger OnValidate()
            begin
                // P80037659
                if Type <> xRec.Type then
                    "Averaging Method" := "Averaging Method"::" ";
                // P80037659
            end;
        }
        field(4; "Description 2"; Text[30])
        {
            Caption = 'Description 2';
        }
        field(5; "Create Separate Lines"; Boolean)
        {
            Caption = 'Create Separate Lines';
        }
        field(119; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(122; "Measuring Method"; Text[50])
        {
            Caption = 'Measuring Method';
        }
        field(123; "Averaging Method"; Option)
        {
            Caption = 'Averaging Method';
            OptionCaption = ' ,First,Last,,,,,,Arithmetic,Geometric,Harmonic';
            OptionMembers = " ",First,Last,,,,,,Arithmetic,Geometric,Harmonic;

            trigger OnValidate()
            begin
                // P80037659
                if "Averaging Method" in ["Averaging Method"::Arithmetic, "Averaging Method"::Geometric, "Averaging Method"::Harmonic] then
                    TestField(Type, Type::Numeric);
                // P80037659
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        // P8000152A Begin
        // P8001090
        //ItemTest.SETCURRENTKEY(Code);
        //ItemTest.SETRANGE(Code,Code);
        //IF ItemTest.FIND('-') THEN
        //  ERROR(Text000,TABLECAPTION,Code,ItemTest.TABLECAPTION);
        DataCollectionLine.SetCurrentKey("Data Element Code");
        DataCollectionLine.SetRange("Data Element Code", Code);
        if not DataCollectionLine.IsEmpty then
            Error(Text000, TableCaption, Code, DataCollectionLine.TableCaption);
        // P8001090

        LotSpec.SetCurrentKey("Data Element Code");
        LotSpec.SetRange("Data Element Code", Code);
        if LotSpec.Find('-') then
            Error(Text000, TableCaption, Code, LotSpec.TableCaption);

        LotSpecLookup.SetRange("Data Element Code", Code);
        LotSpecLookup.DeleteAll;
        // P8000152A End

        // P8000153A Begin
        LotSpecFilter.SetCurrentKey("Data Element Code");
        LotSpecFilter.SetRange("Data Element Code", Code);
        LotSpecFilter.DeleteAll;

        InvSetup.Get;
        if InvSetup."Shortcut Lot Spec. 1 Code" = Code then
            InvSetup."Shortcut Lot Spec. 1 Code" := '';
        if InvSetup."Shortcut Lot Spec. 2 Code" = Code then
            InvSetup."Shortcut Lot Spec. 2 Code" := '';
        if InvSetup."Shortcut Lot Spec. 3 Code" = Code then
            InvSetup."Shortcut Lot Spec. 3 Code" := '';
        if InvSetup."Shortcut Lot Spec. 4 Code" = Code then
            InvSetup."Shortcut Lot Spec. 4 Code" := '';
        if InvSetup."Shortcut Lot Spec. 5 Code" = Code then
            InvSetup."Shortcut Lot Spec. 5 Code" := '';
        InvSetup.Modify;
        // P8000153A End
    end;

    var
        LotSpec: Record "Lot Specification";
        DataCollectionLine: Record "Data Collection Line";
        LotSpecLookup: Record "Data Collection Lookup";
        Text000: Label 'You cannot delete %1 %2 because there is at least one %3 that includes this code.';
        LotSpecFilter: Record "Lot Specification Filter";
        InvSetup: Record "Inventory Setup";
}

