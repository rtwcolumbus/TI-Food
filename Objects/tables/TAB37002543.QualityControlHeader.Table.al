table 37002543 "Quality Control Header"
{
    // PR3.60.02
    //   Update Q/C Completed on lines when changing status to Pass or Fail
    // 
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic
    // 
    // P80037637, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop threshhold results
    // 
    // P80038824, To-Increase, Dayakar Battini, 08 JUN 18
    //   QC-Additions: Re-test flag
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples, field "Sample Quantity Posted" added

    Caption = 'Quality Control Header';
    DataCaptionFields = "Item No.", "Variant Code", "Lot No.";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(2; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Editable = false;
            TableRelation = "Lot No. Information"."Lot No." WHERE("Item No." = FIELD("Item No."),
                                                                   "Variant Code" = FIELD("Variant Code"));
        }
        field(4; "Test No."; Integer)
        {
            Caption = 'Test No.';
            Editable = false;
        }
        field(11; Status; Option)
        {
            Caption = 'Status';
            Description = 'PR3.60.02';
            Editable = false;
            OptionCaption = 'Pending,Pass,Fail,Skip,Suspended';
            OptionMembers = Pending,Pass,Fail,Skip,Suspended;

            trigger OnValidate()
            var
                DelegateSuspend: Boolean;
            begin
                // P80037569
                if xRec.Status = Status then
                    exit;
                if xRec.Status = xRec.Status::Suspended then
                    if not P800QCFns.IsQCAdministrator then
                        Error(NotQCAdminErrorTxt);
                // P80037569
                if (Status = Status::Pass) then begin
                    if (CurrFieldNo <> 0) and (xRec.Status = xRec.Status::Pass) then
                        exit;
                    InventorySetup.Get;
                    QCLine.Reset;
                    QCLine.SetRange("Item No.", "Item No.");
                    QCLine.SetRange("Variant Code", "Variant Code");
                    QCLine.SetRange("Lot No.", "Lot No.");
                    QCLine.SetRange("Test No.", "Test No.");
                    if InventorySetup."All Q/C Tests Must Be Done" then begin
                        QCLine.SetRange(Status, QCLine.Status::"Not Tested");
                        if not QCLine.IsEmpty then
                            Error(Text000, FieldCaption(Status), Status);
                    end;
                    QCLine.SetRange("Must Pass", true);
                    QCLine.SetFilter(Status, '<>%1', QCLine.Status::Pass);
                    if not QCLine.IsEmpty then
                        Error(Text001,
                              QCLine."Test Code", FieldCaption(Status), Status);
                    if not HideValidationDialog then  // P80037569
                        if not Confirm(Text002, false)
                        then
                            Error(Text003);
                end;

                if (Status = Status::Fail) then begin
                    if (CurrFieldNo <> 0) and (xRec.Status = xRec.Status::Fail) then
                        exit;
                    if not HideValidationDialog then  // P80037569
                        if not Confirm(Text004, false)
                        then
                            Error(Text003);
                end;

                // PR3.60.02 Begin
                if Status in [Status::Pass, Status::Fail] then begin
                    QCLine.Reset;
                    QCLine.SetRange("Item No.", "Item No.");
                    QCLine.SetRange("Variant Code", "Variant Code");
                    QCLine.SetRange("Lot No.", "Lot No.");
                    QCLine.SetRange("Test No.", "Test No.");
                    QCLine.ModifyAll(Complete, true);
                end;
                // PR3.60.02 End
            end;
        }
        field(12; "Assigned To"; Code[10])
        {
            Caption = 'Assigned To';
            TableRelation = "Quality Control Technician";
        }
        field(13; "Schedule Date"; Date)
        {
            Caption = 'Schedule Date';
        }
        field(14; "Complete Date"; Date)
        {
            Caption = 'Complete Date';
        }
        field(21; "Item Description"; Text[100])
        {
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(22; "Document No."; Code[20])
        {
            CalcFormula = Lookup("Lot No. Information"."Document No." WHERE("Item No." = FIELD("Item No."),
                                                                             "Variant Code" = FIELD("Variant Code"),
                                                                             "Lot No." = FIELD("Lot No.")));
            Caption = 'Document No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(23; "Posting Date"; Date)
        {
            CalcFormula = Lookup("Lot No. Information"."Document Date" WHERE("Item No." = FIELD("Item No."),
                                                                              "Variant Code" = FIELD("Variant Code"),
                                                                              "Lot No." = FIELD("Lot No.")));
            Caption = 'Posting Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(24; "Expected Release Date"; Date)
        {
            CalcFormula = Lookup("Lot No. Information"."Expected Release Date" WHERE("Item No." = FIELD("Item No."),
                                                                                      "Variant Code" = FIELD("Variant Code"),
                                                                                      "Lot No." = FIELD("Lot No.")));
            Caption = 'Expected Release Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "Release Date"; Date)
        {
            CalcFormula = Lookup("Lot No. Information"."Release Date" WHERE("Item No." = FIELD("Item No."),
                                                                             "Variant Code" = FIELD("Variant Code"),
                                                                             "Lot No." = FIELD("Lot No.")));
            Caption = 'Release Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "Expiration Date"; Date)
        {
            CalcFormula = Lookup("Lot No. Information"."Expiration Date" WHERE("Item No." = FIELD("Item No."),
                                                                                "Variant Code" = FIELD("Variant Code"),
                                                                                "Lot No." = FIELD("Lot No.")));
            Caption = 'Expiration Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(27; "Lot Strength Percent"; Decimal)
        {
            CalcFormula = Lookup("Lot No. Information"."Lot Strength Percent" WHERE("Item No." = FIELD("Item No."),
                                                                                     "Variant Code" = FIELD("Variant Code"),
                                                                                     "Lot No." = FIELD("Lot No.")));
            Caption = 'Lot Strength Percent';
            Editable = false;
            FieldClass = FlowField;
        }
        field(28; "Quantity on Hand"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" WHERE("Item No." = FIELD("Item No."),
                                                                              "Variant Code" = FIELD("Variant Code"),
                                                                              "Lot No." = FIELD("Lot No.")));
            Caption = 'Quantity on Hand';
            Editable = false;
            FieldClass = FlowField;
        }
        field(41; Select; Boolean)
        {
            Caption = 'Select';
        }
        field(42; "Re-Test"; Boolean)
        {
            Caption = 'Re-Test';
            Editable = false;
        }
        field(55; "Q/C Activity No."; Code[20])
        {
            Caption = 'Q/C Activity No.';
            TableRelation = "No. Series";
        }
        // P800122712
        field(56; "Sample Quantity Posted"; Decimal)
        {
            Caption = 'Sample Quantity Posted';
            CalcFormula = - sum("Item Ledger Entry".Quantity where("Item No." = Field("Item No."),
                                                                "Variant code" = Field("Variant code"),
                                                                "Lot No." = Field("Lot No."),
                                                                "Sample Test No." = Field("Test No.")));
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        // P800122712
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Lot No.", "Test No.")
        {
        }
        key(Key2; Status, "Schedule Date")
        {
        }
        key(Key3; "Q/C Activity No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        QCLine.Reset;
        QCLine.SetRange("Item No.", "Item No.");
        QCLine.SetRange("Variant Code", "Variant Code");
        QCLine.SetRange("Lot No.", "Lot No.");
        QCLine.SetRange("Test No.", "Test No.");
        QCLine.DeleteAll;
    end;

    trigger OnInsert()
    begin
        InsertActivityNo;   // P80037569
    end;

    var
        InventorySetup: Record "Inventory Setup";
        QCLine: Record "Quality Control Line";
        Text000: Label 'All Q/C tests must be done before you can set %1 To %2.';
        Text001: Label 'Test %1 must pass before you can set %2 To %3.';
        Text002: Label 'Are you SURE you want to PASS the Q/C?';
        Text003: Label 'Press ESC to continue...';
        Text004: Label 'Are you SURE you want to FAIL the Q/C?';
        HideValidationDialog: Boolean;
        P800QCFns: Codeunit "Process 800 Q/C Functions";
        NotQCAdminErrorTxt: Label 'You are not authorized to change the status. Contact your quality administrator.';

    procedure DeleteHeader()
    var
        QCHeader: Record "Quality Control Header";
        QCLine: Record "Quality Control Line";
        Text000: Label 'Only the last test set may be deleted.';
        Item: Record Item;
        CommCostMgmt: Codeunit "Commodity Cost Management";
    begin
        QCHeader.LockTable;

        TestField(Status, Status::Pending);

        QCHeader.SetRange("Item No.", "Item No.");
        QCHeader.SetRange("Variant Code", "Variant Code");
        QCHeader.SetRange("Lot No.", "Lot No.");
        QCHeader.SetFilter("Test No.", '>%1', "Test No.");
        if QCHeader.Find('-') then
            Error(Text000);

        QCLine.SetRange("Item No.", "Item No.");
        QCLine.SetRange("Variant Code", "Variant Code");
        QCLine.SetRange("Lot No.", "Lot No.");
        QCLine.SetRange("Test No.", "Test No.");
        if QCLine.Find('-') then
            repeat
                QCLine.TestField(Status, QCLine.Status::"Not Tested");
            until QCLine.Next = 0;

        Delete(true);

        // P8000902
        Item.Get("Item No.");
        if (Item."Comm. Payment Class Code" <> '') then
            CommCostMgmt.UpdateOrderOnQCTest(Rec);
        // P8000902
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;    // P80037569
    end;

    procedure InsertActivityNo()
    var
        InventorySetup: Record "Inventory Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        // P80037569
        InventorySetup.Get;
        if InventorySetup."Q/C Activity Nos." <> '' then
            "Q/C Activity No." := NoSeriesManagement.GetNextNo(InventorySetup."Q/C Activity Nos.", Today, true);
    end;

    procedure ActivityCount(ReTest: Boolean): Integer
    var
        QCHeader: Record "Quality Control Header";
    begin
        QCHeader := Rec;
        QCHeader.SetRecFilter();
        QCHeader.SetRange("Test No.");
        QCHeader.SetRange("Re-Test", ReTest);
        exit(QCHeader.Count())
    end;

    procedure SamplesEnabled(): Boolean
    var
        Process800QCFunctions: Codeunit "Process 800 Q/C Functions";
    begin
        // P800122712
        exit(Process800QCFunctions.SamplesEnabled());
    end;
}

