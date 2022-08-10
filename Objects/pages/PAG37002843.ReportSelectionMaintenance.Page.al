page 37002843 "Report Selection - Maintenance"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard "Report Selection" style form, adapted for maintenance
    // 
    // PR5.00.01
    // P8000599A, VerticalSoft, Don Bresee, 13 MAY 08
    //   Report Selections - SP1 change to Usage options, P800 option values increased by 12
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Report Selection - Maintenance';
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Report Selections";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field(ReportUsage2; ReportUsage2)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Usage';
                OptionCaption = 'Work Order';

                trigger OnValidate()
                begin
                    SetUsageFilter;
                    ReportUsage2OnAfterValidate;
                end;
            }
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Sequence; Sequence)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = Objects;
                }
                field("Report Caption"; "Report Caption")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    LookupPageID = Objects;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        NewRecord;
    end;

    trigger OnOpenPage()
    begin
        SetUsageFilter;
    end;

    var
        ReportUsage2: Option "Work Order";

    local procedure SetUsageFilter()
    begin
        FilterGroup(2);
        case ReportUsage2 of
            ReportUsage2::"Work Order":
                SetRange(Usage, Usage::FOODMWorkOrder); // P8000599A
        end;
        FilterGroup(0);
    end;

    local procedure ReportUsage2OnAfterValidate()
    begin
        CurrPage.Update;
    end;
}

