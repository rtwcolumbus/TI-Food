page 37002946 "Incident Search Setup"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Incident Search Setup';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Manage,Process';
    SourceTable = "Incident Search Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Table No."; "Table No.")
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specify the table that would like to be part of the search content.';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specify the field that would like to be part of the search content.';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Entry Field No."; "Incident Entry Field No.")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                    ToolTip = 'Specify the mapping field.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "Field": Record "Field";
                        TableFilter: Record "Table Filter";
                        FieldsLookup: Page "Fields Lookup";
                    begin
                        if "Incident Entry Table No." = 0 then
                            "Incident Entry Table No." := DATABASE::"Incident Entry";
                        Field.SetRange(TableNo, "Incident Entry Table No.");
                        FieldsLookup.SetTableView(Field);
                        FieldsLookup.LookupMode(true);

                        if FieldsLookup.RunModal = ACTION::LookupOK then begin
                            FieldsLookup.GetRecord(Field);
                            if Field."No." = "Incident Entry Field No." then
                                exit;
                            TableFilter.CheckDuplicateField(Field);
                            "Incident Entry Table No." := Field.TableNo;
                            "Incident Entry Field No." := Field."No.";
                            FieldCaptionText := GetFieldCaption;
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        FieldCaptionText := GetFieldCaption;
                    end;
                }
                field(FieldCaptionText; FieldCaptionText)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Incident Source Field Caption';
                    Editable = false;
                    ToolTip = 'Specifies the caption of the field in the external file that is mapped to the field in the Target Table ID field, when you are using an intermediate table for data import.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        FieldCaptionText := GetFieldCaption;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Incident Entry Table No." := DATABASE::"Incident Entry";
        FieldCaptionText := '';
    end;

    var
        [InDataSet]
        FieldCaptionText: Text;
}

