table 37002463 "Production Order XRef"
{
    // PR1.00, Myers Nissi, Jack Reynolds, 26 MAY 00, PR003
    //   Field 1 - Document Type - Option
    //   Field 2 - Document No. - Code 20
    //   Field 3 - Line No. - Integer
    //   Field 11 - Prod. Order Status - Option
    //   Field 12 - Prod. Order No. - Code 20
    //   Field 13 - Prod. Order Line No. - Integer
    //   Field 21 - Quantity (Base) - Decimal
    //   Primary Key - Document Type,Document No.,Line No.,Prod. Order
    //     Status,Prod. Order No.,Prod. Order Line No.
    //  Additional Key - Prod. Order Status,Prod. Order No.,Prod. Order Line
    //     No.,Document Type,Document No.,Line No.
    // 
    // PR1.20.02
    //   Rename Docuement Type to Sales Document Type, Document No. to Sales Document No.
    // 
    // PR2.00
    //   Replace fields identifying source with more general ones
    //     Field 1 - Source Table ID - Integer
    //     Field 2 - Source Type - Integer
    //     Field 3 - Source No. - Code 20
    //     Field 4 - Source Line No. - Integer
    //   Modify keys to reflect field changes
    // 
    // PRW16.00.04
    // P8000875, VerticalSoft, Jack Reynolds, 14 OCT 10
    //   Modify "Quantity (Base)" DecimalPlaces

    Caption = 'Production Order XRef';
    DrillDownPageID = "Production Order Xref";

    fields
    {
        field(1; "Source Table ID"; Integer)
        {
            Caption = 'Source Table ID';
            Description = 'PR2.00';
        }
        field(2; "Source Type"; Option)
        {
            Caption = 'Source Type';
            Description = 'PR2.00';
            OptionCaption = '0,1,2,3,4,5,6,7';
            OptionMembers = "0","1","2","3","4","5","6","7";
        }
        field(3; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Description = 'PR2.00';
        }
        field(4; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            Description = 'PR2.00';
        }
        field(11; "Prod. Order Status"; Option)
        {
            Caption = 'Prod. Order Status';
            OptionCaption = 'Simulated,Planned,Firm Planned,Released,Finished';
            OptionMembers = Simulated,Planned,"Firm Planned",Released,Finished;
        }
        field(12; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
        }
        field(13; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
        }
        field(21; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Source Table ID", "Source Type", "Source No.", "Source Line No.", "Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.")
        {
            SumIndexFields = "Quantity (Base)";
        }
        key(Key2; "Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Source Table ID", "Source Type", "Source No.", "Source Line No.")
        {
            SumIndexFields = "Quantity (Base)";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if "Source Table ID" = DATABASE::"Prod. Order Line" then begin
            ProdOrderLine.Get("Source Type", "Source No.", "Source Line No.");
            ProdOrderLine.Validate("Quantity (Base)", ProdOrderLine."Quantity (Base)" + "Quantity (Base)");
            ProdOrderLine.Modify;
        end;
    end;

    trigger OnInsert()
    begin
        if "Source Table ID" = DATABASE::"Prod. Order Line" then begin
            ProdOrderLine.Get("Source Type", "Source No.", "Source Line No.");
            ProdOrderLine.Validate("Quantity (Base)", ProdOrderLine."Quantity (Base)" - "Quantity (Base)");
            ProdOrderLine.Modify;
        end;
    end;

    var
        ProdOrderLine: Record "Prod. Order Line";
}

