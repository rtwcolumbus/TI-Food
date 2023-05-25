page 37002602 "Supply Driven Process Subform"
{
    // PRW16.00.03
    // P8000793, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001092, Columbus IT, Don Bresee, 11 SEP 12
    //   Set MinValue property to zero on Quantity to Process
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013

    Caption = 'Supply Driven Process Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Production BOM Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Production BOM No."; "Production BOM No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Process BOM No.';
                    Editable = false;
                    LookupPageID = "Co-Product Process List";
                    TableRelation = "Production BOM Header" WHERE("No." = FIELD("Production BOM No."),
                                                                   "Mfg. BOM Type" = CONST(Process),
                                                                   "Output Type" = CONST(Family));
                }
                field(Description; "Prod. BOM Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Maximum Quantity"; MaxReqQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maximum Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("Quantity to Process"; CurrReqQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity to Process';
                    DecimalPlaces = 0 : 5;
                    MinValue = 0;

                    trigger OnValidate()
                    begin
                        if (CurrReqQty > MaxReqQty) then
                            Error(Text001, MaxReqQty);
                        SDPMgmt.SaveProcessPageQty(Rec, CurrReqQty);
                        CurrPage.Update;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        SDPMgmt.GetProcessPageQtys(Rec, CurrReqQty, MaxReqQty); // P8001132
    end;

    trigger OnAfterGetRecord()
    begin
        SDPMgmt.GetProcessPageQtys(Rec, CurrReqQty, MaxReqQty);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(SDPMgmt.ProcessPageFind(Rec, Which));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(SDPMgmt.PageNext(Rec, Steps));
    end;

    var
        Text001: Label 'Quantity to Process cannot be greater than %1.';
        SDPMgmt: Codeunit "Supply Driven Planning Mgmt.";
        CurrReqQty: Decimal;
        MaxReqQty: Decimal;

    procedure SetSDPMgmt(var ParentSDPMgmt: Codeunit "Supply Driven Planning Mgmt.")
    begin
        SDPMgmt := ParentSDPMgmt;
    end;
}

