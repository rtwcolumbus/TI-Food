page 37002478 "New Version"
{
    // PR1.00.02
    //   Glue on buttons
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'New Version';
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            field(VersionNo; VersionNo)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Version Code';
            }
        }
    }

    actions
    {
    }

    var
        VersionNo: Code[20];

    procedure ReturnVersionNo(): Code[20]
    begin
        exit(VersionNo);
    end;
}

