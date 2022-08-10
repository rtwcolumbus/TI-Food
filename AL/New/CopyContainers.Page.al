page 37002599 "Copy Containers"
{
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order

    Caption = 'Copy Containers';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(NoOfContainers; NoOfContainers)
            {
                ApplicationArea = FOODBasic;
                Caption = 'No. of Containers';
                MaxValue = 99;
                MinValue = 1;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        NoOfContainers := 1;
    end;

    var
        NoOfContainers: Integer;

    procedure GetNoOfCopies(): Integer
    begin
        exit(NoOfContainers);
    end;
}

