table 37002687 "Commodity Manifest Dest. Bin"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic

    Caption = 'Commodity Manifest Dest. Bin';

    fields
    {
        field(1; "Commodity Manifest No."; Code[20])
        {
            Caption = 'Commodity Manifest No.';
            TableRelation = "Commodity Manifest Header";
        }
        field(4; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code;

            trigger OnValidate()
            begin
                TestField("Bin Code");
                CommManifestHeader.Get("Commodity Manifest No.");
                CommManifestHeader.TestField("Location Code");
                CommManifestHeader.TestField("Product Rejected", false);
                if ("Bin Code" = CommManifestHeader."Bin Code") then
                    CommManifestHeader.FieldError("Bin Code");
                Bin.Get(CommManifestHeader."Location Code", "Bin Code");
            end;
        }
        field(5; Quantity; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
    }

    keys
    {
        key(Key1; "Commodity Manifest No.", "Bin Code")
        {
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField("Bin Code");
    end;

    var
        CommManifestHeader: Record "Commodity Manifest Header";
        Bin: Record Bin;

    procedure LookupBin(var Text: Text[1024]): Boolean
    var
        BinList: Page "Bin List";
    begin
        CommManifestHeader.Get("Commodity Manifest No.");
        CommManifestHeader.TestField("Location Code");
        CommManifestHeader.TestField("Product Rejected", false);
        Bin.Reset;
        Bin.FilterGroup(2);
        Bin.SetRange("Location Code", CommManifestHeader."Location Code");
        Bin.SetFilter(Code, '<>%1', CommManifestHeader."Bin Code");
        Bin.FilterGroup(0);
        BinList.LookupMode(true);
        BinList.SetTableView(Bin);
        if (Text <> '') then begin
            Bin."Location Code" := CommManifestHeader."Location Code";
            Bin.Code := CopyStr(Text, 1, MaxStrLen(Bin.Code));
            if Bin.Find('=><') then
                BinList.SetRecord(Bin);
        end;
        if (BinList.RunModal <> ACTION::LookupOK) then
            exit(false);
        BinList.GetRecord(Bin);
        Text := Bin.Code;
        exit(true);
    end;
}

