page 37002585 "Reg. Pre-Process Activity"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Reg. Pre-Process Activity';
    DataCaptionExpression = GetDataCaption;
    Editable = false;
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "Reg. Pre-Process Activity";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                group(Control37002036)
                {
                    ShowCaption = false;
                    field("Prod. Order Status"; "Prod. Order Status")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Prod. Order No."; "Prod. Order No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Prod. Order BOM No."; "Prod. Order BOM No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Location Code"; "Location Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                }
                group(Control37002037)
                {
                    ShowCaption = false;
                    field("Replenishment Area Code"; "Replenishment Area Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("To-Bin Code"; "To-Bin Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("From-Bin Code"; "From-Bin Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Pre-Process")
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pre-Process Type Code"; "Pre-Process Type Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Blending; Blending)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order Specific"; "Order Specific")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Auto Complete"; "Auto Complete")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Blending Order Status"; "Blending Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Blending Order No."; "Blending Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002038)
                {
                    ShowCaption = false;
                    field(Quantity; Quantity)
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Quantity Processed"; "Quantity Processed")
                    {
                        ApplicationArea = FOODBasic;
                        Importance = Promoted;
                    }
                }
            }
            part(Lines; "Reg. Pre-Process Act. Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Activity No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            systempart(Control37002030; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002028; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Print Labels")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print Labels';
                Image = Print;

                trigger OnAction()
                begin
                    if Confirm(Text000, true, "No.") then
                        PrintLabels;
                end;
            }
        }
        area(navigation)
        {
            action("Prod. Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Prod. Order';
                Image = Production;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Shift+F7';

                trigger OnAction()
                begin
                    Activity.ShowProdOrder("Prod. Order Status", "Prod. Order No.");
                end;
            }
            action("Blending Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Blending Order';
                Enabled = BlendingOrderExists;
                Image = GetLines;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Ctrl+B';

                trigger OnAction()
                begin
                    Activity.ShowProdOrder("Blending Order Status", "Blending Order No.");
                end;
            }
            action(Item)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item';
                Image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Item No.");
                RunPageMode = View;
            }
            separator(Separator37002019)
            {
            }
            action("Warehouse Entries")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Warehouse Entries';
                Image = BinLedger;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Warehouse Entries";
                RunPageLink = "Source No." = FIELD("No.");
                RunPageView = SORTING("Source Type", "Source Subtype", "Source No.")
                              WHERE("Source Type" = CONST(37002494),
                                    "Source Subtype" = CONST("0"));
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        BlendingOrderExists := ("Blending Order No." <> '');
    end;

    var
        Activity: Record "Pre-Process Activity";
        [InDataSet]
        BlendingOrderExists: Boolean;
        Text000: Label 'Do you want to print labels for Activity %1?';

    procedure GetDataCaption(): Text[80]
    begin
        exit(StrSubstNo('(%4) %1 - %2 %3', "Prod. Order No.", "Item No.", Description, "No."));
    end;
}

