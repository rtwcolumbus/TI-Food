report 37002711 "Container Label"
{
    // PRW16.00.01
    // P8000698, VerticalSoft, Jack Reynolds, 09 JUL 09
    //   Added RTC layout
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
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

    DefaultRenderingLayout = StandardRDLCLayout;

    Caption = 'Container Label';
    ShowPrintStatus = false;

    dataset
    {
        dataitem(CopyLoop; Integer)
        {
            DataItemTableView = SORTING(Number);
            column(LicensePlate; '*' + ContainerLabel."Container License Plate" + '*')
            {
            }
            column(LicensePlate2; ContainerLabel."Container License Plate")
            {
            }
            column(NetWeight; StrSubstNo(Text003, ContainerLabel."Net Weight", ContainerLabel."Weight Unit of Measure"))
            {
            }
            column(GrossWeight; StrSubstNo(Text003, ContainerLabel."Net Weight" + ContainerLabel."Tare Weight", ContainerLabel."Weight Unit of Measure"))
            {
            }
            column(ItemText; ItemText)
            {
            }
            column(ItemDescription; ContainerLabel."Item Description")
            {
            }
            column(LotText; LotText)
            {
            }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, ContainerLabel."No. Of Copies");
            end;
        }
        dataitem(ContainerLabel; "Container Label")
        {
            trigger OnPreDataItem()
            begin 
                CurrReport.Break();
            end;
        }
    }

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/ContainerLabel.rdlc';
        }
    }

    labels
    {
        NetWeightCaption = 'Net Weight:';
        GrossWeightCaption = 'Gross Weight:';
    }

    trigger OnPreReport()
    var
        LabelManagement: Codeunit "Label Management";
        LabelData: RecordRef;
    begin
        LabelManagement.GetLabelData(LabelData);
        LabelData.SetTable(ContainerLabel);

        if ContainerLabel."Item No." <> '' then
            ItemText := StrSubstNo(Text001, ContainerLabel."Item No.");
        if ContainerLabel."Lot No." <> '' then
            LotText := StrSubstNo(Text002, ContainerLabel."Lot No.");
    end;

    var
        ItemText: Text[30];
        LotText: Text[50];
        Text001: Label 'Item: %1';
        Text002: Label 'Lot: %1';
        Text003: Label '%1 %2';
}