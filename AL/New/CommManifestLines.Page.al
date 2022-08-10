page 37002686 "Comm. Manifest Lines"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW18.00
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory

    AutoSplitKey = true;
    Caption = 'Comm. Manifest Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Commodity Manifest Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field("Vendor Name"; "Vendor Name")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Purch. Order Status"; "Purch. Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Purch. Order No."; "Purch. Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Manifest Quantity"; "Manifest Quantity")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("GetReceivedPercentage()"; GetReceivedPercentage())
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Received Percentage';
                    DecimalPlaces = 1 : 1;
                    Editable = false;
                }
                field("Received Date"; "Received Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Received Lot No."; "Received Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if ("Received Lot No." = '') then
                            if AssistEditRcptLotNo(xRec) then
                                CurrPage.Update;
                    end;
                }
                field("Rejection Action"; "Rejection Action")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetupNewLine(xRec);
    end;
}

