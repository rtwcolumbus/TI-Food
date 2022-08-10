page 37002837 "PM Material Subform"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style subform for PM order materials
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

    Caption = 'Material';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "PM Material";

    layout
    {
        area(content)
        {
            field(AccountNo; AccountNo)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Material Account';
                TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));

                trigger OnValidate()
                var
                    PMOrder: Record "Preventive Maintenance Order";
                begin
                    // P8000664
                    if (AccountNo <> xAccountNo) and (EntryNo <> '') then begin
                        PMOrder.Get(EntryNo);
                        PMOrder."Material Account" := AccountNo;
                        PMOrder.Modify;
                    end;
                    xAccountNo := AccountNo;
                end;
            }
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupItem(Text));
                    end;
                }
                field("Part No."; "Part No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Planned Quantity"; "Planned Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Planned Cost"; "Planned Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

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
            xAccountNo := PMOrder."Material Account";
            AccountNo := xAccountNo;
        end;
    end;
}

