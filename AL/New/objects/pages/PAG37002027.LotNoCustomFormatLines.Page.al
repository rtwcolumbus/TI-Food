page 37002027 "Lot No. Custom Format Lines"
{
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW121.2
    // P800163700, To-Increase, Jack Reynolds, 07 FEB 23
    //   Support for Auto-Save as You Work
    //   Also added updated for Update Propigation

    AutoSplitKey = true;
    Caption = 'Lot No. Custom Format Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Lot No. Custom Format Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; "Line No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        if Type <> xRec.Type then begin
                            Segment := '';
                            Description := '';
                            "Segment Code" := '';
                        end;
                    end;
                }
                field(Segment; Segment)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Type = Type::Text then
                            exit(false);

                        LotNoSegment.Reset;
                        LotNoSegment.Code := Text;
                        LotNoSegment.Find('=><');
                        if PAGE.RunModal(PAGE::"Lot No. Segments", LotNoSegment) = ACTION::LookupOK then begin
                            Text := LotNoSegment.Code;
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if Segment <> '' then
                            case Type of
                                Type::Code:
                                    begin
                                        LotNoSegment.Get(Segment);
                                        Description := LotNoSegment.Description;
                                        "Segment Code" := LotNoSegment."Segment Code";
                                    end;
                                Type::Text:
                                    begin
                                        Description := Text001;
                                        "Segment Code" := Segment;
                                    end;
                            end;
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    QuickEntry = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    var
        CustomFormatLine: Record "Lot No. Custom Format Line";
    begin
        CustomFormatLine."Custom Format Code" := "Custom Format Code";
        CustomFormatLine."Line No." := "Line No.";
        CurrPage.Update(false); // P800163700
        exit(CustomFormatLine.Delete(true));
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        LoadLines;
        exit(Find(Which));
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        CustomFormatLine: Record "Lot No. Custom Format Line";
    begin
        CustomFormatLine."Custom Format Code" := "Custom Format Code";
        CustomFormatLine."Line No." := "Line No.";
        CustomFormatLine.Type := Type;
        CustomFormatLine."Segment Code" := "Segment Code";
        CurrPage.Update(false); // P800163700
        exit(CustomFormatLine.Insert(true));
    end;

    trigger OnModifyRecord(): Boolean
    var
        CustomFormatLine: Record "Lot No. Custom Format Line";
    begin
        CustomFormatLine."Custom Format Code" := "Custom Format Code";
        CustomFormatLine."Line No." := "Line No.";
        CustomFormatLine.Type := Type;
        CustomFormatLine."Segment Code" := "Segment Code";
        CurrPage.Update(false); // P800163700
        exit(CustomFormatLine.Modify(true));
    end;

    trigger OnOpenPage()
    begin
        CustomFormat.InitializeSegments(LotNoSegment);
    end;

    var
        LotNoSegment: Record "Lot No. Segment" temporary;
        Text001: Label 'Free Text';
        CustomFormat: Codeunit "Lot No. Custom Format";
        CustomFormatCode: Code[10];

    procedure LoadLines()
    var
        CustomFormatLine: Record "Lot No. Custom Format Line";
    begin
        FilterGroup(4);
        if CustomFormatCode = GetFilter("Custom Format Code") then begin
            FilterGroup(0);
            exit;
        end;

        CustomFormatCode := GetFilter("Custom Format Code");
        CustomFormatLine.Copy(Rec);
        Reset;
        DeleteAll;

        if CustomFormatLine.FindSet then
            repeat
                Init;
                "Custom Format Code" := CustomFormatLine."Custom Format Code";
                "Line No." := CustomFormatLine."Line No.";
                Type := CustomFormatLine.Type;
                "Segment Code" := CustomFormatLine."Segment Code";
                if Type = Type::Code then begin
                    LotNoSegment.SetRange("Segment Code", "Segment Code");
                    if LotNoSegment.FindFirst then begin
                        Segment := LotNoSegment.Code;
                        Description := LotNoSegment.Description;
                    end;
                end else begin
                    Segment := "Segment Code";
                    Description := Text001;
                end;
                Insert;
            until CustomFormatLine.Next = 0;

        Rec.Copy(CustomFormatLine);
        if FindFirst then;
    end;
}

