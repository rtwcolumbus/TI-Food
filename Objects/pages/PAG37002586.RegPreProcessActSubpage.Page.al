page 37002586 "Reg. Pre-Process Act. Subpage"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Reg. Pre-Process Act. Subpage';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Reg. Pre-Process Activity Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Processed"; "Quantity Processed")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Processed (Base)"; "Qty. Processed (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Warehouse Entries")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Warehouse Entries';
                Image = BinLedger;
                RunObject = Page "Warehouse Entries";
                RunPageLink = "Source No." = FIELD("Activity No."),
                              "Source Line No." = FIELD("Line No.");
                RunPageView = SORTING("Source Type", "Source Subtype", "Source No.")
                              WHERE("Source Type" = CONST(37002494),
                                    "Source Subtype" = CONST("0"));
                ShortCutKey = 'Ctrl+F7';
            }
            separator(Separator37002006)
            {
            }
            action("Print Labels")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print Labels';
                Image = Print;

                trigger OnAction()
                var
                    RegActivityLine: Record "Reg. Pre-Process Activity Line";
                begin
                    CurrPage.SetSelectionFilter(RegActivityLine);
                    if not RegActivityLine.IsEmpty then
                        if Confirm(Text000) then begin
                            RegActivityLine.FindSet;
                            repeat
                                RegActivityLine.PrintLabel();
                            until (RegActivityLine.Next = 0);
                        end;
                end;
            }
        }
    }

    var
        Text000: Label 'Do you want to print labels for the selected lines?';
}

