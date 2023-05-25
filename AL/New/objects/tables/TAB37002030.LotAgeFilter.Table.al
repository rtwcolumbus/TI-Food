table 37002030 "Lot Age Filter"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Holds lot age preferences for customer/item, sales lines, BOM lines, prod order components
    //   Used to pass filter information to functions for setting and testing lot age filters
    // 
    // PR3.70.08
    // P8000174A, Myers Nissi, Jack Reynolds, 27 JAN 05
    //   Key - Table ID,ID 2
    // 
    // PR4.00
    // P8000251A, Myers Nissi, Jack Reynolds, 20 OCT 05
    //   Add field for days to expire filter

    Caption = 'Lot Age Filter';

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = '0,1,2,3,4,5,6,7,8,9';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9";
        }
        field(3; ID; Code[20])
        {
            CaptionClass = StrSubstNo('37002021,%1,%2', "Table ID", 3);
            Caption = 'ID';
        }
        field(4; "ID 2"; Code[20])
        {
            CaptionClass = StrSubstNo('37002021,%1,%2', "Table ID", 4);
            Caption = 'ID 2';
            TableRelation = IF ("Table ID" = CONST(18)) Item;

            trigger OnValidate()
            begin
                case "Table ID" of
                    DATABASE::Customer:
                        begin
                            Item.Get("ID 2");
                            Item.TestField("Item Tracking Code");
                            ItemTrackingCode.Get(Item."Item Tracking Code");
                            ItemTrackingCode.TestField("Lot Specific Tracking", true);
                        end;
                end;
            end;
        }
        field(5; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(11; "Age Filter"; Text[250])
        {
            Caption = 'Age Filter';

            trigger OnValidate()
            var
                LotAgeFilter: Record "Lot Age Filter";
            begin
                LotAgeFilter.SetFilter("Integer Field", "Age Filter");
                "Age Filter" := LotAgeFilter.GetFilter("Integer Field");
            end;
        }
        field(12; "Category Filter"; Text[250])
        {
            Caption = 'Category Filter';
            TableRelation = "Lot Age Category";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                LotAgeFilter: Record "Lot Age Filter";
            begin
                LotAgeFilter.SetFilter("Code Field", "Category Filter");
                "Category Filter" := LotAgeFilter.GetFilter("Code Field");
            end;
        }
        field(13; "Days to Expire Filter"; Text[250])
        {
            Caption = 'Days to Expire Filter';

            trigger OnValidate()
            var
                LotAgeFilter: Record "Lot Age Filter";
            begin
                // P8000251A
                LotAgeFilter.SetFilter("Integer Field", "Days to Expire Filter");
                "Days to Expire Filter" := LotAgeFilter.GetFilter("Integer Field");
            end;
        }
        field(21; "Integer Field"; Integer)
        {
            Caption = 'Integer Field';
        }
        field(22; "Code Field"; Code[10])
        {
            Caption = 'Code Field';
        }
    }

    keys
    {
        key(Key1; "Table ID", Type, ID, "ID 2", "Prod. Order Line No.", "Line No.")
        {
        }
        key(Key2; "Table ID", "ID 2")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if ("Table ID" = DATABASE::Customer) and ("ID 2" = '') then
            Error(Text001, Item.TableCaption, Item.FieldCaption("No."));
    end;

    var
        Text001: Label '%1 %2 must be specified.';
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
}

