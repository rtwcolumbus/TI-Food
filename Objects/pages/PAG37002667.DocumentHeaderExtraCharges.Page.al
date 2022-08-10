page 37002667 "Document Header Extra Charges"
{
    // PR4.00.06
    // P8000487A, VerticalSoft, Jack Reynolds, 12 JUN 07
    //   Multi-currency support for extra charges
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for extra charges on transfer orders
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001032, Columbus IT, Jack Reynolds, 02 FEB 12
    //   Correct flaw in design of Document Extra Charge table

    Caption = 'Document Header Extra Charges';
    DataCaptionExpression = SetCaption;
    PageType = List;
    SourceTable = "Document Extra Charge";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Extra Charge Code"; "Extra Charge Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Charge; Charge)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allocation Method"; "Allocation Method")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Charge (LCY)"; "Charge (LCY)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action(Allocate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allocate';
                    Image = Allocate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        PurchaseHeader: Record "Purchase Header";
                        TransferHeader: Record "Transfer Header";
                        ExtraCharge: Record "Extra Charge";
                        DocExtraCharge: Record "Document Extra Charge";
                        ExtraChargeMgmt: Codeunit "Extra Charge Management";
                    begin
                        // P8000928
                        if not Evaluate(DocExtraCharge."Table ID", GetFilter("Table ID")) then
                            exit;
                        case DocExtraCharge."Table ID" of
                            DATABASE::"Purchase Header": // P8001032
                                begin
                                    // P8000928
                                    if not Evaluate(PurchaseHeader."Document Type", GetFilter("Document Type")) then
                                        exit;
                                    if not Evaluate(PurchaseHeader."No.", GetFilter("Document No.")) then
                                        exit;
                                    if not PurchaseHeader.Find('=') then
                                        exit;
                                    PurchaseHeader.TestField(Status, PurchaseHeader.Status::Open);

                                    ExtraChargeMgmt.AllocateChargesToLines(DocExtraCharge."Table ID", PurchaseHeader."Document Type", // P8000928
                                      PurchaseHeader."No.", PurchaseHeader."Currency Code", ExtraCharge);                              // P8000928
                                                                                                                                       // P8000928
                                end;
                            DATABASE::"Transfer Header": // P8000132
                                begin
                                    if not Evaluate(TransferHeader."No.", GetFilter("Document No.")) then
                                        exit;
                                    if not TransferHeader.Find('=') then
                                        exit;
                                    TransferHeader.TestField(Status, TransferHeader.Status::Open);

                                    ExtraChargeMgmt.AllocateChargesToLines(DocExtraCharge."Table ID", 0, // P8000928
                                      TransferHeader."No.", '', ExtraCharge);                               // P8000928
                                end;
                        end;
                        // P8000928
                    end;
                }
            }
        }
    }

    var
        Text001: Label 'Purchase %1 %2';
        Text002: Label 'Transfer Order %1';

    procedure SetCaption(): Text[100]
    begin
        // P8001032
        case "Table ID" of
            DATABASE::"Purchase Header":
                exit(StrSubstNo(Text001, "Document Type", "Document No."));
            DATABASE::"Transfer Header":
                exit(StrSubstNo(Text002, "Document No."));
        end;
    end;
}

