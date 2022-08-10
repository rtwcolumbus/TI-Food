report 37002710 "Item Case Label"
{
    // PRW16.00.01
    // P8000698, VerticalSoft, Jack Reynolds, 09 JUL 09
    //   Added RTC layout
    // 
    // PRW18.00.02
    // P8004230, Columbus IT, Jack Reynolds, 02 OCT 15
    //   Label printing through BIS
    // 
    // PRW18.00.03
    // P8006373, To-Increase, Jack Reynolds, 21 JAN 16
    //   Cleanup for BIS label printing
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    DefaultLayout = RDLC;
    RDLCLayout = './layout/ItemCaseLabel.rdlc';

    Caption = 'Item Case Label';
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
        LotText: Text[50];
        AltQtyText: Text[50];
        Text001: Label 'Lot: %1';
        Text002: Label '%1 %2';
}