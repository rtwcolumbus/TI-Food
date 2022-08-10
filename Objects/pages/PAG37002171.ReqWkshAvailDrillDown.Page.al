page 37002171 "Req. Wksh. Avail. DrillDown"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 20 MAR 06
    //   Provides 2-level drill down for item availability (purchases, sales, transfers)
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.05
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status

    Caption = 'Availability';
    DataCaptionExpression = CaptionText;
    Editable = false;
    PageType = List;
    SourceTable = "Item Availability";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Data Element"; "Data Element")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity Available';

                    trigger OnDrillDown()
                    begin
                        ReqWkshFns.ItemAvailDrillDown(ItemNo, VariantCode, LocationCode, BegDate, EndDate, Rec); // P8000936
                    end;
                }
                field("Quantity Not Available"; "Quantity Not Available")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        // P8001083
                        ReqWkshFns.ItemAvailDrillDown(ItemNo, VariantCode, LocationCode, BegDate, EndDate, Rec);
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900000003; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000004; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    var
        ReqWkshFns: Codeunit "Process 800 Req. Wksh. Fns.";
        ItemNo: Code[20];
        VariantCode: Code[10];
        LocationCode: Code[10];
        BegDate: Date;
        EndDate: Date;
        DataElementText: Text[30];
        LotStatusExclusionFilter: Text[1024];

    procedure SetData(ItmNo: Code[20]; VarCode: Code[10]; LocCode: Code[10]; Date1: Date; Date2: Date; var Avail: Record "Item Availability" temporary)
    begin
        ItemNo := ItmNo;
        VariantCode := VarCode;
        LocationCode := LocCode;
        BegDate := Date1;
        EndDate := Date2;
        DataElementText := Format(Avail."Data Element");

        if Avail.Find('-') then
            repeat
                Rec := Avail; // P8000936
                Insert;       // P8000936
            until Avail.Next = 0;

        FindFirst; // P8000936
    end;

    procedure CaptionText() Caption: Text[250]
    begin
        Caption := DataElementText;
        if LocationCode <> '' then
            Caption := LocationCode + ' ' + Caption;
        if VariantCode <> '' then
            Caption := VariantCode + ' ' + Caption;
        if ItemNo <> '' then
            Caption := ItemNo + ' ' + Caption;
    end;
}

