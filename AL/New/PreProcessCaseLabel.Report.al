report 37002713 "Pre-Process Case Label"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Jack Reynolds, 23 JAN 13
    //   Support for pre-process
    // 
    // PRW18.00.02
    // P8004230, Columbus IT, Jack Reynolds, 02 OCT 15
    //   Label printing through BIS
    // 
    // PRW18.00.03
    // P8006373, To-Increase, Jack Reynolds, 21 JAN 16
    //   Cleanup for BIS label printing
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 16 JAN 17
    //   Correct misspellings
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    DefaultLayout = RDLC;
    RDLCLayout = './layout/PreProcessCaseLabel.rdlc';

    Caption = 'Pre-Process Case Label';
    ShowPrintStatus = false;

    dataset
    {
        dataitem(CopyLoop; Integer)
        {
            DataItemTableView = SORTING(Number);
            column(ItemNo; '*' + ItemCaseLabel."Item No." + '*')
            {
            }
            column(ItemNo2; ItemCaseLabel."Item No.")
            {
            }
            column(Description; ItemCaseLabel.Description)
            {
            }
            column(LotText; LotText)
            {
            }
            column(AltQtyText; AltQtyText)
            {
            }
            column(lProdOrderNo; ItemCaseLabel."Prod. Order No.")
            {
            }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, ItemCaseLabel."No. Of Copies");
            end;
        }
        dataitem(ItemCaseLabel; "Item Case Label")
        {
            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
    }

    trigger OnPreReport()
    var
        LabelManagement: Codeunit "Label Management";
        LabelData: RecordRef;
    begin
        LabelManagement.GetLabelData(LabelData);
        LabelData.SetTable(ItemCaseLabel);

        if ItemCaseLabel."Lot No." <> '' then
            LotText := StrSubstNo(Text001, ItemCaseLabel."Lot No.");

        if ItemCaseLabel."Alternate Unit of Measure" <> '' then
            AltQtyText := StrSubstNo(Text002, ItemCaseLabel."Quantity (Alt.)", ItemCaseLabel."Alternate Unit of Measure");
    end;

    var
        Text001: Label 'Lot: %1';
        Text002: Label '%1 %2';
        LotText: Text[50];
        AltQtyText: Text[50];
}