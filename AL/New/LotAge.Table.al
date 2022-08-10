table 37002028 "Lot Age"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Used as a temporary table to calculate and retain lot age fields
    // 
    // PR3.70.08
    // P8000165A, Myers Nissi, Jack Reynolds, 11 FEB 05
    //   Modify CalculateFields to use a specified date instead of TODAY
    // 
    // PR4.00
    // P8000251A, Myers Nissi, Jack Reynolds, 20 OCT 05
    //   Add fields for expiration date and days to expire
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Lot Age';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
        }
        field(3; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Production Date"; Date)
        {
            Caption = 'Production Date';
            DataClassification = SystemMetadata;
        }
        field(5; Age; Integer)
        {
            Caption = 'Age';
            DataClassification = SystemMetadata;
        }
        field(6; "Age Category"; Code[10])
        {
            Caption = 'Age Category';
            DataClassification = SystemMetadata;
        }
        field(7; "Current Age Date"; Date)
        {
            Caption = 'Current Age Date';
            DataClassification = SystemMetadata;
        }
        field(8; "Remaining Days"; Integer)
        {
            Caption = 'Remaining Days';
            DataClassification = SystemMetadata;
        }
        field(9; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = SystemMetadata;
        }
        field(10; "Days to Expire"; Integer)
        {
            Caption = 'Days to Expire';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Lot No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure CalculateFields(AgeDate: Date)
    var
        Item: Record Item;
        ItemCat: Record "Item Category";
        LotProfileCat: Record "Lot Age Profile Category";
        LotAgeProfileCode: Code[10];
    begin
        // P8000165A - add parameter AgeDate
        // P8000251A Begin
        if "Expiration Date" = 0D then
            "Days to Expire" := 2147483647
        else
            if AgeDate < "Expiration Date" then
                "Days to Expire" := "Expiration Date" - AgeDate
            else
                "Days to Expire" := 0;
        // P8000251A End

        if "Production Date" <> 0D then
            Age := AgeDate - "Production Date" // P8000165A
        else begin
            Age := -1;
            exit;
        end;

        Item.Get("Item No.");
        if Item."Item Category Code" = '' then
            exit;
        ItemCat.Get(Item."Item Category Code");
        LotAgeProfileCode := ItemCat.GetLotAgeProfileCode; // P8007749
        if LotAgeProfileCode = '' then                     // P8007749
            exit;

        LotProfileCat.SetRange("Profile Code", LotAgeProfileCode); // P8007749
        LotProfileCat.SetFilter("Beginning Age (Days)", '<=%1', Age);
        if LotProfileCat.Find('+') then begin
            "Age Category" := LotProfileCat."Category Code";
            "Current Age Date" := "Production Date" + LotProfileCat."Beginning Age (Days)";
            LotProfileCat.SetRange("Beginning Age (Days)");
            if LotProfileCat.Next <> 0 then
                "Remaining Days" := LotProfileCat."Beginning Age (Days)" - Age
            else
                "Remaining Days" := 2147483647;
        end;
    end;
}

