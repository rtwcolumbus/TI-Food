page 37002521 "Item Forecast Matrix"
{
    // PRW16.00.03
    // P8000796, VerticalSoft, Don Bresee, 01 APR 10
    //   Rework interface for NAV 2009
    // 
    // PRW16.00.04
    // P8000839, VerticalSoft, Jack Reynolds, 12 JUL 10
    //   Fix problem with Manufacturing Policy filter
    // 
    // P8000869, VerticalSoft, Jack Reynolds, 28 SEP 10
    //   Fixes to support for Variant Code
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Item Forecast Matrix';
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = Item;
    SourceTableView = SORTING("Item Type", "Item Category Code");

    layout
    {
        area(content)
        {
            repeater(Control37002008)
            {
                FreezeColumn = "Base Unit of Measure";
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Field1; MATRIX_CellData[1])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[1];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(1);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[2];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(2);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[3];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(3);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[4];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(4);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[5];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(5);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[6];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(6);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[7];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(7);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[8];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(8);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[9];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(9);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[10];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(10);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[11];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(11);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[12];
                    DecimalPlaces = 0 : 5;
                    Editable = AllowVariant;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(12);
                    end;

                    trigger OnValidate()
                    begin
                        QtyValidate(12);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Item")
            {
                Caption = '&Item';
                action("&Card")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Card';
                    Image = Card;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(Item),
                                  "No." = FIELD("No.");
                }
                separator(Separator37002002)
                {
                    Caption = '';
                }
                action("&Units of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Units of Measure';
                    Image = UnitOfMeasure;
                    RunObject = Page "Item Units of Measure";
                    RunPageLink = "Item No." = FIELD("No.");
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        MATRIX_CurrentColumnOrdinal: Integer;
        MATRIX_Steps: Integer;
    begin
        MATRIX_CurrentColumnOrdinal := 0;
        while MATRIX_CurrentColumnOrdinal < MATRIX_NoOfMatrixColumns do begin
            MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + 1;
            MATRIX_OnAfterGetRecord(MATRIX_CurrentColumnOrdinal);
        end;

        // P8000869
        if VariantFilter <> '' then
            AllowVariant := ItemVariant.Get("No.", VariantFilter)
        else
            AllowVariant := true;
        // P8000869
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        SetRowFilters;
        exit(Find(Which));
    end;

    var
        ItemTypeFilter: Option " ","Raw Materials",Packaging,Intermediates,"Finished Goods";
        ItemCategoryFilter: Code[20];
        MfgPolicyFilter: Option " ","Make-to-Stock","Make-to-Order";
        LocationFilter: Text[30];
        VariantFilter: Text[30];
        PeriodFormMgt: Codeunit PeriodFormManagement;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        QtyType: Option "Net Change","Balance at Date";
        MatrixRecords: array[12] of Record Date;
        MATRIX_NoOfMatrixColumns: Integer;
        MATRIX_CellData: array[12] of Decimal;
        MATRIX_CaptionSet: array[12] of Text[1024];
        Text000: Label 'The Forecast On field must be Sales Items or Component.';
        Text001: Label 'A forecast was previously made on the %1. Do you want all forecasts of the period %2-%3 moved to the start of the period?';
        Text003: Label 'You must set a location filter.';
        Text004: Label 'You must change view to Sales Items or Component.';
        ItemVariant: Record "Item Variant";
        [InDataSet]
        AllowVariant: Boolean;

    local procedure SetRowFilters()
    begin
        if ItemTypeFilter <> ItemTypeFilter::" " then
            SetRange("Item Type", ItemTypeFilter)
        else
            SetRange("Item Type");

        if ItemCategoryFilter <> '' then
            SetRange("Item Category Code", ItemCategoryFilter)
        else
            SetRange("Item Category Code");

        // P8000839
        case MfgPolicyFilter of
            MfgPolicyFilter::"Make-to-Stock":
                SetRange("Manufacturing Policy", "Manufacturing Policy"::"Make-to-Stock");
            MfgPolicyFilter::"Make-to-Order":
                SetRange("Manufacturing Policy", "Manufacturing Policy"::"Make-to-Order");
            else
                SetRange("Manufacturing Policy");
        end;
        // P8000839
    end;

    local procedure SetColumnFilters(ColumnID: Integer)
    begin
        if LocationFilter <> '' then
            SetFilter("Location Filter", LocationFilter)
        else
            SetRange("Location Filter");

        if VariantFilter <> '' then
            SetFilter("Variant Filter", VariantFilter)
        else
            SetRange("Variant Filter");

        if QtyType = QtyType::"Net Change" then
            if MatrixRecords[ColumnID]."Period Start" = MatrixRecords[ColumnID]."Period End" then
                SetRange("Date Filter", MatrixRecords[ColumnID]."Period Start")
            else
                SetRange("Date Filter", MatrixRecords[ColumnID]."Period Start", MatrixRecords[ColumnID]."Period End")
        else
            SetRange("Date Filter", 0D, MatrixRecords[ColumnID]."Period End");
    end;

    procedure Load(var MatrixColumns1: array[12] of Text[1024]; var MatrixRecords1: array[12] of Record Date; ItemTypeFilter1: Option " ","Raw Materials",Packaging,Intermediates,"Finished Goods"; ItemCategoryFilter1: Code[20]; MfgPolicyFilter1: Option " ","Make-to-Stock","Make-to-Order"; LocationFilter1: Text[30]; VariantFilter1: Text[30]; QtyType1: Option "Net Change","Balance at Date"; NoOfMatrixColumns1: Integer)
    var
        i: Integer;
    begin
        CopyArray(MATRIX_CaptionSet, MatrixColumns1, 1);
        for i := 1 to ArrayLen(MatrixRecords) do begin
            if MatrixColumns1[i] = '' then
                MATRIX_CaptionSet[i] := ' '
            else
                MATRIX_CaptionSet[i] := MatrixColumns1[i];
            MatrixRecords[i] := MatrixRecords1[i];
        end;
        ItemTypeFilter := ItemTypeFilter1;
        ItemCategoryFilter := ItemCategoryFilter1;
        MfgPolicyFilter := MfgPolicyFilter1;
        LocationFilter := LocationFilter1;
        VariantFilter := VariantFilter1;
        QtyType := QtyType1;
        MATRIX_NoOfMatrixColumns := NoOfMatrixColumns1;
    end;

    local procedure MatrixOnDrillDown(ColumnID: Integer)
    var
        ItemForecast: Record "Production Forecast";
        ItemForecastList: Page "Production Forecast List";
    begin
        SetColumnFilters(ColumnID);
        ItemForecast.SetRange("Item No.", "No.");
        CopyFilter("Date Filter", ItemForecast.Date);
        CopyFilter("Location Filter", ItemForecast."Location Code");
        CopyFilter("Variant Filter", ItemForecast."Variant Code");
        ItemForecastList.SetTableView(ItemForecast);
        ItemForecastList.Run;
    end;

    local procedure MATRIX_OnAfterGetRecord(ColumnID: Integer)
    begin
        SetColumnFilters(ColumnID);
        CalcFields("Forecast Quantity");
        MATRIX_CellData[ColumnID] := "Forecast Quantity";
    end;

    local procedure QtyValidate(ColumnID: Integer)
    begin
        SetColumnFilters(ColumnID);
        Validate("Forecast Quantity", MATRIX_CellData[ColumnID]);
    end;
}

