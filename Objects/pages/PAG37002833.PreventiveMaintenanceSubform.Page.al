page 37002833 "Preventive Maintenance Subform"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style subform for PM Orders
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 06 FEB 09
    //   Transformed from form
    //   Changes made to page after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW110.0
    // P8007748, to IncreaseT, Jack Reynolds, 14 DEC 16
    //   Re-caption Make Order to Make Work Order

    Caption = 'Preventive Maintenance';
    PageType = ListPart;
    SourceTable = "Preventive Maintenance Order";
    SourceTableView = SORTING("Asset No.", "Group Code", "Frequency Code");

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                Editable = false;
                ShowCaption = false;
                field("Group Code"; "Group Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Frequency Code"; "Frequency Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Last PM Date"; "Last PM Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Last PM Usage"; "Last PM Usage")
                {
                    ApplicationArea = FOODBasic;
                    BlankNumbers = BlankNeg;
                }
                field("Last Work Order"; "Last Work Order")
                {
                    ApplicationArea = FOODBasic;
                }
                field(NextPMDate; NextPMDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Next PM Date';
                }
                field("Work Requested (First Line)"; "Work Requested (First Line)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Card)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Card';
                Image = EditLines;

                trigger OnAction()
                begin
                    ShowCard;
                end;
            }
            action("Create Work Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Create Work Order';
                Image = CreateDocument;

                trigger OnAction()
                begin
                    // P8000664
                    CreateOrder;
                end;
            }
        }
    }

    var
        Text001: Label '%1 %2 %3 created.';

    procedure ShowCard()
    var
        PMOrder: Record "Preventive Maintenance Order";
        PMCard: Page "Preventive Maintenance Order";
    begin
        PMOrder := Rec;
        PMOrder.SetRecFilter;
        PMCard.SetTableView(PMOrder);
        PMCard.Run;
    end;

    procedure CreateOrder()
    var
        WorkOrder: Record "Work Order";
    begin
        CreateWorkOrder(WorkOrder, WorkDate, Time, WorkDate);
        CurrPage.SaveRecord;
        Message(Text001, WorkOrder.TableCaption, WorkOrder.FieldCaption("No."), WorkOrder."No.");
    end;
}

