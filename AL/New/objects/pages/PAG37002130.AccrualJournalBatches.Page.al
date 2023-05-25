page 37002130 "Accrual Journal Batches"
{
    // PR3.61AC
    // 
    // PRW16.00.02
    // P8000672, VerticalSoft, Jimmy Abidi, 03 FEB 09
    //   Support for opening from batch form
    // 
    // PRW16.00.03
    // P8000802, VerticalSoft, Jack Reynolds, 25 MAR 10
    //   Add standard code to OnOpenForm
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Accrual Journal Batches';
    DataCaptionExpression = DataCaption;
    PageType = List;
    SourceTable = "Accrual Journal Batch";

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
                field("Posting No. Series"; "Posting No. Series")
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
                ShortCutKey = 'Return';

                trigger OnAction()
                begin
                    // P8000672A
                    AccrualJnlMgt.TemplateSelectionFromBatch(Rec);
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
                        ReportPrint.PrintAccrualJnlBatch(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Image = Post;
                    RunObject = Codeunit "Accrual Jnl.-B.Post";
                    ShortCutKey = 'F9';
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    RunObject = Codeunit "Accrual Jnl.-B.Post+Print";
                    ShortCutKey = 'Shift+F9';
                }
            }
        }
        area(Promoted)
        {
            actionref(EditJournal_Promoted; "Edit Journal")
            {
            }
            group(Post)
            {
                Caption = 'Post';
                ShowAs = SplitButton;

                actionref(Post_Promoted; "P&ost")
                {
                }
                actionref(PostAndPrint_Promoted; "Post and &Print")
                {
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetupNewBatch;
    end;

    trigger OnOpenPage()
    begin
        AccrualJnlMgt.OpenJnlBatch(Rec); // P8000802
    end;

    var
        ReportPrint: Codeunit "Test Report-Print";
        AccrualJnlMgt: Codeunit AccrualJnlManagement;

    local procedure DataCaption(): Text[250]
    var
        AccrualJnlTemplate: Record "Accrual Journal Template";
    begin
        if not CurrPage.LookupMode then
            if GetFilter("Journal Template Name") <> '' then
                if GetRangeMin("Journal Template Name") = GetRangeMax("Journal Template Name") then
                    if AccrualJnlTemplate.Get(GetRangeMin("Journal Template Name")) then
                        exit(AccrualJnlTemplate.Name + ' ' + AccrualJnlTemplate.Description);
    end;
}

