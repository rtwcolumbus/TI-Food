page 37002830 "Asset Usage"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //  This form displays a non editable table box of asset usage and provides fields to enter new usage
    // 
    // PRW15.00.10
    // P8000590A, VerticalSoft, Jack Reynolds, 07 MAR 08
    //   Check usage tolerance
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 16 FEB 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.04
    // P8000884, VerticalSoft, Jack Reynolds, 03 DEC 10
    //   Fix problem opening page if no usage yet exists
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001149, Columbus IT, Don Bresee, 25 APR 13
    //   Change calling of page to use lookup mode
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Asset Usage';
    DataCaptionFields = "Asset No.";
    PageType = Worksheet;
    SourceTable = "Asset Usage";
    SourceTableView = ORDER(Descending);

    layout
    {
        area(content)
        {
            field(ReadingDate; NewReading.Date)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Date';

                trigger OnValidate()
                begin
                    NewReading.Validate(Date);
                    TestTolerance; // P8000590A
                end;
            }
            field("NewReading.Reading"; NewReading.Reading)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reading';
                DecimalPlaces = 0 : 5;
                MinValue = 0;

                trigger OnValidate()
                begin
                    NewReading.Validate(Reading);
                    TestTolerance; // P8000590A
                end;
            }
            field("NewReading.Type"; NewReading.Type)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Type';
                OptionCaption = 'Meter Change,Reading';

                trigger OnValidate()
                begin
                    NewReading.Validate(Type);
                    SetControlProperties;
                end;
            }
            field("Asset.""Usage Unit of Measure"""; Asset."Usage Unit of Measure")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Unit of Measure';
                Editable = false;
            }
            field(InitialReading; InitialReading)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Initial Reading';
                DecimalPlaces = 0 : 5;
                Enabled = editInitialReading;
                HideValue = hideInitialReading;
                MinValue = 0;
            }
            field("NewReading.""Average Daily Usage"""; NewReading."Average Daily Usage")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
                Caption = 'Average Daily Usage';
                DecimalPlaces = 0 : 5;
                Editable = false;
            }
            repeater(Control37002000)
            {
                Editable = false;
                ShowCaption = false;
                field(Date; Date)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Reading; Reading)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Average Daily Usage"; "Average Daily Usage")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Save")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Save';
                Image = Save;

                trigger OnAction()
                begin
                    NewReading.Insert(true);
                    if NewReading.Type = NewReading.Type::"Meter Change" then begin
                        NewReading.Type := NewReading.Type::Reading;
                        NewReading.Reading := InitialReading;
                        NewReading.CalcAvgDailyUsage;
                        NewReading.Insert;
                    end;
                    CurrPage.Update(false);
                    NewReading.Init;
                    NewReading.Date := 0D;
                    NewReading.Type := NewReading.Type::Reading;
                    SetControlProperties;
                end;
            }
        }
        area(Promoted)
        {
            actionref(Save_Promoted; "&Save")
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        if FindFirst then;
        SetControlProperties;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // P8000664
        // IF (CloseAction <> ACTION::OK) OR ((NewReading.Date = 0D) AND (NewReading.Reading = 0)) THEN    // P8001149
        if (CloseAction <> ACTION::LookupOK) or ((NewReading.Date = 0D) and (NewReading.Reading = 0)) then // P8001149
            exit(true);

        exit(Confirm(Text003, false));
    end;

    var
        Asset: Record Asset;
        AssetUSage: Record "Asset Usage";
        NewReading: Record "Asset Usage";
        InitialReading: Decimal;
        Text001: Label 'Change in Average Daily Usage exceeds tolerance.  Continue?';
        Text002: Label 'The update has been interrupted to respect the warning.';
        [InDataSet]
        EditInitialReading: Boolean;
        [InDataSet]
        HideInitialReading: Boolean;
        Text003: Label 'Usage has been entered, do you want to close the page?';

    procedure SetAsset(AssetRec: Record Asset)
    begin
        Asset := AssetRec;
        NewReading."Asset No." := Asset."No.";
        NewReading.Type := NewReading.Type::Reading;

        FilterGroup(4);
        SetRange("Asset No.", Asset."No.");
        FilterGroup(0);
    end;

    procedure SetControlProperties()
    begin
        EditInitialReading := NewReading.Type = NewReading.Type::"Meter Change"; // P8000664
        HideInitialReading := not EditInitialReading;
    end;

    procedure TestTolerance()
    begin
        // P8000590A
        if not NewReading.CheckTolerance then
            if not Confirm(Text001, false) then
                Error(Text002);
    end;
}

