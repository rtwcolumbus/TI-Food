report 37002762 "Staged Pick - Get Prod. Orders"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks

    Caption = 'Staged Pick - Get Prod. Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Prod. Order Line"; "Prod. Order Line")
        {
            DataItemTableView = SORTING(Status, "Prod. Order No.", "Line No.") WHERE(Status = CONST(Released));
            RequestFilterFields = "Prod. Order No.", "Item No.", "Starting Date";
            RequestFilterHeading = 'Prod. Order Line';
            dataitem(ProdCompLine; "Prod. Order Component")
            {
                DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("Prod. Order No."), "Prod. Order Line No." = FIELD("Line No.");
                DataItemTableView = SORTING(Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.");
                RequestFilterFields = "Item No.";
                RequestFilterHeading = 'Prod. Order Component';

                trigger OnAfterGetRecord()
                begin
                    WhseStagedPickMgmt.AddSourceProdCompLine(WhseStagedPickHeader, ProdCompLine);
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
          WhseStagedPickHeader."Staging Type"::Production);
    end;
}

