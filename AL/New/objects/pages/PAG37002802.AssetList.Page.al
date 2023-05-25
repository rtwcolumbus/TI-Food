page 37002802 "Asset List"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Standard list  style for form assets
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   RENAMED - was "Assets"
    // 
    // PRW16.00.01
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Add controls for downtime
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 04 FEB 09y
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    //   Update Images for actions
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    Caption = 'Asset List';
    CardPageID = "Asset Card";
    Editable = false;
    PageType = List;
    SourceTable = Asset;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Asset Category Code"; "Asset Category Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Physical Location"; "Physical Location")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Total Cost"; "Total Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Labor Cost"; "Labor Cost")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Material Cost"; "Material Cost")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Contract Cost"; "Contract Cost")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Downtime (Hours)"; "Downtime (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Completed Work Order List";
                }
            }
        }
        area(factboxes)
        {
            part(Control1900000003; "Asset Details Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
                Visible = true;
            }
            part(AssetUsageFactBox; "Asset Usage FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
                Visible = false;
            }
            systempart(Control1900000005; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
            systempart(Control1900000006; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Asset")
            {
                Caption = '&Asset';
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    RunObject = Page "Maint. Ledger Entries";
                    RunPageLink = "Asset No." = FIELD("No.");
                    RunPageView = SORTING("Asset No.", "Entry Type", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                }
                action("Work Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Orders';
                    Image = Document;
                    RunObject = Page "Work Order List";
                    RunPageLink = "Asset No." = FIELD("No.");
                    RunPageView = SORTING("Asset No.");
                }
                action("PM Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'PM Orders';
                    Image = Document;
                    RunObject = Page "Preventive Maintenance Orders";
                    RunPageLink = "Asset No." = FIELD("No.");
                    RunPageView = SORTING("Asset No.", "Group Code", "Frequency Code");
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(FOODAsset),
                                  "No." = FIELD("No.");
                }
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(37002801),
                                      "No." = FIELD("No.");
                        ShortCutKey = 'Shift+Ctrl+D';
                    }
                    action("Dimensions-&Multiple")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;

                        trigger OnAction()
                        var
                            Asset: Record Asset;
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(Asset);
                            DefaultDimMultiple.SetMultiRecord(Asset, FieldNo("No.")); // P80073095
                            DefaultDimMultiple.RunModal;
                        end;
                    }
                }
                separator(Separator1102603036)
                {
                }
                action("Spare Parts")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Spare Parts';
                    Image = Components;

                    trigger OnAction()
                    begin
                        ShowSpares;
                    end;
                }
                action(DataCollectionLines)
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Data Collection Line" = R;
                    Caption = 'Data Collection Lines';
                    Image = EditLines;
                    RunObject = Page "Data Collection Lines";
                    RunPageLink = "Source ID" = CONST(37002801),
                                  "Source Key 1" = FIELD("No.");
                }
                action(Usage)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Usage';
                    Image = Troubleshoot;

                    trigger OnAction()
                    begin
                        ShowAssetUsage;
                    end;
                }
            }
        }
        area(creation)
        {
            action("Work Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Work Order';
                Image = Document;
                RunObject = Page "Work Order";
                RunPageLink = "Asset No." = FIELD("No.");
                RunPageMode = Create;
            }
        }
        area(reporting)
        {
            action("Asset List")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Asset List';
                Image = "Report";
                RunObject = Report "Asset List";
            }
            action("PM Master Schedule")
            {
                ApplicationArea = FOODBasic;
                Caption = 'PM Master Schedule';
                Image = "Report";
                RunObject = Report "PM Master Schedule";
            }
            separator(Separator37002001)
            {
            }
            action("PM Past Due")
            {
                ApplicationArea = FOODBasic;
                Caption = 'PM Past Due';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "PM Past Due";
            }
            separator(Separator37002002)
            {
            }
            action("Asset Cost Summary")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Asset Cost Summary';
                Image = "Report";
                RunObject = Report "Asset Cost Summary";
            }
            action("Asset History")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Asset History';
                Image = "Report";
                RunObject = Report "Asset History";
            }
            action("Work Order Summary")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Work Order Summary';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Work Order Summary";
            }
            action("Work Order History")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Work Order History';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Work Order History";
            }
        }
        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'New';

                actionref("Work Order_Promoted"; "Work Order")
                {
                }
            }
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(WorkOrders_Promoted; "Work Orders")
                {
                }
                actionref(PMOrders_Promoted; "PM Orders")
                {
                }
                actionref(SpareParts_Promoted; "Spare Parts")
                {
                }
                actionref(Usage_Promoted; Usage)
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Reports';

                actionref(AssetList_Promoted; "Asset List")
                {
                }
                actionref(PMMasterSchedule_Promoted; "PM Master Schedule")
                {
                }
                actionref(AssetCostSummary_Promoted; "Asset Cost Summary")
                {
                }
                actionref(AssetHistory_Promoted; "Asset History")
                {
                }
            }
        }
    }
}

