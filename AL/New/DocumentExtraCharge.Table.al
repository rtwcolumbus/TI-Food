table 37002663 "Document Extra Charge"
{
    // PR4.00.06
    // P8000487A, VerticalSoft, Jack Reynolds, 12 JUN 07
    //   Multi-currency support for extra charges
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for extra charges on transfer orders
    // 
    // PRW16.00.06
    // P8001032, Columbus IT, Jack Reynolds, 02 FEB 12
    //   Correct flaw in design of Document Extra Charge table
    // 
    // PRW17.10.03
    // P8001333, Columbus IT, Jack Reynolds, 03 JUL 14
    //   Allow Vendor No to be blank

    Caption = 'Document Extra Charge';
    DrillDownPageID = "Document Line Extra Charges";
    LookupPageID = "Document Line Extra Charges";

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            NotBlank = true;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
            NotBlank = true;
            TableRelation = "Extra Charge";

            trigger OnValidate()
            begin
                if ("Line No." = 0) and ("Extra Charge Code" <> xRec."Extra Charge Code") then begin
                    ExtraCharge.Get("Extra Charge Code");
                    "Allocation Method" := ExtraCharge."Allocation Method";
                end;
            end;
        }
        field(5; "Charge (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Charge (LCY)';
            Editable = false;

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin
                // P8000487A
                if "Currency Code" <> '' then begin
                    Currency2.Get("Currency Code");
                    Charge :=
                      Round(
                        CurrExchRate.ExchangeAmtLCYToFCY(WorkDate, "Currency Code", "Charge (LCY)", "Currency Factor"),
                        Currency2."Amount Rounding Precision")
                end else begin
                    Currency2.InitRoundingPrecision;
                    Charge :=
                      Round("Charge (LCY)", Currency2."Amount Rounding Precision");
                end;
                // P8000487A
            end;
        }
        field(6; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            begin
                // P8000487A
                // P8001333
                if "Vendor No." = '' then
                    Validate("Currency Code", '')
                else begin
                    // P8001333
                    Vendor.Get("Vendor No.");
                    Validate("Currency Code", Vendor."Currency Code");
                end; // P8001333
                // P8000487A
            end;
        }
        field(7; "Allocation Method"; Option)
        {
            Caption = 'Allocation Method';
            OptionCaption = ' ,Amount,Quantity,Weight,Volume';
            OptionMembers = " ",Amount,Quantity,Weight,Volume;
        }
        field(8; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                // P8000487A
                if "Currency Code" <> xRec."Currency Code" then begin
                    UpdateCurrencyFactor;
                    Validate(Charge);
                end;
            end;
        }
        field(9; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
        }
        field(10; Charge; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Charge';

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin
                // P8000487A
                Currency2.InitRoundingPrecision;
                if "Currency Code" <> '' then
                    "Charge (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(WorkDate, "Currency Code", Charge, "Currency Factor"),
                        Currency2."Amount Rounding Precision")
                else
                    "Charge (LCY)" :=
                      Round(Charge, Currency2."Amount Rounding Precision");
            end;
        }
        field(11; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
    }

    keys
    {
        key(Key1; "Table ID", "Document Type", "Document No.", "Line No.", "Extra Charge Code")
        {
            SumIndexFields = "Charge (LCY)", Charge;
        }
        key(Key2; "Extra Charge Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestStatusOpen;
    end;

    trigger OnInsert()
    begin
        TestStatusOpen;
    end;

    trigger OnModify()
    begin
        TestStatusOpen;
    end;

    trigger OnRename()
    begin
        TestStatusOpen;
    end;

    var
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        ExtraCharge: Record "Extra Charge";
        Vendor: Record Vendor;
        CurrExchRate: Record "Currency Exchange Rate";

    procedure TestStatusOpen()
    begin
        // P8000928
        case "Table ID" of
            DATABASE::"Purchase Header", DATABASE::"Purchase Line": // P8001032
                begin
                    // P8000928
                    PurchHeader.Get("Document Type", "Document No.");
                    PurchHeader.TestField(Status, PurchHeader.Status::Open);
                    // P8000928
                end;
            DATABASE::"Transfer Header", DATABASE::"Transfer Line": // P8001032
                begin
                    TransHeader.Get("Document No.");
                    TransHeader.TestField(Status, TransHeader.Status::Open);
                end;
        end;
        // P8000928
    end;

    procedure UpdateCurrencyFactor()
    begin
        // P8000487A
        if "Currency Code" <> '' then
            "Currency Factor" := CurrExchRate.ExchangeRate(WorkDate, "Currency Code")
        else
            "Currency Factor" := 0;
    end;

    procedure InitRecord()
    var
        PurchHeader: Record "Purchase Header";
    begin
        // P8000487A
        if "Table ID" in [DATABASE::"Purchase Header", DATABASE::"Purchase Line"] then // P8000928, P8001032
            if "Line No." <> 0 then begin
                PurchHeader.Get("Document Type", "Document No.");
                Validate("Currency Code", PurchHeader."Currency Code");
            end;
    end;
}

