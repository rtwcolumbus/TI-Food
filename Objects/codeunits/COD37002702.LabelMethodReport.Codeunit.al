codeunit 37002702 "Label Method - Report" implements "Label Method"
{
    procedure PrintLabel(Label: Record Label; LabelRec: RecordRef)
    var
        LabelManagement: Codeunit "Label Management";
    begin
        LabelManagement.SetLabelData(LabelRec);
        BindSubscription(LabelManagement);
        Report.Run(Label."Report ID", false, false);
    end;

    procedure PrinterName(LabelPrinterSelection: Record "Label Printer Selection"): Text
    begin
        exit(LabelPrinterSelection."Printer Name");
    end;
}