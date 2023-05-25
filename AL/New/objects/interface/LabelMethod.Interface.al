interface "Label Method"
{
    procedure PrintLabel(Label: Record Label; LabelRec: RecordRef);

    procedure PrinterName(LabelPrinterSelection: Record "Label Printer Selection"): Text;
}