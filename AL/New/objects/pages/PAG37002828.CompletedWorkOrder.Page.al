page 37002828 "Completed Work Order"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Same as Work Order form except for completed wortk orders
    // 
    // P8000336A, VerticalSoft, Jack Reynolds, 14 SEP 06
    //   Add controls to General tab for Standing Order
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Add controls for material and contract account
    // 
    // PRW16.00.01
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Add controls for downtime
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 10 FEB 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // P8000719, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Support for combined maintenance journal
    // 
    // PRW16.00.03
    // P8000819, VerticalSoft, Jack Reynolds, 30 APR 10
    //   Replace parts for work request and corrective action with multi-line text box
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds 10 JAN 17
    //   Update Images for actions

    Caption = 'Completed Work Order';
    Editable = false;
    PageType = Card;
    SourceTable = "Work Order";
    SourceTableView = SORTING(Completed)
                      WHERE(Completed = CONST(true));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Asset No."; "Asset No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Asset Description"; "Asset Description")
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
                }
                field("Fault Code"; "Fault Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Originator; Originator)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Origination Date"; "Origination Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Origination Time"; "Origination Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Priority; Priority)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Time"; "Due Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Standing Order"; "Standing Order")
                {
                    ApplicationArea = FOODBasic;
                }
                group("Work Requested")
                {
                    Caption = 'Work Requested';
                    field(WorkRequest; WorkRequest)
                    {
                        ApplicationArea = FOODBasic;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
            }
            group("Action")
            {
                Caption = 'Action';
                field("Scheduled Date"; "Scheduled Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Scheduled Time"; "Scheduled Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Completion Date"; "Completion Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Completion Time"; "Completion Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Usage; Usage)
                {
                    ApplicationArea = FOODBasic;
                    BlankNumbers = BlankNeg;
                }
                field("Cause Code"; "Cause Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Action Code"; "Action Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Downtime (Hours)"; "Downtime (Hours)")
                {
                    ApplicationArea = FOODBasic;
                }
                group(CostsAndAction)
                {
                    ShowCaption = false;
                    fixed(Costs)
                    {
                        ShowCaption = false;
                        group(Total)
                        {
                            Caption = 'Total';
                            field(TotalActual; "Total Cost (Actual)")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Actual Cost';
                            }
                            field(TotalPlanned; "Labor Cost (Planned)" + "Material Cost (Planned)" + "Contract Cost (Planned)")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Planned Cost';
                            }
                        }
                        group(Labor)
                        {
                            Caption = 'Labor';
                            field(ActualLabor; "Labor Cost (Actual)")
                            {
                                ApplicationArea = FOODBasic;
                            }
                            field(PlannedLabor; "Labor Cost (Planned)")
                            {
                                ApplicationArea = FOODBasic;
                            }
                        }
                        group(Material)
                        {
                            Caption = 'Material';
                            field(ActualMaterial; "Material Cost (Actual)")
                            {
                                ApplicationArea = FOODBasic;
                            }
                            field(PlannedMaterial; "Material Cost (Planned)")
                            {
                                ApplicationArea = FOODBasic;
                            }
                        }
                        group(Contract)
                        {
                            Caption = 'Contract';
                            field(ActualContract; "Contract Cost (Actual)")
                            {
                                ApplicationArea = FOODBasic;
                            }
                            field(PlannedContract; "Contract Cost (Planned)")
                            {
                                ApplicationArea = FOODBasic;
                            }
                        }
                    }
                    group("Corrective Action")
                    {
                        Caption = 'Corrective Action';
                        field(CorrectiveAction; CorrectiveAction)
                        {
                            ApplicationArea = FOODBasic;
                            MultiLine = true;
                            ShowCaption = false;
                        }
                    }
                }
            }
            part(Control37002025; "Work Order Labor Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Work Order No." = FIELD("No.");
            }
            part(MaterialLines; "Work Order Material Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Work Order No." = FIELD("No.");
            }
            part(ContractLines; "Work Order Contract Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Work Order No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            part(Control1900000008; "Asset Details Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Asset No.");
                Visible = true;
            }
            systempart(Control1900000009; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000010; Notes)
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
            group("O&rder")
            {
                Caption = 'O&rder';
                action("E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'E&ntries';
                    Image = Entries;
                    RunObject = Page "Maint. Ledger Entries";
                    RunPageLink = "Work Order No." = FIELD("No.");
                    RunPageView = SORTING("Work Order No.", "Posting Date", "Entry No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                action("Asset Card")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Asset Card';
                    Image = Card;
                    RunObject = Page "Asset Card";
                    RunPageLink = "No." = FIELD("Asset No.");
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Work Order Comment Sheet";
                    RunPageLink = "No." = FIELD("No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
                }
                separator(Separator37002003)
                {
                }
                action("Maintenance Journal")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maintenance Journal';
                    Image = Journals;

                    trigger OnAction()
                    var
                        MaintFns: Codeunit "Maintenance Management";
                        MaintJnlMgt: Codeunit "Maintenance Journal Management";
                    begin
                        // P8000719
                        MaintFns.CheckPostingGracePeriod("No.");
                        MaintJnlMgt.RunForWorkOrder(Rec);
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Find entries...';
                Image = Navigate;

                trigger OnAction()
                begin
                    Navigate;
                end;
            }
        }
        area(reporting)
        {
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
            actionref(Navigate_Promoted; "&Navigate")
            {
            }
            actionref(Entries_Promoted; "E&ntries")
            {
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        TextFns: Codeunit "Text Functions";
    begin
        // P8001132
        CurrPage.ContractLines.PAGE.SetWorkOrder("No.");
        CurrPage.MaterialLines.PAGE.SetWorkOrder("No.");

        WorkRequest := TextFns.NoteToText("Work Requested");         // P8000819, P8001132
        CorrectiveAction := TextFns.NoteToText("Corrective Action"); // P8000819, P8001132
    end;

    var
        WorkRequest: Text;
        CorrectiveAction: Text;
}

