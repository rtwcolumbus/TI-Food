page 37002488 "Create Production Orders"
{
    // PR1.00.02
    //   Rearrange buttons
    // 
    // PR2.00
    //   Dimensions
    //   Order Status
    // 
    // PR3.70.06
    // P8000110A, Myers Nissi, Jack Reynolds, 08 SEP 04
    //   Renamed from "Quick Planner Create Orders"
    //   Show number of orders as part of form caption
    // 
    // PRW16.00.03
    // P8000796, VerticalSoft, Don Bresee, 01 APR 10
    //   Rework interface for NAV 2009
    // 
    // PRW16.00.04
    // P8000875, VerticalSoft, Jack Reynolds, 14 OCT 10
    //   Add support for Planned orders
    // 
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Modified for Batch Planning
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Refactoring for default dimensions

    Caption = 'Create Production Orders';
    InstructionalText = 'Do you want to create the production orders?';
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            field(Direction; Direction)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Scheduling Direction';
                Editable = DirectionEditable;
                OptionCaption = 'Forward,Backward';
            }
            field(OrderStatus; OrderStatus)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Order Status';
                Editable = OrderStatusEditable;
                OptionCaption = 'Planned,Firm Planned,Released';

                trigger OnValidate()
                begin
                    // P8000877
                    if OrderStatus < MinOrderStatus then
                        Error(Text003, MinOrderStatus);
                    // P8000877
                end;
            }
            field(Dimensions; Dimensions)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Dimensions';
                Editable = false;

                trigger OnAssistEdit()
                begin
                    // P8000877
                    DimensionSetID := DimMgt.EditDimensionSet(DimensionSetID, CurrPage.Caption); // P8001133
                    Dimensions := GetDimensions;
                end;
            }
            field(Location; Location)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Location Code';
                Editable = LocationEditable;
                TableRelation = Location;
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        OrderStatusEditable := true;
        DirectionEditable := true; // P8000877
        LocationEditable := true; // P8000877
        //DimValueMgt.LoadDefaults(0,''); // PR2.00, P8000877
    end;

    trigger OnOpenPage()
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        ShortcutDimValue: Code[20];
    begin
        // P8000877
        case OrderCnt of
            0:
                CurrPage.Caption := Text000;
            1:
                CurrPage.Caption := Text000 + Text001;
            else
                CurrPage.Caption := Text000 + Text002;
        end;
        CurrPage.Caption := StrSubstNo(CurrPage.Caption, OrderCnt);
        // P8000877
        // P8001133
        if DefaultDimCode <> '' then begin
            // P800144605
            DimMgt.AddDimSource(DefaultDimSource, DATABASE::"Process Setup", DefaultDimCode);
            DimensionSetID :=
              DimMgt.GetDefaultDimID(DefaultDimSource, '', ShortcutDimValue, ShortcutDimValue, 0, 0);
            // P800144605
            Dimensions := GetDimensions; // P8000877
        end; // P8001133
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        Location: Code[10];
        Direction: Option Forward,Backward;
        OrderStatus: Option Planned,"Firm Planned",Released;
        MinOrderStatus: Option Planned,"Firm Planned",Released;
        DefaultDimTable: Integer;
        DefaultDimCode: Code[20];
        Dimensions: Text[1024];
        DimensionSetID: Integer;
        OrderCnt: Integer;
        Text000: Label 'Create Production Orders';
        Text001: Label ' - %1 Order';
        Text002: Label ' - %1 Orders';
        [InDataSet]
        OrderStatusEditable: Boolean;
        [InDataSet]
        DirectionEditable: Boolean;
        [InDataSet]
        LocationEditable: Boolean;
        Text003: Label 'Order status must be at least %1.';

    procedure SetVariables(loc: Code[10]; status: Integer; cnt: Integer)
    begin
        // P8000110A - add parameter for status and order count
        Location := loc;
        OrderStatus := status - 1; // P8000110A, P8000875
        OrderCnt := cnt;           // P8000110A
    end;

    procedure SetDefaultDimensions(TableID: Integer; "Code": Code[20])
    begin
        // P8000877
        // P8001133 - Parameter No changed to Code
        DefaultDimTable := TableID;
        DefaultDimCode := Code; // P8001133
    end;

    procedure SetMinimumOrderStatus(Status: Integer)
    begin
        // P8000877
        MinOrderStatus := Status - 1;
    end;

    procedure ProhibitStatusChange()
    begin
        // P800110A
        OrderStatusEditable := false;
    end;

    procedure ProhibitDirectionChange()
    begin
        // P8000877
        DirectionEditable := false;
    end;

    procedure ProhibitLocationChange()
    begin
        // P8000877
        LocationEditable := false;
    end;

    procedure ReturnVariables(var Loc: Code[10]; var Dir: Integer; var Status: Integer; var DimSetID: Integer)
    begin
        Loc := Location;
        Dir := Direction;
        Status := 1 + OrderStatus; // PR2.00, P8000875
        DimSetID := DimensionSetID; // P801133
    end;

    procedure GetDimensions() Dimensions: Text[1024]
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        // P8001133
        DimMgt.GetDimensionSet(TempDimSetEntry, DimensionSetID);
        if TempDimSetEntry.Find('-') then begin
            repeat
                Dimensions := Dimensions + StrSubstNo('; %1 - %2', TempDimSetEntry."Dimension Code", TempDimSetEntry."Dimension Value Code");
            until TempDimSetEntry.Next(1) = 0;
            Dimensions := CopyStr(Dimensions, 3);
        end;
    end;
}

