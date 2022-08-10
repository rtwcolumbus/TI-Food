table 37002690 "Pstd. Comm. Manifest Dest. Bin"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic

    Caption = 'Pstd. Comm. Manifest Dest. Bin';

    fields
    {
        field(1; "Posted Comm. Manifest No."; Code[20])
        {
            Caption = 'Posted Comm. Manifest No.';
            TableRelation = "Posted Comm. Manifest Header";
        }
        field(4; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code;
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
        key(Key1; "Posted Comm. Manifest No.", "Bin Code")
        {
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
    }

    procedure LookupBin()
    var
        PstdCommManifestHeader: Record "Posted Comm. Manifest Header";
        Bin: Record Bin;
        BinList: Page "Bin List";
    begin
        PstdCommManifestHeader.Get("Posted Comm. Manifest No.");
        Bin.Reset;
        Bin.FilterGroup(2);
        Bin.SetRange("Location Code", PstdCommManifestHeader."Location Code");
        Bin.FilterGroup(0);
        BinList.LookupMode(true);
        BinList.SetTableView(Bin);
        Bin."Location Code" := PstdCommManifestHeader."Location Code";
        Bin.Code := "Bin Code";
        BinList.SetRecord(Bin);
        BinList.RunModal;
    end;
}

