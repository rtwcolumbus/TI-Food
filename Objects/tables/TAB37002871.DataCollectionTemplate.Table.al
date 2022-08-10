table 37002871 "Data Collection Template"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Collection Template';
    DataCaptionFields = "Code", Description;
    LookupPageID = "Data Collection Templates";

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
            OptionCaption = ' ,Q/C,Shipping,Receiving,Production,Log';
            OptionMembers = " ","Q/C",Shipping,Receiving,Production,Log;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                    TemplateLine.Reset;
                    TemplateLine.SetRange("Template Code", Code);
                    if not TemplateLine.IsEmpty then
                        Error(Text001, FieldCaption(Type));
                end;
            end;
        }
        field(11; "Item Category Filter"; Code[20])
        {
            Caption = 'Item Category Filter';
            FieldClass = FlowFilter;
            TableRelation = "Item Category";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; Type)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TemplateLine.Reset;
        TemplateLine.SetRange("Template Code", Code);
        TemplateLine.DeleteAll(true);

        DataCollectionLine.SetRange("Source Template Code", Code);
        DataCollectionLine.ModifyAll("Source Template Code", '');
    end;

    var
        TemplateLine: Record "Data Collection Template Line";
        DataCollectionLine: Record "Data Collection Line";
        Text001: Label 'You cannot change %1 because there is at least one line for this template.';

    procedure AssignedToItemCategory(): Boolean
    var
        ItemCategory: Record "Item Category";
        ItemCategory2: Record "Item Category";
        DataCollectionTempItemCat: Record "Data Collection Temp/Item Cat.";
        ItemCatFilter: Text;
    begin
        // P8007749
        ItemCatFilter := GetFilter("Item Category Filter");
        if ItemCatFilter = '' then
            exit;

        ItemCategory.SetFilter(Code, ItemCatFilter);
        if ItemCategory.FindSet then
            repeat
                if DataCollectionTempItemCat.Get(ItemCategory.Code, Code) then
                    exit(true);
                ItemCategory2 := ItemCategory;
                while ItemCategory2."Parent Category" <> '' do begin
                    if DataCollectionTempItemCat.Get(ItemCategory2."Parent Category", Code) then
                        exit(true);
                    ItemCategory2.Get(ItemCategory2."Parent Category");
                end;
            until ItemCategory.Next = 0;
    end;
}

