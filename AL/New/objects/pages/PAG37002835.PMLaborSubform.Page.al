page 37002835 "PM Labor Subform"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style subform for PM order labor activites
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 11 FEB 09
    //   Transformed from form
    //   Changes made to page after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Labor';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "PM Activity";
    SourceTableView = SORTING("PM Entry No.", Type, "Trade Code")
                      WHERE(Type = CONST(Labor));

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Trade Code"; "Trade Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CalcFields("Trade Description");
                    end;
                }
                field("Trade Description"; "Trade Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Rate (Hourly)"; "Rate (Hourly)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Planned Hours"; "Planned Hours")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Planned Cost"; "Planned Cost")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }
}

