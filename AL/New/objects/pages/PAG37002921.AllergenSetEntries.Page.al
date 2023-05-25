page 37002921 "Allergen Set Entries"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergen Set Entries';
    DataCaptionExpression = PageCaption;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Allergen Set Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Allergen Code"; "Allergen Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allergen Description"; "Allergen Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field(Presence; Presence)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        if Presence > MaxPresence.Presence then
                            Error(Text002, FieldCaption(Presence), MaxPresence.Presence);
                    end;
                }
                field("Pending Change"; "Pending Change")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ShowPendingChange;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Detail)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Detail';
                Image = Properties;
                Visible = ShowDetail;

                trigger OnAction()
                var
                    AllergenManagement: Codeunit "Allergen Management";
                begin
                    AllergenManagement.ShowAllergenDetail(SourceRecord);
                end;
            }
        }
        area(Promoted)
        {
            actionref(Detail_Promoted; Detail)
            {
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        Modified := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Modified := true;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Modified := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Presence := MaxPresence.Presence;
    end;

    trigger OnOpenPage()
    begin
        ShowDetail := not (CurrPage.Editable or ShowPendingChange);
    end;

    var
        SourceRecord: Variant;
        MaxPresence: Record "Allergen Set Entry";
        AllergenSetID: Integer;
        PendingAllergenSetID: Integer;
        PageCaption: Text;
        Modified: Boolean;
        [InDataSet]
        ShowDetail: Boolean;
        Text001: Label '·';
        Text002: Label '%1 may not exceed "%2".';
        [InDataSet]
        ShowPendingChange: Boolean;

    procedure SetSource(SourceRec: Variant)
    var
        Item: Record Item;
        UnapprovedItem: Record "Unapproved Item";
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
        AllergenSetEntry: Record "Allergen Set Entry";
        SourceRecRef: RecordRef;
        AllergenManagement: Codeunit "Allergen Management";
    begin
        SourceRecord := SourceRec;
        SourceRecRef.GetTable(SourceRec);
        case SourceRecRef.Number of
            DATABASE::Item:
                begin
                    Item := SourceRec;
                    if AllergenManagement.IsProducedItem(Item) then begin
                        AllergenSetID := Item."Indirect Allergen Set ID";
                        CurrPage.Editable := false;
                    end else begin
                        AllergenSetID := Item."Direct Allergen Set ID";
                        ShowPendingChange := AllergenManagement.RecordHasPendingAllergenSetChange(SourceRec, PendingAllergenSetID);
                        CurrPage.Editable := not ShowPendingChange;
                    end;
                    MaxPresence.Presence := MaxPresence.Presence::Allergen;
                    PageCaption := StrSubstNo('%2 %1 %3 %1 %4', Text001, Item.TableCaption, Item."No.", Item.Description);
                end;

            DATABASE::"Unapproved Item":
                begin
                    UnapprovedItem := SourceRec;
                    AllergenSetID := UnapprovedItem."Allergen Set ID";
                    MaxPresence.Presence := MaxPresence.Presence::Allergen;
                    PageCaption := StrSubstNo('%2 %1 %3 %1 %4', Text001, UnapprovedItem.TableCaption, UnapprovedItem."No.", UnapprovedItem.Description);
                    ShowPendingChange := AllergenManagement.RecordHasPendingAllergenSetChange(SourceRec, PendingAllergenSetID);
                    CurrPage.Editable := not ShowPendingChange;
                end;

            DATABASE::"Production BOM Header":
                begin
                    ProductionBOMHeader := SourceRec;
                    AllergenSetID := ProductionBOMHeader."Allergen Set ID";
                    MaxPresence.Presence := MaxPresence.Presence::"May Contain";
                    PageCaption := StrSubstNo('%2 %1 %3 %1 %4', Text001, ProductionBOMHeader.TableCaption, ProductionBOMHeader."No.", ProductionBOMHeader.Description);
                    CurrPage.Editable := false;
                end;

            DATABASE::"Production BOM Version":
                begin
                    ProductionBOMVersion := SourceRec;
                    if ProductionBOMVersion.Status in [ProductionBOMVersion.Status::New, ProductionBOMVersion.Status::"Under Development"] then begin
                        AllergenSetID := ProductionBOMVersion."Direct Allergen Set ID";
                        ShowPendingChange := AllergenManagement.RecordHasPendingAllergenSetChange(SourceRec, PendingAllergenSetID);
                        CurrPage.Editable := not ShowPendingChange;
                    end else begin
                        AllergenSetID := ProductionBOMVersion."Indirect Allergen Set ID";
                        CurrPage.Editable := false;
                    end;
                    MaxPresence.Presence := MaxPresence.Presence::"May Contain";
                    ProductionBOMHeader.Get(ProductionBOMVersion."Production BOM No.");
                    PageCaption := StrSubstNo('%2 %1 %3 %1 %4 %1 %5', Text001, ProductionBOMVersion.TableCaption,
                      ProductionBOMVersion."Production BOM No.", ProductionBOMHeader.Description, ProductionBOMVersion."Version Code");
                end;
        end;

        AllergenSetEntry.SetRange("Allergen Set ID", AllergenSetID);
        if AllergenSetEntry.FindSet then
            repeat
                Rec := AllergenSetEntry;
                "Allergen Set ID" := 0;
                if ShowPendingChange then
                    "Pending Change" := "Pending Change"::Delete;
                Insert;
            until AllergenSetEntry.Next = 0;

        if ShowPendingChange then begin
            AllergenSetEntry.SetRange("Allergen Set ID", PendingAllergenSetID);
            if AllergenSetEntry.FindSet then
                repeat
                    if Get(0, AllergenSetEntry."Allergen Code") then begin
                        if Presence <> AllergenSetEntry.Presence then
                            "Pending Change" := "Pending Change"::"Change Presence"
                        else
                            "Pending Change" := "Pending Change"::" ";
                        Modify;
                    end else begin
                        Rec := AllergenSetEntry;
                        "Allergen Set ID" := 0;
                        "Pending Change" := "Pending Change"::Add; // Add
                        Insert;
                    end;
                until AllergenSetEntry.Next = 0;
        end;

        if FindFirst then;
    end;

    procedure GetAllergenSet(): Integer
    var
        AllergenManagement: Codeunit "Allergen Management";
    begin
        if not Modified then
            exit(AllergenSetID);

        Reset;
        exit(AllergenManagement.GetAllergenSetID(Rec));
    end;
}

