table 37002920 Allergen
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // P80050544, To-Increase, Dayakar Battini, 15 MAR 18
    //   CheckRecordHasUsageRestrictions() parameter changed by MS.
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Allergen';
    LookupPageID = Allergens;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Allergen ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Allergen ID';
        }
        field(4; Blocked; Boolean)
        {
            Caption = 'Blocked';
            InitValue = true;

            trigger OnValidate()
            var
                RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
            begin
                if not Blocked then
                    RecordRestrictionMgt.CheckRecordHasUsageRestrictions(Rec);  // Standard parameter changed

                if Blocked then
                    if IsUsed then
                        FieldError(Blocked, Text002);
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        AllergenSetEntry: Record "Allergen Set Entry";
    begin
        AllergenSetEntry.SetRange("Allergen ID", "Allergen ID");
        if not AllergenSetEntry.IsEmpty then
            Error(Text001, TableCaption);
    end;

    trigger OnRename()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        ApprovalsMgmt.RenameApprovalEntries(xRec.RecordId, RecordId);
    end;

    var
        Text001: Label '%1 has been used and cannot be deleted.';
        Text002: Label 'may not be set';

    procedure IsUsed(): Boolean
    var
        AllergenPresenceItem: Query "Allergen Presence-Item-Direct";
        AllergenPresenceUnapproved: Query "Allergen Presence-Unapproved";
        AllergenPresenceBOMVersion: Query "Allergen Presence-BOM Version";
    begin
        AllergenPresenceItem.SetRange(Code, Code);
        if AllergenPresenceItem.Open then
            if AllergenPresenceItem.Read then
                exit(true);

        AllergenPresenceUnapproved.SetRange(Code, Code);
        if AllergenPresenceUnapproved.Open then
            if AllergenPresenceUnapproved.Read then
                exit(true);

        AllergenPresenceBOMVersion.SetRange(Code, Code);
        if AllergenPresenceBOMVersion.Open then
            if AllergenPresenceBOMVersion.Read then
                exit(true);
    end;

    procedure ShowWherePresent()
    var
        AllergenPresence: Page "Allergen Presence";
    begin
        AllergenPresence.SetAllergen(Rec);
        AllergenPresence.RunModal;
    end;
}

