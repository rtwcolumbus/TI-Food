page 37002949 "Incident Entries"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work


    ApplicationArea = FOODBasic;
    Caption = 'Incident Entries';
    CardPageID = "Incident Entry Card";
    DelayedInsert = true;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Incident Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                Editable = false;
                ShowCaption = false;
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("FORMAT(""Source Record ID"")"; Format("Source Record ID"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source';
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Item Category"; "Item Category")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("To-do No."; "To-do No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Transaction Date"; "Source Transaction Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Source Quantity"; "Source Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Unit of Measure Code"; "Source Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Reason Code"; "Incident Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Quantity"; "Incident Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Unit of Measure Code"; "Incident Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Archived; Archived)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Active Resolution No."; "Active Resolution No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Classification"; "Incident Classification")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Created On"; "Created On")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            part(Control37002008; "Incident Resolution Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Incident Entry No." = FIELD("Entry No.");
            }
            systempart(Control37002029; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002033; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Incident")
            {
                Caption = '&Incident';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Incident Entry Card";
                    RunPageLink = "Entry No." = FIELD("Entry No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Incident Comment Lines";
                    RunPageLink = "Incident Entry No." = FIELD("Entry No.");
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        LookupMode := CurrPage.LookupMode; // P8001323
    end;

    var
        [InDataSet]
        LookupMode: Boolean;
}

