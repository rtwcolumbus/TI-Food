page 37002842 "PM Worksheet"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Worksheet for generating suggested PM work orders and for creating them
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    AutoSplitKey = true;
    Caption = 'PM Worksheet';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "PM Worksheet";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CurrWkshName; CurrWkshName)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord;
                    if PAGE.RunModal(0, PMWkshName) = ACTION::LookupOK then begin
                        CurrWkshName := PMWkshName.Name;
                        FilterGroup := 2;
                        SetRange("PM Worksheet Name", CurrWkshName);
                        FilterGroup := 0;
                        if Find('-') then;
                    end;
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    CurrPage.SaveRecord;
                    FilterGroup := 2;
                    SetRange("PM Worksheet Name", CurrWkshName);
                    FilterGroup := 0;
                    if Find('-') then;
                    CurrPage.Update(false);
                end;
            }
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Create Order"; "Create Order")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Master PM"; "Master PM")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Asset No."; "Asset No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Group Code"; "Group Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Frequency Code"; "Frequency Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Last PM Date"; "Last PM Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Create Date"; "Create Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Work Requested"; "Work Requested")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900000003; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000004; Notes)
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
            group(PM)
            {
                Caption = 'PM';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Preventive Maintenance Order";
                    RunPageLink = "Entry No." = FIELD("PM Entry No.");
                    ShortCutKey = 'Shift+F7';
                }
            }
        }
        area(processing)
        {
            action("Suggest PM Orders")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Suggest PM Orders';
                Image = SuggestLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SuggestPM: Report "Suggest PM Orders";
                begin
                    SuggestPM.SetWkshName(CurrWkshName);
                    SuggestPM.RunModal;
                end;
            }
            separator(Separator1102603022)
            {
            }
            action("Create PM Orders")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Create PM Orders';
                Image = CreateDocuments;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MaintMgt: Codeunit "Maintenance Management";
                    WOCreated: array[2] of Code[20];
                begin
                    MaintMgt.CreatePMOrders(Rec, WOCreated);

                    if WOCreated[1] = '' then
                        Message(Text002)
                    else
                        if WOCreated[1] = WOCreated[2] then
                            Message(Text003, WOCreated[1])
                        else
                            Message(Text004, WOCreated[1], WOCreated[2]);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not PMWkshName.Get("PM Worksheet Name") then begin
            if PMWkshName.Find('-') then
                CurrWkshName := PMWkshName.Name
            else begin
                PMWkshName.Name := Text001;
                PMWkshName.Description := Text001;
                PMWkshName.Insert;
                CurrWkshName := PMWkshName.Name;
            end;
        end else
            CurrWkshName := "PM Worksheet Name";

        FilterGroup := 2;
        SetRange("PM Worksheet Name", CurrWkshName);
        FilterGroup := 0;
    end;

    var
        PMWkshName: Record "PM Worksheet Name";
        CurrWkshName: Code[10];
        Text001: Label 'Default';
        Text002: Label 'No work orders created.';
        Text003: Label 'Work order %1 created.';
        Text004: Label 'Work orders %1 through %2 created.';
}

