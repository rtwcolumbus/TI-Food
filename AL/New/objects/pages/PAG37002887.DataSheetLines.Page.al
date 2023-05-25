page 37002887 "Data Sheet Lines"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method
    // 
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work

    Caption = 'Data Sheet Lines';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Data Sheet Line";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Data Element Code"; "Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Data Element Type"; "Data Element Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Schedule Date"; "Schedule Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Schedule Time"; "Schedule Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Result; Result)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DataCollectionMgmt: Codeunit "Data Collection Management";
                    begin
                        if "Data Element Type" <> "Data Element Type"::"Lookup" then
                            exit(false);
                        exit(DataCollectionMgmt.DataElementLookup("Data Element Code", Text))
                    end;
                }
                field("Actual Date"; "Actual Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Actual Time"; "Actual Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Recurrence; Recurrence)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Frequency; Frequency)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Scheduled Type"; "Scheduled Type")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Schedule Base"; "Schedule Base")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
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
    }

    actions
    {
    }

    trigger OnModifyRecord(): Boolean
    begin
        Modify(true);
        CurrPage.Update(false);
        exit(false);
    end;
}

