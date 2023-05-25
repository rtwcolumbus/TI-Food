page 37002762 "Build Warehouse Activity"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 18 AUG 06
    //   Form to create movements and register picks from the bin status form
    // 
    // PR5.00
    // P8000503A, VerticalSoft, Don Bresee, 06 AUG 07
    //    BuildSpecFromData - check for any data found
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 23 JUL 08
    //   Resize command buttons to standard width
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001034, Columbus IT, Jack Reynolds, 10 FEB 12
    //   Change codeunit for Warehouse Employee functions
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Build Warehouse Activity';
    DataCaptionExpression = '';
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Warehouse Entry";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'From Bin Code';

                    trigger OnValidate()
                    begin
                        if ("Bin Code" <> '') then begin
                            Bin.Get("Location Code", "Bin Code");
                            if ("Reference No." = "Bin Code") then
                                "Reference No." := '';
                        end;
                    end;
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'To Bin Code';
                    TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        BinList: Page "Bin List";
                    begin
                        TestField("Location Code");
                        Bin.Reset;
                        Bin.SetRange("Location Code", "Location Code");
                        BinList.SetTableView(Bin);
                        if (Text <> '') then begin
                            Bin.SetFilter(Code, Text);
                            if Bin.Find('-') then
                                BinList.SetRecord(Bin);
                        end;
                        Bin.Reset;
                        BinList.LookupMode(true);
                        if (BinList.RunModal <> ACTION::LookupOK) then
                            exit(false);
                        BinList.GetRecord(Bin);
                        Text := Bin.Code;
                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        if ("Reference No." <> '') then begin
                            Bin.Get("Location Code", "Reference No.");
                            if ("Bin Code" = "Reference No.") then
                                "Bin Code" := '';
                        end;
                    end;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        Item.Get("Item No.");
                        Description := Item.Description;
                        Validate("Variant Code", '');
                        Validate("Unit of Measure Code", Item."Base Unit of Measure");
                    end;
                }
                field(ItemDescription; GetItemDescription(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Description';
                    Editable = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        if ("Variant Code" <> '') then
                            ItemVariant.Get("Item No.", "Variant Code");
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    NotBlank = true;

                    trigger OnValidate()
                    var
                        OldItemUnitOfMeasure: Record "Item Unit of Measure";
                    begin
                        if not ItemUnitOfMeasure.Get("Item No.", xRec."Unit of Measure Code") then
                            Clear(ItemUnitOfMeasure);
                        "Qty. (Base)" := Quantity * ItemUnitOfMeasure."Qty. per Unit of Measure";
                        if not ItemUnitOfMeasure.Get("Item No.", "Unit of Measure Code") then
                            Clear(ItemUnitOfMeasure);
                        Quantity := Round("Qty. (Base)" / ItemUnitOfMeasure."Qty. per Unit of Measure", 0.00001);

                        "Qty. (Base)" := CalcBaseQty(Quantity);
                    end;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        TestField("Item No.");
                        exit(ItemTrackingMgt.WhseAssistEdit(
                               "Location Code", "Item No.", "Variant Code", "Bin Code", Text));
                    end;

                    trigger OnValidate()
                    begin
                        if ("Lot No." <> '') then begin
                            TestField("Item No.");
                            LotNoInfo.Get("Item No.", "Variant Code", "Lot No.");
                        end;
                    end;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SerialNoList: Page "Serial Nos.";
                    begin
                        TestField("Item No.");
                        SerialNoInfo.Reset;
                        SerialNoInfo.SetRange("Item No.", "Item No.");
                        SerialNoInfo.SetRange("Variant Code", "Variant Code");
                        SerialNoList.SetTableView(SerialNoInfo);
                        if (Text <> '') then begin
                            SerialNoInfo.SetFilter("Serial No.", Text);
                            if SerialNoInfo.Find('-') then
                                SerialNoList.SetRecord(SerialNoInfo);
                        end;
                        SerialNoInfo.Reset;
                        SerialNoList.LookupMode(true);
                        if (SerialNoList.RunModal <> ACTION::LookupOK) then
                            exit(false);
                        SerialNoList.GetRecord(SerialNoInfo);
                        Text := SerialNoInfo."Serial No.";
                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        if ("Serial No." <> '') then begin
                            TestField("Item No.");
                            SerialNoInfo.Get("Item No.", "Variant Code", "Serial No.");
                        end;
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        "Qty. (Base)" := CalcBaseQty(Quantity);
                    end;
                }
                field("Qty. (Base)"; "Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RegMoveButton)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Register Movement';
                Ellipsis = true;
                Image = CreateMovement;

                trigger OnAction()
                var
                    WhseActHeader: Record "Warehouse Activity Header";
                begin
                    BuildSpecFromFormData(Text001); // P8000503A
                    if not Confirm(Text000) then
                        exit;
                    P800WhseActCreate.RegisterMoveFromSpecification;
                    CurrPage.Close;
                end;
            }
            action(CreatePutAwayButton)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Create P&ut-Away';
                Ellipsis = true;
                Image = CreatePutAway;

                trigger OnAction()
                var
                    WhseActHeader: Record "Warehouse Activity Header";
                begin
                    BuildSpecFromFormData(Text002); // P8000503A
                    P800WhseActCreate.CreateWhsePutAway(WhseActHeader);
                    P800WhseActCreate.ShowWhseActHeader(WhseActHeader);
                    CurrPage.Close;
                end;
            }
        }
        area(Promoted)
        {
            actionref(RegMoveButton_Promoted; RegMoveButton)
            {
            }
            actionref(CreatePutAwayButton_Promoted; CreatePutAwayButton)
            {
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SetSelectionFilter(TempFormData);
        TempFormData.DeleteAll;
        exit(false);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        TempFormData.Copy(Rec);
        if not TempFormData.Find(Which) then
            exit(false);
        Rec := TempFormData;
        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        TestField("Location Code");
        if ("Reference No." = '') then
            TestField("Bin Code");
        TestField("Item No.");
        TestField("Unit of Measure Code");
        TempFormData := Rec;
        TempFormData.Insert;
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        TestField("Location Code");
        if ("Reference No." = '') then
            TestField("Bin Code");
        TestField("Item No.");
        TestField("Unit of Measure Code");
        TempFormData := Rec;
        TempFormData.Modify;
        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        TempFormData.Reset;
        if not TempFormData.Find('+') then
            Clear(TempFormData);
        "Entry No." := TempFormData."Entry No." + 1;
        "Location Code" := LocationCode;
        "Bin Code" := BinCode;
        TempFormData.Copy(Rec);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NumSteps: Integer;
    begin
        TempFormData.Copy(Rec);
        NumSteps := TempFormData.Next(Steps);
        if (NumSteps = 0) then
            exit(0);
        Rec := TempFormData;
        exit(NumSteps);
    end;

    trigger OnOpenPage()
    begin
        if (LocationCode = '') then
            LocationCode := P800CoreFns.GetDefaultEmpLocation; // P8001034
        Location.Get(LocationCode);
        BuildFormDataFromSpec;
    end;

    var
        TempFormData: Record "Warehouse Entry" temporary;
        NextTempFormEntryNo: Integer;
        LocationCode: Code[10];
        BinCode: Code[20];
        Location: Record Location;
        Bin: Record Bin;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        LotNoInfo: Record "Lot No. Information";
        SerialNoInfo: Record "Serial No. Information";
        P800CoreFns: Codeunit "Process 800 Core Functions";
        P800WhseActCreate: Codeunit "Process 800 Create Whse. Act.";
        Text000: Label 'Register Movement?';
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        Text001: Label 'Nothing to Move.';
        Text002: Label 'Nothing to Put-Away.';

    procedure SetLocation(NewLocationCode: Code[10])
    begin
        LocationCode := NewLocationCode;
    end;

    procedure SetSingleBin(NewLocationCode: Code[10]; NewBinCode: Code[20])
    begin
        LocationCode := NewLocationCode;
        BinCode := NewBinCode;
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        if not ItemUnitOfMeasure.Get("Item No.", "Unit of Measure Code") then
            Clear(ItemUnitOfMeasure);
        ItemUnitOfMeasure.TestField("Qty. per Unit of Measure");
        exit(Round(Qty * ItemUnitOfMeasure."Qty. per Unit of Measure", 0.00001));
    end;

    procedure SetBinContents(var BinContent: Record "Bin Content")
    begin
        P800WhseActCreate.BuildBinContentsSpecification(BinContent);
    end;

    local procedure BuildFormDataFromSpec()
    var
        TempFormJnlData: Record "Warehouse Journal Line" temporary;
    begin
        P800WhseActCreate.GetSpecification(TempFormJnlData);
        Clear(P800WhseActCreate);
        TempFormData.Reset;
        TempFormData.DeleteAll;
        TempFormData."Entry No." := 0;
        with TempFormJnlData do
            if Find('-') then
                repeat
                    TempFormData."Entry No." := TempFormData."Entry No." + 1;
                    TempFormData."Location Code" := "Location Code";
                    TempFormData."Bin Code" := "From Bin Code";
                    TempFormData."Reference No." := "To Bin Code";
                    TempFormData."Item No." := "Item No.";
                    TempFormData."Variant Code" := "Variant Code";
                    TempFormData."Unit of Measure Code" := "Unit of Measure Code";
                    TempFormData."Lot No." := "Lot No.";
                    TempFormData."Serial No." := "Serial No.";
                    TempFormData.Quantity := Quantity;
                    TempFormData."Qty. (Base)" := "Qty. (Base)";
                    TempFormData.Insert;
                until (Next = 0);
    end;

    local procedure BuildSpecFromFormData(TextMsg: Text[30])
    begin
        Clear(P800WhseActCreate);
        with TempFormData do begin
            Copy(Rec);
            SetFilter(Quantity, '>0'); // P8000503A
            if not Find('-') then      // P8000503A
                Error(TextMsg);          // P8000503A
            repeat
                P800WhseActCreate.AddToSpecificationBase(
                  "Location Code", "Bin Code", "Reference No.",
                  "Item No.", "Variant Code", "Unit of Measure Code",
                  "Lot No.", "Serial No.", Quantity, "Qty. (Base)");
            until (Next = 0);
        end;
    end;

    local procedure GetItemDescription(var WhseJnlLine: Record "Warehouse Entry"): Text[100]
    var
        Item: Record Item;
    begin
        with WhseJnlLine do
            if ("Item No." <> '') then
                if Item.Get("Item No.") then
                    exit(Item.Description);
    end;
}

