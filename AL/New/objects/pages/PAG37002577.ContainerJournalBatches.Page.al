page 37002577 "Container Journal Batches"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Standard list form for container journal batches
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // P8000782, VerticalSoft, Rick Tweedle, 02 MAR 10
    //   Transformed to Page using transfor tool
    // 
    // PRW16.00.03
    // P8000802, VerticalSoft, Jack Reynolds, 25 MAR 10
    //   Add standard code to OnOpenPage
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Container Journal Batches';
    DataCaptionExpression = DataCaption;
    PageType = List;
    SourceTable = "Container Journal Batch";

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
            systempart(Control1900000004; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000005; Notes)
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
                    ContainerJnlMgt.TemplateSelectionFromBatch(Rec);
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
                        ReportPrint.PrintContainerJnlBatch(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Image = Post;
                    RunObject = Codeunit "Container Jnl.-B.Post";
                    ShortCutKey = 'F9';
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    RunObject = Codeunit "Container Jnl.-B.Post+Print";
                    ShortCutKey = 'Shift+F9';
                }
            }
        }
        area(Promoted)
        {
            actionref(EditJournal_Promoted; "Edit Journal")
            {
            }
            group(Category_Post)
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
        ContainerJnlMgt.OpenJnlBatch(Rec); // P8000802
    end;

    var
        ReportPrint: Codeunit "Test Report-Print";
        ContainerJnlMgt: Codeunit ContainerJnlManagement;

    local procedure DataCaption(): Text[250]
    var
        ContJnlTemplate: Record "Container Journal Template";
    begin
        if not CurrPage.LookupMode then
            if GetFilter("Journal Template Name") <> '' then
                if GetRangeMin("Journal Template Name") = GetRangeMax("Journal Template Name") then
                    if ContJnlTemplate.Get(GetRangeMin("Journal Template Name")) then
                        exit(ContJnlTemplate.Name + ' ' + ContJnlTemplate.Description);
    end;
}

