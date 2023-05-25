page 37002021 "Data Collection Data Elements"
{
    // PR1.10
    //   This form is used for maintaining the lot specification categories
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Renamed form and menu item
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001160, Columbus IT, Jack Reynolds, 23 MAY 13
    //   Add field for Create Separate Lines
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method
    // 
    // P80037659, To-Increase, Jack Reynolds, 25 JUL 18
    //   QC-Additions: Develop average measurement
    // 
    // PRW111.00.03
    // P80078499, To-increase, Gangabhushan, 04 JUL 19
    //   CS00070380 - Data Collection Data Elements will Expose an Error On Lookup Table
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Data Collection Data Elements';
    PageType = List;
    SourceTable = "Data Collection Data Element";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Create Separate Lines"; "Create Separate Lines")
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
                field("Averaging Method"; "Averaging Method")
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
        area(navigation)
        {
            group("Data Element")
            {
                Caption = 'Data Element';
                action(Lookups)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lookups';
                    Image = Delegate;
                    RunObject = Page "Data Collection Lookups";
                    RunPageLink = "Data Element Code" = FIELD(Code);
                    Visible = Type = Type::Lookup;
                }
            }
        }
        area(Promoted)
        {
            actionref(Lookups_Promoted; Lookups)
            {
            }
        }
    }
}

