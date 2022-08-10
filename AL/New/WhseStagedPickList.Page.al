page 37002765 "Whse. Staged Pick List"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Warehouse Staged Picks';
    CardPageID = "Whse. Staged Pick";
    DataCaptionFields = "No.";
    Editable = false;
    PageType = List;
    SourceTable = "Whse. Staged Pick Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sorting Method"; "Sorting Method")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Staging Status"; "Staging Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Staging Type"; "Staging Type")
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
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Staged &Pick")
            {
                Caption = 'Staged &Pick';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    begin
                        PAGE.Run(PAGE::"Whse. Staged Pick", Rec);
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Warehouse Comment Sheet";
                    RunPageLink = "Table Name" = CONST("Staged Pick"),
                                  Type = CONST(" "),
                                  "No." = FIELD("No.");
                }
                separator(Separator1102603011)
                {
                }
                action("Item &Pick Lines (To Stage)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item &Pick Lines (To Stage)';
                    Image = ItemLines;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Warehouse Activity Lines";
                    RunPageLink = "Whse. Document No." = FIELD("No.");
                    RunPageView = SORTING("Whse. Document No.", "Whse. Document Type", "Activity Type")
                                  WHERE("Activity Type" = CONST(Pick),
                                        "Whse. Document Type" = CONST(FOODStagedPick));
                }
                action("Reg. Item P&ick Lines (To Stage)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reg. Item P&ick Lines (To Stage)';
                    Image = RegisterPick;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Registered Whse. Act.-Lines";
                    RunPageLink = "Whse. Document No." = FIELD("No.");
                    RunPageView = SORTING("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.")
                                  WHERE("Whse. Document Type" = CONST(FOODStagedPick));
                }
                separator(Separator1102603014)
                {
                }
                action("O&rder Pick Lines (From Stage)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'O&rder Pick Lines (From Stage)';
                    Image = PickLines;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Warehouse Activity Lines";
                    RunPageLink = "From Staged Pick No." = FIELD("No.");
                    RunPageView = SORTING("From Staged Pick No.", "From Staged Pick Line No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.", "Unit of Measure Code", "Action Type", "Breakbulk No.", "Original Breakbulk");
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if Find(Which) then begin

            WhseStagedPickHeader := Rec;
            while true do
                if WMSMgt.LocationIsAllowed("Location Code") then
                    exit(true)
                else
                    if Next(1) = 0 then begin
                        Rec := WhseStagedPickHeader;
                        if Find(Which) then
                            while true do
                                if WMSMgt.LocationIsAllowed("Location Code") then
                                    exit(true)
                                else
                                    if Next(-1) = 0 then
                                        exit(false);
                    end;
        end;
        exit(false);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        RealSteps: Integer;
        NextSteps: Integer;
    begin
        if Steps = 0 then
            exit;

        WhseStagedPickHeader := Rec;
        repeat
            NextSteps := Next(Steps / Abs(Steps));
            if WMSMgt.LocationIsAllowed("Location Code") then begin
                RealSteps := RealSteps + NextSteps;
                WhseStagedPickHeader := Rec;
            end;
        until (NextSteps = 0) or (RealSteps = Steps);
        Rec := WhseStagedPickHeader;
        Find;
        exit(RealSteps);
    end;

    var
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
        WMSMgt: Codeunit "WMS Management";
}

