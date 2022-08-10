page 37002849 "My Assets"
{
    // PRW16.00.20
    // P8000671, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Standard page to display personal list of Assets
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.10
    // P8001222, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Change Open action to run card in View mode
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Refactoring changes to Open action
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'My Assets';
    PageType = ListPart;
    SourceTable = "My Asset";

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                ShowCaption = false;
                field("Asset No."; "Asset No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        SyncFieldsWithAsset; // P800703965
                    end;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
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
                RunObject = Page "Asset Card";
                RunPageLink = "No." = FIELD("Asset No.");
                RunPageMode = View;
                RunPageView = SORTING("No.");
                ShortCutKey = 'Return';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SyncFieldsWithAsset; // P800703965
    end;

    trigger OnOpenPage()
    begin
        SetRange("User ID", UserId);
    end;

    var
        Asset: Record Asset;

    local procedure SyncFieldsWithAsset()
    var
        MyAsset: Record "My Asset";
    begin
        // P800703965
        if Asset.Get("Asset No.") then
            if (Description <> Asset.Description) or (Type <> Asset.Type) or (Status <> Asset.Status) then begin
                Description := Asset.Description;
                Type := Asset.Type;
                Status := Asset.Status;
                if MyAsset.Get("User ID", "Asset No.") then
                    Modify;
            end;
    end;
}

