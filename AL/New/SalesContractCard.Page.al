page 37002182 "Sales Contract Card"
{
    // PRW16.00.06
    // P8001044, Columbus IT, Jack Reynolds, 14 MAR 12
    //   Fix problem editing Starting Date and Ending Date
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Sales Contract';
    PageType = Document;
    SourceTable = "Sales Contract";
    SourceTableView = SORTING("No.");

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002019)
                {
                    ShowCaption = false;
                    field("Sales Type"; "Sales Type")
                    {
                        ApplicationArea = FOODBasic;

                        trigger OnValidate()
                        begin
                            if ("Sales Code" <> '') or ("Sales Type" = "Sales Type"::"All Customers") then begin // P8001044
                                CurrPage.SaveRecord; // P8001044
                                CurrPage.SalesPriceLines.PAGE.SetContract(Rec);
                            end;                   // P8001044
                            "Sales Code" := ''; // P800-MegaApp
                            UpdatePageControls;
                        end;
                    }
                    field("Sales Code"; "Sales Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = SalesCodeEditable;

                        trigger OnValidate()
                        begin
                            if ("Sales Code" <> '') or ("Sales Type" = "Sales Type"::"All Customers") then begin // P8001044
                                CurrPage.SaveRecord; // P8001044
                                CurrPage.SalesPriceLines.PAGE.SetContract(Rec);
                            end;                   // P8001044
                        end;
                    }
                }
                group(Control37002017)
                {
                    ShowCaption = false;
                    field("Starting Date"; "Starting Date")
                    {
                        ApplicationArea = FOODBasic;

                        trigger OnValidate()
                        begin
                            // P8001044
                            if "Starting Date" <> xRec."Starting Date" then begin
                                CurrPage.SaveRecord;
                                CurrPage.SalesPriceLines.PAGE.SetContract(Rec);
                            end;
                            // P8001044
                        end;
                    }
                    field("Ending Date"; "Ending Date")
                    {
                        ApplicationArea = FOODBasic;

                        trigger OnValidate()
                        begin
                            // P8001044
                            if "Ending Date" <> xRec."Ending Date" then begin
                                CurrPage.SaveRecord;
                                CurrPage.SalesPriceLines.PAGE.SetContract(Rec);
                            end;
                            // P8001044
                        end;
                    }
                }
                group(Control37002018)
                {
                    ShowCaption = false;
                    field("Contract Limit Unit of Measure"; "Contract Limit Unit of Measure")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Contract Limit"; "Contract Limit")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(CalcLimitUsed; CalcLimitUsed)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contract Limit Used';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                    }
                }
            }
            group(Control37002016)
            {
                ShowCaption = false;
                part(SalesContractLines; "Sales Contract Subform")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Contract Lines';
                    SubPageLink = "Contract No." = FIELD("No.");
                    SubPageView = SORTING("Contract No.", "Item Type", "Item Code");
                }
                part(SalesPriceLines; "Sales Contract Price Subform")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sales Prices';
                    Provider = SalesContractLines;
                    SubPageLink = "Contract No." = FIELD("Contract No."),
                                  "Item Type" = FIELD("Item Type"),
                                  "Item Code" = FIELD("Item Code");
                    SubPageView = SORTING("Contract No.")
                                  WHERE("Price Type" = CONST(Contract));
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("&Customer")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Customer';
                Image = Customer;
                ShortCutKey = 'Shift+F5';

                trigger OnAction()
                begin
                    Cust.Reset;
                    case "Sales Type" of
                        "Sales Type"::Customer:
                            Cust.SetRange("No.", "Sales Code");
                        "Sales Type"::"Customer Price Group":
                            Cust.SetRange("Customer Price Group", "Sales Code");
                        "Sales Type"::"All Customers", "Sales Type"::Campaign:
                            Cust.Reset;
                    end;
                    PAGE.Run(PAGE::"Customer Card", Cust);
                end;
            }
            action("&History")
            {
                ApplicationArea = FOODBasic;
                Caption = '&History';
                Image = History;
                RunObject = Page "Sales Contract History";
                RunPageLink = "Contract No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
            }
            action("&Sales Documents")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Sales Documents';
                Image = Documents;

                trigger OnAction()
                begin
                    SalesLine.Reset;
                    SalesLine.SetCurrentKey("Contract No.", "Price ID");
                    SalesLine.SetRange("Contract No.", "No.");
                    PAGE.RunModal(PAGE::"Sales Lines", SalesLine);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        if ("No." <> '') and (("Sales Code" <> '') or ("Sales Type" = "Sales Type"::"All Customers")) then
            CurrPage.SalesPriceLines.PAGE.SetContract(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        UpdatePageControls;
    end;

    trigger OnOpenPage()
    begin
        if ("No." <> '') and (("Sales Code" <> '') or ("Sales Type" = "Sales Type"::"All Customers")) then
            CurrPage.SalesPriceLines.PAGE.SetContract(Rec);
        UpdatePageControls(); // P800-MegaApp
    end;

    var
        Cust: Record Customer;
        [InDataSet]
        SalesCodeEditable: Boolean;
        SalesLine: Record "Sales Line";

    procedure UpdatePageControls()
    begin
        SalesCodeEditable := "Sales Type" <> "Sales Type"::"All Customers";
    end;
}

