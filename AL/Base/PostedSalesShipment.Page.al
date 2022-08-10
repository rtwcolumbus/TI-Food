﻿page 130 "Posted Sales Shipment"
{
    // PR3.70.03
    //   Fix control misalignment
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW18.00.02
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Reorganize Shipping tab
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Posted Sales Shipment';
    InsertAllowed = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Print/Send,Shipment,Certificate of Supply';
    SourceTable = "Sales Shipment Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the record.';
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer';
                    Editable = false;
                    ToolTip = 'Specifies the name of customer at the sell-to address.';
                }
                group("Sell-to")
                {
                    Caption = 'Sell-to';
                    field("Sell-to Address"; "Sell-to Address")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Address';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the customer''s sell-to address.';
                    }
                    field("Sell-to Address 2"; "Sell-to Address 2")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Address 2';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the customer''s extended sell-to address.';
                    }
                    field("Sell-to City"; "Sell-to City")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'City';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the city of the customer on the sales document.';
                    }
                    group(Control15)
                    {
                        ShowCaption = false;
                        Visible = IsSellToCountyVisible;
                        field("Sell-to County"; "Sell-to County")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'County';
                            Editable = false;
                            Importance = Additional;
                            ToolTip = 'Specifies the state, province or county as a part of the address.';
                        }
                    }
                    field("Sell-to Post Code"; "Sell-to Post Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post Code';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the post code of the customer''s sell-to address.';
                    }
                    field("Sell-to Country/Region Code"; "Sell-to Country/Region Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Country/Region';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the country/region of the customer on the sales document.';
                    }
                    field("Sell-to Contact No."; "Sell-to Contact No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Contact No.';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the contact number.';
                    }
                    field(SellToPhoneNo; SellToContact."Phone No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Phone No.';
                        Importance = Additional;
                        Editable = false;
                        ExtendedDatatype = PhoneNo;
                        ToolTip = 'Specifies the telephone number of the contact person at the customer''s sell-to address.';
                    }
                    field(SellToMobilePhoneNo; SellToContact."Mobile Phone No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Mobile Phone No.';
                        Importance = Additional;
                        Editable = false;
                        ExtendedDatatype = PhoneNo;
                        ToolTip = 'Specifies the mobile telephone number of the contact person at the customer''s sell-to address.';
                    }
                    field(SellToEmail; SellToContact."E-Mail")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Email';
                        Importance = Additional;
                        Editable = false;
                        ExtendedDatatype = EMail;
                        ToolTip = 'Specifies the email address of the contact person at the customer''s sell-to address.';
                    }
                }
                field("Sell-to Contact"; "Sell-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contact';
                    Editable = false;
                    ToolTip = 'Specifies the name of the contact at the customer''s sell-to address.';
                }
                field("No. Printed"; "No. Printed")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies how many times the document has been printed.';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the posting date for the entry.';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the posting date of the document.';
                }
                field("Requested Delivery Date"; "Requested Delivery Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date that the customer has asked for the order to be delivered.';
                }
                field("Promised Delivery Date"; "Promised Delivery Date")
                {
                    ApplicationArea = OrderPromising;
                    Editable = false;
                    ToolTip = 'Specifies the date that you have promised to deliver the order, as a result of the Order Promising function.';
                }
                field("Quote No."; "Quote No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of the sales quote document if a quote was used to start the sales process.';
                }
                field("Order No."; "Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the sales order that this invoice was posted from.';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the number that the customer uses in their own system to refer to this sales document.';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies a code for the salesperson who normally handles this customer''s account.';
                }
                field("Responsibility Center"; "Responsibility Center")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the code for the responsibility center that serves the customer on this sales document.';
                }
                group("Work Description")
                {
                    Caption = 'Work Description';
                    field(GetWorkDescription; GetWorkDescription)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        Importance = Additional;
                        MultiLine = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the products or services being offered.';
                    }
                }
            }
            part(SalesShipmLines; "Posted Sales Shpt. Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Document No." = FIELD("No.");
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Address Code';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the code for the customer''s additional shipment address.';
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the customer that you delivered the items to.';
                }
                field("Ship-to Address"; "Ship-to Address")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Address';
                    Editable = false;
                    ToolTip = 'Specifies the address that you delivered the items to.';
                }
                field("Ship-to Address 2"; "Ship-to Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Address 2';
                    Editable = false;
                    ToolTip = 'Specifies the extended address that you delivered the items to.';
                }
                field("Ship-to City"; "Ship-to City")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'City';
                    Editable = false;
                    ToolTip = 'Specifies the city of the customer on the sales document.';
                }
                group(Control21)
                {
                    ShowCaption = false;
                    Visible = IsShipToCountyVisible;
                    field("Ship-to County"; "Ship-to County")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'County';
                        Editable = false;
                        ToolTip = 'Specifies the state, province or county as a part of the address.';
                    }
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Code';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the post code of the customer''s ship-to address.';
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Country/Region';
                    Editable = false;
                    ToolTip = 'Specifies the customer''s country/region.';
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contact';
                    Editable = false;
                    ToolTip = 'Specifies the name of the person you regularly contact at the address that the items were shipped to.';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the location from where inventory items to the customer on the sales document are to be shipped by default.';
                }
                field("Delivery Route No."; "Delivery Route No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Delivery Stop No."; "Delivery Stop No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Outbound Whse. Handling Time"; "Outbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                    ToolTip = 'Specifies a date formula for the time it takes to get items ready to ship from this location. The time element is used in the calculation of the delivery date as follows: Shipment Date + Outbound Warehouse Handling Time = Planned Shipment Date + Shipping Time = Planned Delivery Date.';
                }
                field("Shipping Time"; "Shipping Time")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies how long it takes from when the items are shipped from the warehouse to when they are delivered.';
                }
                group("Shipment Method")
                {
                    Caption = 'Shipment Method';
                    field("Shipment Method Code"; "Shipment Method Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Code';
                        Editable = false;
                        ToolTip = 'Specifies the shipment method for the shipment.';
                    }
                    field("Shipping Agent Code"; "Shipping Agent Code")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Agent';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies which shipping agent is used to transport the items on the sales document to the customer.';
                    }
                    field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Agent Service';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies which shipping agent service is used to transport the items on the sales document to the customer.';
                    }
                    field("Package Tracking No."; "Package Tracking No.")
                    {
                        ApplicationArea = Suite;
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the shipping agent''s package number.';
                    }
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                }
            }
            group(Billing)
            {
                Caption = 'Billing';
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer No.';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the customer at the billing address.';
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the customer that you sent the invoice to.';
                }
                field("Bill-to Address"; "Bill-to Address")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Address';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the address that you sent the invoice to.';
                }
                field("Bill-to Address 2"; "Bill-to Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Address 2';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the extended address that you sent the invoice to.';
                }
                field("Bill-to City"; "Bill-to City")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'City';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the city of the customer on the sales document.';
                }
                group(Control29)
                {
                    ShowCaption = false;
                    Visible = IsBillToCountyVisible;
                    field("Bill-to County"; "Bill-to County")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'County';
                        Editable = false;
                        Importance = Additional;
                        ToolTip = 'Specifies the state, province or county as a part of the address.';
                    }
                }
                field("Bill-to Post Code"; "Bill-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Code';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the post code of the customer''s bill-to address.';
                }
                field("Bill-to Country/Region Code"; "Bill-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Country/Region Code';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the country or region of the address.';
                }
                field("Bill-to Contact No."; "Bill-to Contact No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contact No.';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the contact person at the customer''s bill-to address.';
                }
                field(BillToContactPhoneNo; BillToContact."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Phone No.';
                    Editable = false;
                    Importance = Additional;
                    ExtendedDatatype = PhoneNo;
                    ToolTip = 'Specifies the telephone number of the contact person at the customer''s bill-to address.';
                }
                field(BillToContactMobilePhoneNo; BillToContact."Mobile Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Mobile Phone No.';
                    Editable = false;
                    Importance = Additional;
                    ExtendedDatatype = PhoneNo;
                    ToolTip = 'Specifies the mobile telephone number of the contact person at the customer''s bill-to address.';
                }
                field(BillToContactEmail; BillToContact."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Email';
                    Editable = false;
                    Importance = Additional;
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the email address of the contact at the customer''s bill-to address.';
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contact';
                    Editable = false;
                    ToolTip = 'Specifies the name of the person you regularly contact at the customer to whom you sent the invoice.';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
            }
            group(ElectronicDocument)
            {
                Caption = 'Electronic Document';
                field("Transit-to Location"; "Transit-to Location")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the location that the goods or merchandise are moved to.';
                }
                field("Transport Operators"; "Transport Operators")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the operator of the vehicle that transports the goods or merchandise.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Transit-from Date/Time"; "Transit-from Date/Time")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the estimated date and time at which the goods or merchandise leave the start address.';
                }
                field("Transit Hours"; "Transit Hours")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the estimated time in hours that it will take to transit from the start address to the temporary or final destination.';
                }
                field("Transit Distance"; "Transit Distance")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the distance travelled in kilometers from the start address to the temporary or final destination as a combination of the distances that are travelled by the different means of transport that move the goods or merchandise.';
                }
                field("Vehicle Code"; "Vehicle Code")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the vehicle that transports the goods or merchandise.';
                }
                field("Trailer 1"; "Trailer 1")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the trailer or semi-trailer that is used with the vehicle for the transfer of goods or merchandise.';
                }
                field("Trailer 2"; "Trailer 2")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the second trailer or semi-trailer that is used with the vehicle for the transfer of goods or merchandise.';
                }
                field("Foreign Trade"; "Foreign Trade")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies whether the goods or merchandise that are transported enter or leave the national territory.';
                }
                field("Insurer Name"; "Insurer Name")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the name of the insurer that covers the risks of the motor transport used for the transfer of goods or merchandise.';
                }
                field("Insurer Policy Number"; "Insurer Policy Number")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the policy number assigned by the insurer, which covers the risks of the motor transport used for the transfer of goods or merchandise.';
                }
                field("Medical Insurer Name"; "Medical Insurer Name")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the insurer that covers potential damage to the environment if the transport includes materials, residues or remnants, or hazardous waste.';
                }
                field("Medical Ins. Policy Number"; "Medical Ins. Policy Number")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the insurance policy number if the transport includes materials, residues or remnants, or hazardous waste.';
                }
                field("SAT Weight Unit Of Measure"; "SAT Weight Unit Of Measure")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the unit of measurement of the weight of the goods and / or merchandise that are moved in this transport.';
                }
                field("Electronic Document Status"; "Electronic Document Status")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the status of the document.';
                }
                field("Date/Time Stamped"; "Date/Time Stamped")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the date and time that the document received a digital stamp from the authorized service provider.';
                }
                field("Date/Time Canceled"; "Date/Time Canceled")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the date and time that the document was canceled.';
                }
                field("Error Code"; "Error Code")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the error code that the authorized service provider, PAC, has returned to Business Central.';
                }
                field("Error Description"; "Error Description")
                {
                    ApplicationArea = BasicMX;
                    ToolTip = 'Specifies the error message that the authorized service provider, PAC, has returned to Business Central.';
                }
                field("PAC Web Service Name"; "PAC Web Service Name")
                {
                    ApplicationArea = BasicMX;
                    Importance = Additional;
                    ToolTip = 'Specifies the name of the authorized service provider, PAC, which has processed the electronic document.';
                }
                field("Fiscal Invoice Number PAC"; "Fiscal Invoice Number PAC")
                {
                    ApplicationArea = BasicMX;
                    Importance = Additional;
                    ToolTip = 'Specifies the official invoice number for the electronic document.';
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
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Shipment")
            {
                Caption = '&Shipment';
                Image = Shipment;
                action(Statistics)
                {
                    ApplicationArea = Suite;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Page "Sales Shipment Statistics";
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category5;
                    RunObject = Page "Sales Comment Sheet";
                    RunPageLink = "Document Type" = CONST(Shipment),
                                  "No." = FIELD("No."),
                                  "Document Line No." = CONST(0);
                    ToolTip = 'View or add comments for the record.';
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions();
                    end;
                }
                action(Approvals)
                {
                    AccessByPermission = TableData "Posted Approval Entry" = R;
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.ShowPostedApprovalEntries(RecordId);
                    end;
                }
                action(CertificateOfSupplyDetails)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Certificate of Supply Details';
                    Image = Certificate;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "Certificates of Supply";
                    RunPageLink = "Document Type" = FILTER("Sales Shipment"),
                                  "Document No." = FIELD("No.");
                    ToolTip = 'View the certificate of supply that you must send to your customer for signature as confirmation of receipt. You must print a certificate of supply if the shipment uses a combination of VAT business posting group and VAT product posting group that have been marked to require a certificate of supply in the VAT Posting Setup window.';
                }
                action(PrintCertificateofSupply)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print Certificate of Supply';
                    Image = PrintReport;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ToolTip = 'Print the certificate of supply that you must send to your customer for signature as confirmation of receipt.';

                    trigger OnAction()
                    var
                        CertificateOfSupply: Record "Certificate of Supply";
                    begin
                        CertificateOfSupply.SetRange("Document Type", CertificateOfSupply."Document Type"::"Sales Shipment");
                        CertificateOfSupply.SetRange("Document No.", "No.");
                        CertificateOfSupply.Print;
                    end;
                }
                separator(Separator37002003)
                {
                }
                action("Data Sheets")
                {
                    AccessByPermission = TableData "Data Sheet Header" = R;
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Sheets';
                    Ellipsis = true;
                    Image = EntriesList;

                    trigger OnAction()
                    var
                        DataCollectionMgmt: Codeunit "Data Collection Management";
                    begin
                        // P8001090
                        DataCollectionMgmt.DataSheetsForSalesShipment(Rec);
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("&Track Package")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Track Package';
                    Image = ItemTracking;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Open the shipping agent''s tracking page to track the package. ';

                    trigger OnAction()
                    begin
                        StartTrackingSite();
                    end;
                }
            }
            group("Electronic Document")
            {
                Caption = '&Electronic Document';
                action("S&end")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'S&end';
                    Ellipsis = true;
                    Image = SendTo;
                    Promoted = true;
                    ToolTip = 'Send an email to the customer with the electronic invoice attached as an XML file.';

                    trigger OnAction()
                    begin
                        RequestStampEDocument();
                    end;
                }
                action("Export E-Document as &XML")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'Export E-Document as &XML';
                    Image = ExportElectronicDocument;
                    Promoted = true;
                    ToolTip = 'Export the posted sales invoice as an electronic invoice, and XML file, and save it to a specified location.';

                    trigger OnAction()
                    begin
                        ExportEDocument();
                    end;
                }
                action("&Cancel")
                {
                    ApplicationArea = BasicMX;
                    Caption = '&Cancel';
                    Image = Cancel;
                    Promoted = true;
                    ToolTip = 'Cancel the sending of the electronic sales invoice.';

                    trigger OnAction()
                    begin
                        CancelEDocument();
                    end;
                }
                action("Print Carta Porte Document")
                {
                    ApplicationArea = BasicMX;
                    Caption = 'Print Carta Porte Document';
                    Image = PrintForm;
                    ToolTip = 'Prepare to print the Carta Porte document so that it can be shown upon request from inspectors or other authorities.';

                    trigger OnAction()
                    var
                        ElectronicCartaPorteMX: Report "Electronic Carta Porte MX";
                    begin
                        ElectronicCartaPorteMX.SetRecord(Rec);
                        ElectronicCartaPorteMX.Run();
                    end;
                }
            }
            action("&Print")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Print the shipping notice.';

                trigger OnAction()
                begin
                    SalesShptHeader := Rec;
                    OnBeforePrintRecords(Rec, SalesShptHeader);
                    CurrPage.SetSelectionFilter(SalesShptHeader);
                    SalesShptHeader.PrintRecords(true);
                end;
            }
            action("&Navigate")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Category5;
                ShortCutKey = 'Shift+Ctrl+I';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';

                trigger OnAction()
                begin
                    Navigate;
                end;
            }
            action("Update Document")
            {
                ApplicationArea = Suite;
                Caption = 'Update Document';
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Add new information that is relevant to the document, such as information from the shipping agent. You can only edit a few fields because the document has already been posted.';

                trigger OnAction()
                var
                    PostedSalesShipmentUpdate: Page "Posted Sales Shipment - Update";
                begin
                    PostedSalesShipmentUpdate.LookupMode := true;
                    PostedSalesShipmentUpdate.SetRec(Rec);
                    PostedSalesShipmentUpdate.RunModal;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetSecurityFilterOnRespCenter;
        IsBillToCountyVisible := FormatAddress.UseCounty("Bill-to Country/Region Code");
        IsShipToCountyVisible := FormatAddress.UseCounty("Ship-to Country/Region Code");
        IsSellToCountyVisible := FormatAddress.UseCounty("Sell-to Country/Region Code");
    end;

    trigger OnAfterGetRecord()
    begin
        SellToContact.GetOrClear("Sell-to Contact No.");
        BillToContact.GetOrClear("Bill-to Contact No.");
    end;

    var
        SalesShptHeader: Record "Sales Shipment Header";
        SellToContact: Record Contact;
        BillToContact: Record Contact;
        FormatAddress: Codeunit "Format Address";
        IsBillToCountyVisible: Boolean;
        IsSellToCountyVisible: Boolean;
        IsShipToCountyVisible: Boolean;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintRecords(SalesShptHeaderRec: Record "Sales Shipment Header"; var SalesShptHeaderToPrint: Record "Sales Shipment Header")
    begin
    end;
}

