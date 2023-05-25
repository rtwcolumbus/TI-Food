page 7302 Bins
{
    // PRW16.00.04
    // P8000890, VerticalSoft, Don Bresee, 16 DEC 10
    //   Add "Combine Lots Method" fields
    //   Add Clear function to empty the bin
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality

    Caption = 'Bins';
    DataCaptionExpression = GetCaption();
    DelayedInsert = true;
    PageType = List;
    SourceTable = Bin;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the location from which you opened the Bins window.';
                    Visible = false;
                }
                field("Code"; Code)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a code that uniquely describes the bin.';
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = Warehouse;
                    Editable = true;
                    ToolTip = 'Specifies the code of the zone in which the bin is located.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a description of the bin.';
                }
                field("Bin Type Code"; Rec."Bin Type Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the bin type that applies to the bin.';
                    Visible = false;
                }
                field("Warehouse Class Code"; Rec."Warehouse Class Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the warehouse class that applies to the bin.';
                    Visible = false;
                }
                field("Block Movement"; Rec."Block Movement")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how the movement of an item, or bin content, into or out of this bin, is blocked.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        if "Block Movement" <> xRec."Block Movement" then
                            if not Confirm(Text004, false) then
                                Error('');
                    end;
                }
                field("Special Equipment Code"; Rec."Special Equipment Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the equipment needed when working in the bin.';
                    Visible = false;
                }
                field("Bin Ranking"; Rec."Bin Ranking")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the ranking of the bin. Items in the highest-ranking bins (with the highest number in the field) will be picked first.';
                    Visible = false;
                }
                field("Maximum Cubage"; Rec."Maximum Cubage")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the maximum cubage (volume) that the bin can hold.';
                    Visible = false;
                }
                field("Maximum Weight"; Rec."Maximum Weight")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the maximum weight that this bin can hold.';
                    Visible = false;
                }
                field(Empty; Empty)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies that the bin Specifies no items.';
                }
                field("Cross-Dock Bin"; Rec."Cross-Dock Bin")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies if the bin is considered a cross-dock bin.';
                    Visible = false;
                }
                field(Dedicated; Dedicated)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies that quantities in the bin are protected from being picked for other demands.';
                }
                field("Lot Combination Method"; "Lot Combination Method")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Current Item No."; "Current Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Current Variant Code"; "Current Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Current Lot No."; "Current Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Clear")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Clear';
                Ellipsis = true;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    CombineLots: Codeunit "Combine Whse. Lots";
                begin
                    // P8000890
                    TestField("Lot Combination Method", "Lot Combination Method"::"Use Existing Lot");
                    if ("Current Lot No." = '') then
                        TestField(Empty, false);
                    if Confirm(Text37002100, false, TableCaption, Code, FieldCaption("Current Lot No.")) then begin
                        CombineLots.ClearBin(Rec);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
        area(navigation)
        {
            group("&Bin")
            {
                Caption = '&Bin';
                Image = Bins;
                action("&Contents")
                {
                    ApplicationArea = Warehouse;
                    Caption = '&Contents';
                    Image = BinContent;
                    RunObject = Page "Bin Content";
                    RunPageLink = "Location Code" = FIELD("Location Code"),
                                  "Zone Code" = FIELD("Zone Code"),
                                  "Bin Code" = FIELD(Code);
                    ToolTip = 'View the bin content. A bin can hold several different items. Each item that has been fixed to the bin, placed in the bin, or for which the bin is the default bin appears in this window as a separate line. Some of the fields on the lines contain information about the bin for which you are creating bin content, for example, the bin ranking, and you cannot change these values.';
                }
                action(DataCollectionLines)
                {
                    AccessByPermission = TableData "Data Collection Line" = R;
                    ApplicationArea = FOODBasic;
                    Caption = 'Data Collection Lines';
                    Image = EditLines;
                    RunObject = Page "Data Collection Lines";
                    RunPageLink = "Source ID" = CONST(7354),
                                  "Source Key 1" = FIELD("Location Code"),
                                  "Source Key 2" = FIELD(Code);
                }
                separator(Separator37002008)
                {
                }
                action("Clear Bin &History")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Clear Bin &History';
                    Image = Delete;
                    RunObject = Page "Clear Bin History Entries";
                    RunPageLink = "Location Code" = FIELD("Location Code"),
                                  "Bin Code" = FIELD(Code);
                    RunPageView = SORTING("Location Code", "Bin Code");
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if GetFilter("Zone Code") <> '' then
            "Zone Code" := GetFilter("Zone Code");
        SetUpNewLine();
    end;

    var
        Text004: Label 'Do you want to update the bin contents?';
        Text37002100: Label '%1 %2 will be emptied and the %3 will be cleared.\\Are you sure you want to clear %1 %2?';

    local procedure GetCaption(): Text[250]
    var
        ObjTransl: Record "Object Translation";
        FormCaption: Text[250];
        SourceTableName: Text[30];
    begin
        SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 14);
        FormCaption := StrSubstNo('%1 %2', SourceTableName, "Location Code");
        exit(FormCaption);
    end;
}

