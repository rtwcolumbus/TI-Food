report 37002761 "Staged Pick - Get Shipments"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks

    Caption = 'Staged Pick - Get Shipments';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Warehouse Shipment Header"; "Warehouse Shipment Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Shipment Date";
            RequestFilterHeading = 'Shipment Header';
            dataitem(WhseShptLine; "Warehouse Shipment Line")
            {
                DataItemLink = "No." = FIELD("No.");
                DataItemTableView = SORTING("No.", "Line No.");
                RequestFilterFields = "Item No.", "Due Date";
                RequestFilterHeading = 'Shipment Line';

                trigger OnAfterGetRecord()
                begin
                    WhseStagedPickMgmt.AddSourceWhseShptLine(WhseStagedPickHeader, WhseShptLine);
                end;
            }
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
    end;

    var
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

