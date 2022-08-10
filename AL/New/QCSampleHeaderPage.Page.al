page 37002959 "Quality Control SampleHdr.Page"
{
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Quality Control Samples';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "Quality Control Sample";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(Group1)
            {
                ShowCaption = false;
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DocNoVisible;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container License Plate"; Rec."Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ContainerIDVisible;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(Rec.LookupContainer(Text));
                    end;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Posted"; Rec."Quantity Posted")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Lines; "Quality Control Sample Lines")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
            }

        }
    }


    actions
    {
        area(Processing)
        {
            action(Post)
            {
                ApplicationArea = FOODBasic;
                Caption = 'P&ost';
                Image = PostOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ShortCutKey = 'F9';
                ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                trigger OnAction()
                var
                    Process800QCFunctions: Codeunit "Process 800 Q/C Functions";
                begin
                    QCSampleLines.SetFilter("Quanity to Post", '>%1', 0);
                    if QCSampleLines.FindSet() then begin
                        if Confirm(PostLabel) then begin
                            Process800QCFunctions.PostSample(Rec, QCSampleLines);
                            Message(SuccessLabel);
                            Posted := true;
                            CurrPage.Close();
                        end;
                    end
                    else
                        Error(NothingLabel);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetVariables();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not Posted then
            if not Confirm(ConfirmLabel) then
                exit(false);
    end;

    var
        InventorySetup: Record "Inventory Setup";
        QCSampleLines: Record "Quality Control Sample" temporary;
        P800Functions: Codeunit "Process 800 Functions";
        ContainerIDVisible: Boolean;
        DocNoVisible: Boolean;
        ConfirmLabel: Label 'If you close this page the data will get deleted from this page. Do you want to continue ?';
        NothingLabel: Label 'There is nothing to post.';
        PostLabel: Label 'Do you want to post the sample?';
        SuccessLabel: Label 'Sample posted successfully';
        Posted: Boolean;

    local procedure SetVariables()
    begin
        ContainerIDVisible := P800Functions.ContainerTrackingInstalled();
        InventorySetup.Get();
        DocNoVisible := InventorySetup."Sample Document No. Series" = '';
    end;

    procedure SetSampleData(var QCSample: Record "Quality Control Sample" temporary)
    begin
        if QCSample.FindFirst() then
            Rec := QCSample;
        Rec.Insert();
        QCSampleLines.Copy(QCSample, true);
        CurrPage.Lines.Page.SetSampleData(QCSampleLines);
    end;
}