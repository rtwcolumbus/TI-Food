page 37002553 "Lot Quality Test Results"
{
    // PRW16.00.06
    // P8001079, Columbus IT, Jack Reynolds, 15 JUN 12
    //    Support for selective re-tests
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001149, Columbus IT, Don Bresee, 25 APR 13
    //   Change calling of page to use lookup mode

    Caption = 'Lot Quality Tests';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "Item Quality Test Result";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Lot)
            {
                ShowCaption = false;

                field("LotInfo.""Item No."""; LotInfo."Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item No.';
                    Editable = false;
                }
                field("LotInfo.""Variant Code"""; LotInfo."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant Code';
                    Editable = false;
                    Lookup = false;
                }
                field("LotInfo.""Lot No."""; LotInfo."Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot No.';
                    Editable = false;
                }
                field(ReasonCode; ReasonCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reason Code';
                    TableRelation = "Reason Code";
                    Visible = Retest;
                }
                field(Retest; Retest)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re-Test';
                    Editable = false;
                }
                field(NoOfCopies; NoOfCopies)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'No. of Copies';
                    MinValue = 1;
                }
            }
            repeater(Group)
            {
                field(Include; Rec.Include)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Reason Code Required"; Rec."Reason Code Required")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = Retest;
                }
                field("Test No."; Rec."Test No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = Retest;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = Retest;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = FOODBasic;
                    Visible = Retest;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = FOODBasic;
                    Visible = Retest;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = FOODBasic;
                    Visible = Retest;
                }
                field(Target; Rec.Target)
                {
                    ApplicationArea = FOODBasic;
                    Visible = Retest;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        NoOfCopies := 1;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        TestResult: Record "Item Quality Test Result";
    begin
        // IF CloseAction = ACTION::OK THEN    // P8001149
        if CloseAction = ACTION::LookupOK then // P8001149
            if (ReasonCode = '') and Retest then begin
                TestResult.Copy(Rec);
                Rec.Reset;
                Rec.SetRange(Include, true);
                Rec.SetRange("Reason Code Required", true);
                if Rec.FindFirst then
                    Error(Text001, Rec.Code);
                Rec.Copy(TestResult);
            end;

        exit(true);
    end;

    var
        LotInfo: Record "Lot No. Information";
        ReasonCode: Code[10];
        Retest: Boolean;
        NoOfCopies: Integer;
        Text001: Label 'Test %1 requires a reason code.';

    procedure SetLot(LotInfo2: Record "Lot No. Information")
    var
        DataCollectionLine: Record "Data Collection Line";
    begin
        // P8001090 - replace ItemTest with DataCollectionLine
        LotInfo := LotInfo2;

        DataCollectionLine.SetRange("Source ID", DATABASE::Item);          // P8001090
        DataCollectionLine.SetRange("Source Key 1", LotInfo."Item No.");   // P8001090
        DataCollectionLine.SetRange(Type, DataCollectionLine.Type::"Q/C"); // P8001090
        DataCollectionLine.SetRange(Active, true);                         // P8001090
        if LotInfo."Variant Code" = '' then
            DataCollectionLine.SetFilter("Variant Type", '%1|%2',
              DataCollectionLine."Variant Type"::"Item Only", DataCollectionLine."Variant Type"::"Item and Variant")
        else
            DataCollectionLine.SetFilter("Variant Type",
              '%1|%2', DataCollectionLine."Variant Type"::"Variant Only", DataCollectionLine."Variant Type"::"Item and Variant");

        if DataCollectionLine.FindSet then begin
            repeat
                Rec."Item No." := DataCollectionLine."Source Key 1"; // P8001090
                Rec."Variant Type" := DataCollectionLine."Variant Type";
                Rec.Code := DataCollectionLine."Data Element Code"; // P8001090
                Rec.Description := DataCollectionLine.Description;
                Rec.Type := DataCollectionLine."Data Element Type"; // P8001090
                Rec."Reason Code Required" := DataCollectionLine."Re-Test Requires Reason Code";
                Rec.Include := true;
                Rec."Variant Code" := LotInfo."Variant Code";
                Rec."Lot No." := LotInfo."Lot No.";
                Rec."Line No." := DataCollectionLine."Line No."; // P8001090
                Rec.GetResults;
                Rec.Insert;
            until DataCollectionLine.Next = 0;

            Rec.FindFirst;
        end;
    end;

    procedure SetReTest(NewRetest: Boolean)
    begin
        Retest := NewRetest;
    end;

    procedure GetReasonCode(): Code[10]
    begin
        exit(ReasonCode);
    end;

    procedure GetNoOfCopies(): Integer
    begin
        exit(NoOfCopies);
    end;

    procedure GetTests(var DataCollectionLine: Record "Data Collection Line" temporary)
    var
        DataCollectionLine2: Record "Data Collection Line";
    begin
        // P8001090 - replace ItemTest with DataCollectionLine
        Rec.Reset;
        Rec.SetRange(Include, true);
        if Rec.FindSet then
            repeat
                DataCollectionLine2.Get(DATABASE::Item, Rec."Item No.", '', DataCollectionLine.Type::"Q/C",
                  Rec."Variant Type", Rec.Code, Rec."Line No.");
                DataCollectionLine := DataCollectionLine2;
                DataCollectionLine.Insert;
            until Rec.Next = 0;
    end;
}

