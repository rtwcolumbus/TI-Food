codeunit 37002702 "Label Method - Report" implements "Label Method"

// PRW120.2
// P800149380, To Increase, Jack Reynolds, 03 AUG 22
//   Support for label printing unit tests
//
// PRW120.2
// P800152082, To Increase, Jack Reynolds, 07 SEP 22
//   Support for sub-lot wizard unit tests

{
    procedure PrintLabel(Label: Record Label; LabelRec: RecordRef)
    var
        LabelManagement: Codeunit "Label Management";
        UseRequestPage, UseSystemPrinter : Boolean;
        XMLFileName: Text;
    begin
        LabelManagement.SetLabelData(LabelRec);
        BindSubscription(LabelManagement);
        // P800149380, P800152082
        OnBeforeRunLabelReport(Label, LabelRec, UseRequestPage, UseSystemPrinter, XMLFileName);
        if XMLFileName <> '' then
            Report.SaveAsXml(Label."Report ID", XMLFileName)
        else
            Report.Run(Label."Report ID", UseRequestPage, UseSystemPrinter);
        // P800149380, P800152082
    end;

    procedure PrinterName(LabelPrinterSelection: Record "Label Printer Selection"): Text
    begin
        exit(LabelPrinterSelection."Printer Name");
    end;

    // P800149380
    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunLabelReport(Label: Record Label; LabelRec: RecordRef; var UseRequestPage: Boolean; UseSystemPrinter: Boolean; var XMLFileName: Text)
    begin
    end;
}