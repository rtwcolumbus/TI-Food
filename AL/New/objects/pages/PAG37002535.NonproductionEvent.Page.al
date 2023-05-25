page 37002535 "Non-production Event"
{
    // PRW16.00.04
    // P8000889, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Page to edit and create new non-production events
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 16 JAN 17
    //   Correct misspellings

    Caption = 'Non-production Event';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = StandardDialog;
    SourceTable = "Production Sequencing";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Production Date"; ProductionDate)
            {
                ApplicationArea = FOODBasic;

                trigger OnValidate()
                begin
                    if ProductionDate = 0D then
                        Error(Txt001);

                    Validate("Starting Date-Time", CreateDateTime(ProductionDate, "Starting Time"));
                end;
            }
            field("Equipment Code"; "Equipment Code")
            {
                ApplicationArea = FOODBasic;
                Editable = false;
                Lookup = false;
            }
            field("Event Code"; "Event Code")
            {
                ApplicationArea = FOODBasic;
                Editable = "Line No." = 0;

                trigger OnValidate()
                begin
                    if "Event Code" = '' then
                        Error(Txt002);

                    if xRec."Event Code" <> "Event Code" then begin
                        ProdEvent.Get("Event Code");
                        Validate("Duration (Hours)", ProdEvent."Duration (Hours)");
                    end;
                end;
            }
            field("Starting Time"; "Starting Time")
            {
                ApplicationArea = FOODBasic;
            }
            field("Duration (Hours)"; "Duration (Hours)")
            {
                ApplicationArea = FOODBasic;
                NotBlank = false;
            }
            field("Ending Time"; "Ending Time")
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
    }

    var
        ProdEvent: Record "Production Planning Event";
        ProductionDate: Date;
        Txt001: Label 'Production date should not be empty.';
        Txt002: Label 'Please select non-production event.';

    procedure SetData(ProdSeq: Record "Production Sequencing")
    begin
        Rec := ProdSeq;
        Insert;
        ProductionDate := DT2Date("Starting Date-Time");
    end;

    procedure GetData(var ProdSeq: Record "Production Sequencing")
    begin
        ProdSeq := Rec;
    end;
}

