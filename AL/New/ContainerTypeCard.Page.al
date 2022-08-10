page 37002590 "Container Type Card"
{
    // P8001373, To-Increase, Dayakar Battini, 11 Feb 15
    //   Support containers for purchase returns.
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW111.00.01
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    // 
    // P80060684, To Increase, Jack Reynolds, 26 JUL 18
    //   Missing captions

    Caption = 'Container Type Card';
    PageType = Card;
    SourceTable = "Container Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container Item No."; "Container Item No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if ItemAssistEdit then
                            CurrPage.Update;
                    end;

                    trigger OnValidate()
                    begin
                        UpdateEditable;
                        CurrPage.Update;
                    end;
                }
                group(Control37002020)
                {
                    ShowCaption = false;
                    field("Track Inventory"; TrackInventory())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Track Inventory';

                        trigger OnValidate()
                        begin
                            UpdateEditable;
                        end;
                    }
                    field("Maintain Inventory Value"; "Maintain Inventory Value")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = UsingItem;

                        trigger OnValidate()
                        begin
                            UpdateEditable;
                        end;
                    }
                    field(Serializable; IsSerializable())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Serializable';
                    }
                }
            }
            group(Options)
            {
                field("Default Cont. License Plate"; "Default Cont. License Plate")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Serialized;
                }
                field("Setup Level"; "Setup Level")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Container Sales Processing"; "Container Sales Processing")
                {
                    ApplicationArea = FOODBasic;
                    Editable = UsingItem;
                }
                field("Container Purchase Processing"; "Container Purchase Processing")
                {
                    ApplicationArea = FOODBasic;
                }
                field("No. of Labels"; "No. of Labels")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002017)
                {
                    ShowCaption = false;
                    field("Tare Weight"; "Tare Weight")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Tare Unit of Measure"; "Tare Unit of Measure")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                group(Control37002018)
                {
                    ShowCaption = false;
                    field(Capacity; Capacity)
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Capacity Unit of Measure"; "Capacity Unit of Measure")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
            }
            part(Items; "Container Type Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Items';
                SubPageLink = "Container Type Code" = FIELD(Code);
                SubPageView = SORTING("Container Type Code", "Item Type", "Item Code");
            }
        }
        area(factboxes)
        {
            systempart(Control37002010; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
            systempart(Control37002009; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("&Charges")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Charges';
                Enabled = ChargesEnabled;
                Image = ItemCosts;
                RunObject = Page "Container Type Charges";
                RunPageLink = "Container Type Code" = FIELD(Code);
            }
            action("<Action37002021>")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Labels';
                Image = Text;
                RunObject = Page "Container Labels";
                RunPageLink = "Source Type" = CONST(37002578),
                              "Source No." = FIELD(Code);
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateEditable;
        ChargesEnabled := "Container Item No." <> '';
    end;

    var
        [InDataSet]
        UsingItem: Boolean;
        [InDataSet]
        Serialized: Boolean;
        [InDataSet]
        ChargesEnabled: Boolean;

    local procedure UpdateEditable()
    begin
        UsingItem := TrackInventory();
        Serialized := IsSerializable; // P8005555
    end;
}

