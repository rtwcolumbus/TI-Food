report 37002712 "Shipping Container Label"
{
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Simple label for picking containers
    // 
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
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    DefaultLayout = RDLC;
    RDLCLayout = './layout/ShippingContainerLabel.rdlc';

    Caption = 'Shipping Container Label';
    ShowPrintStatus = false;

    dataset
    {
        dataitem(CopyLoop; Integer)
        {
            DataItemTableView = SORTING(Number);
            column(ContainerLicensePlate; '*' + ShipProdContainerlabel."Container License Plate" + '*')
            {
            }
            column(ContainerLicensePlate2; ShipProdContainerlabel."Container License Plate")
            {
            }
            column(Destination; StrSubstNo('%1 %2', ShipProdContainerlabel."Destination Type", ShipProdContainerlabel."Destination No."))
            {
            }
            column(DestinationName; ShipProdContainerlabel."Destination Name")
            {
            }
            column(SourceDescription; ShipProdContainerlabel."Source Description")
            {
            }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, ShipProdContainerlabel."No. Of Copies");
            end;
        }
        dataitem(ShipProdContainerLabel; "Ship/Prod. Container Label")
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
        LabelData.SetTable(ShipProdContainerlabel);
    end;
}

