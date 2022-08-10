page 37002518 "Resize Batch"
{
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Resize Batch';
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            field(BatchSize; BatchSize)
            {
                ApplicationArea = FOODBasic;
                CaptionClass = '3,' + BatchSizeCaption;
                DecimalPlaces = 0 : 5;

                trigger OnValidate()
                begin
                    if BatchSize <= 0 then
                        Error(Text001);
                end;
            }
        }
    }

    actions
    {
    }

    var
        BatchSize: Decimal;
        BatchSizeCaption: Text[30];
        Text001: Label 'Batch size may not be less than or equal to zero.';

    procedure SetCaption(text: Text[30])
    begin
        BatchSizeCaption := text;
    end;

    procedure SetBatchSize(size: Decimal)
    begin
        BatchSize := size;
    end;

    procedure GetBatchSize(): Decimal
    begin
        exit(BatchSize);
    end;
}

