page 37002822 "Maintenance Journal Batches"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard jornal batches form, adapted for maintenance
    // 
    // PRW16.00.20
    // P8000672, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Add Edit Journal button to run the selected journal
    // 
    // P8000664, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.03
    // P8000801, VerticalSoft, Jack Reynolds, 25 MAR 10
    //   Remove OnInit code that clears filter on template name
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Maintenance Journal Batches';
    DataCaptionExpression = DataCaption;
    PageType = List;
    SourceTable = "Maintenance Journal Batch";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Reason Code"; "Reason Code")
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
        area(processing)
        {
            action("Edit Journal")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Edit Journal';
                Image = EditJournal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Return';

                trigger OnAction()
                begin
                    // P8000672A
                    MaintJnlMgt.TemplateSelectionFromBatch(Rec);
                end;
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action("Test Report")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintMaintJnlBatch(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Maint. Jnl.-B.Post";
                    ShortCutKey = 'F9';
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Maint. Jnl.-B.Post+Print";
                    ShortCutKey = 'Shift+F9';
                }
            }
        }
    }

    trigger OnInit()
    begin
        //SETRANGE("Journal Template Name"); // P8000801
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetupNewBatch;
    end;

    trigger OnOpenPage()
    begin
        MaintJnlMgt.OpenJnlBatch(Rec);
    end;

    var
        ReportPrint: Codeunit "Test Report-Print";
        MaintJnlMgt: Codeunit "Maintenance Journal Management";

    local procedure DataCaption(): Text[250]
    var
        MaintJnlTemplate: Record "Maintenance Journal Template";
    begin
        if not CurrPage.LookupMode then
            if GetFilter("Journal Template Name") <> '' then
                if GetRangeMin("Journal Template Name") = GetRangeMax("Journal Template Name") then
                    if MaintJnlTemplate.Get(GetRangeMin("Journal Template Name")) then
                        exit(MaintJnlTemplate.Name + ' ' + MaintJnlTemplate.Description);
    end;
}

