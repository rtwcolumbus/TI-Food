report 37002714 "Production Container Label"
{
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    DefaultRenderingLayout = StandardRDLCLayout;

    Caption = 'Production Container Label';
    ShowPrintStatus = false;

    dataset
    {
        dataitem(CopyLoop; Integer)
        {
            DataItemTableView = SORTING(Number);
            column(ContainerLicensePlate; '*' + ShipProdContainerLabel."Container License Plate" + '*')
            {
            }
            column(ContainerLicensePlate2; ShipProdContainerLabel."Container License Plate")
            {
            }
            column(SourceNo; ShipProdContainerLabel."Source No.")
            {
            }
            column(ProdOrderDescription; ShipProdContainerLabel."Prod. Order Description")
            {
            }

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, ShipProdContainerLabel."No. Of Copies");
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

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/ProductionContainerLabel.rdlc';
        }
    }

    trigger OnPreReport()
    var
        LabelManagement: Codeunit "Label Management";
        LabelData: RecordRef;
    begin
        LabelManagement.GetLabelData(LabelData);
        LabelData.SetTable(ShipProdContainerLabel);
    end;
}