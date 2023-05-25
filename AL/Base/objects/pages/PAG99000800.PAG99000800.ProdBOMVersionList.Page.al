page 99000800 "Prod. BOM Version List"
{
    // PRW16.00.06
    // P8001022, Columbus IT, Jack Reynolds, 17 JAN 12
    //   Bring form modifications to the page

    Caption = 'Prod. BOM Version List';
    DataCaptionFields = "Production BOM No.", "Version Code", Description;
    Editable = false;
    PageType = List;
    SourceTable = "Production BOM Version";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Production BOM No."; Rec."Production BOM No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field(BOMDescription; BOMDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Production BOM Description';
                    Visible = false;
                }
                field("Version Code"; Rec."Version Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the version code of the production BOM.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a description for the production BOM version.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting date for this production BOM version.';

                    trigger OnValidate()
                    begin
                        StartingDateOnAfterValidate();
                    end;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies when the production BOM version card was last modified.';
                    Visible = false;
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
    }

    trigger OnOpenPage()
    begin
        // P8001022
        CurrPage.Caption(StrSubstNo(Text37002000, Format(Type)));
        FilterGroup(9);
        SetRange(Type, Type);
        FilterGroup(0);
        // P8001022
    end;

    var
        Text37002000: Label 'Prod. %1 Version';

    local procedure StartingDateOnAfterValidate()
    begin
        CurrPage.Update();
    end;
}

