table 245 "Requisition Wksh. Name"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 17 MAR 06
    //   Add fields for P800 extended requisition
    // 
    // PPRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   View handling functions

    Caption = 'Requisition Wksh. Name';
    DataCaptionFields = Name, Description;
    LookupPageID = "Req. Wksh. Names";

    fields
    {
        field(1; "Worksheet Template Name"; Code[10])
        {
            Caption = 'Worksheet Template Name';
            NotBlank = true;
            TableRelation = "Req. Wksh. Template";
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(21; "Template Type"; Enum "Req. Worksheet Template Type")
        {
            CalcFormula = Lookup("Req. Wksh. Template".Type WHERE(Name = FIELD("Worksheet Template Name")));
            Caption = 'Template Type';
            Editable = false;
            FieldClass = FlowField;
        }
        field(22; Recurring; Boolean)
        {
            CalcFormula = Lookup("Req. Wksh. Template".Recurring WHERE(Name = FIELD("Worksheet Template Name")));
            Caption = 'Recurring';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002040; "Days View"; Integer)
        {
            Caption = 'Days View';
            MinValue = 0;
        }
        field(37002041; "Item View"; BLOB)
        {
            Caption = 'Item View';
        }
        field(37002042; Frequency; DateFormula)
        {
            Caption = 'Frequency';

            trigger OnValidate()
            begin
                // P800xxx
                if (Format(Frequency) <> '') and ("Last Date" <> 0D) then
                    "Next Date" := CalcDate(Frequency, "Last Date")
                else
                    "Next Date" := 0D;
            end;
        }
        field(37002043; "Last Date"; Date)
        {
            Caption = 'Last Date';
            Editable = false;
        }
        field(37002044; "Next Date"; Date)
        {
            Caption = 'Next Date';
            Editable = false;
        }
        field(37002045; Lines; Integer)
        {
            CalcFormula = Count ("Requisition Line" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                          "Journal Batch Name" = FIELD(Name)));
            Caption = 'Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002046; "End Date"; Date)
        {
            Caption = 'End Date';
            Editable = false;
        }
        field(37002047; "Show All Items"; Boolean)
        {
            Caption = 'Show All Items';
        }
    }

    keys
    {
        key(Key1; "Worksheet Template Name", Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ReqLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ReqLine.SetRange("Journal Batch Name", Name);
        ReqLine.DeleteAll(true);

        PlanningErrorLog.SetRange("Worksheet Template Name", "Worksheet Template Name");
        PlanningErrorLog.SetRange("Journal Batch Name", Name);
        PlanningErrorLog.DeleteAll();
    end;

    trigger OnInsert()
    begin
        LockTable();
        ReqWkshTmpl.Get("Worksheet Template Name");
    end;

    trigger OnRename()
    begin
        ReqLine.SetRange("Worksheet Template Name", xRec."Worksheet Template Name");
        ReqLine.SetRange("Journal Batch Name", xRec.Name);
        while ReqLine.FindFirst() do
            ReqLine.Rename("Worksheet Template Name", Name, ReqLine."Line No.");

        PlanningErrorLog.SetRange("Worksheet Template Name", xRec."Worksheet Template Name");
        PlanningErrorLog.SetRange("Journal Batch Name", xRec.Name);
        while PlanningErrorLog.FindFirst() do
            PlanningErrorLog.Rename("Worksheet Template Name", Name, PlanningErrorLog."Entry No.");
    end;

    var
        ReqWkshTmpl: Record "Req. Wksh. Template";
        ReqLine: Record "Requisition Line";
        PlanningErrorLog: Record "Planning Error Log";
        Text001: Label 'Are you sure you want to clear the %1?';
        Text002: Label 'The %1 is not defined.';
        Text003: Label 'Define %1 View';

    procedure GetItemViewText() ItemViewText: Text
    var
        ReqWkshName: Record "Requisition Wksh. Name";
        ViewStream: InStream;
    begin
        // P8000312A
        // P8004516 - ItemViewText is unlimited
        ItemViewText := '';
        if not ReqWkshName.Get("Worksheet Template Name", Name) then
            exit;
        CalcFields("Item View");
        if "Item View".HasValue then begin
            "Item View".CreateInStream(ViewStream);
            ViewStream.ReadText(ItemViewText);
        end;
    end;

    procedure SetItemViewText(ItemViewText: Text)
    var
        ViewStream: OutStream;
    begin
        // P8000312A
        // P8004516 - ItemViewText is unlimited
        Clear("Item View");
        if (ItemViewText <> '') then begin
            "Item View".CreateOutStream(ViewStream);
            ViewStream.WriteText(ItemViewText);
        end;
    end;

    procedure ClearItemView()
    begin
        // P8000312A
        CalcFields("Item View");
        if "Item View".HasValue then
            if Confirm(Text001, false, FieldCaption("Item View")) then begin
                Clear("Item View");
                Modify(true);
            end;
    end;

    procedure LoadItemView(var Item: Record Item): Boolean
    var
        ItemViewText: Text;
    begin
        // P8000312A
        // P8004516 - ItemViewText is unlimited
        Item.Reset;
        ItemViewText := GetItemViewText();
        if (ItemViewText = '') then
            exit(false);
        Item.SetView(ItemViewText);
        exit(true);
    end;

    procedure SaveItemView(var Item: Record Item)
    begin
        // P8000312A
        if (Item.GetFilters = '') then
            SetItemViewText('')
        else
            SetItemViewText(Item.GetView());
    end;

    procedure DefineItemView()
    var
        Item: Record Item;
        FilterPage: FilterPageBuilder;
        ItemViewText: Text;
        Index: Integer;
    begin
        // P8004516
        FilterPage.PageCaption := StrSubstNo(Text003, Item.TableCaption);
        FilterPage.AddTable(Item.TableCaption, DATABASE::Item);
        FilterPage.AddFieldNo(Item.TableCaption, 1); // No. is field 1

        ItemViewText := GetItemViewText;
        if ItemViewText <> '' then
            FilterPage.SetView(Item.TableCaption, ItemViewText);
        if FilterPage.RunModal then begin
            ItemViewText := FilterPage.GetView(Item.TableCaption);
            Index := StrPos(ItemViewText, 'SORTING(No.)');
            if Index = 1 then
                ItemViewText := DelChr(CopyStr(ItemViewText, 13), '<');
            SetItemViewText(ItemViewText);
            Modify;
        end;
    end;

    procedure ShowItemView()
    var
        Item: Record Item;
    begin
        // P8000312A
        if not LoadItemView(Item) then
            Error(Text002, FieldCaption("Item View"));
        PAGE.RunModal(0, Item);
    end;
}

