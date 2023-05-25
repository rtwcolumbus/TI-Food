table 37002029 "Lot Specification Filter"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Holds lot specification preferences for customer/item, sales lines, BOM lines, prod order components
    //   Used to pass filter information to functions for setting and testing lot specification filters
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method

    Caption = 'Lot Specification Filter';
    LookupPageID = "Lot Specification Filters";

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
        field(11; "Data Element Code"; Code[10])
        {
            Caption = 'Data Element Code';
            TableRelation = "Data Collection Data Element";

            trigger OnValidate()
            begin
                LotSpecCat.Get("Data Element Code");
                "Data Element Type" := LotSpecCat.Type;
            end;
        }
        field(12; "Data Element Type"; Option)
        {
            Caption = 'Data Element Type';
            Editable = false;
            OptionCaption = 'Boolean,Date,Lookup,Numeric,Text';
            OptionMembers = Boolean,Date,"Lookup",Numeric,Text;
        }
        field(13; "Filter"; Text[250])
        {
            Caption = 'Filter';

            trigger OnValidate()
            var
                LotSpecFilter: Record "Lot Specification Filter";
            begin
                case "Data Element Type" of
                    "Data Element Type"::Boolean:
                        begin
                            LotSpecFilter.SetFilter("Boolean Field", Filter);
                            Filter := LotSpecFilter.GetFilter("Boolean Field");
                        end;
                    "Data Element Type"::Date:
                        begin
                            LotSpecFilter.SetFilter("Date Field", Filter);
                            Filter := LotSpecFilter.GetFilter("Date Field");
                        end;
                    "Data Element Type"::"Lookup", "Data Element Type"::Text:
                        begin
                            LotSpecFilter.SetFilter("Code Field", Filter);
                            Filter := LotSpecFilter.GetFilter("Code Field");
                        end;
                    "Data Element Type"::Numeric:
                        begin
                            LotSpecFilter.SetFilter("Numeric Field", Filter);
                            Filter := LotSpecFilter.GetFilter("Numeric Field");
                        end;
                end;
            end;
        }
        field(21; "Boolean Field"; Boolean)
        {
            Caption = 'Boolean Field';
        }
        field(22; "Date Field"; Date)
        {
            Caption = 'Date Field';
        }
        field(23; "Code Field"; Code[50])
        {
            Caption = 'Code Field';
        }
        field(24; "Numeric Field"; Decimal)
        {
            Caption = 'Numeric Field';
        }
        field(119; "Unit of Measure Code"; Code[10])
        {
            CalcFormula = Lookup ("Data Collection Data Element"."Unit of Measure Code" WHERE(Code = FIELD("Data Element Code")));
            Caption = 'Unit of Measure Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(122; "Measuring Method"; Text[50])
        {
            CalcFormula = Lookup ("Data Collection Data Element"."Measuring Method" WHERE(Code = FIELD("Data Element Code")));
            Caption = 'Measuring Method';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Table ID", Type, ID, "ID 2", "Prod. Order Line No.", "Line No.", "Data Element Code")
        {
        }
        key(Key2; "Data Element Code")
        {
        }
        key(Key3; "Table ID", "ID 2")
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
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        LotSpecCat: Record "Data Collection Data Element";
        Text001: Label '%1 %2 must be specified.';
}

