page 37002827 "Complete Work Order"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This form is for entering completion data for work orders
    // 
    // PRW15.00.01
    // P8000515A, VerticalSoft, Jack Reynolds, 12 SEP 07
    //   Fix problem with work order completion even when OK button is not pressed
    // 
    // P8000590A, VerticalSoft, Jack Reynolds, 07 MAR 08
    //   Check usage tolerance
    // 
    // PRW16.00.01
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Add controls for downtime
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 04 FEB 09
    //   Transformed from form
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Complete Work Order';
    InstructionalText = 'Do you want to complete this work order?';
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            field("WorkOrder.""No."""; WorkOrder."No.")
            {
                ApplicationArea = FOODBasic;
                Caption = 'No.';
                Editable = false;
            }
            field("WorkOrder.""Asset No."""; WorkOrder."Asset No.")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Asset No.';
                Editable = false;
            }
            field("WorkOrder.""Asset Description"""; WorkOrder."Asset Description")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Asset Description';
                Editable = false;
            }
            field("WorkOrder.""Origination Date"""; WorkOrder."Origination Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Origination Date';
                Editable = false;
            }
            field("WorkOrder.""Origination Time"""; WorkOrder."Origination Time")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Originate Time';
                Editable = false;
            }
            field("WorkOrder.""Completion Date"""; WorkOrder."Completion Date")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Completion Date';

                trigger OnValidate()
                begin
                    WorkOrder.CheckDatesAndTimes;
                    WorkOrder.CheckUsage;

                    TestTolerance; // P8000590A
                end;
            }
            field("WorkOrder.""Completion Time"""; WorkOrder."Completion Time")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Completion Time';

                trigger OnValidate()
                begin
                    WorkOrder.CheckDatesAndTimes;
                end;
            }
            field(Usage; WorkOrder.Usage)
            {
                ApplicationArea = FOODBasic;
                BlankNumbers = BlankNeg;
                Caption = 'Usage';
                DecimalPlaces = 0 : 5;
                Editable = usageeditable;
                MinValue = 0;

                trigger OnValidate()
                begin
                    WorkOrder.CheckUsage;

                    TestTolerance; // P8000590A
                end;
            }
            field("Asset.""Usage Unit of Measure"""; Asset."Usage Unit of Measure")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Usage Unit of Measure';
                Editable = false;
            }
            field("WorkOrder.""Downtime (Hours)"""; WorkOrder."Downtime (Hours)")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Downtime (Hours)';
                DecimalPlaces = 0 : 2;
                Editable = usageeditable;
                MinValue = 0;

                trigger OnValidate()
                begin
                    WorkOrder.CheckUsage;

                    TestTolerance; // P8000590A
                end;
            }
            field("WorkOrder.Status"; WorkOrder.Status)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Status';
                OptionCaption = ',,,,,Closed,Cancelled';
            }
            field(Control37002009; '')
            {
                ApplicationArea = FOODBasic;
                CaptionClass = CorrectiveActionWarning;
                Editable = false;
                ShowCaption = false;
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // P8000664A
        if CloseAction = ACTION::Yes then begin
            if WorkOrder.Usage = -1 then
                if WorkOrder.UsageRequired then
                    Error(Text002, WorkOrder.FieldCaption(Usage));
            WorkOrder.Completed := true;
        end;
        exit(true);
    end;

    var
        Asset: Record Asset;
        WorkOrder: Record "Work Order";
        Text001: Label ' No %1 has been entered.';
        Text002: Label '%1 must be entered.';
        Text003: Label 'Change in Average Daily Usage exceeds tolerance.  Continue?';
        Text004: Label 'The update has been interrupted to respect the warning.';
        [InDataSet]
        UsageEditable: Boolean;

    procedure SetWorkOrder(rec: Record "Work Order")
    begin
        WorkOrder := rec;
        Asset.Get(WorkOrder."Asset No.");
        UsageEditable := Asset."Usage Unit of Measure" <> ''; // P8000664
    end;

    procedure GetWorkOrder(var rec: Record "Work Order")
    begin
        rec := WorkOrder;
    end;

    procedure CorrectiveActionWarning(): Text[50]
    begin
        if WorkOrder."Corrective Action" = 0 then
            exit(UpperCase(StrSubstNo(Text001, WorkOrder.FieldCaption("Corrective Action"))));
    end;

    procedure TestTolerance()
    var
        AssetUsage: Record "Asset Usage";
    begin
        // P8000590A
        if (WorkOrder."Completion Date" = 0D) or (WorkOrder.Usage = -1) then
            exit;

        if AssetUsage.Get(WorkOrder."Asset No.", WorkOrder."Completion Date", AssetUsage.Type::Reading) then
            exit;

        AssetUsage."Asset No." := WorkOrder."Asset No.";
        AssetUsage.Date := WorkOrder."Completion Date";
        AssetUsage.Type := AssetUsage.Type::Reading;
        AssetUsage.Reading := WorkOrder.Usage;
        AssetUsage.CalcAvgDailyUsage;
        if not AssetUsage.CheckTolerance then
            if not Confirm(Text003, false) then
                Error(Text004);
    end;
}

