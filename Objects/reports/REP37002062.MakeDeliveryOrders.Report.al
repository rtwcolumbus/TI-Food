report 37002062 "Make Delivery Orders"
{
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Make Delivery Orders';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(NewOrderDate; Date)
        {
            DataItemTableView = SORTING("Period Type", "Period Start") WHERE("Period Type" = CONST(Date));
            dataitem(RoutingLine; "Delivery Routing Matrix Line")
            {
                DataItemTableView = SORTING("Day Of Week", "Delivery Route No.", "Delivery Stop No.", "Standing Order No.") WHERE("Standing Order No." = FILTER(<> ''));
                RequestFilterFields = "Delivery Route No.", "Delivery Stop No.", "Source No.";
                RequestFilterHeading = 'Delivery Routing Matrix';
                dataitem(StandingOrder; "Sales Header")
                {
                    DataItemLink = "No." = FIELD("Standing Order No.");
                    DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST(FOODStandingOrder));

                    trigger OnAfterGetRecord()
                    begin
                        if not StandingOrderMgmt.MakeDeliveryOrder(StandingOrder, NewOrderDate."Period Start") then
                            CurrReport.Skip;

                        NumOrdersCreated := NumOrdersCreated + 1;
                        if (NumOrdersCreated = 1) then
                            StandingOrderMgmt.GetSalesOrderHeader(FirstOrder);
                    end;
                }

                trigger OnPreDataItem()
                begin
                    SetRange("Day Of Week", DeliveryRouteMgmt.RoutingDateToDOW(NewOrderDate."Period Start"));
                end;
            }

            trigger OnPreDataItem()
            begin
                SetRange("Period Start", StartDate, EndDate);
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
                    field("Starting Date"; StartDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Starting Date';
                        NotBlank = true;

                        trigger OnValidate()
                        begin
                            if (StartDate > EndDate) then
                                EndDate := StartDate;
                        end;
                    }
                    field("Ending Date"; EndDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Ending Date';
                        NotBlank = true;

                        trigger OnValidate()
                        begin
                            if (StartDate > EndDate) then
                                StartDate := EndDate;
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if (StartDate = 0D) then
                StartDate := WorkDate;
            if (EndDate = 0D) then
                EndDate := WorkDate;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        if (NumOrdersCreated = 0) then
            Message(Text000)
        else
            Message(Text001, NumOrdersCreated, FirstOrder."No.");
    end;

    var
        StartDate: Date;
        EndDate: Date;
        NumOrdersCreated: Integer;
        FirstOrder: Record "Sales Header";
        DeliveryRouteMgmt: Codeunit "Delivery Route Management";
        StandingOrderMgmt: Codeunit "Standing Sales Order to Order";
        Text000: Label 'No Orders were created.';
        Text001: Label '%1 Orders were created starting with Order %2.';
}

