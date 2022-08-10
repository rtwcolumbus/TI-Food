page 37002947 "Incident Classification Codes"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Incident Classification Codes';
    PageType = ListPlus;
    SourceTable = "Incident Classification";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specifies a unique code for the incident classification.';
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specifies a description of the incident classification.';
                }
                field("Incident Type"; "Incident Type")
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specify type of incident classification.';
                }
                field("Incident Area"; "Incident Area")
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specify transaction area of incident classification.';
                }
                field("Incident Area ID"; "Incident Area ID")
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specify source table of incident.';

                    trigger OnAssistEdit()
                    begin
                        SelectIncidetAreaID;
                    end;

                    trigger OnValidate()
                    begin
                        GetIncidentAreaID;
                    end;
                }
                field(GetIncidentAreaID; GetIncidentAreaID)
                {
                    ApplicationArea = FOODBasic;
                    ShowCaption = false;
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

    var
        IncidentAreaIDText: Text;

    local procedure GetIncidentAreaID(): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if "Incident Area ID" = 0 then
            exit;
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", "Incident Area ID");
        AllObjWithCaption.FindFirst;
        exit(AllObjWithCaption."Object Name");
    end;

    local procedure SelectIncidetAreaID(): Integer
    var
        SelectTable: Page "Table Objects";
        ObjectTable: Record AllObjWithCaption;
    begin
        SelectTable.LookupMode := true;
        if SelectTable.RunModal = ACTION::LookupOK then begin
            SelectTable.GetRecord(ObjectTable);
            Validate("Incident Area ID", ObjectTable."Object ID");
        end;
    end;
}

