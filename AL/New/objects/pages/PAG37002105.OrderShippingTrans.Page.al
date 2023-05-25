page 37002105 "Order Shipping-Trans."
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Transfer order form for posting shipments from order shipping
    // 
    // PRW15.00.01
    // P8000576A, VerticalSoft, Jack Reynolds, 14 FEB 08
    //   Order menu button is always visible
    // 
    // PRW16.00.02
    // P8000777, VerticalSoft, Don Bresee, 03 MAR 10
    //   Remove HeaderVisible use in properties
    //   Moves Lines part to first in content area
    // 
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.02
    // P80071657, To Increase, Jack Reynolds, 15 MAR 19
    //   Refactoring
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Transfer Order';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    SaveValues = true;
    SourceTable = "Transfer Header";

    layout
    {
        area(content)
        {
            part(Lines; "Order Shipping-Trans. Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Document No." = FIELD("No.");
            }
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Transfer-from Code"; "Transfer-from Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Transfer-to Code"; "Transfer-to Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("In-Transit Code"; "In-Transit Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(ShipDate; ShipDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date Shipped';
                    Editable = NOT PostingDisabled;
                    NotBlank = true;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
            }
            group(TransferFrom)
            {
                Caption = 'Transfer-from';
                group("Transfer-from")
                {
                    Caption = 'Transfer-from';
                    field("Transfer-from Name"; "Transfer-from Name")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Name';
                        Editable = false;
                    }
                    field("Transfer-from Name 2"; "Transfer-from Name 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Name 2';
                        Editable = false;
                    }
                    field("Transfer-from Address"; "Transfer-from Address")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address';
                        Editable = false;
                    }
                    field("Transfer-from Address 2"; "Transfer-from Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address 2';
                        Editable = false;
                    }
                    field("Transfer-from City"; "Transfer-from City")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'City';
                        Editable = false;
                        Lookup = false;
                    }
                    group(Control37002037)
                    {
                        ShowCaption = false;
                        Visible = IsTransferFromCountyVisible;
                        field("Transfer-from County"; "Transfer-from County")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                        }
                    }
                    field("Transfer-from Post Code"; "Transfer-from Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Trsf.-from Country/Region Code"; "Trsf.-from Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Editable = false;
                        Importance = Additional;
                        Lookup = false;
                    }
                    field("Transfer-from Contact"; "Transfer-from Contact")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact';
                        Editable = false;
                    }
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Outbound Whse. Handling Time"; "Outbound Whse. Handling Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Shipping Time"; "Shipping Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Shipping Advice"; "Shipping Advice")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
            }
            group(TransferTo)
            {
                Caption = 'Transfer-to';
                group("Transfer-to")
                {
                    Caption = 'Transfer-to';
                    field("Transfer-to Name"; "Transfer-to Name")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Name';
                        Editable = false;
                    }
                    field("Transfer-to Name 2"; "Transfer-to Name 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Name 2';
                        Editable = false;
                    }
                    field("Transfer-to Address"; "Transfer-to Address")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address';
                        Editable = false;
                    }
                    field("Transfer-to Address 2"; "Transfer-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address 2';
                        Editable = false;
                    }
                    field("Transfer-to City"; "Transfer-to City")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'City';
                        Editable = false;
                        Lookup = false;
                    }
                    group(Control37002041)
                    {
                        ShowCaption = false;
                        Visible = IsTransferToCountyVisible;
                        field("Transfer-to County"; "Transfer-to County")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                        }
                    }
                    field("Transfer-to Post Code"; "Transfer-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Trsf.-to Country/Region Code"; "Trsf.-to Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Editable = false;
                        Importance = Additional;
                        Lookup = false;
                    }
                    field("Transfer-to Contact"; "Transfer-to Contact")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact';
                        Editable = false;
                    }
                }
                field("Receipt Date"; "Receipt Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Inbound Whse. Handling Time"; "Inbound Whse. Handling Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            part(Control1901796907; "Item Warehouse FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = Lines;
                SubPageLink = "No." = FIELD("Item No.");
                Visible = true;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
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
            group(bnOrder)
            {
                Caption = 'O&rder';
                Visible = Editable;
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Inventory Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Transfer Order"),
                                  "No." = FIELD("No.");
                    Visible = Editable;
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    Visible = Editable;

                    trigger OnAction()
                    begin
                        ShowDocDim;          // P8001133
                        CurrPage.SaveRecord; // P8001133
                    end;
                }
                separator(Separator1102603078)
                {
                }
                action("Co&ntainers")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&ntainers';
                    Image = Inventory;
                    ShortCutKey = 'Ctrl+N';

                    trigger OnAction()
                    begin
                        ContainerSpecification;
                    end;
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Visible = NOT PostingDisabled;
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    ShortCutKey = 'F9';
                    Visible = NOT PostingDisabled;

                    trigger OnAction()
                    begin
                        Post(false); // P80071657
                        CurrPage.Close;
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';
                    Visible = NOT PostingDisabled;

                    trigger OnAction()
                    begin
                        Post(true); // P80071657
                        CurrPage.Close;
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Post)
            {
                Caption = 'Post';
                ShowAs = SplitButton;

                actionref(Post_Promoted; "P&ost")
                {
                }
                actionref(PostAndPrint_Promoted; "Post and &Print")
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsTransferFromCountyVisible := FormatAddress.UseCounty("Trsf.-from Country/Region Code"); // P80066030
        IsTransferToCountyVisible := FormatAddress.UseCounty("Trsf.-to Country/Region Code"); // P80066030
    end;

    trigger OnInit()
    begin
        HeaderVisible := true;
        Editable := true; // P8000954
    end;

    trigger OnOpenPage()
    begin
        BottomMargin := FrmHeight - (LinesYPos + LinesHeight);
        HdrPos := HeaderYPos;
        HdrHeight := HeaderHeight;

        ShipDate := WorkDate;

        SetHeaderDisplay(ShowHeader);

        // P8000954
        if PostingDisabled then begin
            Location.Get(PostingLocation);
            Editable := DelTripNo <> ''; // P8004518
            CurrPage.Lines.PAGE.SetFormEditable(Editable);
        end;
        // P8000954
    end;

    var
        Location: Record Location;
        FormatAddress: Codeunit "Format Address";
        ShipDate: Date;
        ShowHeader: Boolean;
        DelTripNo: Code[20];
        PostingLocation: Code[10];
        [InDataSet]
        PostingDisabled: Boolean;
        [InDataSet]
        Editable: Boolean;
        BottomMargin: Integer;
        HdrPos: Integer;
        HdrHeight: Integer;
        Text000: Label 'Do you want to post the shipment?';
        LinesYPos: Integer;
        HeaderYPos: Integer;
        LinesHeight: Integer;
        HeaderHeight: Integer;
        FrmHeight: Integer;
        [InDataSet]
        HeaderVisible: Boolean;
        IsTransferFromCountyVisible: Boolean;
        IsTransferToCountyVisible: Boolean;

    procedure SetTransHeader(WhseReq: Record "Warehouse Request")
    begin
        Get(WhseReq."Source No.");
        FilterGroup(2);
        SetRecFilter;
        FilterGroup(0);
    end;

    procedure SetDelTripOrder(DeliveryTripOrder: Record "Delivery Trip Order")
    begin
        // P8000954
        PostingLocation := DeliveryTripOrder."Location Code";
        Get(DeliveryTripOrder."Source No.");
        FilterGroup(2);
        SetRecFilter;
        FilterGroup(0);

        DelTripNo := DeliveryTripOrder."Delivery Trip No.";
        PostingDisabled := true;
    end;

    procedure SetHeaderDisplay(Display: Boolean)
    var
        LineBottom: Integer;
    begin
        //CurrForm.bnOrder.VISIBLE(Display); // P8000576A

        LineBottom := FrmHeight - BottomMargin;
        HeaderVisible := Display;
        if Display then
            LinesYPos := HdrPos + HdrHeight + 220
        else
            ;
        LinesHeight := LineBottom - LinesYPos;
    end;

    local procedure Post(Print: Boolean)
    var
        TransferPostShipment: Codeunit "TransferOrder-Post Shipment";
        TransferOrderPostPrint: Codeunit "TransferOrder-Post + Print";
    begin
        // P80071657
        Rec.Find;
        if not Confirm(Text000, false) then
            exit;

        Validate("Posting Date", ShipDate);
        TransferPostShipment.Run(Rec);
        if Print then
            TransferOrderPostPrint.PrintReport(Rec, 1); // P80053245
    end;
}

