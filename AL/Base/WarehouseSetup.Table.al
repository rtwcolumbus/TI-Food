table 5769 "Warehouse Setup"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 05 SEP 06
    //   Add Whse. Staged Pick Nos.
    // 
    // PRW110.0.02
    // P80038975, To-Increase, Dayakar Battini, 13 DEC 17
    //    Pick Class Code functionality
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Warehouse Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Whse. Receipt Nos."; Code[20])
        {
            AccessByPermission = TableData "Warehouse Receipt Header" = R;
            Caption = 'Whse. Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Whse. Put-away Nos."; Code[20])
        {
            AccessByPermission = TableData "Posted Invt. Put-away Header" = R;
            Caption = 'Whse. Put-away Nos.';
            TableRelation = "No. Series";
        }
        field(5; "Whse. Pick Nos."; Code[20])
        {
            AccessByPermission = TableData "Posted Invt. Pick Header" = R;
            Caption = 'Whse. Pick Nos.';
            TableRelation = "No. Series";
        }
        field(6; "Whse. Ship Nos."; Code[20])
        {
            AccessByPermission = TableData "Warehouse Shipment Header" = R;
            Caption = 'Whse. Ship Nos.';
            TableRelation = "No. Series";
        }
        field(7; "Registered Whse. Pick Nos."; Code[20])
        {
            AccessByPermission = TableData "Posted Invt. Pick Header" = R;
            Caption = 'Registered Whse. Pick Nos.';
            TableRelation = "No. Series";
        }
        field(10; "Registered Whse. Put-away Nos."; Code[20])
        {
            AccessByPermission = TableData "Posted Invt. Put-away Header" = R;
            Caption = 'Registered Whse. Put-away Nos.';
            TableRelation = "No. Series";
        }
        field(13; "Require Receive"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Receipt Header" = R;
            Caption = 'Require Receive';

            trigger OnValidate()
            begin
                if not "Require Receive" then
                    "Require Put-away" := false;
            end;
        }
        field(14; "Require Put-away"; Boolean)
        {
            AccessByPermission = TableData "Posted Invt. Put-away Header" = R;
            Caption = 'Require Put-away';

            trigger OnValidate()
            begin
                if "Require Put-away" then
                    "Require Receive" := true;
            end;
        }
        field(15; "Require Pick"; Boolean)
        {
            AccessByPermission = TableData "Posted Invt. Pick Header" = R;
            Caption = 'Require Pick';

            trigger OnValidate()
            begin
                if "Require Pick" then
                    "Require Shipment" := true;
            end;
        }
        field(16; "Require Shipment"; Boolean)
        {
            AccessByPermission = TableData "Warehouse Shipment Header" = R;
            Caption = 'Require Shipment';

            trigger OnValidate()
            begin
                if not "Require Shipment" then
                    "Require Pick" := false;
            end;
        }
        field(17; "Last Whse. Posting Ref. No."; Integer)
        {
            Caption = 'Last Whse. Posting Ref. No.';
            Editable = false;
            ObsoleteReason = 'Replaced by Last Whse. Posting Ref. Seq. field.';
            ObsoleteState = Pending;
            ObsoleteTag = '19.0';
        }
        field(18; "Receipt Posting Policy"; Option)
        {
            Caption = 'Receipt Posting Policy';
            OptionCaption = 'Posting errors are not processed,Stop and show the first posting error';
            OptionMembers = "Posting errors are not processed","Stop and show the first posting error";
        }
        field(19; "Shipment Posting Policy"; Option)
        {
            Caption = 'Shipment Posting Policy';
            OptionCaption = 'Posting errors are not processed,Stop and show the first posting error';
            OptionMembers = "Posting errors are not processed","Stop and show the first posting error";
        }
        field(20; "Last Whse. Posting Ref. Seq."; Code[40])
        {
            Caption = 'Last Whse. Posting Ref. Seq.';
            Editable = false;
        }
        field(7301; "Posted Whse. Receipt Nos."; Code[20])
        {
            AccessByPermission = TableData "Warehouse Receipt Header" = R;
            Caption = 'Posted Whse. Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(7303; "Posted Whse. Shipment Nos."; Code[20])
        {
            AccessByPermission = TableData "Warehouse Shipment Header" = R;
            Caption = 'Posted Whse. Shipment Nos.';
            TableRelation = "No. Series";
        }
        field(7304; "Whse. Internal Put-away Nos."; Code[20])
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Whse. Internal Put-away Nos.';
            TableRelation = "No. Series";
        }
        field(7306; "Whse. Internal Pick Nos."; Code[20])
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Whse. Internal Pick Nos.';
            TableRelation = "No. Series";
        }
        field(7308; "Whse. Movement Nos."; Code[20])
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Whse. Movement Nos.';
            TableRelation = "No. Series";
        }
        field(7309; "Registered Whse. Movement Nos."; Code[20])
        {
            AccessByPermission = TableData "Warehouse Source Filter" = R;
            Caption = 'Registered Whse. Movement Nos.';
            TableRelation = "No. Series";
        }
        field(37002760; "Whse. Staged Pick Nos."; Code[20])
        {
            Caption = 'Whse. Staged Pick Nos.';
            TableRelation = "No. Series";
        }
        field(37002761; "Whse. Pick Using Pick Class"; Boolean)
        {
            Caption = 'Whse. Pick Using Pick Class';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    procedure GetCurrentReference(): Integer
    begin
        Rec.Get();
        if Rec."Last Whse. Posting Ref. Seq." = '' then
            exit(Rec."Last Whse. Posting Ref. No.");
        EnsureSequenceExists();
        exit(NumberSequence.Current(Rec."Last Whse. Posting Ref. Seq.") mod MaxInt());
    end;

    procedure GetNextReference(): Integer
    begin
        EnsureSequenceExists();
        exit(NumberSequence.Next(Rec."Last Whse. Posting Ref. Seq.") mod MaxInt());
    end;

    local procedure EnsureSequenceExists()
    var
        DummySeq: BigInteger;
    begin
        Rec.Get();
        if Rec."Last Whse. Posting Ref. Seq." = '' then begin
            LockTable();
            Get();
            if Rec."Last Whse. Posting Ref. Seq." = '' then begin
                Rec."Last Whse. Posting Ref. Seq." := CopyStr(Format(CreateGuid()), 1, MaxStrLen(Rec."Last Whse. Posting Ref. Seq."));
                Rec."Last Whse. Posting Ref. Seq." := DelChr(Rec."Last Whse. Posting Ref. Seq.", '=', '{}');
                Modify();
            end;
        end;
        if NumberSequence.Exists("Last Whse. Posting Ref. Seq.") then
            exit;
        NumberSequence.Insert(Rec."Last Whse. Posting Ref. Seq.", Rec."Last Whse. Posting Ref. No.", 1);
        // Simulate that a number was used - init issue with number sequences.
        DummySeq := NumberSequence.next(Rec."Last Whse. Posting Ref. Seq.");
    end;

    local procedure MaxInt(): Integer
    begin
        exit(2147483647);
    end;
}

