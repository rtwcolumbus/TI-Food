page 37002834 "Preventive Maintenance Orders"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style form for PM Orders
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 05 FEB 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformationP8000664, VerticalSoft, Jack Reynolds, 05 FEB 09
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds 10 JAN 17
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
    Caption = 'Preventive Maintenance Orders';
    CardPageID = "Preventive Maintenance Order";
    Editable = false;
    PageType = List;
    SourceTable = "Preventive Maintenance Order";
    SourceTableView = SORTING("Asset No.", "Group Code", "Frequency Code");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control37002002)
            {
                Editable = false;
                ShowCaption = false;
                field("Asset No."; "Asset No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Group Code"; "Group Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Frequency Code"; "Frequency Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Last PM Date"; "Last PM Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Last PM Usage"; "Last PM Usage")
                {
                    ApplicationArea = FOODBasic;
                    BlankNumbers = BlankNeg;
                }
                field("Last Work Order"; "Last Work Order")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Current Work Order"; "Current Work Order")
                {
                    ApplicationArea = FOODBasic;
                }
                field(NextPMDate; NextPMDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Next PM Date';
                }
                field("Work Requested (First Line)"; "Work Requested (First Line)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            part(Control1900000003; "Asset Details Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Asset No.");
                Visible = true;
            }
            part(AssetUsageFactBox; "Asset Usage FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Asset No.");
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
            group("&PM")
            {
                Caption = '&PM';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(FOODPMOrder),
                                  "No." = FIELD("Entry No.");
                }
                group(Dimenssions)
                {
                    Caption = 'Dimensions';
                    action(DimensionsSingle)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(37002819),
                                      "No." = FIELD("Entry No.");
                        ShortCutKey = 'Shift+Ctrl+D';
                    }
                    action(DimensionsMultiple)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;

                        trigger OnAction()
                        var
                            PMOrder: Record "Preventive Maintenance Order";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            // P80073095
                            CurrPage.SetSelectionFilter(PMOrder);
                            DefaultDimMultiple.SetMultiRecord(PMOrder, FieldNo("Entry No."));
                            DefaultDimMultiple.RunModal;
                        end;
                    }
                }
                separator(Separator1102603027)
                {
                }
                action(Labor)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Labor';
                    Image = ServiceMan;
                    RunObject = Page "PM Activities";
                    RunPageLink = "PM Entry No." = FIELD("Entry No.");
                    RunPageView = WHERE(Type = CONST(Labor));
                }
                action(Material)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Material';
                    Image = Inventory;
                    RunObject = Page "PM Materials";
                    RunPageLink = "PM Entry No." = FIELD("Entry No.");
                }
                action(Contract)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Contract';
                    Image = List;
                    RunObject = Page "PM Activities";
                    RunPageLink = "PM Entry No." = FIELD("Entry No.");
                    RunPageView = WHERE(Type = CONST(Contract));
                }
            }
        }
        area(processing)
        {
            action("PM Worksheet")
            {
                ApplicationArea = FOODBasic;
                Caption = 'PM Worksheet';
                Image = OpenWorksheet;
                RunObject = Page "PM Worksheet Names";
            }
        }
        area(reporting)
        {
            action("PM Master Schedule")
            {
                ApplicationArea = FOODBasic;
                Caption = 'PM Master Schedule';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "PM Master Schedule";
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
        }
        area(Promoted)
        {
            actionref(PMWorksheet_Promoted; "PM Worksheet")
            {
            }
            group(Category_Activities)
            {
                Caption = 'Activities';

                actionref(Labor_Promoted; Labor)
                {
                }
                actionref(Material_Promoted; Material)
                {
                }
                actionref(Contract_Promoted; Contract)
                {
                }
            }
        }
    }
}

