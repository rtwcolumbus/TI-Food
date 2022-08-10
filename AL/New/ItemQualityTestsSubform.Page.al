page 37002546 "Item Quality Tests Subform"
{
    // PR1.10.01
    //   Add controls for Certificate of Analysis and Comment
    //   Add controls for Alpha and Boolean Target Values
    //   Add function to display comments
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
    // P8000664, VerticalSoft, Jack Reynolds, 13 APR 09
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
    // PRW110.0.02
    // P80047926, To-Increase, Dayakar Battini, 31 OCT 17
    //   Fixing Item Q/C comments
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
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples
    // 
    // P800144674, To-Increase, Gangabhushan, 01 JUN 22
    //   Q/C templates can be added to Items without Item Tracking Code

    Caption = 'Item Quality Tests';
    PageType = ListPart;
    SourceTable = "Data Collection Line";
    SourceTableView = WHERE("Source ID" = CONST(27),
                            Type = CONST("Q/C"));

    layout
    {
        area(content)
        {
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
                    Visible = SortByTemplate;
                }
                field("Source Template Description"; Rec.GetTemplateDesc())
                {
                    ApplicationArea = FOODBasic;
                    HideValue = HideTemplate;
                    Style = Strong;
                    Visible = SortByTemplate;
                }
                field("Data Element Code"; Rec."Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Code';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Rec."Data Element Type")
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
                // P800122712
                field("Sample Quantity"; Rec."Sample Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Visible = SampleFieldVisible;
                }
                field("Sample Unit of Measure Code"; Rec."Sample Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = SampleFieldVisible;
                }
                field("Combine Samples"; Rec."Combine Samples")
                {
                    ApplicationArea = FOODBasic;
                    Visible = SampleFieldVisible;
                }
                // P800122712
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Test")
            {
                Caption = '&Test';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Data Collection Comments";
                    RunPageLink = "Source ID" = FIELD("Source ID"),
                                  "Source Key 1" = FIELD("Source Key 1"),
                                  "Source Key 2" = FIELD("Source Key 2"),
                                  Type = FIELD(Type),
                                  "Variant Type" = FIELD("Variant Type"),
                                  "Data Element Code" = FIELD("Data Element Code"),
                                  "Data Collection Line No." = FIELD("Line No.");
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
                        Item: Record Item;
                        DataCollectionTemplates: Page "Data Collection Templates";
                        DataCollectionManagement: Codeunit "Data Collection Management";
                    begin
                        // P800139946
                        // P800144674
                        Item.Get(Rec."Source Key 1");
                        if not Item.CheckQualityAllowed(Item."No.") then
                            Error(QCTemplateError, Rec."Source Key 1");
                        // P800144674                        
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
            }
        }
    }

    trigger OnOpenPage()
    begin
        SampleFieldVisible := Rec.SamplesEnabled(); // P800122712
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        // P800139946
        if SortByTemplate then
            Rec.SetCurrentKey("Source Template Code")
        else
            Rec.SetCurrentKey("Source ID", "Source Key 1", "Source Key 2", Type, "Variant Type", "Data Element Code", "Line No.");
        exit(Rec.Find(Which));
        // P800139946
    end;

    trigger OnAfterGetRecord()
    begin
        BooleanValue := "Data Element Type" = "Data Element Type"::Boolean; // P8001090
        LookupValue := "Data Element Type" = "Data Element Type"::"Lookup";   // P8001090
        NumericValue := "Data Element Type" = "Data Element Type"::Numeric; // P8001090
        TextValue := "Data Element Type" = "Data Element Type"::Text;       // P8001090
        NotNumericValue := not NumericValue;
        // P800139946
        HideTemplate := false;
        if not Rec.IsFirstTemplate() then
            HideTemplate := true;
        // P800139946
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
        SortByTemplate: Boolean;
        HideTemplate: Boolean;
        SampleFieldVisible: Boolean; // P800122712
        QCTemplateError: Label 'Item %1 should be Lot tracked'; // P800144674

    procedure SetSortingPrefference(NewSortByTemplate: Boolean; UpdateRequired: Boolean)
    begin
        // P800139946
        SortByTemplate := NewSortByTemplate;
    end;
}

