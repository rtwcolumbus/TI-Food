page 37002471 "Unapproved Item List"
{
    // PR1.00, Myers Nissi, Jack Reynolds, 30 JUL 00, PR007
    //   Standard lookup list form for Unapproved Items
    // 
    // PR2.00.04
    //   Document Management
    // 
    // PRW15.00.01
    // P8000559A, VerticalSoft, Jack Reynolds, 18 JAN 08
    //   Fix incorrect reference for comments
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 05 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Unapproved Items';
    CardPageID = "Unapproved Item Card";
    Editable = false;
    PageType = List;
    SourceTable = "Unapproved Item";
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
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Search Description"; "Search Description")
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
            group("&Item")
            {
                Caption = '&Item';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(FOODUnapprovedItem),
                                  "No." = FIELD("No.");
                }
                separator(Separator1102603018)
                {
                }
                action("&Units of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Units of Measure';
                    Image = UnitOfMeasure;
                    RunObject = Page "Unappr Item Units of Measure";
                    RunPageLink = "Unapproved Item No." = FIELD("No.");
                }
                action(Allergens)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Image = Properties;
                    ObsoleteReason = 'Replaced by ShowAllergens action';
                    ObsoleteState = Pending;
                    ObsoleteTag = 'FOOD-22';
                    Visible = false;

                    trigger OnAction()
                    begin
                        // P8006959
                        ShowAllergens;
                        if "Allergen Set ID" <> xRec."Allergen Set ID" then
                            CurrPage.SaveRecord;
                    end;
                }
                action(ShowAllergens)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Image = Properties;

                    trigger OnAction()
                    begin
                        // P8006959
                        ShowAllergens;
                        if "Allergen Set ID" <> xRec."Allergen Set ID" then
                            CurrPage.SaveRecord;
                    end;
                }
                action(AllergenHistory)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergen History';
                    Image = History;
                    RunObject = Page "Allergen Set History";
                    RunPageLink = "Table No." = CONST(37002465),
                                  "Code 1" = FIELD("No.");
                }
            }
        }
        area(Promoted)
        {
            actionref(UnitsOfMeasure_Promoted; "&Units of Measure")
            {
            }
        }
    }
}

