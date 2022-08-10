table 37002824 "PM Worksheet"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Worksheet used to review suggested PM work orders and to create work orders

    Caption = 'PM Worksheet';

    fields
    {
        field(1; "PM Worksheet Name"; Code[10])
        {
            Caption = 'PM Worksheet Name';
            Editable = false;
            TableRelation = "PM Worksheet Name";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(3; "PM Entry No."; Code[20])
        {
            Caption = 'PM Entry No.';
            Editable = false;
        }
        field(4; "Master PM"; Boolean)
        {
            Caption = 'Master PM';
            Editable = false;
        }
        field(5; "Create Order"; Boolean)
        {
            Caption = 'Create Order';

            trigger OnValidate()
            begin
                if "Create Order" then begin
                    if (not "Master PM") and ("Group Code" <> '') then begin
                        PMWksh := Rec;
                        PMWksh.SetRange("PM Worksheet Name", "PM Worksheet Name");
                        PMWksh.SetRange("Asset No.", "Asset No.");
                        PMWksh.SetRange("Group Code", "Group Code");
                        PMWksh.SetRange("Create Order", true);
                        if PMWksh.Next(-1) = 0 then begin
                            "Master PM" := true;
                            if PMWksh.Next <> 0 then begin
                                PMWksh."Master PM" := false;
                                PMWksh.Modify;
                            end;
                        end;
                    end;
                end else begin
                    if "Master PM" and ("Group Code" <> '') then begin
                        "Master PM" := false;
                        PMWksh := Rec;
                        PMWksh.SetRange("PM Worksheet Name", "PM Worksheet Name");
                        PMWksh.SetRange("Asset No.", "Asset No.");
                        PMWksh.SetRange("Group Code", "Group Code");
                        PMWksh.SetRange("Create Order", true);
                        if PMWksh.Next <> 0 then begin
                            PMWksh."Master PM" := true;
                            PMWksh.Modify;
                        end;
                    end;
                end;
            end;
        }
        field(11; "Asset No."; Code[20])
        {
            Caption = 'Asset No.';
            Editable = false;
            TableRelation = Asset;
        }
        field(12; "Group Code"; Code[10])
        {
            Caption = 'Group Code';
            Editable = false;
        }
        field(13; "Frequency Code"; Code[10])
        {
            Caption = 'Frequency Code';
            Editable = false;
            TableRelation = "PM Frequency";
        }
        field(14; "Last PM Date"; Date)
        {
            Caption = 'Last PM Date';
            Editable = false;
        }
        field(15; "Due Date"; Date)
        {
            Caption = 'Due Date';
            Editable = false;
        }
        field(16; "Create Date"; Date)
        {
            Caption = 'Create Date';
            Editable = false;
        }
        field(17; "Days Since Last PM"; Integer)
        {
            Caption = 'Days Since Last PM';
            Editable = false;
        }
        field(18; "Work Requested"; Text[80])
        {
            Caption = 'Work Requested';
        }
    }

    keys
    {
        key(Key1; "PM Worksheet Name", "Line No.")
        {
        }
        key(Key2; "Asset No.", "Group Code", "Days Since Last PM")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PMWksh: Record "PM Worksheet";
}

