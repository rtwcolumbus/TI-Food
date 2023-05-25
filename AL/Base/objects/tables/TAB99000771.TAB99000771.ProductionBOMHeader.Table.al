table 99000771 "Production BOM Header"
{
    // PR1.00
    //   Add processing to support formulas as a special type of BOM
    //     Assign number from appropriate number series depending on type
    //   New Process 800 fields
    //     Type
    //     Auto Version Numbering
    // 
    // PR1.20
    //   Add support for Item Process
    //   Add Process to Type OptionString
    //   New Fields
    //     Output Item No.
    //     Output Item Description
    // 
    // PR2.00.05
    //   Status - don't allow certification if BOM has variables and BOM is attached to an item
    // 
    // PR3.61.02
    //   Handled related record in Family table on Rename
    // 
    // PR3.70
    //   Relocate Status check for variables to Production BOM-Check codeunit
    // 
    // PR4.00
    //   Leftover local variable removed from OnValidate for Status
    // 
    // PRW15.00.01
    // P8000511A, VerticalSoft, Jack Reynolds, 12 SEP 07
    //   New function GetNextVersion that solves problem of SQL sorting of version numbers
    // 
    // P8000533A, VerticalSoft, Jack Reynolds, 15 OCT 07
    //   Fix problems with using correct number series for formulas
    // 
    // P8000534A, VerticalSoft, Jack Reynolds, 15 OCT 07
    //   Fix problem with wrong number series for AssitEdit function
    // 
    // PRW16.00.01
    // P8000678, VerticalSoft, Don Bresee, 23 FEB 09
    //   Add Genesis Integration fields
    // 
    // P8000705, VerticalSoft, Don Bresee, 16 JUN 09
    //   Add "Serving Size Specification" field for Genesis Integration
    // 
    // P8000707, VerticalSoft, Don Bresee, 11 JUL 09
    //   Add new fields for BOM Version and Recipe Weight
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001092, Columbus IT, Don Bresee, 20 AUG 12
    //   Add Variant Code for Item Processes
    //   Add logic for Co-Product Planning
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW19.01.01
    // P8007502, To Increase, Jack Reynolds, 28 JUL 16
    //   Correct problem with auto version numbering
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.2
    // P800153678, To Increase, Jack Reynolds, 13 SEP 22
    //   Allergen Permission Error

    Caption = 'Production BOM Header';
    DataCaptionFields = "No.", Description;
    DrillDownPageID = "Production BOM List";
    LookupPageID = "Production BOM List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                "Search Name" := Description;
            end;
        }
        field(11; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(12; "Search Name"; Code[100])
        {
            Caption = 'Search Name';
        }
        field(21; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemUnitOfMeasure: Record "Item Unit of Measure";
            begin
                if Status = Status::Certified then
                    FieldError(Status);
                Item.SetCurrentKey("Production BOM No.");
                Item.SetRange("Production BOM No.", "No.");
                if Item.FindSet() then
                    repeat
                        ItemUnitOfMeasure.Get(Item."No.", "Unit of Measure Code");
                    until Item.Next() = 0;
            end;
        }
        field(22; "Low-Level Code"; Integer)
        {
            Caption = 'Low-Level Code';
            Editable = false;
        }
        field(25; Comment; Boolean)
        {
            CalcFormula = Exist("Manufacturing Comment Line" WHERE("Table Name" = CONST("Production BOM Header"),
                                                                    "No." = FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            Editable = false;
        }
        field(43; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(45; Status; Enum "BOM Status")
        {
            Caption = 'Status';

            trigger OnValidate()
            var
                Item: Record Item;
                ProdBOMLineRec: Record "Production BOM Line";
                PlanningAssignment: Record "Planning Assignment";
                MfgSetup: Record "Manufacturing Setup";
                ProdBOMCheck: Codeunit "Production BOM-Check";
                IsHandled: Boolean;
            begin
                if (Status <> xRec.Status) and (Status = Status::Certified) then begin
                    ProdBOMLineRec.SetLoadFields(Type, "No.", "Variant Code");
                    ProdBOMLineRec.SetRange("Production BOM No.", "No.");
                    while ProdBOMLineRec.Next() <> 0 do begin
                        if Item.IsVariantMandatory(ProdBOMLineRec.Type = ProdBOMLineRec.Type::Item, ProdBOMLineRec."No.") then
                            ProdBOMLineRec.TestField("Variant Code");
                    end;
                    MfgSetup.LockTable();
                    MfgSetup.Get();
                    ProdBOMCheck.ProdBOMLineCheck("No.", '');
                    "Low-Level Code" := 0;
                    ProdBOMCheck.Run(Rec);
                    PlanningAssignment.NewBOM("No.");
                end;
                if Status = Status::Closed then begin
                    IsHandled := false;
                    OnValidateStatusOnBeforeConfirm(Rec, xRec, IsHandled);
                    If not IsHandled then
                        if Confirm(Text001, false) then begin
                            ProdBOMVersion.SetRange("Production BOM No.", "No.");
                            if ProdBOMVersion.Find('-') then
                                repeat
                                    ProdBOMVersion.Status := ProdBOMVersion.Status::Closed;
                                    ProdBOMVersion.Modify();
                                until ProdBOMVersion.Next() = 0;
                        end else
                            Status := xRec.Status;
                end;
            end;
        }
        field(50; "Version Nos."; Code[20])
        {
            Caption = 'Version Nos.';
            TableRelation = "No. Series";
        }
        field(51; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(37002460; "Mfg. BOM Type"; Option)
        {
            Caption = 'Mfg. BOM Type';
            Description = 'PR1.20';
            OptionCaption = 'BOM,Formula,Process';
            OptionMembers = BOM,Formula,Process;
        }
        field(37002461; "Auto Version Numbering"; Boolean)
        {
            Caption = 'Auto Version Numbering';
            Description = 'PR1.00';

            trigger OnValidate()
            begin
                // PR1.00 Begin
                ProcessSetup.Get;
                if (ProcessSetup."Initial Version Code" = '') and "Auto Version Numbering" then begin
                    Message(Text37002000);
                    "Auto Version Numbering" := false;
                end;
                // PR1.00 End
            end;
        }
        field(37002462; "Output Item No."; Code[20])
        {
            Caption = 'Output Item No.';
            Description = 'PR1.20';
            TableRelation = Item."No." WHERE("Item Type" = CONST(Intermediate));

            trigger OnValidate()
            var
                AllergenManagement: Codeunit "Allergen Management";
                P800Functions: Codeunit "Process 800 Functions";
            begin
                if P800Functions.AllergenInstalled() then // P800153678
                    AllergenManagement.CheckAllergenAssigned("Output Item No."); // P8006959
                CalcFields("Output Item Description"); // PR1.20
            end;
        }
        field(37002463; "Output Item Description"; Text[100])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Output Item No.")));
            Caption = 'Output Item Description';
            Description = 'PR1.20';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002464; "Output Type"; Option)
        {
            Caption = 'Output Type';
            Description = 'PR3.60';
            OptionCaption = 'Item,Family';
            OptionMembers = Item,Family;
        }
        field(37002465; "Output Variant Code"; Code[10])
        {
            Caption = 'Output Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Output Item No."));
        }
        field(37002860; "Genesis Recipe"; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
        }
        field(37002861; "Servings per BOM"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
        }
        field(37002862; "Serving Wgt. Quantity"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
        }
        field(37002863; "Serving Wgt. Measure"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
            OptionMembers = " ","Ounce-weight",Pound,Microgram,Milligram,Gram,Kilogram;
        }
        field(37002864; "Serving Size Specification"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
            OptionMembers = "Servings per BOM","Weight per Serving";
        }
        field(37002865; "Genesis Version No."; Code[10])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
        }
        field(37002866; "Recipe Wgt. Quantity"; Decimal)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
        }
        field(37002867; "Recipe Wgt. Measure"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
            ObsoleteTag = 'FOOD-16';
            OptionMembers = " ","Ounce-weight",Pound,Microgram,Milligram,Gram,Kilogram;
        }
        field(37002920; "Allergen Set ID"; Integer)
        {
            Caption = 'Allergen Set ID';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Search Name")
        {
        }
        key(Key3; Description)
        {
        }
        key(Key4; Status)
        {
        }
        key(Key5; "Output Item No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, Status)
        {
        }
    }

    trigger OnDelete()
    var
        Item: Record Item;
    begin
        Item.SetRange("Production BOM No.", "No.");
        if not Item.IsEmpty() then
            Error(Text000);

        // P8001030
        SKU.SetCurrentKey("Production BOM No.");
        SKU.SetRange("Production BOM No.", "No.");
        if SKU.Find('-') then
            Error(Text37002002);
        // P8001030

        ProdBOMLine.SetRange("Production BOM No.", "No.");
        ProdBOMLine.DeleteAll(true);

        ProdBOMVersion.SetRange("Production BOM No.", "No.");
        ProdBOMVersion.DeleteAll(true); // PR1.00

        MfgComment.SetRange("Table Name", MfgComment."Table Name"::"Production BOM Header");
        MfgComment.SetRange("No.", "No.");
        MfgComment.DeleteAll();

        // PR3.10
        if ("Mfg. BOM Type" = "Mfg. BOM Type"::Process) then
            if Family.Get("No.") then
                Family.Delete(true);
        // PR3.10
    end;

    trigger OnInsert()
    begin
        MfgSetup.Get();
        if "No." = '' then begin
            TestNoSeries;  // P8000533A
            NoSeriesMgt.InitSeries(GetNoSeriesCode, xRec."No. Series", 0D, "No.", "No. Series"); // P8000533A
        end;
        InitRecord; // PR1.00

        "Creation Date" := Today;

        if ProcessSetup."Initial Version Code" <> '' then // PR1.00
            "Auto Version Numbering" := true;               // PR1.00

        // PR3.60
        if ("Mfg. BOM Type" = "Mfg. BOM Type"::Process) and ("Output Type" = "Output Type"::Family) then begin
            Family.Init;
            Family.Validate("No.", "No.");
            Family.Validate(Description, Description);
            Family.Validate("Description 2", "Description 2");
            Family."Process Family" := true;
            if not Family.Insert(true) then
                Family.Modify(true);
        end;
        // PR3.60
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;

        // PR3.60
        if ("Mfg. BOM Type" = "Mfg. BOM Type"::Process) and ("Output Type" = "Output Type"::Family) then begin
            Family.Init;
            Family.Validate("No.", "No.");
            Family.Validate(Description, Description);
            Family.Validate("Description 2", "Description 2");
            Family."Process Family" := true;
            if not Family.Insert(true) then
                Family.Modify(true);
        end;
        // PR3.60
    end;

    trigger OnRename()
    begin
        if Status = Status::Certified then
            Error(Text002, TableCaption(), FieldCaption(Status), Format(Status));

        // PR3.61.02
        if ("Mfg. BOM Type" = "Mfg. BOM Type"::Process) and ("Output Type" = "Output Type"::Family) then begin
            if Family.Get(xRec."No.") then begin
                if Family.Get("No.") then begin
                    Family.Validate(Description, Description);
                    Family.Validate("Description 2", "Description 2");
                    Family."Process Family" := true;
                    Family.Modify(true);
                    Family.Get(xRec."No.");
                    Family.Delete(true);
                end else
                    Family.Rename("No.");
            end else begin
                Family.Init;
                Family.Validate("No.", "No.");
                Family.Validate(Description, Description);
                Family.Validate("Description 2", "Description 2");
                Family."Process Family" := true;
                Family.Insert(true);
            end;
        end;
        // PR3.61.02
    end;

    var
        Text000: Label 'This Production BOM is being used on Items.';
        Text001: Label 'All versions attached to the BOM will be closed. Close BOM?';
        MfgSetup: Record "Manufacturing Setup";
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersion: Record "Production BOM Version";
        ProdBOMLine: Record "Production BOM Line";
        MfgComment: Record "Manufacturing Comment Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text002: Label 'You cannot rename the %1 when %2 is %3.';
        ProcessSetup: Record "Process Setup";
        Text37002000: Label 'Initial Version Code in Process Setup must be non-blank to use Automatic Version Numbering.';
        Family: Record Family;
        Text37002001: Label '%1 is currently in use and may not be certified with variables.';
        SKU: Record "Stockkeeping Unit";
        Text37002002: Label 'This Production BOM is being used on Stockkeeping Units.';

    procedure AssistEdit(OldProdBOMHeader: Record "Production BOM Header"): Boolean
    var
        SeriesSelected: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeAsistEdit(Rec, OldProdBOMHeader, SeriesSelected, IsHandled);
        if IsHandled then
            exit(SeriesSelected);

        with ProdBOMHeader do begin
            ProdBOMHeader := Rec;
            TestNoSeries;   // P8000534A
            if NoSeriesMgt.SelectSeries(GetNoSeriesCode, OldProdBOMHeader."No. Series", "No. Series") then begin // P8000533A
                NoSeriesMgt.SetSeries("No.");
                Rec := ProdBOMHeader;
                exit(true);
            end;
        end;
    end;

    local procedure TestNoSeries(): Boolean
    begin
        // P8000533A
        case "Mfg. BOM Type" of
            "Mfg. BOM Type"::BOM:
                begin
                    MfgSetup.Get;
                    MfgSetup.TestField("Production BOM Nos.");
                end;
            "Mfg. BOM Type"::Formula:
                begin
                    ProcessSetup.Get;
                    ProcessSetup.TestField("Formula Nos.");
                end;
            "Mfg. BOM Type"::Process:
                begin
                    ProcessSetup.Get;
                    ProcessSetup.TestField("Process Nos.");
                end;
        end;
        // P8000533A
    end;

    local procedure GetNoSeriesCode(): Code[20]
    begin
        // P80053245 - Enlarge result
        // P8000533A
        case "Mfg. BOM Type" of
            "Mfg. BOM Type"::BOM:
                begin
                    MfgSetup.Get;
                    exit(MfgSetup."Production BOM Nos.");
                end;
            "Mfg. BOM Type"::Formula:
                begin
                    ProcessSetup.Get;
                    exit(ProcessSetup."Formula Nos.");
                end;
            "Mfg. BOM Type"::Process:
                begin
                    ProcessSetup.Get;
                    exit(ProcessSetup."Process Nos.");
                end;
        end;
        // P8000533A
    end;

    procedure InitRecord()
    begin
        ProcessSetup.Get; // PR1.20
    end;

    procedure GetNextVersion(): Code[10]
    var
        Version: Record "Production BOM Version";
        TempVersion: Record "Production BOM Version Code" temporary;
        ProcessSetup: Record "Process Setup";
    begin
        // P8000511A
        if "Auto Version Numbering" then begin
            Version.Reset;
            Version.SetRange("Production BOM No.", "No.");
            Version.SetRange(Version.Type, "Mfg. BOM Type");
            if Version.FindSet then begin
                repeat
                    TempVersion."Version Code" := Version."Version Code"; // P8007502
                    TempVersion.Insert;
                until Version.Next = 0;
                TempVersion.FindLast;
                exit(IncStr(TempVersion."Version Code"));
            end else begin
                ProcessSetup.Get;
                exit(ProcessSetup."Initial Version Code");
            end;
        end;
    end;

    procedure IsProdFamilyBOM(): Boolean
    begin
        exit(("Mfg. BOM Type" = "Mfg. BOM Type"::Process) and ("Output Type" = "Output Type"::Family)); // P8001092
    end;

    procedure GetCoProdBOMFactor(VersionCode: Code[10]; ItemNo: Code[20]): Decimal
    var
        ProdBOMVersion: Record "Production BOM Version";
        FamilyLine: Record "Family Line";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        // P8001092
        if IsProdFamilyBOM() then
            if ProdBOMVersion.Get("No.", VersionCode) then
                if FamilyLine.FindOutputItem("No.", ItemNo) then
                    exit(ProdBOMVersion.GetInputQtyBase() /
                         (FamilyLine.Quantity * P800UOMFns.UOMtoMetricBase(FamilyLine."Unit of Measure Code")));
        exit(1);
    end;

    procedure IsPrimaryCoProduct(ItemNo: Code[20]): Boolean
    var
        FamilyLine: Record "Family Line";
    begin
        // P8001092
        if FamilyLine.FindOutputItem("No.", ItemNo) then
            exit(FamilyLine.IsPrimaryCoProduct());
    end;

    procedure ShowAllergens()
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P8006959
        AllergenManagement.ShowAllergenSet(Rec);
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnBeforeAsistEdit(var ProductionBOMHeader: Record "Production BOM Header"; OldProductionBOMHeader: Record "Production BOM Header"; var SeriesSelected: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateStatusOnBeforeConfirm(var ProductionBOMHeader: Record "Production BOM Header"; xProductionBOMHeader: Record "Production BOM Header"; var IsHandled: Boolean)
    begin
    end;
}

