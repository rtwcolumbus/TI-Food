page 37002894 "My Alerts"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.10
    // P8001222, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Change Open action to run card in View mode
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Refactoring changes to Open action

    Caption = 'My Alerts';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "My Alert";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("DataSheetHeader.Description"; DataSheetHeader.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Sheet';
                    Editable = false;
                }
                field("DataElement.Description"; DataElement.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Element';
                    Editable = false;
                }
                field("DataCollectionAlert.Critical"; DataCollectionAlert.Critical)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Critical';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Open)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Open';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Data Collection Alert";
                RunPageLink = "Entry No." = FIELD("Alert Entry No.");
                RunPageMode = View;
                RunPageView = SORTING("Entry No.");
                ShortCutKey = 'Return';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DataCollectionAlert.Get("Alert Entry No.");
        DataSheetHeader.Get(DataCollectionAlert."Data Sheet No.");
        DataElement.Get(DataCollectionAlert."Data Element Code");
    end;

    trigger OnOpenPage()
    begin
        SetRange("User ID", UserId);
    end;

    var
        DataSheetHeader: Record "Data Sheet Header";
        DataElement: Record "Data Collection Data Element";
        DataCollectionAlert: Record "Data Collection Alert";
}

