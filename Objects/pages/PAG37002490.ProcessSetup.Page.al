page 37002490 "Process Setup"
{
    // PR1.20
    //   Process Setup card to replace several cards
    // 
    // PR2.00
    //   Modifed for dimensions
    //   Removed default locations
    // 
    // PR2.00.05
    //   Added new Seperate Package Order Boolean
    // 
    // PR3.70.05
    // P8000064A, Myers Nissi, Jack Reynolds, 02 JUL 04
    //   Add controls for Batch Report Balancing to Production tab
    // 
    // PR3.70.06
    // P8000115A, Myers Nissi, Jack Reynolds, 13 SEP 04
    //   Set InsertAllowed and DeleteAllowed to No
    // 
    // PR4.00.02
    // P8000316A, VerticalSoft, Jack Reynolds, 31 MAR 06
    //   Add control for Batch Reporting Line Retention
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.04
    // P8000875, VerticalSoft, Jack Reynolds, 14 OCT 10
    //   Add field "Forecast Time Fence "
    // 
    // P8000877, Columbus IT, Jack Reynolds, 10 MAR 11
    //   Remove Separate Paclage Orders
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001082, Columbus IT, Rick Tweedle, 05 JUL 12
    //   Added field "Pre-Processing Nos"
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Process Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Process Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Formula)
            {
                Caption = 'Formula';
                field("Formula Nos."; "Formula Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(DefaultPrimaryUOMFormula; "Default Primary UOM")
                {
                    ApplicationArea = FOODBasic;
                }
                field("InitialVersionCodFormula>"; "Initial Version Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Item Process")
            {
                Caption = 'Item Process';
                field("Process Nos."; "Process Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(DefaultPrimaryUOMProcess; "Default Primary UOM")
                {
                    ApplicationArea = FOODBasic;
                }
                field(InitialVersionCodeProcess; "Initial Version Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Planning)
            {
                Caption = 'Planning';
                field("Forecast Time Fence"; "Forecast Time Fence")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shop Calendar Priority"; "Shop Calendar Priority")
                {
                    ApplicationArea = FOODBasic;
                }
                group("Batch Orders")
                {
                    Caption = 'Batch Orders';
                    field("Batch Order Nos."; "Batch Order Nos.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Packaging Order Nos."; "Packaging Order Nos.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Default Batch Status"; "Default Batch Status")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("BatchShortcutDimCode[1]"; BatchShortcutDimCode[1])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = StrSubstNo(Text000, '1,2,1');

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupShortcutDimCode('BATCH', 1, BatchShortcutDimCode[1]);
                        end;

                        trigger OnValidate()
                        begin
                            ValidateShortcutDimCode('BATCH', 1, BatchShortcutDimCode[1]);
                        end;
                    }
                    field("BatchShortcutDimCode[2]"; BatchShortcutDimCode[2])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = StrSubstNo(Text000, '1,2,2');

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupShortcutDimCode('BATCH', 2, BatchShortcutDimCode[2]);
                        end;

                        trigger OnValidate()
                        begin
                            ValidateShortcutDimCode('BATCH', 2, BatchShortcutDimCode[2]);
                        end;
                    }
                }
                group("Process Orders")
                {
                    Caption = 'Process Orders';
                    field("Process Order Nos."; "Process Order Nos.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Default Process Ticket"; "Default Process Ticket")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Default Ticket';
                    }
                    field("Process Default Populate Jnls"; "Process Default Populate Jnls")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Default Populate Journals';
                    }
                    field("Default Process Status"; "Default Process Status")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("ProcessShortcutDimCode[1]"; ProcessShortcutDimCode[1])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = StrSubstNo(Text000, '1,2,1');

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupShortcutDimCode('PROCESS', 1, ProcessShortcutDimCode[1]);
                        end;

                        trigger OnValidate()
                        begin
                            ValidateShortcutDimCode('PROCESS', 1, ProcessShortcutDimCode[1]);
                        end;
                    }
                    field("ProcessShortcutDimCode[2]"; ProcessShortcutDimCode[2])
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = StrSubstNo(Text000, '1,2,2');

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupShortcutDimCode('PROCESS', 2, ProcessShortcutDimCode[2]);
                        end;

                        trigger OnValidate()
                        begin
                            ValidateShortcutDimCode('PROCESS', 2, ProcessShortcutDimCode[2]);
                        end;
                    }
                }
            }
            group(Production)
            {
                Caption = 'Production';
                group(Control37002022)
                {
                    Caption = 'Batch Orders';
                    field("Batch Output Template"; "Batch Output Template")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Output Journal Template Name';
                    }
                    field("Batch Output Batch"; "Batch Output Batch")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Output Journal Batch Name';
                    }
                    field("Batch Consumption Template"; "Batch Consumption Template")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Consumption Journal Template Name';
                    }
                    field("Batch Consumption Batch"; "Batch Consumption Batch")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Consumption Journal Batch Name';
                    }
                    field("Batch Reporting Balancing"; "Batch Reporting Balancing")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Batch Reporting Line Retention"; "Batch Reporting Line Retention")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                group(Control37002000)
                {
                    Caption = 'Process Orders';
                    field("Process Output Template"; "Process Output Template")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Output Journal Template Name';
                    }
                    field("Process Output Batch"; "Process Output Batch")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Output Journal Batch Name';
                    }
                    field("Process Consumption Template"; "Process Consumption Template")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Consumption Journal Template Name';
                    }
                    field("Process Consumption Batch"; "Process Consumption Batch")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Consumption Journal Batch Name';
                    }
                }
                group("Pre-Process")
                {
                    Caption = 'Pre-Process';
                    field("Pre-Process Activity Nos."; "Pre-Process Activity Nos.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
            }
            group("Production Ticket")
            {
                Caption = 'Production Ticket';
                field("Prod. Ticket Print Quality"; "Prod. Ticket Print Quality")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Print Quality';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900000007; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000008; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Dimensions)
            {
                Caption = 'Dimensions';
                action("Default &Batch Order Dimensions")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Default &Batch Order Dimensions';
                    Image = DefaultDimension;

                    trigger OnAction()
                    begin
                        EditDimensions('BATCH'); // P8001133
                    end;
                }
                action("Default &Process Order Dimensions")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Default &Process Order Dimensions';
                    Image = DefaultDimension;

                    trigger OnAction()
                    begin
                        EditDimensions('PROCESS'); // P8001133
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;

        case BegTab of
            'FORMULA':
                ;
            'ITEM PROCESS':
                ;
            'PLANNING':
                ;
            'PRODUCTION':
                ;
            'PROD TICKET':
                ;
        end;

        ShowShortcutDimCode(BatchShortcutDimCode, ProcessShortcutDimCode); // PR2.00
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        BegTab: Code[20];
        BatchShortcutDimCode: array[8] of Code[20];
        ProcessShortcutDimCode: array[8] of Code[20];
        Text000: Label '%1,Default ';

    procedure BeginningTab(TabName: Code[20])
    begin
        BegTab := TabName;
    end;

    procedure LookupShortcutDimCode(FieldType: Code[20]; FieldNo: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNo, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"Process Setup", FieldType, FieldNo, ShortcutDimCode);
    end;

    procedure ShowShortcutDimCode(var BatchShortcutDimCode: array[8] of Code[20]; var ProcessShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.ShowDefaultDim(DATABASE::"Process Setup", 'BATCH', BatchShortcutDimCode);
        DimMgt.ShowDefaultDim(DATABASE::"Process Setup", 'PROCESS', ProcessShortcutDimCode);
    end;

    procedure EditDimensions("Code": Code[20])
    var
        DefaultDim: Record "Default Dimension";
        DefaultDimensions: Page "Default Dimensions";
    begin
        // P8001133
        DefaultDim.FilterGroup(2);
        DefaultDim.SetRange("Table ID", DATABASE::"Process Setup");
        DefaultDim.SetRange("No.", Code);
        DefaultDim.FilterGroup(0);
        DefaultDimensions.SetTableView(DefaultDim);
        DefaultDimensions.RunModal;
        case Code of
            'BATCH':
                DimMgt.ShowDefaultDim(DATABASE::"Process Setup", 'BATCH', BatchShortcutDimCode);
            'PROCESS':
                DimMgt.ShowDefaultDim(DATABASE::"Process Setup", 'PROCESS', ProcessShortcutDimCode);
        end;
    end;
}

