page 369 "Order Address List"
{
    // PRW15.00.01
    // P8000547A, VerticalSoft, Jack Reynolds, 02 MAY 08
    //   Support for delivery routes
    // 
    // PRW17.10
    // P8001229, Columbus IT, Jack Reynolds, 04 OCT 13
    //   Vendor certifications

    Caption = 'Order Address List';
    CardPageID = "Order Address";
    DataCaptionFields = "Vendor No.";
    Editable = false;
    PageType = List;
    SourceTable = "Order Address";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an order-from address code.';
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company name for the order address.';
                }
                field(Address; Address)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the order address.';
                    Visible = false;
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies additional address information.';
                    Visible = false;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code.';
                    Visible = false;
                }
                field(City; City)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city of the order address.';
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region of the address.';
                    Visible = false;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the telephone number that is associated with the order address.';
                    Visible = false;
                }
                field("Fax No."; "Fax No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the fax number associated with the address.';
                    Visible = false;
                }
                field(Contact; Contact)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the person you regularly contact when you do business with this vendor at this address.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Address")
            {
                Caption = '&Address';
                Image = Addresses;
                separator(Action1102601001)
                {
                }
                action("Online Map")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Online Map';
                    Image = Map;
                    ToolTip = 'View the address on an online map.';

                    trigger OnAction()
                    begin
                        DisplayMap;
                    end;
                }
                separator(Separator37002002)
                {
                }
                action(Certifications)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Certifications';
                    Image = CopyDocument;
                    RunObject = Page "Vendor Certs. by Vendor";
                    RunPageLink = "Vendor No." = FIELD("Vendor No."),
                                  "Order Address Code" = FIELD(Code);
                    RunPageView = WHERE("Source Type" = CONST("Order Address"));
                }
                action("Delivery Routing Matrix")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delivery Routing Matrix';
                    Image = ShowMatrix;
                    RunObject = Page "Delivery Routing Matrix";
                    RunPageLink = "Source Type" = CONST("Order Address"),
                                  "Source No." = FIELD("Vendor No."),
                                  "Source No. 2" = FIELD(Code);
                }
            }
        }
    }
}

