page 37002543 "Quality Control Results Sub."
{
    // PR1.10, Navision US, John Nozzi, 28 MAR 01, New Object
    //   This form is used enter the results of Quality Control Tests. No insert or delete allowed, just the
    //   entry of results fields. Same as Form #14015001, except formatted as a sub-form.
    // 
    // PR1.10.01
    //   Add controls for Result and Comment
    //   Add function for displaying test comments
    // 
    // PR1.10.02
    //   Add controls for Must Pass
    // 
    // PR2.00.03
    //   Make comments non-editable when displaying
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Rearrange controls and add controls for lookup result, date result, and lookup target value
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
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method
    // 
    // P80038815, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Certificate of Analysis changes
    // 
    // P80037659, To-Increase, Jack Reynolds, 25 JUL 18
    //   QC-Additions: Develop average measurement
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Quality Control Results';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Quality Control Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Test Code"; "Test Code")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                }
                field(Result; Result)
                {
                    ApplicationArea = FOODBasic;
                    Editable = AllowEdits;
                    StyleExpr = LineStyle;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        LotSpecFns: Codeunit "Lot Specification Functions";
                    begin
                        // P8000152A Begin
                        if Type <> Type::"Lookup" then
                            exit(false);
                        exit(LotSpecFns.LotSpecLookup("Test Code", Text));
                        // P8000152A End
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true); // P8000664
                    end;
                }
                field("Boolean Result"; "Boolean Result")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Date Result"; "Date Result")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Lookup Result"; "Lookup Result")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Numeric Result"; "Numeric Result")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = notnumericvalue;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Text Result"; "Text Result")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Test Date"; "Test Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = AllowEdits;
                    StyleExpr = LineStyle;
                }
                field("Test Time"; "Test Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = AllowEdits;
                    StyleExpr = LineStyle;
                }
                field("Tested By"; "Tested By")
                {
                    ApplicationArea = FOODBasic;
                    Editable = AllowEdits;
                    StyleExpr = LineStyle;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Editable = AllowEdits;
                    OptionCaption = 'Not Tested,Pass,Fail,,Suspended';
                    StyleExpr = LineStyle;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true); // P8000664
                    end;
                }
                field("Must Pass"; "Must Pass")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Boolean Target Value"; "Boolean Target Value")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Lookup Target Value"; "Lookup Target Value")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Numeric Low Value"; "Numeric Low Value")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = notnumericvalue;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Numeric Target Value"; "Numeric Target Value")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = notnumericvalue;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Numeric High Value"; "Numeric High Value")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = notnumericvalue;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Text Target Value"; "Text Target Value")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                }
                field("Measuring Method"; "Measuring Method")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
                }
                field("Threshold on COA"; "Threshold on COA")
                {
                    ApplicationArea = FOODBasic;
                    StyleExpr = LineStyle;
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
            group("&Line")
            {
                Caption = '&Line';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = ViewComments;

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002542. Unsupported part was commented. Please check it.
                        /*CurrPage.Tests.PAGE.*/
                        ShowComments; // PR1.10.01

                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        NotNumericValue := Type <> Type::Numeric; // P8000664
        LineStyle := SetLineStyle; // P80037659
    end;

    trigger OnOpenPage()
    begin
        SampleFieldVisible := Rec.SamplesEnabled(); // P800122712
    end;

    var
        [InDataSet]
        NotNumericValue: Boolean;
        [InDataSet]
        AllowEdits: Boolean;
        [InDataSet]
        LineStyle: Text;
        SampleFieldVisible: Boolean; // P800122712

    procedure ShowComments()
    var
        DataCollectionComment: Record "Data Collection Comment";
        DataCollectionComments: Page "Data Collection Comments";
    begin
        // P8001090 - changed for Data Collection
        DataCollectionComment.SetRange("Source ID", DATABASE::Item);
        DataCollectionComment.SetRange("Source Key 1", "Item No.");
        DataCollectionComment.SetRange(Type, DataCollectionComment.Type::"Q/C");
        DataCollectionComment.SetRange("Data Element Code", "Test Code");
        DataCollectionComment.SetRange("Data Collection Line No.", "Line No.");

        DataCollectionComments.SetTableView(DataCollectionComment);
        DataCollectionComments.Editable(false);
        DataCollectionComments.Run;
    end;

    procedure SetAllowEdits(Editable: Boolean)
    begin
        AllowEdits := Editable; // P8000664
    end;

    local procedure SetLineStyle(): Text
    begin
        // P80037659
        if Status = Status::Fail then
            exit('Attention');
    end;
}

