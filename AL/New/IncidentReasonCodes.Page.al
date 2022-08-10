page 37002948 "Incident Reason Codes"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Incident Reason Codes';
    PageType = ListPlus;
    SourceTable = "Incident Reason Code";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specifies the reason type.';
                }
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specifies a reason code.';
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specifies a description of the reason.';
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
    }
}

