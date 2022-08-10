table 204 "Unit of Measure"
{
    // PR1.00
    //   New Process 800 fields
    //     Type (i.e. Length,Weight,Volume)
    //     Base per Unit of Measure
    // 
    // PR3.60
    //   Add UOM captions
    // 
    // PRW16.00.01
    // P8000678, VerticalSoft, Don Bresee, 23 FEB 09
    //   Add "Genesis Measure" field
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Jack Reynolds, 22 JUN 10
    //   Alter DecimalPlaces property for "Base per Unit of Measure"
    // 
    // PRW16.00.04
    // P8000867, VerticalSoft, Jack Reynolds, 01 SEP 10
    //   Fix decimal places issue with Genesis Qty. per UOM
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality

    Caption = 'Unit of Measure';
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "Units of Measure";
    LookupPageID = "Units of Measure";

    fields
    {
        field(37002000; Type; Option)
        {
            Caption = 'Type';
            Description = 'PR1.00';
            OptionCaption = ' ,Length,Weight,Volume';
            OptionMembers = " ",Length,Weight,Volume;

            trigger OnValidate()
            begin
                CheckForBase; // PR1.00
            end;
        }
        field(37002001; "Base per Unit of Measure"; Decimal)
        {
            BlankZero = true;
            Caption = 'Base per Unit of Measure';
            DecimalPlaces = 0 : 12;
            Description = 'PR1.00';

            trigger OnValidate()
            begin
                // PR1.00 Begin
                if Type <> 0 then
                    TestField("Base per Unit of Measure");
                CheckForBase;
                // PR1.00 End
            end;
        }
        field(37002080; "Qty. Field Caption"; Text[30])
        {
            Caption = 'Qty. Field Caption';
            Description = 'PR3.60';
        }
        field(37002081; "Alt. Qty. Decimal Places"; Text[5])
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            Caption = 'Alt. Qty. Decimal Places';
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                // PR3.60
                if ("Alt. Qty. Decimal Places" <> '') then
                    GLSetup.CheckDecimalPlacesFormat("Alt. Qty. Decimal Places");
                // PR3.60
            end;
        }
        field(37002860; "Genesis Measure"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
            OptionMembers = " ","Ounce-weight",Pound,Microgram,Milligram,Gram,Kilogram,Teaspoon,Tablespoon,"Fluid ounce",Cup,Pint,Quart,Gallon,Milliliter,Liter,Piece,Each,Box,Can,Bag,Jar,"Case",Package;
        }
        field(37002861; "Genesis Qty. per UOM"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
        }
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;

            trigger OnValidate()
            begin
                CheckForBase; // PR1.00
            end;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "International Standard Code"; Code[10])
        {
            Caption = 'International Standard Code';
        }
        field(4; Symbol; Text[10])
        {
            Caption = 'Symbol';
        }
        field(5; "Last Modified Date Time"; DateTime)
        {
            Caption = 'Last Modified Date Time';
            Editable = false;
        }
        field(720; "Coupled to CRM"; Boolean)
        {
            Caption = 'Coupled to Dynamics 365 Sales';
            Editable = false;
        }
        field(8000; Id; Guid)
        {
            Caption = 'Id';
            ObsoleteState = Pending;
            ObsoleteReason = 'This functionality will be replaced by the systemID field';
            ObsoleteTag = '15.0';
        }
        field(27000; "SAT UofM Classification"; Code[10])
        {
            Caption = 'SAT UofM Classification';
            TableRelation = "SAT Unit of Measure";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; Description)
        {
        }
        key(Key3; SystemModifiedAt)
        {
        }
        key(Key4; "Coupled to CRM")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Code", Description, "International Standard Code")
        {
        }
    }

    var
        UoMIsStillUsedError: Label 'You cannot delete the unit of measure because it is assigned to one or more records.';

    trigger OnDelete()
    var
        Item: Record Item;
    begin
        Item.SetCurrentKey("Base Unit of Measure");
        Item.SetRange("Base Unit of Measure", Code);
        if not Item.IsEmpty() then
            Error(UoMIsStillUsedError);

        UnitOfMeasureTranslation.SetRange(Code, Code);
        UnitOfMeasureTranslation.DeleteAll();
    end;

    trigger OnInsert()
    begin
        // PR1.00 Begin
        if Type <> 0 then
            TestField("Base per Unit of Measure");
        // PR1.00 End
        SetLastDateTimeModified;
    end;

    trigger OnModify()
    begin
        // PR1.00 Begin
        if Type <> 0 then
            TestField("Base per Unit of Measure");
        // PR1.00 End
        SetLastDateTimeModified;
    end;

    trigger OnRename()
    begin
        UpdateItemBaseUnitOfMeasure;
    end;

    var
        UnitOfMeasureTranslation: Record "Unit of Measure Translation";
        MeasuringSystem: Record "Measuring System";
        InvSetup: Record "Inventory Setup";
        GLSetup: Record "General Ledger Setup";

    local procedure UpdateItemBaseUnitOfMeasure()
    var
        Item: Record Item;
    begin
        Item.SetCurrentKey("Base Unit of Measure");
        Item.SetRange("Base Unit of Measure", xRec.Code);
        if not Item.IsEmpty() then
            Item.ModifyAll("Base Unit of Measure", Code, true);
    end;

    local procedure CheckForBase()
    begin
        // PR1.00 Begin
        MeasuringSystem.SetRange(UOM, Code);
        MeasuringSystem.SetRange(Type, Type);
        if MeasuringSystem.Find('-') then begin
            InvSetup.Get;
            if InvSetup."Measuring System" = MeasuringSystem."Measuring System" then
                "Base per Unit of Measure" := 1
            else
                "Base per Unit of Measure" := MeasuringSystem."Conversion to Other"
        end;
        // PR1.00 End
    end;

    procedure GetDescriptionInCurrentLanguage(): Text[50]
    var
        UnitOfMeasureTranslation: Record "Unit of Measure Translation";
        Language: Codeunit Language;
    begin
        if UnitOfMeasureTranslation.Get(Code, Language.GetUserLanguageCode) then
            exit(UnitOfMeasureTranslation.Description);
        exit(Description);
    end;

    procedure CreateListInCurrentLanguage(var TempUnitOfMeasure: Record "Unit of Measure" temporary)
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if UnitOfMeasure.FindSet() then
            repeat
                TempUnitOfMeasure := UnitOfMeasure;
                TempUnitOfMeasure.Description := UnitOfMeasure.GetDescriptionInCurrentLanguage;
                TempUnitOfMeasure.Insert();
            until UnitOfMeasure.Next() = 0;
    end;

    local procedure SetLastDateTimeModified()
    var
        DotNet_DateTimeOffset: Codeunit DotNet_DateTimeOffset;
    begin
        "Last Modified Date Time" := DotNet_DateTimeOffset.ConvertToUtcDateTime(CurrentDateTime);
    end;
}

