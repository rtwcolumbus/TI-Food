page 37002541 "Item Tests"
{
    // PR1.10, Navision US, John Nozzi, 23 MAR 01, New Object
    //   This form is so the user can attach Quality Control Tests to each Item. It should only be
    //   called from the Item Card or Item List.
    // 
    // PR1.10.01
    //   Add controls for Certificate of Analysis and Comment
    //   Add controls for Alpha and Boolean Target
    // 
    // PR1.10.02
    //   Add controls for Must Pass
    // 
    // PR3.70.02
    //   Add controls for Variant Type
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Rearrange controls and add control for Lookup Target Value
    // 
    // PRW16.00.20
    // P8000685, VerticalSoft, Jack Reynolds, 10 APR 09
    //   Add Item No. as DataCaptionFields
    // 
    // P8000664, VerticalSoft, Jack Reynolds, 10 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001079, Columbus IT, Jack Reynolds, 15 JUN 12
    //   Support for Reaon Code on re-test
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.10.02
    // P8001281, Columbus IT, Jack Reynolds, 06 FEB 14
    //   Fix problem adding new comments
    // 
    // PRW19.00.01
    // P8006432, To-Increase, Dayakar Battini, 05 JUL 16
    //   Fix issues with Editable properties.
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method
    // 
    // P80038815, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Certificate of Analysis changes
    //
    // PRW119.03
    // P800139946, To-Increase, Gangabhushan, 24 FEB 22
    //   Copy QC test-templates to Item Quality Tests      
    //
    // P800145410, Gangabhushan, To-Increase, 01 JUN 22
    //   Error "Code must be filled in. Enter a value." on adding Q/C Template to Item Quality Test   

    Caption = 'Item Quality Tests';
    DataCaptionFields = "Source Key 1";
    DelayedInsert = true; // P800145410
    PageType = List;
    SourceTable = "Data Collection Line";
    SaveValues = true;
    SourceTableView = WHERE("Source ID" = CONST(27),
                            Type = CONST("Q/C"));

    layout
    {
        area(content)
        {
            field(BlnDisplaySorting; BlnDisplaySorting)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Variant Type"; Rec."Variant Type")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Source Template Code"; Rec.GetTemplateCodeForDisplay())
                {
                    ApplicationArea = FOODBasic;
                    HideValue = HideTemplate;
                    Style = Strong;
                    Visible = BlnDisplaySorting;
                }
                field("Source Template Description"; Rec.GetTemplateDesc())
                {
                    ApplicationArea = FOODBasic;
                    HideValue = HideTemplate;
                    Style = Strong;
                    Visible = BlnDisplaySorting;
                }
                field("Data Element Code"; Rec."Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Code';

                    trigger OnValidate()
                    begin
                        SetEditable;    // P8006432
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Data Element Type"; Rec."Data Element Type")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Type';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Boolean Target Value"; Rec."Boolean Target Value")
                {
                    ApplicationArea = FOODBasic;
                    Editable = booleanvalue;
                }
                field("Lookup Target Value"; Rec."Lookup Target Value")
                {
                    ApplicationArea = FOODBasic;
                    Editable = lookupvalue;
                }
                field("Numeric High-High Value"; Rec."Numeric High-High Value")
                {
                    ApplicationArea = FOODBasic;
                    Editable = numericvalue;
                    HideValue = notnumericvalue;
                }
                field("Numeric High Value"; Rec."Numeric High Value")
                {
                    ApplicationArea = FOODBasic;
                    Editable = numericvalue;
                    HideValue = notnumericvalue;
                }
                field("Numeric Target Value"; Rec."Numeric Target Value")
                {
                    ApplicationArea = FOODBasic;
                    Editable = numericvalue;
                    HideValue = notnumericvalue;
                }
                field("Numeric Low Value"; Rec."Numeric Low Value")
                {
                    ApplicationArea = FOODBasic;
                    Editable = numericvalue;
                    HideValue = notnumericvalue;
                }
                field("Numeric Low-Low Value"; Rec."Numeric Low-Low Value")
                {
                    ApplicationArea = FOODBasic;
                    Editable = numericvalue;
                    HideValue = notnumericvalue;
                }
                field("Text Target Value"; Rec."Text Target Value")
                {
                    ApplicationArea = FOODBasic;
                    Editable = textvalue;
                }
                field("Must Pass"; Rec."Must Pass")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Re-Test Requires Reason Code"; Rec."Re-Test Requires Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Certificate of Analysis"; Rec."Certificate of Analysis")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Threshold on COA"; Rec."Threshold on COA")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Measuring Method"; Rec."Measuring Method")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
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
        area(navigation)
        {
            group("&Test")
            {
                Caption = '&Test';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Data Collection Comments";
                    RunPageLink = "Source ID" = CONST(27),
                                  "Source Key 1" = FIELD("Source Key 1"),
                                  "Variant Type" = FIELD("Variant Type"),
                                  "Data Element Code" = FIELD("Data Element Code"),
                                  "Data Collection Line No." = FIELD("Line No.");
                }
            }
            action(SelcectTemplate)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Select Template';
                Ellipsis = true;
                Image = SelectEntries;

                trigger OnAction()
                var
                    DataCollectionTemplate: Record "Data Collection Template";
                    DataCollectionTemplates: Page "Data Collection Templates";
                    DataCollectionManagement: Codeunit "Data Collection Management";
                begin
                    // P800139946
                    DataCollectionTemplate.FILTERGROUP(9);
                    DataCollectionTemplate.SetRange(Type, DataCollectionTemplate.Type::"Q/C");
                    DataCollectionTemplates.SetTableView(DataCollectionTemplate);
                    DataCollectionTemplates.SetItem("Source Key 1");
                    DataCollectionTemplates.LookupMode(true);
                    if DataCollectionTemplates.RunModal() = Action::LookupOK then begin
                        DataCollectionTemplates.GetSelectedTemplates(DataCollectionTemplate);
                        if DataCollectionTemplate.FindSet() then begin
                            repeat
                                DataCollectionManagement.CopyTemplateToLines(DataCollectionTemplate, "Source ID", "Source Key 1", "Source Key 2");
                            until DataCollectionTemplate.NEXT = 0;
                            CurrPage.Update(false);
                        end;
                    end;
                end;
            }
            action(ToggleTest)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Sort on Test';
                Image = SortAscending;
                Visible = BlnDisplaySorting;
                trigger OnAction()
                begin
                    // P800139946
                    BlnDisplaySorting := not BlnDisplaySorting;
                end;

            }
            action(ToggleTemplate)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Sort on Template';
                Image = SortAscending;
                Visible = not BlnDisplaySorting;
                trigger OnAction()
                begin
                    // P800139946
                    BlnDisplaySorting := not BlnDisplaySorting;
                end;
            }
        }
        area(Promoted)
        {
            actionref(ToggleTest_Promoted; ToggleTest)
            {
            }
            actionref(ToggleTemplate_Promoted; ToggleTemplate)
            {
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        // P800139946
        if BlnDisplaySorting then
            Rec.SetCurrentKey("Source Template Code")
        else
            Rec.SetCurrentKey("Source ID", "Source Key 1", "Source Key 2", Type, "Variant Type", "Data Element Code", "Line No.");
        exit(Rec.Find(Which));
        // P800139946
    end;

    trigger OnAfterGetRecord()
    begin
        // P800139946
        HideTemplate := false;
        if not Rec.IsFirstTemplate then
            HideTemplate := true;
        // P800139946
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetEditable;    // P8006432
    end;

    var
        [InDataSet]
        BooleanValue: Boolean;
        [InDataSet]
        LookupValue: Boolean;
        [InDataSet]
        NumericValue: Boolean;
        [InDataSet]
        NotNumericValue: Boolean;
        [InDataSet]
        TextValue: Boolean;
        BlnDisplaySorting: Boolean;
        HideTemplate: Boolean;

    local procedure SetEditable()
    begin
        // P8006432
        BooleanValue := Rec."Data Element Type" = Rec."Data Element Type"::Boolean; // P8001090
        LookupValue := Rec."Data Element Type" = Rec."Data Element Type"::"Lookup";   // P8001090
        NumericValue := Rec."Data Element Type" = Rec."Data Element Type"::Numeric; // P8001090
        TextValue := Rec."Data Element Type" = Rec."Data Element Type"::Text;       // P8001090
        NotNumericValue := not NumericValue;
        // P8006432
    end;
}

