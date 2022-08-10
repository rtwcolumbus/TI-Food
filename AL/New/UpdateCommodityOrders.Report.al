report 37002685 "Update Commodity Orders"
{
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Update Commodity Orders';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(PurchOrder; "Purchase Header")
        {
            DataItemTableView = SORTING("Buy-from Vendor No.", "Pay-to Vendor No.", "Commodity Item No.", "Commodity P.O. Type") WHERE("Commodity Manifest Order" = CONST(true), "Commodity Item No." = FILTER(<> ''));
            RequestFilterFields = "Buy-from Vendor No.", "Pay-to Vendor No.", "Comm. P.O. Start Date", "Commodity Item No.", "Commodity P.O. Type";
            RequestFilterHeading = 'Purchase Order';

            trigger OnAfterGetRecord()
            begin
                StatusWindow.Update(1, "No.");
                if BlendUnitCost and ("Commodity P.O. Type" <> "Commodity P.O. Type"::Hauler) then
                    CommCostMgmt.SetBlendedOrderCost(PurchOrder, NewUnitCost)
                else
                    CommCostMgmt.CalcCommOrderCosts(PurchOrder, false);
                Commit;
            end;

            trigger OnPostDataItem()
            begin
                StatusWindow.Close;
            end;

            trigger OnPreDataItem()
            begin
                StatusWindow.Open(Text000);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(BlendUnitCost; BlendUnitCost)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Blend Unit Cost';

                        trigger OnValidate()
                        begin
                            RequestOptionsPage.Update(false);
                        end;
                    }
                    field("New Unit Cost"; NewUnitCost)
                    {
                        ApplicationArea = FOODBasic;
                        AutoFormatType = 2;
                        BlankZero = true;
                        Editable = BlendUnitCost;
                        Enabled = BlendUnitCost;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            BlendUnitCost := false;
        end;
    }

    labels
    {
    }

    var
        CommCostMgmt: Codeunit "Commodity Cost Management";
        StatusWindow: Dialog;
        Text000: Label 'Update Commodity Order Costs...\\Order No. #1##################';
        [InDataSet]
        BlendUnitCost: Boolean;
        NewUnitCost: Decimal;
}

