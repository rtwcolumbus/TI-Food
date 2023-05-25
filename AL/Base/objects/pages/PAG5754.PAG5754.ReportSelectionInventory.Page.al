page 5754 "Report Selection - Inventory"
{
    // PR3.70.04
    // P8000036B, Myers Nissi, Jack Reynolds, 15 MAY 04
    //   Usage - add Container as an option
    //   SetUsageFilter - add code for Container
    // 
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Add Repack Order as usage option
    // 
    // PR5.00.01
    // P8000599A, VerticalSoft, Don Bresee, 13 MAY 08
    //   Report Selections - SP1 change to Usage options, P800 option values increased by 12
    // 
    // PRW121.0
    // P800155629, To Increase, Jack Reynolds, 07 NOV 22
    //   Upgrade to 21.0 - FOOD options for InitUsageFilter

    ApplicationArea = Basic, Suite;
    Caption = 'Report Selection - Inventory';
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Report Selections";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(ReportUsage2; ReportUsage2)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Usage';
                ToolTip = 'Specifies which type of document the report is used for.';

                trigger OnValidate()
                begin
                    SetUsageFilter(true);
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a number that indicates where this report is in the printing order.';
                }
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the object ID of the report.';
                }
                field("Report Caption"; Rec."Report Caption")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the display name of the report.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.NewRecord();
    end;

    trigger OnOpenPage()
    begin
        InitUsageFilter();
        SetUsageFilter(false);
    end;

    var
        ReportUsage2: Enum "Report Selection Usage Inventory";

    local procedure SetUsageFilter(ModifyRec: Boolean)
    begin
        if ModifyRec then
            if Rec.Modify() then;
        Rec.FilterGroup(2);
        case ReportUsage2 of
            "Report Selection Usage Inventory"::"Transfer Order":
                Rec.SetRange(Usage, "Report Selection Usage"::Inv1);
            "Report Selection Usage Inventory"::"Transfer Shipment":
                Rec.SetRange(Usage, "Report Selection Usage"::Inv2);
            "Report Selection Usage Inventory"::"Transfer Receipt":
                Rec.SetRange(Usage, "Report Selection Usage"::Inv3);
            "Report Selection Usage Inventory"::"Inventory Period Test":
                Rec.SetRange(Usage, "Report Selection Usage"::"Invt.Period Test");
            "Report Selection Usage Inventory"::"Assembly Order":
                Rec.SetRange(Usage, "Report Selection Usage"::"Asm.Order");
            "Report Selection Usage Inventory"::"Posted Assembly Order":
                Rec.SetRange(Usage, "Report Selection Usage"::"P.Asm.Order");
            "Report Selection Usage Inventory"::"Phys. Invt. Order":
                Rec.SetRange(Usage, "Report Selection Usage"::"Phys.Invt.Order");
            "Report Selection Usage Inventory"::"Phys. Invt. Order Test":
                Rec.SetRange(Usage, "Report Selection Usage"::"Phys.Invt.Order Test");
            "Report Selection Usage Inventory"::"Phys. Invt. Recording":
                Rec.SetRange(Usage, "Report Selection Usage"::"Phys.Invt.Rec.");
            "Report Selection Usage Inventory"::"Posted Phys. Invt. Order":
                Rec.SetRange(Usage, "Report Selection Usage"::"P.Phys.Invt.Order");
            "Report Selection Usage Inventory"::"Posted Phys. Invt. Recording":
                Rec.SetRange(Usage, "Report Selection Usage"::"P.Phys.Invt.Rec.");
            "Report Selection Usage Inventory"::"Direct Transfer":
                Rec.SetRange(Usage, "Report Selection Usage"::"P.Direct Transfer");
            "Report Selection Usage Inventory"::"Inventory Receipt":
                Rec.SetRange(Usage, "Report Selection Usage"::"Inventory Receipt");
            "Report Selection Usage Inventory"::"Inventory Shipment":
                Rec.SetRange(Usage, "Report Selection Usage"::"Inventory Shipment");
            "Report Selection Usage Inventory"::"Posted Inventory Receipt":
                Rec.SetRange(Usage, "Report Selection Usage"::"P.Inventory Receipt");
            "Report Selection Usage Inventory"::"Posted Inventory Shipment":
                Rec.SetRange(Usage, "Report Selection Usage"::"P.Inventory Shipment");
            ReportUsage2::FOODContainer:               // PR3.70.04
                Rec.SetRange(Usage, Usage::FOODContainer); // PR3.70.04, P8000599A
            ReportUsage2::FOODRepackOrder:                // P8000496A
                Rec.SetRange(Usage, Usage::FOODRepackOrder); // P8000496A, P8000599A
        end;
        OnSetUsageFilterOnAfterSetFiltersByReportUsage(Rec, ReportUsage2);
        Rec.FilterGroup(0);
        CurrPage.Update();
    end;

    local procedure InitUsageFilter()
    var
        NewReportUsage: Enum "Report Selection Usage";
    begin
        if Rec.GetFilter(Usage) <> '' then begin
            if Evaluate(NewReportUsage, Rec.GetFilter(Usage)) then
                case NewReportUsage of
                    "Report Selection Usage"::"Inv1":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Transfer Order";
                    "Report Selection Usage"::"Inv2":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Transfer Shipment";
                    "Report Selection Usage"::"Inv3":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Transfer Receipt";
                    "Report Selection Usage"::"Invt.Period Test":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Inventory Period Test";
                    "Report Selection Usage"::"Asm.Order":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Assembly Order";
                    "Report Selection Usage"::"P.Asm.Order":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Posted Assembly Order";
                    "Report Selection Usage"::"Phys.Invt.Order":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Phys. Invt. Order";
                    "Report Selection Usage"::"Phys.Invt.Order Test":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Phys. Invt. Order Test";
                    "Report Selection Usage"::"Phys.Invt.Rec.":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Phys. Invt. Recording";
                    "Report Selection Usage"::"P.Phys.Invt.Order":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Posted Phys. Invt. Order";
                    "Report Selection Usage"::"P.Phys.Invt.Rec.":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Posted Phys. Invt. Recording";
                    "Report Selection Usage"::"P.Direct Transfer":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Direct Transfer";
                    "Report Selection Usage"::"Inventory Receipt":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Inventory Receipt";
                    "Report Selection Usage"::"Inventory Shipment":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Inventory Shipment";
                    "Report Selection Usage"::"P.Inventory Receipt":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Posted Inventory Receipt";
                    "Report Selection Usage"::"P.Inventory Shipment":
                        ReportUsage2 := "Report Selection Usage Inventory"::"Posted Inventory Shipment";
                    // P800155629
                    "Report Selection Usage"::FOODContainer:
                        ReportUsage2 := "Report Selection Usage Inventory"::FOODContainer;
                    "Report Selection Usage"::FOODRepackOrder:
                        ReportUsage2 := "Report Selection Usage Inventory"::FOODRepackOrder;
                    // P800155629
                    else
                        OnInitUsageFilterOnElseCase(NewReportUsage, ReportUsage2);
                end;
            Rec.SetRange(Usage);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetUsageFilterOnAfterSetFiltersByReportUsage(var Rec: Record "Report Selections"; ReportUsage2: Enum "Report Selection Usage Inventory")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitUsageFilterOnElseCase(ReportUsage: Enum "Report Selection Usage"; var ReportUsage2: Enum "Report Selection Usage Inventory")
    begin
    end;
}

