page 99000811 "Prod. BOM Where-Used"
{
    // PR1.00
    //   Set CAPTION property based on Production BOM type
    //   Add support for unapproved items
    // 
    // PR2.00
    //   Text Constants
    // 
    // PR2.00.05
    //   Add support for variables
    //   Add field for variant code
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU

    Caption = 'Prod. BOM Where-Used';
    DataCaptionExpression = SetCaption();
    PageType = Worksheet;
    SourceTable = "Where-Used Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(LocationCode; LocationCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location';
                    Enabled = NOT LocationDisabled;
                    TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

                    trigger OnValidate()
                    begin
                        // P8001030
                        BuildForm;
                        CurrPage.Update(false);
                    end;
                }
                field(CalculateDate; CalculateDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Calculation Date';
                    ToolTip = 'Specifies the date for which you want to show the where-used lines.';

                    trigger OnValidate()
                    begin
                        CalculateDateOnAfterValidate();
                    end;
                }
                field(ShowLevel; ShowLevel)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Levels';
                    OptionCaption = 'Single,Multi';
                    ToolTip = 'Specifies the level of detail for the where-used lines.';

                    trigger OnValidate()
                    begin
                        ShowLevelOnAfterValidate();
                    end;
                }
            }
            repeater(Control1)
            {
                Editable = false;
                IndentationColumn = DescriptionIndent;
                IndentationControls = Description;
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the item that the base item or production BOM is assigned to.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Version Code"; Rec."Version Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the version code of the production BOM that the item or production BOM component is assigned to.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the description of the item to which the item or production BOM component is assigned.';
                }
                field("Quantity Needed"; Rec."Quantity Needed")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the quantity of the item or the production BOM component that is needed for the assigned item.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        DescriptionIndent := 0;
        DescriptionOnFormat();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(WhereUsedMgt.FindRecord(Which, Rec));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(WhereUsedMgt.NextRecord(Steps, Rec));
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Caption(StrSubstNo(Text37002000, Format(Type))); // PR1.20
        BuildForm();
    end;

    var
        Item: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        WhereUsedMgt: Codeunit "Where-Used Management";
        CalculateDate: Date;
        UnapprItem: Record "Unapproved Item";
        Type: Text[10];
        PkgVariable: Record "Package Variable";
        Text37002000: Label 'Prod. %1 Where-Used';
        SKU: Record "Stockkeeping Unit";
        [InDataSet]
        DescriptionIndent: Integer;
        LocationCode: Code[10];
        [InDataSet]
        LocationDisabled: Boolean;

    protected var
        ShowLevel: Option Single,Multi;

    procedure SetProdBOM(NewProdBOMHeader: Record "Production BOM Header"; NewCalcDate: Date)
    begin
        ProdBOMHeader := NewProdBOMHeader;
        CalculateDate := NewCalcDate;
    end;

    procedure SetItem(NewItem: Record Item; NewCalcDate: Date)
    begin
        Item := NewItem;
        CalculateDate := NewCalcDate;
    end;

    procedure BuildForm()
    begin
        OnBeforeBuildForm(WhereUsedMgt, ShowLevel);
        if ProdBOMHeader."No." <> '' then
            WhereUsedMgt.WhereUsedFromProdBOM(ProdBOMHeader, LocationCode, CalculateDate, ShowLevel = ShowLevel::Multi)
        else
	    if Item."No." <> '' then // PR1.00
                WhereUsedMgt.WhereUsedFromItem(Item, LocationCode, CalculateDate, ShowLevel = ShowLevel::Multi) // P8001030
            else
                if UnapprItem."No." <> '' then // PR1.00, PR2.00.05
                    WhereUsedMgt.WhereUsedFromUnapprItem(UnapprItem, LocationCode, CalculateDate, ShowLevel = ShowLevel::Multi) // PR1.00, P8001030
                                                                                                                                // P8001030
                else
                    if SKU."Item No." <> '' then
                        WhereUsedMgt.WhereUsedFromSKU(SKU, CalculateDate, ShowLevel = ShowLevel::Multi)
                    // P8001030
                    else // PR2.00.05
                        WhereUsedMgt.WhereUsedFromVariable(PkgVariable, LocationCode, CalculateDate, ShowLevel = ShowLevel::Multi); // PR2.00.05, P8001030	
        OnAfterBuildForm(WhereUsedMgt, ShowLevel, Item, ProdBOMHeader, CalculateDate);
    end;

    procedure SetCaption(): Text
    var
        IsHandled: Boolean;
        Result: Text;
    begin
        IsHandled := false;
        OnBeforeSetCaption(Item, ProdBOMHeader, Result, IsHandled);
        If IsHandled then
            exit(Result);

        if ProdBOMHeader."No." <> '' then
            exit(ProdBOMHeader."No." + ' ' + ProdBOMHeader.Description)
        else
            if Item."No." <> '' then // PR1.00
                exit(Item."No." + ' ' + Item.Description)
            else
                if UnapprItem."No." <> '' then // PR1.00, PR2.00.05
                    exit(UnapprItem."No." + ' ' + UnapprItem.Description) // PR1.00
                                                                          // P8001030
                else
                    if SKU."Item No." <> '' then
                        exit(SKU."Item No." + ' ' + SKU."Location Code" + ' ' + SKU."Variant Code")
                    // P8001030
                    else // PR2.00.05
                        exit(PkgVariable.Code + ' ' + PkgVariable.Description); // PR2.00.05
    end;

    local procedure CalculateDateOnAfterValidate()
    begin
        BuildForm();
        CurrPage.Update(false);
    end;

    local procedure ShowLevelOnAfterValidate()
    begin
        BuildForm();
        CurrPage.Update(false);
    end;

    local procedure DescriptionOnFormat()
    begin
        DescriptionIndent := "Level Code" - 1;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildForm(var WhereUsedManagement: Codeunit "Where-Used Management"; ShowLevel: Option; Item: Record Item; ProductionBOMHeader: Record "Production BOM Header"; CalculateDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBuildForm(var WhereUsedManagement: Codeunit "Where-Used Management"; ShowLevel: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetCaption(Item: Record Item; ProdBOM: Record "Production BOM Header"; var Result: Text; var IsHandled: Boolean)
    begin
    end;
    
    procedure SetUnapprItem(NewItem: Record "Unapproved Item"; NewCalcDate: Date)
    begin
        // PR1.00 Begin
        UnapprItem := NewItem;
        CalculateDate := NewCalcDate;
        // PR1.00 End
    end;

    procedure SetType(text: Text[10])
    begin
        Type := text; // PR1.00
    end;

    procedure SetVariable(NewVariable: Record "Package Variable"; NewCalcDate: Date)
    begin
        // PR2.00.05 Begin
        PkgVariable := NewVariable;
        CalculateDate := NewCalcDate;
        // PR2.00.05 End
    end;

    procedure SetSKU(NewSKU: Record "Stockkeeping Unit"; NewCalcDate: Date)
    begin
        // P8001030
        SKU := NewSKU;
        LocationCode := SKU."Location Code";
        CalculateDate := NewCalcDate;
        LocationDisabled := true;
    end;    
}

