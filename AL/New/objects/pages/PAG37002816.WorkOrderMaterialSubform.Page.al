page 37002816 "Work Order Material Subform"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style subform for work order materials
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Decrease height
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 09 FEB 09
    //   Transformed from form
    //   Changes made to page after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Material';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Work Order Material";

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
                    WorkOrder: Record "Work Order";
                begin
                    // P8000664
                    if (AccountNo <> xAccountNo) and (WorkOrderNo <> '') then begin
                        WorkOrder.Get(WorkOrderNo);
                        WorkOrder."Material Account" := AccountNo;
                        WorkOrder.Modify;
                    end;
                    xAccountNo := AccountNo;
                end;
            }
            repeater(Control37002001)
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
                field("Actual Cost"; "Actual Cost")
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
        WorkOrderNo: Code[20];
        AccountNo: Code[20];
        xAccountNo: Code[20];

    procedure SetWorkOrder(No: Code[20])
    var
        WorkOrder: Record "Work Order";
    begin
        // P8000664
        if (WorkOrderNo <> No) and (No <> '') then begin
            WorkOrderNo := No;
            WorkOrder.Get(WorkOrderNo);
            xAccountNo := WorkOrder."Material Account";
            AccountNo := xAccountNo;
        end;
    end;
}

