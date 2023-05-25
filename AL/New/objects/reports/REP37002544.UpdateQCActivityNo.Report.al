report 37002544 "Update Q/C Activity No."
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Update Q/C Activity No.';
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem(ExistingQCHeader; "Quality Control Header")
        {
            DataItemTableView = WHERE("Q/C Activity No." = FILTER(<> ''));

            trigger OnAfterGetRecord()
            begin
                Error(QCActivitiesExistsErrorTxt);
            end;
        }
        dataitem("Quality Control Header"; "Quality Control Header")
        {
            DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", "Test No.");

            trigger OnAfterGetRecord()
            begin
                InsertActivityNo;
            end;

            trigger OnPreDataItem()
            var
                InventorySetup: Record "Inventory Setup";
            begin
                InventorySetup.Get;
                InventorySetup.TestField("Q/C Activity Nos.");
                if not Confirm(AssignQCActivityNoConfirmTxt, false) then
                    Error('');
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

    var
        QCActivitiesExistsErrorTxt: Label 'One or more Q/C Activities exists with activity no. assigned.';
        AssignQCActivityNoConfirmTxt: Label 'Do you want to assign Q/C Activity Nos. from number series?';
}

