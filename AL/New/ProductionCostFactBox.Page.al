page 37002517 "Production Cost FactBox"
{
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Production Cost FactBox';
    PageType = CardPart;
    SourceTable = "Production BOM Version";

    layout
    {
        area(content)
        {
            field("GetActiveVersionDesc()"; GetActiveVersionDesc())
            {
                ApplicationArea = FOODBasic;
                ShowCaption = false;
                Style = Strong;
                StyleExpr = TRUE;
                Visible = ActiveVersionMode;
            }
            field("''"; '')
            {
                ApplicationArea = FOODBasic;
                ShowCaption = false;
                Visible = ActiveVersionMode;
            }
            grid(Control37002035)
            {
                group(Control37002007)
                {
                    ShowCaption = false;
                    field(Control37002006; '')
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(Text003; Text003)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(Text004; Text004)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(Text005; Text005)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(Text006; Text006)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(Text007; Text007)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(Text008; Text008)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                }
                group(Control37002015)
                {
                    ShowCaption = false;
                    field("ColumnText[1]"; ColumnText[1])
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field("ColumnValue[1,1]"; ColumnValue[1, 1])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[1,2]"; ColumnValue[1, 2])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[1,3]"; ColumnValue[1, 3])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[1,4]"; ColumnValue[1, 4])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[1,5]"; ColumnValue[1, 5])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[1,6]"; ColumnValue[1, 6])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                }
                group(Control37002023)
                {
                    ShowCaption = false;
                    Visible = Column2Visible;
                    field("ColumnText[2]"; ColumnText[2])
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field("ColumnValue[2,1]"; ColumnValue[2, 1])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[2,2]"; ColumnValue[2, 2])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[2,3]"; ColumnValue[2, 3])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[2,4]"; ColumnValue[2, 4])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[2,5]"; ColumnValue[2, 5])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[2,6]"; ColumnValue[2, 6])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                }
                group(Control37002031)
                {
                    ShowCaption = false;
                    Visible = Column3Visible;
                    field("ColumnText[3]"; ColumnText[3])
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field("ColumnValue[3,1]"; ColumnValue[3, 1])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[3,2]"; ColumnValue[3, 2])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[3,3]"; ColumnValue[3, 3])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[3,4]"; ColumnValue[3, 4])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[3,5]"; ColumnValue[3, 5])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                    field("ColumnValue[3,6]"; ColumnValue[3, 6])
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 5 : 5;
                        ShowCaption = false;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        ColumnNum: Integer;
    begin
        BOMHeader.Get("Production BOM No.");
        Clear(BOMVars);
        BOMVars.Type := BOMHeader."Mfg. BOM Type";
        BOMVars."No." := "Production BOM No.";
        if ActiveVersionMode then
            BOMVars."Version Code" := VersionMgt.GetBOMVersion("Production BOM No.", WorkDate, true)
        else
            BOMVars."Version Code" := "Version Code";
        BOMVars.InitRecord;

        for ColumnNum := 1 to 3 do
            LoadColumn(ColumnNum);
    end;

    trigger OnInit()
    begin
        ColumnType[1] := ColumnType[1] ::Weight;
        ColumnType[2] := ColumnType[2] ::Total;
    end;

    trigger OnOpenPage()
    begin
        if (ColumnType[2] <> ColumnType[2] ::Empty) then begin
            Column2Visible := true;
            if (ColumnType[3] <> ColumnType[3] ::Empty) then
                Column3Visible := true;
        end;
    end;

    var
        BOMHeader: Record "Production BOM Header";
        BOMVars: Record "BOM Variables";
        ColumnType: array[3] of Option Empty,Weight,Volume,Total;
        ColumnText: array[3] of Text[30];
        ColumnValue: array[3, 6] of Decimal;
        [InDataSet]
        Column2Visible: Boolean;
        [InDataSet]
        Column3Visible: Boolean;
        [InDataSet]
        ActiveVersionMode: Boolean;
        VersionMgt: Codeunit VersionManagement;
        Text001: Label '3,Weight (%1)';
        Text002: Label '3,Volume (%1)';
        Text003: Label 'Material';
        Text004: Label 'Labor';
        Text005: Label 'Machine';
        Text006: Label 'Other';
        Text007: Label 'Overhead';
        Text008: Label 'Total';
        Text009: Label 'Per %1';
        Text010: Label 'Total';
        Text011: Label 'No Active Version';
        Text012: Label 'Version: %1';
        Text013: Label 'Version: %1 / %2';

    procedure SetVolumeMode()
    begin
        Clear(ColumnType);
        ColumnType[1] := ColumnType[1] ::Volume;
        ColumnType[2] := ColumnType[2] ::Total;
    end;

    procedure SetCombinedMode()
    begin
        Clear(ColumnType);
        ColumnType[1] := ColumnType[1] ::Weight;
        ColumnType[2] := ColumnType[2] ::Volume;
        ColumnType[3] := ColumnType[3] ::Total;
    end;

    procedure SetTotalsOnlyMode()
    begin
        Clear(ColumnType);
        ColumnType[1] := ColumnType[1] ::Total;
    end;

    procedure SetActiveVersionMode()
    begin
        ActiveVersionMode := true;
    end;

    local procedure LoadColumn(ColumnNum: Integer)
    begin
        case ColumnType[ColumnNum] of
            ColumnType[ColumnNum] ::Weight:
                begin
                    ColumnText[ColumnNum] := StrSubstNo(Text009, BOMVars."Weight Text");
                    ColumnValue[ColumnNum, 1] := BOMVars."Material Cost (per Weight UOM)";
                    ColumnValue[ColumnNum, 2] := BOMVars."Labor Cost (per Weight UOM)";
                    ColumnValue[ColumnNum, 3] := BOMVars."Machine Cost (per Weight UOM)";
                    ColumnValue[ColumnNum, 4] := BOMVars."Other Cost (per Weight UOM)";
                    ColumnValue[ColumnNum, 5] := BOMVars."Overhead Cost (per Weight UOM)";
                    ColumnValue[ColumnNum, 6] := BOMVars."Total Cost (per Weight UOM)";
                end;
            ColumnType[ColumnNum] ::Volume:
                begin
                    ColumnText[ColumnNum] := StrSubstNo(Text009, BOMVars."Volume Text");
                    ColumnValue[ColumnNum, 1] := BOMVars."Material Cost (per Volume UOM)";
                    ColumnValue[ColumnNum, 2] := BOMVars."Labor Cost (per Volume UOM)";
                    ColumnValue[ColumnNum, 3] := BOMVars."Machine Cost (per Volume UOM)";
                    ColumnValue[ColumnNum, 4] := BOMVars."Other Cost (per Volume UOM)";
                    ColumnValue[ColumnNum, 5] := BOMVars."Overhead Cost (per Volume UOM)";
                    ColumnValue[ColumnNum, 6] := BOMVars."Total Cost (per volume UOM)";
                end;
            ColumnType[ColumnNum] ::Total:
                begin
                    ColumnText[ColumnNum] := Text010;
                    ColumnValue[ColumnNum, 1] := BOMVars."Material Cost";
                    ColumnValue[ColumnNum, 2] := BOMVars."Labor Cost";
                    ColumnValue[ColumnNum, 3] := BOMVars."Machine Cost";
                    ColumnValue[ColumnNum, 4] := BOMVars."Other Cost";
                    ColumnValue[ColumnNum, 5] := BOMVars."Overhead Cost";
                    ColumnValue[ColumnNum, 6] := BOMVars."Total Cost";
                end;
        end;
    end;

    local procedure GetActiveVersionDesc(): Text[100]
    var
        ProdBOMVersion: Record "Production BOM Version";
    begin
        if not ProdBOMVersion.Get(BOMVars."No.", BOMVars."Version Code") then
            exit(Text011);
        if (ProdBOMVersion.Description = '') then
            exit(StrSubstNo(Text012, ProdBOMVersion."Version Code"));
        exit(StrSubstNo(Text013, ProdBOMVersion."Version Code", ProdBOMVersion.Description));
    end;
}

