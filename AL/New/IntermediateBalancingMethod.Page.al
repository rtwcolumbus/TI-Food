page 37002513 "Intermediate Balancing Method"
{
    // PR3.70.06
    // P8000112A, Myers Nissi, Jack Reynolds, 10 SEP 04
    //   Form to allow user to specify intermediate balancing method
    // 
    // PRW16.00.03
    // P8000796, VerticalSoft, Don Bresee, 01 APR 10
    //   Rework interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Intermediate Balancing Method';
    InstructionalText = 'The intermediate quantities will be adjusted so that the output of the batch order is equal to the total consumption on packaging orders. Do you want to balance the intermediate quantities?';
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            field(BalancingMethod; BalancingMethod)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Balance by Adjusting';
                MultiLine = true;
            }
        }
    }

    actions
    {
    }

    var
        BalancingMethod: Option ,"Output on the Batch Order","Consumption on the Packaging Orders";

    procedure SetBalancingMethod(Method: Integer)
    begin
        BalancingMethod := Method;
    end;

    procedure GetBalancingMethod(): Integer
    begin
        exit(BalancingMethod);
    end;
}

