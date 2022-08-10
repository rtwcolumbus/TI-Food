report 37002476 "Daily Production Plan"
{
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.02
    // P80070425, To-Increase, Gangabhushan, 13 FEB 19
    //   TI-12819 - Daily Production Plan shows #error for batch numbers
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/DailyProductionPlan.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Daily Production Plan';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Date; Date)
        {
            DataItemTableView = SORTING("Period Type", "Period Start") WHERE("Period Type" = CONST(Date));
            PrintOnlyIfDetail = true;
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(ProdSeqEqpmtCode; ProdSequence."Equipment Code")
                {
                }
                column(ProdSeqDesc; ProdSequence.Description)
                {
                }
                column(ProdSeqItemNo; ProdSequence."Item No.")
                {
                }
                column(ProdSeqItemDesc; ProdSequence."Item Description")
                {
                }
                column(ProdSeqStartDateTime; ProdSequence."Starting Date-Time")
                {
                }
                column(ProdSeqEndDateTime; ProdSequence."Ending Date-Time")
                {
                }
                column(ProdSeqDurationHrs; FormatDuration(ProdSequence."Duration (Hours)"))
                {
                }
                column(ProdSeqQuantity; ProdSequence.Quantity)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(ProdSeqUOMCode; ProdSequence."Unit of Measure Code")
                {
                }
                column(DatePeriodStart; Date."Period Start")
                {
                }
                column(ResourceName; Resource.Name)
                {
                }
                column(ProdSeqOrderType; ProdSequence.Type = ProdSequence.Type::Order)
                {
                }
                dataitem("Production Order"; "Production Order")
                {
                    DataItemTableView = SORTING(Status, "No.") WHERE("Batch Order" = CONST(true));
                    dataitem("Prod. Order Line"; "Prod. Order Line")
                    {
                        DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("No.");
                        DataItemTableView = SORTING(Status, "Prod. Order No.", "Line No.");
                        column(ProdOrderLineQuantity; Quantity)
                        {
                        }
                        column(ProdOrderLineStartingDateTime; "Starting Date-Time")
                        {
                        }
                        column(ProdOrderLineEndingDateTime; "Ending Date-Time")
                        {
                        }
                        column(BatchNo; BatchNo)
                        {
                        }
                        column(DurationHrs; FormatDuration(DurationHours))
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            BatchNo += 1;
                            DurationHours := Round(("Ending Date-Time" - "Starting Date-Time") / 3600000, 0.001);
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("Equipment Code", ProdSequence."Equipment Code");
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        BatchNo := 0;
                    end;

                    trigger OnPreDataItem()
                    begin
                        if ProdSequence.Type <> ProdSequence.Type::Order then
                            CurrReport.Break;

                        SetRange(Status, ProdSequence."Order Status");
                        SetRange("No.", ProdSequence."Order No.");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        ProdSequence.Find('-')
                    else
                        ProdSequence.Next;

                    if Resource."No." <> ProdSequence."Equipment Code" then
                        Resource.Get(ProdSequence."Equipment Code");
                end;

                trigger OnPreDataItem()
                begin
                    ProdSequence.SetCurrentKey("Resource Group", "Equipment Code", Level, "Sequence No.", "Starting Date-Time", "Ending Date-Time");
                    ProdSequence.SetRange(Level, 1);
                    SetRange(Number, 1, ProdSequence.Count);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ProdSequence.Reset;
                ProdSequence.DeleteAll;
                BatchPlanningFns.LoadProductionSequence(LocationCode, "Period Start", ProdSequence);
                if ProdSequence.IsEmpty then
                    CurrReport.Break;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Period Start", BegDate, EndDate);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(LocationCode; LocationCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location';
                        TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
                    }
                    field(BegDate; BegDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Beginning Date';
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Ending Date';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        DailyProdPlanCaption = 'Daily Production Plan';
        PAGENOCaption = 'Page';
        DescriptionCaption = 'Description';
        ItemNoCaption = 'Item No.';
        ItemDescCaption = 'Item Description';
        StartDateTimeCaption = 'Starting Time';
        EndDateTimeCaption = 'Ending Time';
        DurationHrsCaption = 'Duration';
        QuantityCaption = 'Quantity';
        UOMCaption = 'Unit of Measure';
        ProdDateCaption = 'Production Date';
        BatchNoCaption = 'Batch No.';
    }

    trigger OnPreReport()
    begin
        if (BegDate = 0D) or (EndDate = 0D) then
            Error(Text001);
        if BegDate > EndDate then
            Error(Text002);
    end;

    var
        ProdSequence: Record "Production Sequencing" temporary;
        Resource: Record Resource;
        BatchPlanningFns: Codeunit "Batch Planning Functions";
        LocationCode: Code[10];
        BegDate: Date;
        EndDate: Date;
        Text001: Label 'Beginning and ending dates must be entered.';
        Text002: Label 'Beginning date must precede ending date.';
        BatchNo: Integer;
        DurationHours: Decimal;

    procedure SetParameters(LocCode: Code[10]; Date1: Date; Date2: Date)
    begin
        LocationCode := LocCode;
        BegDate := Date1;
        EndDate := Date2;
    end;

    procedure FormatDuration(DurHours: Decimal) DurText: Text[30]
    var
        Hours: Integer;
        Minutes: Integer;
    begin
        Hours := DurHours div 1;
        Minutes := Round(60 * (DurHours mod 1), 1);
        DurText := Format(Hours, 0) + ':' + Format(Minutes, 2, '<Integer,2><Filler,0>');
    end;
}

