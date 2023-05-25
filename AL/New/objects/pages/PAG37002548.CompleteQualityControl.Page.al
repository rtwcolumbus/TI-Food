page 37002548 "Complete Quality Control"
{
    // PR1.10.02
    //   Add control for entering status and default based on actual test results
    // 
    // PR1.20
    //   Fix problem initializing Pass/Fail when All Tests Must be Done is set to FALSE
    // 
    // PR2.00
    //   Modify for Lot No. Information and Quality Control Header
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 13 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW111.00.01
    // P80037637, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop threshhold results

    Caption = 'Complete Quality Control';
    InstructionalText = 'Do you want to complete this quality control test?';
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            field("Item.""No."""; Item."No.")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item';
                Editable = false;
            }
            field(Control37002002; '')
            {
                ApplicationArea = FOODBasic;
                CaptionClass = Format(Item.Description);
                Editable = false;
                ShowCaption = false;
            }
            field("QCHeader.""Variant Code"""; QCHeader."Variant Code")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Variant Code';
                Editable = false;
            }
            field("QCHeader.""Lot No."""; QCHeader."Lot No.")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot No.';
                Editable = false;
            }
            field("QCHeader.""Test No."""; QCHeader."Test No.")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Test No.';
                Editable = false;
            }
            field(Status; Status)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Status';
                OptionCaption = 'Pass,Fail,Suspend';

                trigger OnValidate()
                begin
                    if Status = Status::Pass then begin
                        if LotNoInfo."Release Date" = 0D then
                            LotNoInfo."Release Date" := WorkDate;
                    end else begin
                        if Format(Item."Quarantine Calculation") <> '' then
                            LotNoInfo."Release Date" := 0D;
                    end;
                    SetLotStatus; // P8001083
                    SetEditableFields;
                    CurrPage.Update;
                end;
            }
            field(RelDate; LotNoInfo."Release Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Release Date';
                Editable = reldateeditable;
            }
            field(ExpDate; LotNoInfo."Expiration Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Expiration Date';
                Editable = expdateeditable;
            }
            field(QCWarningTxt; QCWarningTxt)
            {
                // P800122712
                ApplicationArea = FOODBasic;
                Caption = 'Quality Control Warning';
                Editable = false;
                Style = Attention;
                Visible = QCWarningTxt <> '';

            }
            field(LotStatus; LotNoInfo."Lot Status Code")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Status Code';
                TableRelation = "Lot Status Code";

                trigger OnValidate()
                var
                    InvSetup: Record "Inventory Setup";
                begin
                    // P8001083
                    InvSetup.Get;
                    if InvSetup."Quarantine Lot Status" = '' then
                        exit;
                    if LotNoInfo."Lot Status Code" = InvSetup."Quarantine Lot Status" then
                        Error(Text001, InvSetup."Quarantine Lot Status");
                end;
            }
            field(LotStrength; LotNoInfo."Lot Strength Percent")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Strength Percent';
                Editable = LotStrengtheditable;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        QCWarningTxt := Process800QCFunctions.SetQCWarningText(QCHeader); // P800122712
    end;

    var
        LotNoInfo: Record "Lot No. Information";
        QCHeader: Record "Quality Control Header";
        Item: Record Item;
        InvSetup: Record "Inventory Setup";
        QCLine: Record "Quality Control Line";
        Process800QCFunctions: Codeunit "Process 800 Q/C Functions"; // P800122712
        Status: Option Pass,Fail,Suspend;
        [InDataSet]
        RelDateEditable: Boolean;
        [InDataSet]
        ExpDateEditable: Boolean;
        [InDataSet]
        LotStrengthEditable: Boolean;
        Text001: Label 'Lot status may not be changed to %1.';
        QCWarningTxt: Text; // P800122712

    procedure SetVars(var rec: Record "Quality Control Header")
    var
        Pass: Boolean;
    begin
        InvSetup.Get;
        Pass := true; // PR1.20
        QCHeader := rec;
        LotNoInfo.Get(rec."Item No.", rec."Variant Code", rec."Lot No.");
        Item.Get(rec."Item No.");

        QCLine.SetRange("Item No.", QCHeader."Item No.");
        QCLine.SetRange("Variant Code", QCHeader."Variant Code");
        QCLine.SetRange("Lot No.", QCHeader."Lot No.");
        QCLine.SetRange("Test No.", QCHeader."Test No.");
        if InvSetup."All Q/C Tests Must Be Done" then begin
            QCLine.SetRange(Status, QCLine.Status::"Not Tested");
            Pass := QCLine.IsEmpty;
        end;
        if Pass then begin
            QCLine.SetRange("Must Pass");
            QCLine.SetFilter(Status, '<>%1', QCLine.Status::Pass);
            Pass := QCLine.IsEmpty;
        end;

        if Pass then begin
            if LotNoInfo."Release Date" = 0D then
                LotNoInfo."Release Date" := WorkDate;
            Status := Status::Pass;
        end else begin
            if Format(Item."Quarantine Calculation") <> '' then
                LotNoInfo."Release Date" := 0D;
            Status := Status::Fail;
        end;
        SetLotStatus; // P8001083

        SetEditableFields; // PR2.00
    end;

    procedure SetLotStatus()
    var
        InvSetup: Record "Inventory Setup";
    begin
        // P8001083
        if Status = Status::Pass then
            LotNoInfo."Lot Status Code" := ''
        else begin
            InvSetup.Get;
            LotNoInfo."Lot Status Code" := InvSetup."Quality Ctrl. Fail Lot Status";
        end;
    end;

    procedure GetVars(var rec: Record "Quality Control Header"; var rec2: Record "Lot No. Information")
    begin
        if Status = Status::Pass then
            QCHeader.Status := QCHeader.Status::Pass
        // P80037637
        else
            if Status = Status::Suspend then
                QCHeader.Status := QCHeader.Status::Suspended
            // P80037637
            else
                QCHeader.Status := QCHeader.Status::Fail;

        rec := QCHeader;
        rec2 := LotNoInfo; // PR2.00
    end;

    procedure SetEditableFields()
    begin
        // PR2.00 Begin
        RelDateEditable := (Format(Item."Quarantine Calculation") <> '') and (Status = Status::Pass);
        ExpDateEditable := (Format(Item."Expiration Calculation") <> '');
        LotStrengthEditable := Item."Lot Strength";
        // PR2.00 End
    end;
}

