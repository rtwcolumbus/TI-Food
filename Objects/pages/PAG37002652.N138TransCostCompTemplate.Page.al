page 37002652 "N138 Trans. Cost Comp Template"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects

    Caption = 'Transport Cost Component Template';
    PageType = Document;
    SourceTable = "N138 Trans. Cost Comp Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Percentage; Percentage)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Control1100499008; "N138 Trans. CC Template Line")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Template Code" = FIELD(Code);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Template")
            {
                Caption = '&Template';
                action(List)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'List';
                    Image = List;
                    RunObject = Page "N138 Trans Cost Comp Templates";
                    ShortCutKey = 'Shift+Ctrl+L';
                }
            }
        }
    }
}

