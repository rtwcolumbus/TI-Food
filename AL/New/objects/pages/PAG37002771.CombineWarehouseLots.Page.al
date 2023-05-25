page 37002771 "Combine Warehouse Lots"
{
    // PR5.00
    // P8000495A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Form to combine lots from the bin status form / additional logic for fixed bin items
    // 
    // PRW15.00.01
    // P8000591A, VerticalSoft, Don Bresee, 13 MAR 08
    //   Only show items that don't have alternate quantity
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.02
    // P8000740, VerticalSoft, Don Bresee, 01 DEC 09
    //   Add logic to handle 1-Doc (no adjustment bin), and fixed weight items
    // 
    // PRW16.00.04
    // P8000888, VerticalSoft, Don Bresee, 13 DEC 10
    //   Move posting code to new codeunit
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Don Bresee, 28 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.03
    // P8001337, Columbus IT, Dayakar Battini, 06 Aug 14
    //    Container Visibilty with Bin Status.

    Caption = 'Combine Warehouse Lots';
    DataCaptionExpression = '';
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
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
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    NotBlank = true;
                }
                field(ItemDescription; CombineLots.GetItemDescription(Rec))
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
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    NotBlank = true;
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
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SerialNoInfo: Record "Serial No. Information";
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
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Qty. (Base)"; "Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CombineButton)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Combine Lots';
                Ellipsis = true;
                Image = LotInfo;

                trigger OnAction()
                var
                    WhseActHeader: Record "Warehouse Activity Header";
                begin
                    if RegisterFromForm then
                        CurrPage.Close;
                end;
            }
        }
        area(Promoted)
        {
            actionref(CombineButton_Promoted; CombineButton)
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

    var
        TempFormData: Record "Warehouse Entry" temporary;
        Item: Record Item;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        Text003: Label 'Create a new Lot and combine the existing Lots?';
        CombineLots: Codeunit "Combine Whse. Lots";

    procedure SetBinContents(var BinContent: Record "Bin Content")
    begin
        // P8000888
        CombineLots.LoadFormData(BinContent, TempFormData);
        /*
        SetBinContents(BinContent);
        CheckFormData;
        TempFormData.FINDFIRST;
        */
        // P8000888

    end;

    local procedure RegisterFromForm(): Boolean
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        Clear(CombineLots);  // P8001337
        with SourceCodeSetup do begin
            Get;
            TestField("Item Reclass. Journal"); // P8001132
                                                // SetSourceCode("BOM Journal");          // P8000888
            CombineLots.SetSourceCode("Item Reclass. Journal"); // P8000888, P8001132
        end;
        // SetDocumentNo('');          // P8000888
        CombineLots.SetDocumentNo(''); // P8000888
        with TempFormData do begin
            // P8000888
            // COPY(Rec);
            // CheckFormData;
            CombineLots.SaveFormData(TempFormData);
            // P8000888
            if not Confirm(Text003) then
                exit(false);
            // Register;          // P8000888
            CombineLots.Register; // P8000888
            exit(true);
        end;
    end;
}

