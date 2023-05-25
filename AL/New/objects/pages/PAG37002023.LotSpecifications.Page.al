page 37002023 "Lot Specifications"
{
    // PR1.10
    //   This form is used for displaying the lot specifications associated with a lot
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Removed controls for individual type values and replace with single Value control
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 06 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method

    Caption = 'Lot Specifications';
    DataCaptionFields = "Item No.", "Lot No.";
    PageType = List;
    SourceTable = "Lot Specification";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Data Element Code"; "Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Value; Value)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        LotSpecFns: Codeunit "Lot Specification Functions";
                    begin
                        // P8000152A Begin
                        if Type <> Type::"Lookup" then
                            exit(false);
                        exit(LotSpecFns.LotSpecLookup("Data Element Code", Text));
                    end;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Certificate of Analysis"; "Certificate of Analysis")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Measuring Method"; "Measuring Method")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

