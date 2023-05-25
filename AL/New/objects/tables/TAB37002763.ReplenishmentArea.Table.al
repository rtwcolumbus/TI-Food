table 37002763 "Replenishment Area"
{
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // P8001082, Columbus IT, Rick Tweedle, 22 JUN 12
    //   Added Pre-Processing Staging Area
    // 
    // PRW17.00
    // P8001142, Columbus IT, Don Bresee, 09 MAR 13
    //   Rework Replenishment logic
    // 
    // PRW17.10.02
    // P8001279, Columbus IT, Jack Reynolds, 05 FEB 14
    //   Default replenishment area for equipment
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Replenishment Area';
    DrillDownPageID = "Replenishment Areas";
    LookupPageID = "Replenishment Areas";

    fields
    {
        field(1; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            begin
                CheckLocation;
            end;
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "To Bin Code"; Code[20])
        {
            Caption = 'To Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            begin
                CheckBin("To Bin Code");
            end;
        }
        field(5; "From Bin Code"; Code[20])
        {
            Caption = 'From Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            begin
                CheckBin("From Bin Code");
            end;
        }
        field(6; "Pre-Process Repl. Area Code"; Code[20])
        {
            Caption = 'Pre-Process Repl. Area Code';
            Description = 'P8001082';
            TableRelation = "Replenishment Area".Code WHERE("Location Code" = FIELD("Location Code"),
                                                             "Pre-Process Repl. Area" = CONST(true));

            trigger OnValidate()
            begin
                // P8001082
                if "Pre-Process Repl. Area Code" <> '' then
                    TestField("Pre-Process Repl. Area", false);
            end;
        }
        field(7; "Pre-Process Repl. Area"; Boolean)
        {
            Caption = 'Pre-Process Repl. Area';
            Description = 'P8001082';

            trigger OnValidate()
            begin
                // P8001082
                if "Pre-Process Repl. Area" then begin         // P8001279
                    TestField("Pre-Process Repl. Area Code", ''); // P8001279
                                                                  // P8001279
                    Resource.Reset;
                    Resource.SetRange("Location Code", "Location Code");
                    Resource.SetRange("Replenishment Area Code", Code);
                    if Resource.FindFirst then
                        Error(Text001, TableCaption, Code, Resource.TableCaption, Resource."No.");
                end
                // P8001279
                else
                    TestNotPreProcessArea;
            end;
        }
    }

    keys
    {
        key(Key1; "Location Code", "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }

    trigger OnDelete()
    begin
        if "Pre-Process Repl. Area" then // P8001082
            TestNotPreProcessArea;         // P8001082

        ItemReplArea.Reset;
        ItemReplArea.SetCurrentKey("Location Code", "Replenishment Area Code");
        ItemReplArea.SetRange("Location Code", "Location Code");
        ItemReplArea.SetRange("Replenishment Area Code", Code);
        ItemReplArea.DeleteAll(true);

        // P8001279
        Resource.Reset;
        Resource.SetRange("Location Code", "Location Code");
        Resource.SetRange("Replenishment Area Code", Code);
        Resource.ModifyAll("Replenishment Area Code", '');
        // P8001279
    end;

    trigger OnInsert()
    begin
        TestField("Location Code");
        if Evaluate("Pre-Process Repl. Area", GetFilter("Pre-Process Repl. Area")) then; // P800-MegaApp
    end;

    var
        ReplArea: Record "Replenishment Area";
        ItemReplArea: Record "Item Replenishment Area";
        Resource: Record Resource;
        Text001: Label '%1 %2 is assigned to %3 %4.';

    local procedure CheckLocation()
    var
        Location: Record Location;
    begin
        Location.Get("Location Code");
        Location.TestField("Bin Mandatory", true);
    end;

    local procedure CheckBin(BinCode: Code[20])
    var
        Location: Record Location;
        Bin: Record Bin;
    begin
        if (BinCode <> '') then begin
            TestField("Location Code");
            Location.Get("Location Code");
            if Location."Directed Put-away and Pick" then begin // P8000631A
                Location.TestField("Replenishment Zone Code");
                Bin.Get("Location Code", BinCode);
                Bin.TestField("Zone Code", Location."Replenishment Zone Code");
            end;                                                // P8000631A
        end;
    end;

    local procedure TestNotPreProcessArea()
    begin
        // P8001082
        ReplArea.SetRange("Location Code", "Location Code");
        ReplArea.SetRange("Pre-Process Repl. Area Code", Code);
        if ReplArea.FindFirst then
            ReplArea.FieldError("Pre-Process Repl. Area Code");
    end;

    procedure GetFromBin(LocationCode: Code[10]; ReplAreaCode: Code[20]): Code[20]
    begin
        // P8001142
        Get(LocationCode, ReplAreaCode);
        if "Pre-Process Repl. Area" then begin
            TestField("To Bin Code");
            exit("To Bin Code");
        end;
        TestField("From Bin Code");
        exit("From Bin Code");
    end;

    procedure GetToBin(LocationCode: Code[10]; ReplAreaCode: Code[20]): Code[20]
    begin
        // P8001142
        Get(LocationCode, ReplAreaCode);
        TestField("To Bin Code");
        exit("To Bin Code");
    end;
}

