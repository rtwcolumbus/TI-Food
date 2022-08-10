page 37002570 "Container Lines"
{
    // PR5.00.01
    // P8000599A, VerticalSoft, Don Bresee, 13 MAY 08
    //   Report Selections - SP1 change to Usage options, P800 option values increased by 12
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 28 JUL 08
    //   Missing Help button
    // 
    // PRW16.00.02
    // P8000782, VerticalSoft, Rick Tweedle, 02 MAR 10
    //   Transformed to Page using transfor tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Container Lines';
    DataCaptionFields = "Container ID";
    DelayedInsert = true;
    Editable = false;
    PageType = List;
    SourceTable = "Container Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Container ID"; "Container ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
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
        area(navigation)
        {
            group("&Container")
            {
                Caption = '&Container';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    begin
                        ContHeader.SetRange(ID, "Container ID");
                        PAGE.Run(37002560, ContHeader);
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = ViewComments;

                    trigger OnAction()
                    begin
                        ContCommentLine.SetRange("Container ID", "Container ID");
                        ContCommentLine.SetRange(Status, ContCommentLine.Status::Open);
                        PAGE.Run(37002562, ContCommentLine);
                    end;
                }
                action("Reprint Container")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reprint Container';
                    Image = Print;

                    trigger OnAction()
                    begin
                        ReportSelection.SetRange(Usage, ReportSelection.Usage::FOODContainer); // P8000599A
                        ContHeader.SetRange(ID, "Container ID");
                        if ReportSelection.Find('-') then
                            REPORT.Run(ReportSelection."Report ID", false, false, ContHeader);
                    end;
                }
            }
        }
    }

    var
        ContHeader: Record "Container Header";
        ContCommentLine: Record "Container Comment Line";
        ReportSelection: Record "Report Selections";
}

