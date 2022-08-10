table 37002919 "Skip Logic Setup"
{
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic

    Caption = 'Skip Logic Setup';

    fields
    {
        field(2; "Value Class"; Option)
        {
            Caption = 'Value Class';
            OptionCaption = ' ,a,b,c';
            OptionMembers = " ",a,b,c;

            trigger OnValidate()
            begin
                SetLevel;
            end;
        }
        field(3; "Activity Class"; Option)
        {
            Caption = 'Activity Class';
            OptionCaption = ' ,A,B,C';
            OptionMembers = " ",A,B,C;

            trigger OnValidate()
            begin
                SetLevel;
            end;
        }
        field(4; Level; Integer)
        {
            BlankZero = true;
            Caption = 'Level';
            Editable = false;
        }
        field(5; Accept; Integer)
        {
            BlankZero = true;
            Caption = 'Accept';
            MinValue = 1;
        }
        field(6; Skip; Integer)
        {
            BlankZero = true;
            Caption = 'Skip';
            MinValue = 0;
        }
        field(7; Frequency; Integer)
        {
            Caption = 'Frequency';
            MinValue = 1;
            NotBlank = true;
        }
        field(8; "Rejected Level"; Integer)
        {
            Caption = 'Rejected Level';
            NotBlank = true;
            TableRelation = "Skip Logic Setup".Level WHERE("Value Class" = FIELD("Value Class"),
                                                            "Activity Class" = FIELD("Activity Class"));

            trigger OnValidate()
            begin
                if "Rejected Level" >= Level then
                    Error(RejectLevel, FieldCaption("Rejected Level"));
            end;
        }
        field(9; "Max Interval"; DateFormula)
        {
            Caption = 'Max Interval';
        }
    }

    keys
    {
        key(Key1; "Value Class", "Activity Class", Level)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        SkipLogicSetup: Record "Skip Logic Setup";
    begin
        SkipLogicSetup.SetRange("Value Class", "Value Class");
        SkipLogicSetup.SetRange("Activity Class", "Activity Class");
        if SkipLogicSetup.FindLast then
            if Level <> SkipLogicSetup.Level then
                Error(DeleteLastLevel);

        ResetTransactions;
    end;

    trigger OnInsert()
    begin
        if "Value Class" = 0 then
            Error(FieldMustBeSpecified, FieldCaption("Value Class"));

        if "Activity Class" = 0 then
            Error(FieldMustBeSpecified, FieldCaption("Value Class"));
    end;

    trigger OnModify()
    begin
        if "Value Class" = 0 then
            Error(FieldMustBeSpecified, FieldCaption("Value Class"));

        if "Activity Class" = 0 then
            Error(FieldMustBeSpecified, FieldCaption("Value Class"));

        if (Accept <> xRec.Accept) or (Skip <> xRec.Skip) or (Frequency <> xRec.Frequency) then
            ResetTransactions;
    end;

    trigger OnRename()
    begin
        Error(RenameNotAllowed, TableCaption);
    end;

    var
        RenameNotAllowed: Label 'You cannot rename a %1.';
        DeleteLastLevel: Label 'Only the last level may be deleted.';
        FieldMustBeSpecified: Label '%1 must be specified.';
        RejectLevel: Label '%1 must be less than the current level.';
        ResetWarning: Label 'If you make this change then all items with %1 ''%2'', %3 ''%4'', and Current Level ''%5'' will be reset.\Do you want to continue?';

    local procedure SetLevel()
    var
        SkipLogicSetup: Record "Skip Logic Setup";
    begin
        if ("Value Class" <> 0) and ("Activity Class" <> 0) then begin
            SkipLogicSetup.SetRange("Value Class", "Value Class");
            SkipLogicSetup.SetRange("Activity Class", "Activity Class");
            if SkipLogicSetup.FindLast then
                Level := SkipLogicSetup.Level + 1
            else
                Level := 1;
        end;
    end;

    local procedure ResetTransactions()
    var
        ItemQualitySkipLogicTrans: Record "Item Quality Skip Logic Trans.";
    begin
        ItemQualitySkipLogicTrans.SetRange("Value Class", "Value Class");
        ItemQualitySkipLogicTrans.SetRange("Activity Class", "Activity Class");
        ItemQualitySkipLogicTrans.SetRange("Current Level", Level);
        if ItemQualitySkipLogicTrans.IsEmpty then
            exit;

        if not Confirm(ResetWarning, false, FieldCaption("Value Class"), "Value Class", FieldCaption("Activity Class"), "Activity Class", Level) then
            Error('');

        ItemQualitySkipLogicTrans.SetRange("Current Level");

        ItemQualitySkipLogicTrans.FindSet(true);
        repeat
            ItemQualitySkipLogicTrans.SetRange("Item No.", ItemQualitySkipLogicTrans."Item No.");
            ItemQualitySkipLogicTrans.SetRange("Variant Code", ItemQualitySkipLogicTrans."Variant Code");
            ItemQualitySkipLogicTrans.SetRange("Source Type", ItemQualitySkipLogicTrans."Source Type");
            ItemQualitySkipLogicTrans.SetRange("Source No.", ItemQualitySkipLogicTrans."Source No.");

            ItemQualitySkipLogicTrans.FindLast;
            if ItemQualitySkipLogicTrans."Current Level" = Level then begin
                ItemQualitySkipLogicTrans.SetFilter("Current Level", '>=%1', Level);
                ItemQualitySkipLogicTrans.DeleteAll;
                ItemQualitySkipLogicTrans.SetRange("Current Level");
            end;

            ItemQualitySkipLogicTrans.SetRange("Item No.");
            ItemQualitySkipLogicTrans.SetRange("Variant Code");
            ItemQualitySkipLogicTrans.SetRange("Source Type");
            ItemQualitySkipLogicTrans.SetRange("Source No.");
        until ItemQualitySkipLogicTrans.Next = 0;
    end;
}

