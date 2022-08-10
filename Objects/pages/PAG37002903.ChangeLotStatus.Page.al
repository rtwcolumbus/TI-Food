page 37002903 "Change Lot Status"
{
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status

    Caption = 'Change Lot Status';
    DataCaptionExpression = '';
    InstructionalText = 'Do you want to change the status of the lots on the selected containers?';
    PageType = ConfirmationDialog;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            field(Status; LotStatus)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Status Code';
                TableRelation = "Lot Status Code";

                trigger OnValidate()
                var
                    InvSetup: Record "Inventory Setup";
                begin
                    InvSetup.Get;
                    if InvSetup."Quarantine Lot Status" = '' then
                        exit;
                    if LotStatus = InvSetup."Quarantine Lot Status" then
                        Error(Text001, LotStatus);
                end;
            }
            field(DocumentNo; DocumentNo)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Document No.';
                Visible = DocNoRequired;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        InvSetup.Get;
        DocNoRequired := InvSetup."Chg. Lot Status Document Nos." = '';
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::Yes then begin
            if (DocumentNo = '') and DocNoRequired then
                Error(Text002);
        end else
            exit(true);
    end;

    var
        InvSetup: Record "Inventory Setup";
        LotStatus: Code[10];
        DocumentNo: Code[20];
        Text001: Label 'Lot status Code may not be changed to %1.';
        Text002: Label 'Document No. must be entered.';
        [InDataSet]
        DocNoRequired: Boolean;

    procedure GetData(var Status: Code[10]; var DocNo: Code[10])
    begin
        Status := LotStatus;
        DocNo := DocumentNo;
    end;
}

