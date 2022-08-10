page 37002951 "Item Q/C Skip Logic Lines"
{
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Item Q/C Skip Logic Lines';
    DelayedInsert = true;
    PageType = List;
    SaveValues = true;
    ShowFilter = false;
    SourceTable = "Item Quality Skip Logic Line";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Visible = NOT IsOnMobile;
                field(ItemNoFilterCtrl; ItemNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item No. Filter';
                    ToolTip = 'Specifies a filter for which sales prices to display.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                    begin
                        ItemList.LookupMode := true;
                        if ItemList.RunModal = ACTION::LookupOK then
                            Text := ItemList.GetSelectionFilter
                        else
                            exit(false);

                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        ItemNoFilterOnAfterValidate;
                    end;
                }
            }
            group(Filters)
            {
                Caption = 'Filters';
                Visible = IsOnMobile;
                field(GetFilterDescription; GetFilterDescription)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies a filter for which sales prices to display.';

                    trigger OnAssistEdit()
                    begin
                        FilterLines;
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specifies the number of the item for which the sales price is valid.';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specifies the variant code for the item.';
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Value Class"; "Value Class")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Activity Class"; "Activity Class")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Control1100472001; "Skip Logic Setup")
            {
                ApplicationArea = FOODBasic;
                Editable = false;
                SubPageLink = "Value Class" = FIELD("Value Class"),
                              "Activity Class" = FIELD("Activity Class");
            }
        }
        area(factboxes)
        {
            part(Control1100472006; "Item Q/C SkipLogic Tr. Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code"),
                              "Source Type" = FIELD("Source Type"),
                              "Source No." = FIELD("Source No."),
                              "Value Class" = FIELD("Value Class"),
                              "Activity Class" = FIELD("Activity Class");
                SubPageView = SORTING("Item No.", "Variant Code", "Source Type", "Source No.", "Value Class", "Activity Class", "Line No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Filter")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Filter';
                Image = "Filter";
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Apply filter.';
                Visible = IsOnMobile;

                trigger OnAction()
                begin
                    FilterLines;
                end;
            }
            action(ClearFilter)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Filter';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Clear filter.';
                Visible = IsOnMobile;

                trigger OnAction()
                begin
                    Reset;
                    UpdateBasicRecFilters;
                end;
            }
        }
        area(navigation)
        {
            group("&Quality Control")
            {
                Caption = '&Quality Control';
                Image = Lot;
                action("&Open Quality Control Activities")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Open Quality Control Activities';
                    Image = OpenWorksheet;
                    RunObject = Page "Open Q/C Activity List";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code");
                }
                action("&Completed Quality Control Activities")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Completed Quality Control Activities';
                    Image = Completed;
                    RunObject = Page "Completed Q/C Activity List";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code");
                }
                action("T&ransactions")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'T&ransactions';
                    Image = History;
                    RunObject = Page "Item Q/C SkipLogic Transaction";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Source Type" = FIELD("Source Type"),
                                  "Source No." = FIELD("Source No.");
                    RunPageView = SORTING("Item No.", "Variant Code", "Source Type", "Source No.", "Value Class", "Activity Class", "Line No.");
                }
            }
        }
    }

    trigger OnInit()
    begin
        IsLookupMode := CurrPage.LookupMode;
    end;

    trigger OnOpenPage()
    begin
        IsOnMobile := CurrentClientType = CLIENTTYPE::Phone;
        GetRecFilters;
        SetRecFilters;
    end;

    var
        ItemNoFilter: Text;
        Text001: Label 'No %1 within the filter %2.';
        IsOnMobile: Boolean;
        IsLookupMode: Boolean;

    local procedure GetRecFilters()
    begin
        if GetFilters <> '' then
            UpdateBasicRecFilters;
    end;

    local procedure UpdateBasicRecFilters()
    begin
        ItemNoFilter := GetFilter("Item No."); // PR3.60, P8007748
    end;

    procedure SetRecFilters()
    begin
        if ItemNoFilter <> '' then begin
            SetFilter("Item No.", ItemNoFilter); // PR3.60
        end else
            SetRange("Item No."); // PR3.60

        CheckFilters(DATABASE::Item, ItemNoFilter);

        CurrPage.Update(false);
    end;

    local procedure GetFilterDescription(): Text
    var
        ObjTranslation: Record "Object Translation";
        SourceTableName: Text;
        SalesSrcTableName: Text;
        Description: Text;
    begin
        GetRecFilters;

        SourceTableName := '';
        if ItemNoFilter <> '' then
            SourceTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, 27);

        SalesSrcTableName := '';
        exit(StrSubstNo('%1 %2 %3 %4 %5', ItemNoFilter));
    end;

    local procedure CheckFilters(TableNo: Integer; FilterTxt: Text)
    var
        FilterRecordRef: RecordRef;
        FilterFieldRef: FieldRef;
    begin
        if FilterTxt = '' then
            exit;
        Clear(FilterRecordRef);
        Clear(FilterFieldRef);
        FilterRecordRef.Open(TableNo);
        FilterFieldRef := FilterRecordRef.Field(1);
        FilterFieldRef.SetFilter(FilterTxt);
        if FilterRecordRef.IsEmpty then
            Error(Text001, FilterRecordRef.Caption, FilterTxt);
    end;

    local procedure ItemNoFilterOnAfterValidate()
    begin
        CurrPage.SaveRecord;
        SetRecFilters;
    end;

    local procedure FilterLines()
    var
        FilterPageBuilder: FilterPageBuilder;
    begin
        FilterPageBuilder.AddTable(TableCaption, DATABASE::"Item Quality Skip Logic Line");

        FilterPageBuilder.SetView(TableCaption, GetView);
        if GetFilter("Item No.") = '' then
            FilterPageBuilder.AddFieldNo(TableCaption, FieldNo("Item No."));

        if FilterPageBuilder.RunModal then
            SetView(FilterPageBuilder.GetView(TableCaption));

        UpdateBasicRecFilters;
    end;

    procedure GetSelectionFilter(var ItemQualitySkipLogicTempl: Record "Item Quality Skip Logic Line")
    begin
        CurrPage.SetSelectionFilter(ItemQualitySkipLogicTempl);
    end;
}

