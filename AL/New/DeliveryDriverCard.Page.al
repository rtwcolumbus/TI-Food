page 37002067 "Delivery Driver Card"
{
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 03 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Delivery Driver Card';
    PageType = Card;
    SourceTable = "Delivery Driver";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Address; Address)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = FOODBasic;
                }
                field(City; City)
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002010)
                {
                    ShowCaption = false;
                    Visible = IsCountyVisible;
                    field(County; County)
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;

                    trigger OnValidate()
                    begin
                        IsCountyVisible := FormatAddress.UseCounty("Country/Region Code"); // P80066030
                    end;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = FOODBasic;
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

    trigger OnAfterGetCurrRecord()
    begin
        IsCountyVisible := FormatAddress.UseCounty("Country/Region Code"); // P80066030
    end;

    var
        FormatAddress: Codeunit "Format Address";
        IsCountyVisible: Boolean;
}

