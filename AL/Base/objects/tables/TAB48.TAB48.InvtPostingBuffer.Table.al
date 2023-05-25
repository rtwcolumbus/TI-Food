table 48 "Invt. Posting Buffer"
{
    // PR3.60.01
    //   Add options for writeoff accounts to Account Type OptionString
    // 
    // PR3.70.05
    // P8000062B, Myers Nissi, Jack Reynolds, 18 JUN 04
    //   Field 1 - Account Type
    //   Field 37002660 - Extra Charge Code - Code 20
    //   Primary Key - Account Type,Posting Group 1,Posting Group 2,Extra Charge Code,Dimension Entry No.
    // 
    // PR4.00.04
    // P8000375A, VerticalSoft, Jack Reynolds, 08 SEP 06
    //   Add ABC Direct,ABC Overhead to option string for Account Type
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Modified to support extra charges and ABC detail with changes to inventory to G/L posting
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Invt. Posting Buffer';
    ReplicateData = false;
#if CLEAN21
    TableType = Temporary;
#else
    ObsoleteReason = 'This table will be marked as temporary. Make sure you are not using this table to store records.';
    ObsoleteState = Pending;
    ObsoleteTag = '21.0';
#endif

    fields
    {
        field(1; "Account Type"; Enum "Invt. Posting Buffer Account Type")
        {
            Caption = 'Account Type';
            DataClassification = SystemMetadata;
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
        }
        field(3; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            DataClassification = SystemMetadata;
        }
        field(4; "Dimension Entry No."; Integer)
        {
            Caption = 'Dimension Entry No.';
            DataClassification = SystemMetadata;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(6; "Amount (ACY)"; Decimal)
        {
            Caption = 'Amount (ACY)';
            DataClassification = SystemMetadata;
        }
        field(7; "Interim Account"; Boolean)
        {
            Caption = 'Interim Account';
            DataClassification = SystemMetadata;
        }
        field(8; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
        field(9; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
        }
        field(10; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = SystemMetadata;
        }
        field(11; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = SystemMetadata;
        }
        field(12; Negative; Boolean)
        {
            Caption = 'Negative';
            DataClassification = SystemMetadata;
        }
        field(13; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(14; "Bal. Account Type"; Enum "Invt. Posting Buffer Account Type")
        {
            Caption = 'Bal. Account Type';
            DataClassification = SystemMetadata;
        }
        field(15; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            DataClassification = SystemMetadata;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(37002660; "Additional Posting Code"; Code[20])
        {
            Caption = 'Additional Posting Code';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Posting Date", "Account Type", "Location Code", "Inventory Posting Group", "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Dimension Set ID", "Additional Posting Code", Negative, "Bal. Account Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    procedure UseInvtPostSetup(): Boolean
    var
        UseInventoryPostingSetup: Boolean;
    begin
        UseInventoryPostingSetup :=
          "Account Type" in
          ["Account Type"::Inventory,
           "Account Type"::"Inventory (Interim)",
           "Account Type"::FOODWriteoffCompany, // PR3.61.01
           "Account Type"::FOODWriteoffVendor,  // PR3.61.01
           "Account Type"::"WIP Inventory",
           "Account Type"::"Material Variance",
           "Account Type"::"Capacity Variance",
           "Account Type"::"Subcontracted Variance",
           "Account Type"::"Cap. Overhead Variance",
           "Account Type"::"Mfg. Overhead Variance"];

        OnUseInvtPostSetup(Rec, UseInventoryPostingSetup);

        exit(UseInventoryPostingSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUseInvtPostSetup(var InvtPostingBuffer: Record "Invt. Posting Buffer"; var UseInventoryPostingSetup: Boolean)
    begin
    end;

    procedure UseECPostingSetup(): Boolean
    begin
        // P8000466A
        exit(
          "Account Type" in
          ["Account Type"::FOODInvtAccrualECInterim,
           "Account Type"::FOODDirectCostAppliedEC]);
    end;

    procedure UseABCDetail(): Boolean
    begin
        // P8000466A
        exit(
          "Account Type" in
          ["Account Type"::FOODABCDirect,
           "Account Type"::FOODABCOverhead]);
    end;
}

