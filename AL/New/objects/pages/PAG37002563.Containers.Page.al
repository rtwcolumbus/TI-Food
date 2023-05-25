page 37002563 Containers
{
    // PR3.61.01
    //   Remove Lot No. column
    // 
    // PR3.70.04
    // P8000035B, Myers Nissi, Jack Reynolds, 15 MAY 04
    //   Modify Reprint Labels to to use PrintLabel function on Container Header
    // 
    // P8000042B, Myers Nissi, Jack Reynolds, 20 MAY 04
    //   When reassinging set reassignment flag on container assignment form
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" and related logic
    // 
    // PRW16.00.02
    // P8000782, VerticalSoft, Rick Tweedle, 01 MAR 10
    //   Various modifications to suit the RTC
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW18.00.02
    // P8004230, Columbus IT, Jack Reynolds, 02 OCT 15
    //   Label printing through BIS
    // 
    // PRW110.0.02
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    Caption = 'Containers';
    CardPageID = Container;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Container Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                Editable = false;
                ShowCaption = false;
                field(ID; ID)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Inbound; Inbound)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container Type Code"; "Container Type Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("License Plate"; "License Plate")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(DocumentType; DocumentType)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Type';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(LotStatus; LotStatus)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Status';
                    Visible = false;
                }
                field("Container Serial No."; "Container Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item No.';
                }
                field(ItemDesc; ItemDesc)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Description';
                }
                field("Total Quantity (Base)"; "Total Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Container")
            {
                Caption = '&Container';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page Container;
                    RunPageLink = ID = FIELD(ID);
                    ShortCutKey = 'Shift+F7';
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Container Comment List";
                    RunPageLink = Status = CONST(Open),
                                  "Container ID" = FIELD(ID);
                }
            }
        }
        area(processing)
        {
            action("Assign to Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Assign to Order';
                Enabled = (NOT InTransit) AND ("Whse. Document Type" = 0) AND (NOT "Ship/Receive") AND (NOT "Pending Assignment");
                Image = Apply;
                Visible = NOT LookupMode;

                trigger OnAction()
                begin
                    // P8001324
                    AssignToOrder;
                    CurrPage.Update(false); // P80046533
                end;
            }
            action("Change Lot Status")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Change Lot Status';
                Ellipsis = true;
                Image = ChangeStatus;
                Visible = NOT LookupMode;

                trigger OnAction()
                var
                    ContainerHeader: Record "Container Header";
                    LotStatusMgmt: Codeunit "Lot Status Management";
                begin
                    // P8001083
                    CurrPage.SetSelectionFilter(ContainerHeader);
                    LotStatusMgmt.ChangeLotStatusForContainer(ContainerHeader);
                end;
            }
        }
        area(reporting)
        {
            action(Print)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print';
                Image = Print;

                trigger OnAction()
                var
                    ContainerHeader: Record "Container Header";
                    ReportSelection: Record "Report Selections";
                begin
                    ContainerHeader := Rec;
                    ContainerHeader.SetRecFilter;
                    ReportSelection.SetRange(Usage, ReportSelection.Usage::FOODContainer); // P8000599A, P80073095
                    if ReportSelection.Find('-') then
                        repeat
                            REPORT.Run(ReportSelection."Report ID", true, false, ContainerHeader);
                        until ReportSelection.Next = 0;
                end;
            }
            action("Reprint Container Label")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reprint Container Label';
                Image = Print;

                trigger OnAction()
                begin
                    PrintLabel; // PR3.70.04, P8001322, P8004230
                end;
            }
        }
        area(Promoted)
        {
            actionref(AssignToOrder_Promoted; "Assign to Order")
            {
            }
            actionref(Print_Promoted; Print)
            {
            }
            actionref(ReprintContainerLabel_Promoted; "Reprint Container Label")
            {
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetItem(ItemNo, ItemDesc); // P8001323
        InTransit := ("Document Type" = DATABASE::"Transfer Line") and ("Document Subtype" = 1);
    end;

    trigger OnOpenPage()
    begin
        LookupMode := CurrPage.LookupMode; // P8001323
    end;

    var
        Text001: Label 'Nothing has been selected.';
        Text002: Label '%1 must be %2 for all containers.';
        ItemNo: Code[20];
        ItemDesc: Text[100];
        [InDataSet]
        LookupMode: Boolean;
        [InDataSet]
        InTransit: Boolean;
}

