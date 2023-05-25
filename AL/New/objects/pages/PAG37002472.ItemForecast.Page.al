page 37002472 "Item Forecast"
{
    // PRW16.00.03
    // P8000796, VerticalSoft, Don Bresee, 01 APR 10
    //   Rework interface for NAV 2009
    // 
    // PRW16.00.04
    // P8000869, VerticalSoft, Jack Reynolds, 28 SEP 10
    //   Fix for Location and Variant filters
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Production Forecast';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SaveValues = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field(ItemTypeFilter; ItemTypeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Type';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        SetMatrix;
                    end;
                }
                field(ItemCategoryFilter; ItemCategoryFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Category';
                    Importance = Promoted;
                    TableRelation = "Item Category";

                    trigger OnValidate()
                    begin
                        SetMatrix;
                    end;
                }
                field(MfgPolicyFilter; MfgPolicyFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Manufacturing Policy';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        SetMatrix;
                    end;
                }
                field(LocationFilter; LocationFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Filter';
                    Importance = Promoted;
                    TableRelation = Location;

                    trigger OnValidate()
                    begin
                        SetMatrix;
                    end;
                }
                field(VariantFilter; VariantFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant Filter';
                    Importance = Promoted;
                    TableRelation = Variant;

                    trigger OnValidate()
                    begin
                        SetMatrix;
                    end;
                }
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'View by';
                    Importance = Promoted;
                    OptionCaption = 'Day,Week,Month,Quarter,Year,Accounting Period';

                    trigger OnValidate()
                    var
                        Calendar: Record Date;
                        AccountingPeriod: Record "Accounting Period";
                        DateFound: Boolean;
                    begin
                        Calendar.SetPosition(PKFirstRecInCurrSet);
                        if (PeriodType <> PeriodType::"Accounting Period") then begin
                            Calendar.SetRange("Period Type", PeriodType);
                            Calendar."Period Type" := PeriodType;
                            DateFound := Calendar.Find('=<>');
                        end else begin
                            AccountingPeriod."Starting Date" := Calendar."Period Start";
                            DateFound := AccountingPeriod.Find('=<>');
                            if DateFound then
                                Calendar.Get(Calendar."Period Type"::Date, AccountingPeriod."Starting Date");
                        end;
                        if not DateFound then
                            SetColumns(SetWanted::Initial)
                        else begin
                            PKFirstRecInCurrSet := Calendar.GetPosition;
                            SetColumns(SetWanted::Same);
                        end;
                    end;
                }
            }
            part(Matrix; "Item Forecast Matrix")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Production Forecast';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Previous Set")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Previous Set';
                Image = PreviousSet;
                ToolTip = 'Previous Set';

                trigger OnAction()
                begin
                    SetColumns(SetWanted::Previous);
                end;
            }
            action("Previous Column")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Previous Column';
                Image = PreviousRecord;

                trigger OnAction()
                begin
                    SetColumns(SetWanted::PreviousColumn);
                end;
            }
            action("Next Column")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Next Column';
                Image = NextRecord;

                trigger OnAction()
                begin
                    SetColumns(SetWanted::NextColumn);
                end;
            }
            action("Next Set")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Next Set';
                Image = NextSet;
                ToolTip = 'Next Set';

                trigger OnAction()
                begin
                    SetColumns(SetWanted::Next);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Navigate)
            {
                Caption = 'Navigate';

                actionref(PreviousSet_Promoted; "Previous Set")
                {
                }
                actionref(PreviousColumn_Promoted; "Previous Column")
                {
                }
                actionref(NextColumn_Promoted; "Next Column")
                {
                }
                actionref(NextSet_Promoted; "Next Set")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetColumns(SetWanted::Initial);
    end;

    var
        ItemTypeFilter: Option " ","Raw Materials",Packaging,Intermediates,"Finished Goods";
        ItemCategoryFilter: Code[20];
        MfgPolicyFilter: Option " ","Make-to-Stock","Make-to-Order";
        LocationFilter: Code[10];
        VariantFilter: Code[10];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        MatrixRecords: array[12] of Record Date;
        MatrixColumnCaptions: array[12] of Text[1024];
        ColumnSet: Text[1024];
        SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
        PKFirstRecInCurrSet: Text[100];
        CurrSetLength: Integer;

    procedure SetColumns(SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn)
    var
        MatrixMgt: Codeunit "Matrix Management";
    begin
        MatrixMgt.GeneratePeriodMatrixData(
          SetWanted, ArrayLen(MatrixRecords), false, PeriodType, '', PKFirstRecInCurrSet,
          MatrixColumnCaptions, ColumnSet, CurrSetLength, MatrixRecords);
        SetMatrix;
    end;

    procedure SetMatrix()
    begin
        CurrPage.Matrix.PAGE.Load(
          MatrixColumnCaptions, MatrixRecords, ItemTypeFilter, ItemCategoryFilter,
          MfgPolicyFilter, LocationFilter, VariantFilter, 0, CurrSetLength);
    end;
}

