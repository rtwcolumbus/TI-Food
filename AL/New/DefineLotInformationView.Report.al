report 37002661 "Define Lot Information View"
{
    // PR4.00
    // P8000244A, Myers Nissi, Jack Reynolds, 03 OCT 05
    //   Processing only report used to define view for lot summary form

    Caption = 'Lot Information View';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Lot No. Information"; "Lot No. Information")
        {
            RequestFilterFields = "Item No.", "Variant Code", "Lot No.", "Document No.", "Document Date";

            trigger OnPreDataItem()
            begin
                CurrReport.Break;
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
        ViewSet := true;
        LotInfoViewRec.Copy("Lot No. Information");
    end;

    var
        ViewSet: Boolean;
        LotInfoViewRec: Record "Lot No. Information";

    procedure GetView(var NewLotInfoViewRec: Record "Lot No. Information"): Boolean
    begin
        if ViewSet then
            NewLotInfoViewRec.Copy(LotInfoViewRec);
        exit(ViewSet);
    end;
}

