table 37002481 "Batch Planning Worksheet Name"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Standard Worksheet Name table for Batch Planning
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Batch Planning Worksheet Name';

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Days View"; Integer)
        {
            Caption = 'Days View';
            InitValue = 1;
        }
        field(4; "Create Multi-line Orders"; Boolean)
        {
            Caption = 'Create Multi-line Orders';
            InitValue = true;
        }
        field(11; "Parameter 1 Type"; Option)
        {
            Caption = 'Parameter 1 Type';
            OptionCaption = ' ,Intermediate,Finished';
            OptionMembers = " ",Intermediate,Finished;

            trigger OnValidate()
            begin
                if ("Parameter 1 Type" = 0) or ("Parameter 1 Type" <> xRec."Parameter 1 Type") then begin
                    "Parameter 1 Field" := 0;
                    "Parameter 1 Attribute" := 0; // P8007750
                end;
            end;
        }
        field(12; "Parameter 1 Field"; Option)
        {
            Caption = 'Parameter 1 Field';
            OptionCaption = ' ,Item No.,Item Category,Allergen,,,,Attribute';
            OptionMembers = " ","Item No.","Item Category",Allergen,,,,Attribute;

            trigger OnValidate()
            begin
                if "Parameter 1 Field" <> "Parameter 1 Field"::Attribute then
                    "Parameter 1 Attribute" := 0; // P8007750
            end;
        }
        field(13; "Parameter 1 Attribute"; Integer)
        {
            Caption = 'Parameter 1 Attribute';
            TableRelation = IF ("Parameter 1 Field" = CONST(Attribute)) "Item Attribute";
        }
        field(21; "Parameter 2 Type"; Option)
        {
            Caption = 'Parameter 2 Type';
            OptionCaption = ' ,Intermediate,Finished';
            OptionMembers = " ",Intermediate,Finished;

            trigger OnValidate()
            begin
                if ("Parameter 2 Type" = 0) or ("Parameter 2 Type" <> xRec."Parameter 2 Type") then begin
                    "Parameter 2 Field" := 0;
                    "Parameter 2 Attribute" := 0; // P8007750
                end;
            end;
        }
        field(22; "Parameter 2 Field"; Option)
        {
            Caption = 'Parameter 2 Field';
            OptionCaption = ' ,Item No.,Item Category,Allergen,,,,Attribute';
            OptionMembers = " ","Item No.","Item Category",Allergen,,,,Attribute;

            trigger OnValidate()
            begin
                if "Parameter 2 Field" <> "Parameter 2 Field"::Attribute then
                    "Parameter 2 Attribute" := 0; // P8007750
            end;
        }
        field(23; "Parameter 2 Attribute"; Integer)
        {
            Caption = 'Parameter 2 Attribute';
            TableRelation = IF ("Parameter 2 Field" = CONST(Attribute)) "Item Attribute";
        }
        field(31; "Parameter 3 Type"; Option)
        {
            Caption = 'Parameter 3 Type';
            OptionCaption = ' ,Intermediate,Finished';
            OptionMembers = " ",Intermediate,Finished;

            trigger OnValidate()
            begin
                if ("Parameter 3 Type" = 0) or ("Parameter 3 Type" <> xRec."Parameter 3 Type") then begin
                    "Parameter 3 Field" := 0;
                    "Parameter 3 Attribute" := 0; // P8007750
                end;
            end;
        }
        field(32; "Parameter 3 Field"; Option)
        {
            Caption = 'Parameter 3 Field';
            OptionCaption = ' ,Item No.,Item Category,Allergen,,,,Attribute';
            OptionMembers = " ","Item No.","Item Category",Allergen,,,,Attribute;

            trigger OnValidate()
            begin
                if "Parameter 3 Field" <> "Parameter 3 Field"::Attribute then
                    "Parameter 3 Attribute" := 0; // P8007750
            end;
        }
        field(33; "Parameter 3 Attribute"; Integer)
        {
            Caption = 'Parameter 3 Attribute';
            TableRelation = IF ("Parameter 3 Field" = CONST(Attribute)) "Item Attribute";
        }
        field(102; "Batch Highlight Field"; Option)
        {
            Caption = 'Batch Highlight Field';
            OptionCaption = ' ,Item No.,Item Category,Allergen,,,,Attribute';
            OptionMembers = " ","Item No.","Item Category",Allergen,,,,Attribute;

            trigger OnValidate()
            begin
                if "Batch Highlight Field" <> "Batch Highlight Field"::Attribute then
                    "Batch Highlight Attribute" := 0; // P8007750
            end;
        }
        field(103; "Batch Highlight Attribute"; Integer)
        {
            Caption = 'Batch Highlight Attribute';
            TableRelation = IF ("Batch Highlight Field" = CONST(Attribute)) "Item Attribute";
        }
        field(112; "Package Highlight Field"; Option)
        {
            Caption = 'Package Highlight Field';
            OptionCaption = ' ,Item No.,Item Category,Allergen,,,,Attribute';
            OptionMembers = " ","Item No.","Item Category",Allergen,,,,Attribute;

            trigger OnValidate()
            begin
                if "Package Highlight Field" <> "Package Highlight Field"::Attribute then
                    "Package Highlight Attribute" := 0; // P8007750
            end;
        }
        field(113; "Package Highlight Attribute"; Integer)
        {
            Caption = 'Package Highlight Attribute';
            TableRelation = IF ("Package Highlight Field" = CONST(Attribute)) "Item Attribute";
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }

    fieldgroups
    {
    }
}

