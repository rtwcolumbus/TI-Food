report 5751 "Put-away List"
{
    // PR4.00.04
    // P8000358A, VerticalSoft, Phyllis McGovern, 17 AUG 06
    //   Added option to print barcodes
    // 
    // PRW16.00
    // P8000646, VerticalSoft, Jack Reynolds, 02 DEC 08
    //   Add field for "Print Barcodes" to request page
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 14 APR 10
    //   Report design for RTC
    //     1. Add barcode fields
    //     2. Various fields formatting
    //     3. Change conditions on sections Visibility
    // 
    // PRW110.0.01
    // P80041198, To-Increase, Jack Reynolds, 08 MAY 17
    //   General changes and refactoring for NAV 2017 CU7
    DefaultLayout = RDLC;
    RDLCLayout = './layout/PutawayList.rdlc';
    Caption = 'Put-away List';

    dataset
    {
        dataitem("Warehouse Activity Header"; "Warehouse Activity Header")
        {
            DataItemTableView = SORTING(Type, "No.") WHERE(Type = FILTER("Put-away" | "Invt. Put-away"));
            RequestFilterFields = "No.", "No. Printed";
            column(No_WhseActivHeader; "No.")
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(CompanyName; COMPANYPROPERTY.DisplayName)
                {
                }
                column(TodayFormatted; Format(Today, 0, 4))
                {
                }
                column(Time; Time)
                {
                }
                column(SumUpLines; SumUpLines)
                {
                }
                column(ShowLotSN; ShowLotSN)
                {
                }
                column(InvtPutAway; InvtPutAway)
                {
                }
                column(BinMandatory; Location."Bin Mandatory")
                {
                }
                column(DirPutAwayAndPick; Location."Directed Put-away and Pick")
                {
                }
                column(PutAwayFilter; PutAwayFilter)
                {
                }
                column(TblCptnPutAwayFilter; "Warehouse Activity Header".TableCaption + ': ' + PutAwayFilter)
                {
                }
                column(No1_WhseActivHeader; "Warehouse Activity Header"."No.")
                {
                    IncludeCaption = true;
                }
                column(LocCode_WhseActivHeader; "Warehouse Activity Header"."Location Code")
                {
                    IncludeCaption = true;
                }
                column(HeaderBarcode; HeaderBarcode)
                {
                }
                column(AssgndUID_WhseActivHeader; "Warehouse Activity Header"."Assigned User ID")
                {
                    IncludeCaption = true;
                }
                column(SortingMthd_WhseActivHeader; "Warehouse Activity Header"."Sorting Method")
                {
                    IncludeCaption = true;
                }
                column(SrcDoc_WhseActivHeader; "Warehouse Activity Line"."Source Document")
                {
                    IncludeCaption = true;
                }
                column(CurrReportPAGENOCaption; CurrReportPAGENOCaptionLbl)
                {
                }
                column(PutawayListCaption; PutawayListCaptionLbl)
                {
                }
                column(WhseActLineDueDateCaption; WhseActLineDueDateCaptionLbl)
                {
                }
                column(QtyHandledCaption; QtyHandledCaptionLbl)
                {
                }
                dataitem("Warehouse Activity Line"; "Warehouse Activity Line")
                {
                    DataItemLink = "Activity Type" = FIELD(Type), "No." = FIELD("No.");
                    DataItemLinkReference = "Warehouse Activity Header";
                    DataItemTableView = SORTING("Activity Type", "No.", "Sorting Sequence No.");

                    trigger OnAfterGetRecord()
                    begin
                        if SumUpLines and
                           ("Warehouse Activity Header"."Sorting Method" <>
                            "Warehouse Activity Header"."Sorting Method"::Document)
                        then begin
                            if TempWhseActivLine."No." = '' then begin
                                TempWhseActivLine := "Warehouse Activity Line";
                                TempWhseActivLine.Insert();
                                Mark(true);
                            end else begin
                                TempWhseActivLine.SetSumLinesFilters("Warehouse Activity Line");
                                if TempWhseActivLine.FindFirst() then begin
                                    TempWhseActivLine."Qty. (Base)" := TempWhseActivLine."Qty. (Base)" + "Qty. (Base)";
                                    TempWhseActivLine."Qty. to Handle" := TempWhseActivLine."Qty. to Handle" + "Qty. to Handle";
                                    TempWhseActivLine."Source No." := '';
                                    TempWhseActivLine.Modify();
                                end else begin
                                    TempWhseActivLine := "Warehouse Activity Line";
                                    TempWhseActivLine.Insert();
                                    Mark(true);
                                end;
                            end;
                        end else
                            Mark(true);
                        SetCrossDockMark("Cross-Dock Information");

                        LIBarcode := '';                                                  // P8000358A
                        if (PrintBarcodes) and ("Action Type" = "Action Type"::Take) then // P8000358A
                            LIBarcode := '*' + "Item No." + '*';                            // P8000358A
                    end;

                    trigger OnPostDataItem()
                    begin
                        MarkedOnly(true);
                    end;

                    trigger OnPreDataItem()
                    begin
                        TempWhseActivLine.SetRange("Activity Type", "Warehouse Activity Header".Type);
                        TempWhseActivLine.SetRange("No.", "Warehouse Activity Header"."No.");
                        TempWhseActivLine.DeleteAll();
                        if BreakbulkFilter then
                            TempWhseActivLine.SetRange("Original Breakbulk", false);
                        Clear(TempWhseActivLine);
                    end;
                }
                dataitem(WhseActLine; "Warehouse Activity Line")
                {
                    DataItemLink = "Activity Type" = FIELD(Type), "No." = FIELD("No.");
                    DataItemLinkReference = "Warehouse Activity Header";
                    DataItemTableView = SORTING("Activity Type", "No.", "Sorting Sequence No.");
                    column(SrcNo_WhseActivLine; "Source No.")
                    {
                        IncludeCaption = false;
                    }
                    column(SrcDoc_WhseActivLine; Format("Source Document"))
                    {
                    }
                    column(ShelfNo_WhseActivLine; "Shelf No.")
                    {
                        IncludeCaption = false;
                    }
                    column(ItemNo1_WhseActivLine; "Item No.")
                    {
                        IncludeCaption = false;
                    }
                    column(Desc_WhseActivLine; Description)
                    {
                        IncludeCaption = false;
                    }
                    column(CrsDocInfo_WhseActivLine; "Cross-Dock Information")
                    {
                        IncludeCaption = false;
                    }
                    column(UOMCode_WhseActivLine; "Unit of Measure Code")
                    {
                        IncludeCaption = false;
                    }
                    column(DueDate_WhseActivLine; Format("Due Date"))
                    {
                    }
                    column(QtyToHndl_WhseActivLine; "Qty. to Handle")
                    {
                        IncludeCaption = false;
                    }
                    column(QtyBase_WhseActivLine; "Qty. (Base)")
                    {
                        IncludeCaption = false;
                    }
                    column(CrossDockMark; CrossDockMark)
                    {
                    }
                    column(VariantCode_WhseActivLine; "Variant Code")
                    {
                        IncludeCaption = false;
                    }
                    column(LIBarcode; LIBarcode)
                    {
                    }
                    column(ZoneCode_WhseActivLine; "Zone Code")
                    {
                        IncludeCaption = true;
                    }
                    column(BinCode_WhseActivLine; "Bin Code")
                    {
                        IncludeCaption = true;
                    }
                    column(ActionType_WhseActivLine; "Action Type")
                    {
                        IncludeCaption = true;
                    }
                    column(LotNo1_WhseActivLine; "Lot No.")
                    {
                        IncludeCaption = true;
                    }
                    column(SerialNo_WhseActivLine; "Serial No.")
                    {
                        IncludeCaption = true;
                    }
                    column(LineNo1_WhseActivLine; "Line No.")
                    {
                    }
                    column(BinRanking_WhseActivLine; "Bin Ranking")
                    {
                    }
                    column(EmptyStringCaption; EmptyStringCaptionLbl)
                    {
                    }
                    dataitem(WhseActLine2; "Warehouse Activity Line")
                    {
                        DataItemLink = "Activity Type" = FIELD("Activity Type"), "No." = FIELD("No."), "Bin Code" = FIELD("Bin Code"), "Item No." = FIELD("Item No."), "Action Type" = FIELD("Action Type"), "Variant Code" = FIELD("Variant Code"), "Unit of Measure Code" = FIELD("Unit of Measure Code"), "Due Date" = FIELD("Due Date");
                        DataItemTableView = SORTING("Activity Type", "No.", "Bin Code", "Breakbulk No.", "Action Type");
                        column(LotNo_WhseActivLine; "Lot No.")
                        {
                        }
                        column(SerialNo2_WhseActivLine; "Serial No.")
                        {
                        }
                        column(QtyBase2_WhseActivLine; "Qty. (Base)")
                        {
                        }
                        column(QtyToHndl2_WhseActivLine; "Qty. to Handle")
                        {
                        }
                        column(LineNo_WhseActivLine; "Line No.")
                        {
                        }
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if SumUpLines then begin
                            TempWhseActivLine.Get("Activity Type", "No.", "Line No.");
                            "Qty. (Base)" := TempWhseActivLine."Qty. (Base)";
                            "Qty. to Handle" := TempWhseActivLine."Qty. to Handle";
                        end;
                        SetCrossDockMark("Cross-Dock Information");

                        LIBarcode := '';                                                  // P8000358A
                        if (PrintBarcodes) and ("Action Type" = "Action Type"::Take) then // P8000358A
                            LIBarcode := '*' + "Item No." + '*';                            // P8000358A
                    end;

                    trigger OnPreDataItem()
                    begin
                        Copy("Warehouse Activity Line");
                        Counter := Count;
                        if Counter = 0 then
                            CurrReport.Break();

                        if BreakbulkFilter then
                            SetRange("Original Breakbulk", false);
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                GetLocation("Location Code");
                InvtPutAway := Type = Type::"Invt. Put-away";
                if InvtPutAway then
                    BreakbulkFilter := false
                else
                    BreakbulkFilter := "Breakbulk Filter";

                if not IsReportInPreviewMode then
                    CODEUNIT.Run(CODEUNIT::"Whse.-Printed", "Warehouse Activity Header");

                if PrintBarcodes then                 // P8000358A
                    HeaderBarcode := '*' + "No." + '*'; // P8000358A
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
                    field(Breakbulk; BreakbulkFilter)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Set Breakbulk Filter';
                        Editable = BreakbulkEditable;
                        ToolTip = 'Specifies if you do not want to view the intermediate lines that are created when the unit of measure is changed in put-away instructions.';
                    }
                    field(SumUpLines; SumUpLines)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Sum up Lines';
                        Editable = SumUpLinesEditable;
                        ToolTip = 'Specifies if you want the lines to be summed up for each item, such as several put-away lines that originate from different source documents that concern the same item and bins.';
                    }
                    field(LotSerialNo; ShowLotSN)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Show Serial/Lot Number';
                        ToolTip = 'Specifies if you want to show lot and serial number information for items that use item tracking.';
                    }
                    field(PrintBarcodes; PrintBarcodes)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Print Barcodes';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            SumUpLinesEditable := true;
            BreakbulkEditable := true;
        end;

        trigger OnOpenPage()
        begin
            if HideOptions then begin
                BreakbulkEditable := false;
                SumUpLinesEditable := false;
            end;
        end;
    }

    labels
    {
        WhseActLineItemNoCaption = 'Item No.';
        WhseActLineDescriptionCaption = 'Description';
        WhseActLineVariantCodeCaption = 'Variant Code';
        WhseActLineCrossDockInformationCaption = 'Cross-Dock Information';
        WhseActLineShelfNoCaption = 'Shelf No.';
        WhseActLineQtyBaseCaption = 'Quantity(Base)';
        WhseActLineQtytoHandleCaption = 'Quantity to Handle';
        WhseActLineUnitofMeasureCodeCaption = 'Unit of Measure Code';
        WhseActLineSourceNoCaption = 'Source No.';
    }

    trigger OnInitReport()
    begin
        OnBeforeOnInitReport(ShowLotSN);
    end;

    trigger OnPreReport()
    begin
        PutAwayFilter := "Warehouse Activity Header".GetFilters;
    end;

    var
        Location: Record Location;
        TempWhseActivLine: Record "Warehouse Activity Line" temporary;
        PutAwayFilter: Text;
        BreakbulkFilter: Boolean;
        SumUpLines: Boolean;
        HideOptions: Boolean;
        InvtPutAway: Boolean;
        ShowLotSN: Boolean;
        Counter: Integer;
        CrossDockMark: Text[1];
        [InDataSet]
        BreakbulkEditable: Boolean;
        [InDataSet]
        SumUpLinesEditable: Boolean;
        CurrReportPAGENOCaptionLbl: Label 'Page';
        PutawayListCaptionLbl: Label 'Put-away List';
        WhseActLineDueDateCaptionLbl: Label 'Due Date';
        QtyHandledCaptionLbl: Label 'Quantity Handled';
        EmptyStringCaptionLbl: Label '____________';
        PrintBarcodes: Boolean;
        HeaderBarcode: Text[50];
        LIBarcode: Text[50];

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Location.Init
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody);
    end;

    procedure SetBreakbulkFilter(BreakbulkFilter2: Boolean)
    begin
        BreakbulkFilter := BreakbulkFilter2;
    end;

    procedure SetCrossDockMark(CrossDockInfo: Option)
    begin
        if CrossDockInfo <> 0 then
            CrossDockMark := '!'
        else
            CrossDockMark := '';
    end;

    procedure SetInventory(SetHideOptions: Boolean)
    begin
        HideOptions := SetHideOptions;
    end;

    procedure SetBarcodeOption(PrintBarcode: Boolean)
    begin
        PrintBarcodes := PrintBarcode; // P8000358A
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnInitReport(var ShowLotSN: Boolean)
    begin
    end;
}

