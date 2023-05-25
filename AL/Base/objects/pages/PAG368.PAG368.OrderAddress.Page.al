page 368 "Order Address"
{
    // PRW15.00.01
    // P8000547A, VerticalSoft, Jack Reynolds, 02 MAY 08
    //   Support for delivery routes
    // 
    // PRW17.10
    // P8001229, Columbus IT, Jack Reynolds, 04 OCT 13
    //   Vendor certifications

    Caption = 'Order Address';
    DataCaptionExpression = Caption();
    PageType = Card;
    SourceTable = "Order Address";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an order-from address code.';
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the company located at the address.';
                }
                field(Address; Address)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the street address.';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies additional address information.';
                }
                field(City; City)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city of the address.';
                }
                group(CountyGroup)
                {
                    ShowCaption = false;
                    Visible = IsCountyVisible;
                    field(County; County)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'State / ZIP Code';
                        ToolTip = 'Specifies the state or postal code as part of the address.';
                    }
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the postal code.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region of the address.';

                    trigger OnValidate()
                    begin
                        IsCountyVisible := FormatAddress.UseCounty("Country/Region Code");
                    end;
                }
                field(Contact; Contact)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the person you regularly contact when you do business with this vendor at this address.';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when this order address was last modified.';
                }
                field("Default Delivery Route No."; "Default Delivery Route No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the telephone number that is associated with the order address.';
                }
                field("Fax No."; Rec."Fax No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the fax number associated with the order address.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the email address associated with the order address.';
                }
                field("Home Page"; Rec."Home Page")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the recipient''s web site.';
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
                separator(Action39)
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
                        DisplayMap();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        IsCountyVisible := FormatAddress.UseCounty("Country/Region Code");
    end;

    var
        FormatAddress: Codeunit "Format Address";
        IsCountyVisible: Boolean;
}

