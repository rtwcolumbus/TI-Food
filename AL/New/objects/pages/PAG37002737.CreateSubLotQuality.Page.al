page 37002737 "Create Sub-Lot Quality"
{
    // PRW118.1
    // P800129613, To Increase, Jack Reynolds, 20 SEP 21
    //   Creatre Sub-Lot Wizard

    Caption = 'Create Sub-Lot Quality';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Sub-Lot Buffer";
    SourceTableTemporary = true;
    SourceTableView = sorting("Test No.");

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(TestNo; Rec."Test No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(ReTest; Rec."Re-Test")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;

                }
                field(AssignedTo; Rec."Assigned To")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;

                }
                field(ScheduleDate; Rec."Schedule Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;

                }
                field(QualityTests; Rec.ReadQualityTests())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quality Tests';
                }
                field(CopyToSubLot; Rec."Copy to Sub-lot")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    procedure SetSource(var OpenQualityControl: Record "Sub-Lot Buffer" temporary)
    begin
        Rec.Copy(OpenQualityControl, true);
        Rec.Reset();
        if Rec.FindFirst() then;
    end;

    procedure GetSource(var OpenQualityControl: Record "Sub-Lot Buffer" temporary)
    begin
        OpenQualityControl.Copy(Rec, true);
        Rec.Reset();
        if Rec.FindFirst() then;
    end;
}