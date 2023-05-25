table 37002462 "Process Setup"
{
    // PR1.00, Myers Nissi, Jack Reynolds, 26 MAY 00, PR002
    //   New table to contain processing setup parameters
    //   Initial fields are for formula numbers and default UOM
    // 
    // PR1.00, Myers Nissi, Jack Reynolds, 26 MAY 00, PR003
    //   Field 4 - Batch Order Nos. - Code 10 - relate to No. Series
    //   Field 5 - Packaging Order Nos. - Code 10 - relate to No. Series
    //   Field 6 - Default Batch Location - Code 10 - relate to Location
    //   Field 7 - Default Batch Department - Code 10 - relate to Department
    //   Field 8 - Default Batch Project - Code 10 - relate to Project
    //   Field 9 - Default Batch Status - Option
    //   Field 10 - Batch Output Template - Code 10 - relate to P.O. Output
    //     Journal Template
    //   Field 11 - Batch Output Batch - Code 10 - relate to P.O. Output
    //     Journal Batch
    //   Field 12 - Batch Consumption Template - Code 10 - relate to P.O.
    //     Consump. Journal Template
    //   Field 13 - Batch Consumption Batch - Code 10 - relate to P.O.
    //     Consump. Journal Batch
    // 
    // PR1.00, Myers Nissi, Diane Fox, 24 OCT 00, PR008
    //   Field 14 - Initial Version Code - Code 10 - If Auto Version Numbering
    //      BOM/Formula is set to TRUE, then this is the starting value.
    // 
    // PR1.20
    //   New fields
    //    Process Nos.
    //    Default Process Location
    //    Default Process Department
    //    Default Process Project
    //    Default Process Status
    //    Process Output Template
    //    Process Output Batch
    //    Process Consumption Template
    //    Process Consumption Batch
    //    Process Order Nos.
    //    Process Default Populate Jnls
    //    Default Process Ticket
    //   Rename fields relating to Batch Ticket to Production Ticket
    // 
    // PR2.00
    //   Modified for dimensions
    // 
    // PR2.00.02
    //   Wrong table relation for "Process Output Batch" and "Process Consumption Batch"
    // 
    // PR2.00.05
    //   Add Seperate Package Order Boolean
    // 
    // PR3.10
    //   Change table relations to Item Journal Template and Item Journal Batch
    // 
    // PR3.70.05
    // P8000064A, Myers Nissi, Jack Reynolds, 02 JUL 04
    //   Field 31 - Batch Reporting Balancing - Option
    // 
    // PR3.70.06
    // P8000078A, Myers Nissi, Steve Post, 26 JUL 04
    //   Added Fields
    //    32 Default Sales Forecast Period Option Day,Week,Month
    //    33 Sales Forecast Average
    //    34 Last Sale Formula
    //    35 Excel Export Path
    //    36 Excel Import Path
    //    37 Print Ticket
    //    38 Ad Plan Nos.
    // 
    // P8000112A, Myers Nissi, Jack Reynolds, 10 SEP 04
    //   Remove None from Batch Reporting Balancing option string
    // 
    // PR4.00.02
    // P8000316A, VerticalSoft, Jack Reynolds, 31 MAR 06
    //   Add field for Batch Reporting Line Retention
    // 
    // PRW15.00.01
    // P8000570A, VerticalSoft, Jack Reynolds, 14 FEB 08
    //   Change Default Batch Status and Default Process Status
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Jack Reynolds, 11 JUN 10
    //   Remove disabled fields
    // 
    // PRW16.00.04
    // P8000875, VerticalSoft, Jack Reynolds, 14 OCT 10
    //   Add field "Forecast Time Fence "
    // 
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // P8001082, Columbus IT, Rick Tweedle, 05 JUL 12
    //   Added field "Pre-Processing Nos"
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management
    //   Expand BOM Version code to Code20
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Process Setup';
    LookupPageID = "Process Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Default Primary UOM"; Option)
        {
            Caption = 'Default Primary UOM';
            OptionCaption = 'Weight,Volume';
            OptionMembers = Weight,Volume;
        }
        field(3; "Formula Nos."; Code[20])
        {
            Caption = 'Formula Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Batch Order Nos."; Code[20])
        {
            Caption = 'Batch Order Nos.';
            TableRelation = "No. Series";
        }
        field(5; "Packaging Order Nos."; Code[20])
        {
            Caption = 'Packaging Order Nos.';
            TableRelation = "No. Series";
        }
        field(6; "Default Batch Location"; Code[10])
        {
            Caption = 'Default Batch Location';
            TableRelation = Location;
        }
        field(9; "Default Batch Status"; Option)
        {
            Caption = 'Default Batch Status';
            InitValue = Released;
            OptionCaption = ',,Firm Planned,Released';
            OptionMembers = ,,"Firm Planned",Released;
        }
        field(10; "Batch Output Template"; Code[10])
        {
            Caption = 'Batch Output Template';
            TableRelation = "Item Journal Template" WHERE(Type = CONST(Output));
        }
        field(11; "Batch Output Batch"; Code[10])
        {
            Caption = 'Batch Output Batch';
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Batch Output Template"));
        }
        field(12; "Batch Consumption Template"; Code[10])
        {
            Caption = 'Batch Consumption Template';
            TableRelation = "Item Journal Template" WHERE(Type = CONST(Consumption));
        }
        field(13; "Batch Consumption Batch"; Code[10])
        {
            Caption = 'Batch Consumption Batch';
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Batch Consumption Template"));
        }
        field(14; "Initial Version Code"; Code[20])
        {
            Caption = 'Initial Version Code';
        }
        field(15; "Default Batch Ticket"; Boolean)
        {
            Caption = 'Default Batch Ticket';
        }
        field(17; "Prod. Ticket Print Quality"; Boolean)
        {
            Caption = 'Prod. Ticket Print Quality';
            Description = 'PR1.20';
        }
        field(19; "Process Nos."; Code[20])
        {
            Caption = 'Process Nos.';
            Description = 'PR1.20';
            TableRelation = "No. Series";
        }
        field(20; "Default Process Location"; Code[10])
        {
            Caption = 'Default Process Location';
            Description = 'PR1.20';
            TableRelation = Location;
        }
        field(23; "Default Process Status"; Option)
        {
            Caption = 'Default Process Status';
            Description = 'PR1.20';
            InitValue = Released;
            OptionCaption = ',,Firm Planned,Released';
            OptionMembers = ,,"Firm Planned",Released;
        }
        field(24; "Process Output Template"; Code[10])
        {
            Caption = 'Process Output Template';
            Description = 'PR1.20';
            TableRelation = "Item Journal Template" WHERE(Type = CONST(Output));
        }
        field(25; "Process Output Batch"; Code[10])
        {
            Caption = 'Process Output Batch';
            Description = 'PR1.20';
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Process Output Template"));
        }
        field(26; "Process Consumption Template"; Code[10])
        {
            Caption = 'Process Consumption Template';
            Description = 'PR1.20';
            TableRelation = "Item Journal Template" WHERE(Type = CONST(Consumption));
        }
        field(27; "Process Consumption Batch"; Code[10])
        {
            Caption = 'Process Consumption Batch';
            Description = 'PR1.20';
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Process Consumption Template"));
        }
        field(28; "Process Order Nos."; Code[20])
        {
            Caption = 'Process Order Nos.';
            Description = 'PR1.20';
            TableRelation = "No. Series";
        }
        field(29; "Process Default Populate Jnls"; Boolean)
        {
            Caption = 'Process Default Populate Jnls';
            Description = 'PR1.20';
        }
        field(30; "Default Process Ticket"; Boolean)
        {
            Caption = 'Default Process Ticket';
            Description = 'PR1.20';
        }
        field(31; "Batch Reporting Balancing"; Option)
        {
            Caption = 'Batch Reporting Balancing';
            Description = 'PR3.70.05';
            OptionCaption = ' ,Output Matches Consumption,Consumption Matches Output';
            OptionMembers = " ","Output Matches Consumption","Consumption Matches Output";
        }
        field(32; "Batch Reporting Line Retention"; Option)
        {
            Caption = 'Batch Reporting Line Retention';
            OptionCaption = 'Save,Prompt,Delete';
            OptionMembers = Save,Prompt,Delete;
        }
        field(40; "Forecast Time Fence"; DateFormula)
        {
            Caption = 'Forecast Time Fence';
        }
        field(50; "Pre-Process Activity Nos."; Code[20])
        {
            Caption = 'Pre-Process Activity Nos.';
            Description = 'P8001082';
            TableRelation = "No. Series";
        }
        field(37002580; "Separate Package Order"; Boolean)
        {
            Caption = 'Separate Package Order';
            Description = 'PR2.00.05';
        }
        field(37002751; "Shop Calendar Priority"; Option)
        {
            Caption = 'Shop Calendar Priority';
            OptionCaption = 'Location,Resource Group';
            OptionMembers = Location,"Resource Group";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DimMgt: Codeunit DimensionManagement;
        Text001: Label 'must be specified';

    procedure ValidateShortcutDimCode(FieldType: Code[20]; FieldNo: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNo, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"Process Setup", FieldType, FieldNo, ShortcutDimCode);
        Modify;
    end;
}

