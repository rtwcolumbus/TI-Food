page 37002516 "Production Batch Size FactBox"
{
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001118, Columbus IT, Don Bresee, 15 NOV 12
    //   Remove Batch Sizing feature for Co/By-Product Processes

    Caption = 'Production Batch Size FactBox';
    PageType = CardPart;
    SourceTable = "Production BOM Version";

    layout
    {
        area(content)
        {
            grid(Control37002001)
            {
                group(Control37002002)
                {
                    ShowCaption = false;
                    field("''"; '')
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(Text001; Text001)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(Text002; Text002)
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field("BOMVars.""Density Text"""; BOMVars."Density Text")
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                        Visible = ShowVolume;
                    }
                }
                group(Control37002007)
                {
                    ShowCaption = false;
                    field("BOMVars.""Weight Text"""; BOMVars."Weight Text")
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(Inputweight; BOMVars."Input Weight")
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 0 : 5;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            ResizeBatch(BOMVars.FieldNo("Input Weight"), BOMVars);
                        end;
                    }
                    field(OutputWeight; BOMVars."Output Weight")
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 0 : 5;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            ResizeBatch(BOMVars.FieldNo("Output Weight"), BOMVars);
                        end;
                    }
                    field("BOMVars.Density"; BOMVars.Density)
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 0 : 5;
                        ShowCaption = false;
                        Visible = ShowVolume;
                    }
                }
                group(Control37002011)
                {
                    ShowCaption = false;
                    Visible = ShowVolume;
                    field("BOMVars.""Volume Text"""; BOMVars."Volume Text")
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field(InputVolume; BOMVars."Input Volume")
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 0 : 5;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            ResizeBatch(BOMVars.FieldNo("Input Volume"), BOMVars);
                        end;
                    }
                    field(OutputVolume; BOMVars."Output Volume")
                    {
                        ApplicationArea = FOODBasic;
                        DecimalPlaces = 0 : 5;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            ResizeBatch(BOMVars.FieldNo("Output Volume"), BOMVars);
                        end;
                    }
                    field(Control37002003; '')
                    {
                        ApplicationArea = FOODBasic;
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
    begin
        BOMHeader.Get("Production BOM No.");
        Clear(BOMVars);
        BOMVars.Type := BOMHeader."Mfg. BOM Type";
        BOMVars."No." := "Production BOM No.";
        BOMVars."Version Code" := "Version Code";
        BOMVars.InitRecord;
    end;

    var
        BOMHeader: Record "Production BOM Header";
        BOMVars: Record "BOM Variables";
        Text001: Label 'Input';
        Text002: Label 'Output';
        Text003: Label '%1 may not be %2 or %3.';
        Text004: Label 'Batch cannot be resized from zero.';
        [InDataSet]
        ShowVolume: Boolean;

    procedure CheckStatus()
    var
        BomVersion: array[2] of Record "Production BOM Version";
    begin
        Find; // Re-GET the record
        if Status in [Status::Certified, Status::Closed] then begin
            BomVersion[1].Status := Status::Certified;
            BomVersion[2].Status := Status::Closed;
            Error(Text003, FieldCaption(Status), BomVersion[1].Status, BomVersion[2].Status);
        end;
    end;

    procedure ResizeBatch(FldNo: Integer; var BOMVars: Record "BOM Variables")
    var
        BOMLine: Record "Production BOM Line";
        ResizeBatchPage: Page "Resize Batch";
        FldName: Text[50];
        UOM: Text[10];
        CurrentSize: Decimal;
        factor: Decimal;
    begin
        if BOMHeader.IsProdFamilyBOM() then // P8001118
            exit;                             // P8001118
        CheckStatus;
        case FldNo of
            BOMVars.FieldNo("Input Weight"):
                begin
                    FldName := BOMVars.FieldCaption("Input Weight");
                    UOM := BOMVars."Weight UOM";
                    CurrentSize := BOMVars."Input Weight";
                end;
            BOMVars.FieldNo("Input Volume"):
                begin
                    FldName := BOMVars.FieldCaption("Input Volume");
                    UOM := BOMVars."Volume UOM";
                    CurrentSize := BOMVars."Input Volume";
                end;
            BOMVars.FieldNo("Output Weight"):
                begin
                    FldName := BOMVars.FieldCaption("Output Weight");
                    UOM := BOMVars."Weight UOM";
                    CurrentSize := BOMVars."Output Weight";
                end;
            BOMVars.FieldNo("Output Volume"):
                begin
                    FldName := BOMVars.FieldCaption("Output Volume");
                    UOM := BOMVars."Volume UOM";
                    CurrentSize := BOMVars."Output Volume";
                end;
        end;
        if CurrentSize = 0 then
            Error(Text004);
        ResizeBatchPage.SetCaption(StrSubstNo('%1 (%2)', FldName, UOM));
        ResizeBatchPage.SetBatchSize(CurrentSize);
        if (ResizeBatchPage.RunModal = ACTION::Yes) then begin
            factor := ResizeBatchPage.GetBatchSize / CurrentSize;
            BOMVars.Resize(factor);
            CurrPage.Update;
        end;
    end;

    procedure SetVolumeMode()
    begin
        ShowVolume := true;
    end;
}

