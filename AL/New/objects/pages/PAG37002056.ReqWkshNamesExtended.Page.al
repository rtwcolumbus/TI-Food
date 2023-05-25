page 37002056 "Req. Wksh. Names-Extended"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 17 MAR 06
    //   Copied from Page 295 (Req. Wksh. Name) and additional columns added
    // 
    // PRW16.00.02
    // P8000791, VerticalSoft, MMAS, 18 MAR 10
    //   Page had been changed after transformation.
    //     ItemView added into the Group.
    // 
    // PRW16.00.03
    // P8000802, VerticalSoft, Jack Reynolds, 25 MAR 10
    //   Standard mods for running worksheet
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Req. Wksh. Names';
    DataCaptionExpression = DataCaption;
    PageType = List;
    SourceTable = "Requisition Wksh. Name";

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Lines; Lines)
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Last Date"; "Last Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Frequency; Frequency)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Next Date"; "Next Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Days View"; "Days View")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Show All Items"; "Show All Items")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Control37002000)
            {
                ShowCaption = false;
                field(ItemView; ItemView)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item View';
                    Editable = false;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Worksheet")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Edit Worksheet';
                Image = Edit;
                ShortCutKey = 'Return';

                trigger OnAction()
                begin
                    ReqJnlManagement.TemplateSelectionFromBatch(Rec); // P8000802
                end;
            }
        }
        area(navigation)
        {
            group(bnItemView)
            {
                Caption = 'Item &View';
                Visible = bnItemViewVisible;
                action("&Define")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Define';
                    Ellipsis = true;
                    Image = CreateForm;

                    trigger OnAction()
                    begin
                        DefineItemView;
                    end;
                }
                action("&Clear")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Clear';
                    Ellipsis = true;
                    Image = Delete;

                    trigger OnAction()
                    begin
                        ClearItemView;
                    end;
                }
                separator(Separator1102603013)
                {
                }
                action("&Show Items")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Show Items';
                    Ellipsis = true;
                    Image = Item;

                    trigger OnAction()
                    begin
                        ShowItemView;
                    end;
                }
            }
        }
        area(Promoted)
        {
                actionref(EditWorksheet_Promoted; "Edit Worksheet")
                {
                }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        SetItemView;
    end;

    trigger OnInit()
    begin
        bnItemViewVisible := true;
    end;

    trigger OnOpenPage()
    begin
        ReqJnlManagement.OpenJnlBatch(Rec); // P8000802
        bnItemViewVisible := not CurrPage.LookupMode;
    end;

    var
        ReqJnlManagement: Codeunit ReqJnlManagement;
        ItemView: Text[1024];
        [InDataSet]
        bnItemViewVisible: Boolean;

    local procedure DataCaption(): Text[250]
    var
        ReqWkshTmpl: Record "Req. Wksh. Template";
    begin
        if not CurrPage.LookupMode then
            if GetFilter("Worksheet Template Name") <> '' then
                if GetRangeMin("Worksheet Template Name") = GetRangeMax("Worksheet Template Name") then
                    if ReqWkshTmpl.Get(GetRangeMin("Worksheet Template Name")) then
                        exit(ReqWkshTmpl.Name + ' ' + ReqWkshTmpl.Description);
    end;

    local procedure SetItemView()
    var
        Item: Record Item;
    begin
        xRec := Rec;
        LoadItemView(Item);
        ItemView := Item.GetFilters;
    end;
}

