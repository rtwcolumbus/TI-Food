page 37002049 "Item Price List Sequence"
{
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Item Price List Sequence';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SaveValues = true;
    SourceTable = Item;
    SourceTableView = SORTING("Item Category Order")
                      WHERE("Item Type" = CONST("Finished Good"));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field("Price List Items Preview"; PriceListItemsPreview)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Price List Items Preview';

                trigger OnValidate()
                begin
                    // P8007749
                    CurrPage.SaveRecord;
                    SetPriceListView;
                    CurrPage.Update(false);
                end;
            }
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Price List Sequence No."; "Price List Sequence No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        // P8007749
                        if PriceListItemsPreview then
                            CurrPage.Update;
                    end;
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
    }

    trigger OnOpenPage()
    begin
        SetPriceListView;
    end;

    var
        PriceListItemsPreview: Boolean;

    local procedure SetPriceListView()
    begin
        FilterGroup(2);
        if PriceListItemsPreview then begin
            SetCurrentKey("Item Category Order", "Price List Sequence No."); // P8007749
            SetFilter("Price List Sequence No.", '<>%1', '');
        end else begin
            SetCurrentKey("Item Category Order"); // P8007749
            SetRange("Price List Sequence No.");
        end;
        FilterGroup(0);
    end;

    local procedure PriceListSequenceNoOnAfterVali()
    begin
    end;

    local procedure PriceListItemsPreviewOnPush()
    begin
    end;
}

