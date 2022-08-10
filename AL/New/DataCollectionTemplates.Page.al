page 37002872 "Data Collection Templates"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001149, Columbus IT, Don Bresee, 26 APR 13
    //   Change calling of page to use lookup mode
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Data Collection Templates';
    PageType = List;
    SourceTable = "Data Collection Template";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field(AssignedToItemCategory; AssignedToItemCategory)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Assigned To Item Category';
                    DrillDown = false;
                    Visible = ShowCategory;
                }
            }
        }
        area(factboxes)
        {
            part(Control37002010; "Data Collection Temp. Line FB")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Template Code" = FIELD(Code);
            }
            systempart(Control37002007; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002006; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Lines)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                Image = AllLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TemplateLine: Record "Data Collection Template Line";
                    TemplateLines: Page "Data Collection Template Lines";
                begin
                    TestField(Type);

                    TemplateLine.FilterGroup(9);
                    TemplateLine.SetRange("Template Code", Code);
                    TemplateLine.FilterGroup(0);

                    TemplateLines.SetTableView(TemplateLine);
                    TemplateLines.Run;
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // IF CloseAction = ACTION::OK THEN    // P8001149
        if CloseAction = ACTION::LookupOK then // P8001149
            CurrPage.SetSelectionFilter(SelectedTemplate);

        exit(true);
    end;

    var
        SelectedTemplate: Record "Data Collection Template";
        Item: Record Item;
        [InDataSet]
        ShowCategory: Boolean;

    procedure GetSelectedTemplates(var DataCollectionTemplate: Record "Data Collection Template")
    begin
        DataCollectionTemplate.Copy(SelectedTemplate);
    end;

    procedure SetItem(ItemNo: Code[20])
    begin
        Item.Get(ItemNo);
        SetRange("Item Category Filter", Item."Item Category Code");
        ShowCategory := Item."Item Category Code" <> '';
    end;
}

