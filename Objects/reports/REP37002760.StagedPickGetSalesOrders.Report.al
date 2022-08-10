report 37002760 "Staged Pick - Get Sales Orders"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks

    Caption = 'Staged Pick - Get Sales Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Warehouse Request"; "Warehouse Request")
        {
            DataItemTableView = SORTING(Type, "Location Code", "Source Type", "Source Subtype", "Source No.") WHERE(Type = CONST(Outbound), "Source Type" = CONST(37), "Source Subtype" = CONST("1"), "Document Status" = CONST(Released), "Completely Handled" = FILTER(false));
            dataitem("Sales Header"; "Sales Header")
            {
                DataItemLink = "No." = FIELD("Source No.");
                DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST(Order));
                dataitem(SalesLine; "Sales Line")
                {
                    DataItemLink = "Document No." = FIELD("No.");
                    DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE("Document Type" = CONST(Order), Type = CONST(Item));
                    RequestFilterFields = "Document No.", "No.", "Shipment Date";
                    RequestFilterHeading = 'Sales Order Line';

                    trigger OnAfterGetRecord()
                    begin
                        WhseStagedPickMgmt.AddSourceSalesLine(WhseStagedPickHeader, SalesLine);
                    end;
                }
            }

            trigger OnPreDataItem()
            begin
                if (ShptDateFilter <> '') then
                    SetFilter("Shipment Date", ShptDateFilter);
                SetRange("Location Code", WhseStagedPickHeader."Location Code");
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        WhseStagedPickHeader.Find;

        ShptDateFilter := SalesLine.GetFilter("Shipment Date");
    end;

    var
        ShptDateFilter: Text[250];
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
        WhseStagedPickMgmt: Codeunit "Whse. Staged Pick Mgmt.";

    procedure SetWhseStagedPick(StagedPickNo: Code[20])
    begin
        WhseStagedPickHeader.Get(StagedPickNo);
        WhseStagedPickHeader.TestField("Location Code");
        WhseStagedPickHeader.TestField("Staging Type",
          WhseStagedPickHeader."Staging Type"::Shipment);
    end;
}

