page 37002836 "PM Contract Subform"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style subform for PM order contract activites
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Decrease height
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 11 FEB 09
    //   Transformed from form
    //   Changes made to page after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Contract';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "PM Activity";
    SourceTableView = SORTING("PM Entry No.", Type, "Trade Code")
                      WHERE(Type = CONST(Contract));

    layout
    {
        area(content)
        {
            field(AccountNo; AccountNo)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Contract Account';
                TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));

                trigger OnValidate()
                var
                    PMOrder: Record "Preventive Maintenance Order";
                begin
                    // P8000664
                    if (AccountNo <> xAccountNo) and (EntryNo <> '') then begin
                        PMOrder.Get(EntryNo);
                        PMOrder."Contract Account" := AccountNo;
                        PMOrder.Modify;
                    end;
                    xAccountNo := AccountNo;
                end;
            }
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Trade Code"; "Trade Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CalcFields("Trade Description");
                    end;
                }
                field("Trade Description"; "Trade Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CalcFields("Vendor Name");
                    end;
                }
                field("Vendor Name"; "Vendor Name")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
                field("Rate (Hourly)"; "Rate (Hourly)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Planned Hours"; "Planned Hours")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Planned Cost"; "Planned Cost")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    var
        EntryNo: Code[20];
        AccountNo: Code[20];
        xAccountNo: Code[20];

    procedure SetPMOrder(No: Code[20])
    var
        PMOrder: Record "Preventive Maintenance Order";
    begin
        // P8000664
        if (EntryNo <> No) and (No <> '') then begin
            EntryNo := No;
            PMOrder.Get(EntryNo);
            xAccountNo := PMOrder."Contract Account";
            AccountNo := xAccountNo;
        end;
    end;
}

