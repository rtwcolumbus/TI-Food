page 37002769 "Convert Warehouse Units"
{
    // PR5.00
    // P8000503A, VerticalSoft, Don Bresee, 05 DEC 06
    //   Form to convert units from the bin status form
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

    Caption = 'Convert Warehouse Units';
    DataCaptionExpression = '';
    DelayedInsert = true;
    InsertAllowed = false;
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
                    Editable = false;

                    trigger OnValidate()
                    begin
                        if ("Bin Code" <> '') then begin
                            Bin.Get("Location Code", "Bin Code");
                            if ("Reference No." = "Bin Code") then
                                "Reference No." := '';
                        end;
                    end;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
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
                    Editable = false;
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
                    Editable = false;
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
                    Editable = false;

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
                    Editable = false;
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
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Available Qty.';
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        ValidateQuantity;
                    end;
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'New Unit of Measure Code';
                    TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemUnitOfMeasureList: Page "Item Units of Measure";
                    begin
                        TestField("Item No.");
                        ItemUnitOfMeasure.Reset;
                        ItemUnitOfMeasure.SetRange("Item No.", "Item No.");
                        ItemUnitOfMeasureList.SetTableView(ItemUnitOfMeasure);
                        if (Text <> '') then begin
                            ItemUnitOfMeasure.SetFilter(Code, Text);
                            if ItemUnitOfMeasure.Find('-') then
                                ItemUnitOfMeasureList.SetRecord(ItemUnitOfMeasure);
                        end;
                        ItemUnitOfMeasure.Reset;
                        ItemUnitOfMeasureList.LookupMode(true);
                        if (ItemUnitOfMeasureList.RunModal <> ACTION::LookupOK) then
                            exit(false);
                        ItemUnitOfMeasureList.GetRecord(ItemUnitOfMeasure);
                        Text := ItemUnitOfMeasure.Code;
                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        if ("Reference No." <> '') then begin
                            ItemUnitOfMeasure.Get("Item No.", "Reference No.");
                            if ("Unit of Measure Code" = "Reference No.") then
                                Error(Text001, "Unit of Measure Code");
                            ValidateQuantity;
                        end;
                    end;
                }
                field("Qty. (Base)"; "Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'New Quantity';

                    trigger OnValidate()
                    begin
                        Quantity :=
                          ConvertQuantity("Item No.", "Qty. (Base)", "Reference No.", "Unit of Measure Code");
                        if (Quantity > "Remaining Quantity") then
                            Error(Text002, Quantity - "Remaining Quantity");
                    end;
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
                Caption = '&Register';
                Ellipsis = true;
                Image = Register;

                trigger OnAction()
                var
                    WhseActHeader: Record "Warehouse Activity Header";
                begin
                    if RegisterFromFormData then
                        CurrPage.Close;
                end;
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Autofill Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Autofill Quantity';
                    Image = AutofillQtyToHandle;

                    trigger OnAction()
                    begin
                        SetQuantities(false);
                        CurrPage.Update(false);
                    end;
                }
                action("Delete Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delete Quantity';
                    Image = Delete;

                    trigger OnAction()
                    begin
                        SetQuantities(true);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(RegMoveButton_Promoted; RegMoveButton)
            {
            }
            actionref(AutofillQuantity_Promoted; "Autofill Quantity")
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
        NewItemUnitOfMeasure: Record "Item Unit of Measure";
        LotNoInfo: Record "Lot No. Information";
        SerialNoInfo: Record "Serial No. Information";
        P800CoreFns: Codeunit "Process 800 Core Functions";
        P800WhseActCreate: Codeunit "Process 800 Create Whse. Act.";
        Text000: Label 'Register Unit of Measure Conversion?';
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        Text001: Label 'New Unit of Measure must not be %1.';
        Text002: Label 'Quantity exceeds the Available Qty. by %1.';
        Text003: Label 'Nothing to Register.';

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

    local procedure ValidateQuantity()
    begin
        if (Quantity > "Remaining Quantity") then
            Error(Text002, Quantity - "Remaining Quantity");
        "Qty. (Base)" :=
          ConvertQuantity("Item No.", Quantity, "Unit of Measure Code", "Reference No.");
    end;

    local procedure ConvertQuantity(ItemNo: Code[20]; FromQty: Decimal; FromUOMCode: Code[10]; ToUOMCode: Code[10]): Decimal
    var
        FromUOM: Record "Item Unit of Measure";
        ToUOM: Record "Item Unit of Measure";
    begin
        if FromUOM.Get(ItemNo, FromUOMCode) then
            if ToUOM.Get(ItemNo, ToUOMCode) then
                exit(Round(FromQty *
                  (FromUOM."Qty. per Unit of Measure" / ToUOM."Qty. per Unit of Measure"), 0.00001));
        exit(0);
    end;

    local procedure BuildFormDataFromSpec()
    var
        TempFormJnlData: Record "Warehouse Journal Line" temporary;
        DefUOM: Record "Item Unit of Measure";
    begin
        P800WhseActCreate.GetSpecification(TempFormJnlData);
        Clear(P800WhseActCreate);
        DefUOM.SetCurrentKey("Item No.", "Qty. per Unit of Measure");
        TempFormData.Reset;
        TempFormData.DeleteAll;
        TempFormData."Entry No." := 0;
        with TempFormJnlData do begin
            SetFilter(Quantity, '>0');
            if Find('-') then
                repeat
                    TempFormData."Entry No." := TempFormData."Entry No." + 1;
                    TempFormData."Location Code" := "Location Code";
                    TempFormData."Bin Code" := "From Bin Code";
                    TempFormData."Item No." := "Item No.";
                    TempFormData."Variant Code" := "Variant Code";
                    TempFormData."Unit of Measure Code" := "Unit of Measure Code";
                    TempFormData."Lot No." := "Lot No.";
                    TempFormData."Serial No." := "Serial No.";
                    TempFormData."Remaining Quantity" := Quantity;
                    TempFormData."Remaining Qty. (Base)" := "Qty. (Base)";
                    if ItemUnitOfMeasure.Get("Item No.", "Unit of Measure Code") then begin
                        TempFormData."Reference No." := '';
                        DefUOM.SetRange("Item No.", "Item No.");
                        DefUOM.SetFilter(
                          "Qty. per Unit of Measure", '<%1', ItemUnitOfMeasure."Qty. per Unit of Measure");
                        if DefUOM.Find('+') then
                            TempFormData."Reference No." := DefUOM.Code
                        else begin
                            DefUOM.SetFilter(
                              "Qty. per Unit of Measure", '>%1', ItemUnitOfMeasure."Qty. per Unit of Measure");
                            if DefUOM.Find('-') then
                                TempFormData."Reference No." := DefUOM.Code;
                        end;
                        if (TempFormData."Reference No." <> '') then
                            TempFormData.Insert;
                    end;
                until (Next = 0);
        end;
    end;

    local procedure RegisterFromFormData(): Boolean
    begin
        Clear(P800WhseActCreate);
        with TempFormData do begin
            Copy(Rec);
            SetFilter(Quantity, '>0');
            if not Find('-') then
                Error(Text003);
            if not Confirm(Text000) then
                exit(false);
            repeat
                P800WhseActCreate.RegisterUOMConversion2(
                  "Location Code", "Bin Code", "Item No.",
                  "Variant Code", "Unit of Measure Code", "Reference No.",
                  "Lot No.", "Serial No.", Quantity, "Qty. (Base)");
            until (Next = 0);
        end;
        exit(true);
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

    local procedure SetQuantities(SetToZero: Boolean)
    begin
        with TempFormData do begin
            Copy(Rec);
            if Find('-') then
                repeat
                    if SetToZero then begin
                        Quantity := 0;
                        "Qty. (Base)" := 0;
                    end else begin
                        Quantity := "Remaining Quantity";
                        "Qty. (Base)" :=
                          ConvertQuantity("Item No.", Quantity, "Unit of Measure Code", "Reference No.");
                    end;
                    Modify;
                until (Next = 0);
        end;
    end;
}

