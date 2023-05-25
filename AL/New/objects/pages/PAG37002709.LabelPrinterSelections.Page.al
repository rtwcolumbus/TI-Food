page 37002709 "Label Printer Selections"
{
    ApplicationArea = FOODBasic;
    Caption = 'Label Printer Selections';
    DelayedInsert = true;
    SourceTableView = sorting("Location Code", "User ID", "Label Code");
    PageType = List;
    SourceTable = "Label Printer Selection";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(PrinterSelection)
            {
                ShowCaption = false;
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Label Code"; "Label Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        SetEditable();
                    end;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = "User Lookup";
                }
                field("Printer Name"; "Printer Name")
                {
                    ApplicationArea = FOODBasic;
                    Editable = PrinterNameEditable;
                    LookupPageID = Printers;
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
    var

        PrinterNameEditable: Boolean;

    local procedure SetEditable()
    var
        Label: Record Label;
    begin
        PrinterNameEditable := true;
        if "Label Code" <> '' then begin
            Label.Get("Label Code");
            PrinterNameEditable := Label.Method = Label.Method::Report;
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        SetEditable();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetEditable();
    end;
}