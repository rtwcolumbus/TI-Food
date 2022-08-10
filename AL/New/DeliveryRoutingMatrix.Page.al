page 37002062 "Delivery Routing Matrix"
{
    // PR3.60
    //   Delivery Routing
    // 
    // PRW15.00.01
    // P8000547A, VerticalSoft, Jack Reynolds, 02 MAY 08
    //   Modified to support ship-to's, vendors, and order addresses
    // 
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Cleanup TimerUpdate property
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Delivery Routing Matrix';
    DataCaptionExpression = SourceLabel + ' ' + SourceNo;
    DataCaptionFields = "Source No.";
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SaveValues = true;
    SourceTable = "Delivery Routing Matrix Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            fixed(Control37002000)
            {
                ShowCaption = false;
                group(Control37002001)
                {
                    ShowCaption = false;
                    field(SourceLabel; SourceLabel)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(SourceLabel2; SourceLabel2)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                }
                group(Control37002007)
                {
                    ShowCaption = false;
                    field(SourceNo; SourceNo)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(SourceNo2; SourceNo2)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                }
                group(Control37002010)
                {
                    ShowCaption = false;
                    field(SourceName; SourceName)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(SourceName2; SourceName2)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                }
            }
            repeater(Lines)
            {
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Day Of Week"; "Day Of Week")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Delivery Route No."; "Delivery Route No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupRoute(Text)); // P8000547A
                    end;
                }
                field("Delivery Route Description"; "Delivery Route Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Delivery Stop No."; "Delivery Stop No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DeliveryStopNoVisible;
                }
                field("Standing Order No."; "Standing Order No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = StandingOrderNoVisible;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnClosePage()
    begin
        SaveSource;
    end;

    trigger OnOpenPage()
    var
        i: Integer;
    begin
        for i := 0 to 4 do begin // P8000954
            "Source Type" := i;
            if Format("Source Type") = GetFilter("Source Type") then
                SourceType := i;
        end;
        case SourceType of
            0, 1:
                begin                      // P8000954
                    SourceLabel := Customer.TableCaption;
                    SourceLabel2 := Text001; // P8000954
                end;                       // P8000954
            2, 3:
                begin                      // P8000954
                    SourceLabel := Vendor.TableCaption;
                    SourceLabel2 := Text001; // P8000954
                end;                       // P8000954
                                           // P8000954
            4:
                begin
                    SourceLabel := TransferRoute.FieldCaption("Transfer-from Code");
                    SourceLabel2 := TransferRoute.FieldCaption("Transfer-to Code");
                end;
                // P8000954
        end;

        DeliveryStopNoVisible := (SourceType in [0, 1, 4]); // P8000954
        StandingOrderNoVisible := (SourceType = 0);

        GetSource;
        LoadSource;
    end;

    var
        SourceType: Integer;
        SourceFilter: Code[20];
        SourceNo: Code[20];
        OldSourceNo: Code[20];
        SourceFilter2: Code[10];
        SourceNo2: Code[10];
        OldSourceNo2: Code[10];
        SourceName: Text[100];
        SourceName2: Text[100];
        SourceLabel: Text[30];
        SourceLabel2: Text[30];
        DayOfWeek: Integer;
        RouteMatrixLine: Record "Delivery Routing Matrix Line";
        Customer: Record Customer;
        BlankFilter: Label '''''';
        ShipToAddress: Record "Ship-to Address";
        Vendor: Record Vendor;
        OrderAddress: Record "Order Address";
        Location: Record Location;
        TransferRoute: Record "Transfer Route";
        [InDataSet]
        DeliveryStopNoVisible: Boolean;
        [InDataSet]
        StandingOrderNoVisible: Boolean;
        Text001: Label 'Address';

    local procedure GetSource()
    begin
        SourceFilter := GetFilter("Source No.");
        if SourceFilter = BlankFilter then
            SourceNo := ''
        else
            SourceNo := SourceFilter;
        GetSourceName;

        SourceFilter2 := GetFilter("Source No. 2"); // P8000954
        if SourceFilter2 = BlankFilter then         // P8000954
            SourceNo2 := ''                           // P8000954
        else
            SourceNo2 := SourceFilter2;               // P8000954
        GetSourceName2;                             // P8000954
    end;

    local procedure LoadSource()
    begin
        SaveSource;

        Reset;
        DeleteAll;
        SetRange("Source Type", SourceType);
        SetRange("Source No.", SourceNo);
        SetRange("Source No. 2", SourceNo2); // P8000954

        if (SourceNo <> '') or (SourceNo2 <> '') then begin // P8000954
            for DayOfWeek := 1 to 7 do
                if RouteMatrixLine.Get(SourceType, SourceNo, SourceNo2, DayOfWeek) then begin // P8000954
                    Rec := RouteMatrixLine;
                    Insert;
                end else begin
                    Init;
                    "Source Type" := SourceType;
                    "Source No." := SourceNo;
                    "Source No. 2" := SourceNo2; // P8000954
                    "Day Of Week" := DayOfWeek;
                    Insert;
                end;
            SetFilter("Delivery Route No.", '<>%1', '');
            if not Find('-') then begin
                "Source Type" := SourceType;
                "Source No." := SourceNo;
                "Source No. 2" := SourceNo2; // P8000954
                "Day Of Week" := "Day Of Week"::Monday;
            end;
            SetRange("Delivery Route No.");
        end;
        OldSourceNo := SourceNo;
        OldSourceNo2 := SourceNo2; // P8000954
        CurrPage.Update(false);
    end;

    local procedure SaveSource()
    begin
        if (OldSourceNo <> '') or (OldSourceNo2 <> '') then begin // P8000954
            Reset;
            if Find('-') then
                repeat
                    if IsBlank then begin
                        if RouteMatrixLine.Get("Source Type", "Source No.", "Source No. 2", "Day Of Week") then
                            RouteMatrixLine.Delete;
                    end else begin
                        RouteMatrixLine := Rec;
                        if not RouteMatrixLine.Modify then
                            RouteMatrixLine.Insert;
                    end;
                until Next = 0;
        end;
    end;

    procedure GetSourceName()
    begin
        if SourceNo = '' then
            SourceName := ''
        else
            case SourceType of
                0, 1:
                    begin
                        Customer.Get(SourceNo);
                        SourceName := Customer.Name;
                    end;
                2, 3:
                    begin
                        Vendor.Get(SourceNo);
                        SourceName := Vendor.Name;
                    end;
                // P8000954
                4:
                    begin
                        Location.Get(SourceNo);
                        SourceName := Location.Name;
                    end;
                    // P8000954
            end;
    end;

    procedure GetSourceName2()
    begin
        // P8000954 - renamed from GetAddressName
        if SourceNo2 = '' then // P8000954
            SourceName2 := ''
        else
            case SourceType of
                1:
                    begin
                        ShipToAddress.Get(SourceNo, SourceNo2); // P8000954
                        SourceName2 := ShipToAddress.Name;    // P8000954
                    end;
                3:
                    begin
                        OrderAddress.Get(SourceNo, SourceNo2);  // P8000954
                        SourceName2 := OrderAddress.Name;     // P8000954
                    end;
                // P8000954
                4:
                    begin
                        Location.Get(SourceNo2);
                        SourceName2 := Location.Name;
                    end;
                    // P8000954
            end;
    end;
}

