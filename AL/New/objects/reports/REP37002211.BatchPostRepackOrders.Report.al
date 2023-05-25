report 37002211 "Batch Post Repack Orders"
{
    // PR4.00.04
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Adpated from Batch Post Sales Orders
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Batch Post Repack Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Repack Order"; "Repack Order")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            var
                RepackBatchPostMgt: Codeunit "Repack Batch Post Mgt.";
            begin
                // P80053245
                RepackBatchPostMgt.RunBatch("Repack Order", ReplacePostingDate, PostingDateReq, TransReq, ProdReq);

                CurrReport.Break;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(TransReq; TransReq)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Transfer';
                    }
                    field(ProdReq; ProdReq)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Produce';
                    }
                    field(PostingDateReq; PostingDateReq)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting Date';
                    }
                    field(ReplacePostingDate; ReplacePostingDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Replace Posting Date';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        PostingDateReq: Date;
        TransReq: Boolean;
        ProdReq: Boolean;
        ReplacePostingDate: Boolean;
}

