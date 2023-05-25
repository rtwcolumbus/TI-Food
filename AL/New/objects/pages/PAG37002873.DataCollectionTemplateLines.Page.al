page 37002873 "Data Collection Template Lines"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Data Collection Template Lines';
    DataCaptionFields = "Template Code";
    PageType = Worksheet;
    SourceTable = "Data Collection Template Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Variant Type"; "Variant Type")
                {
                    ApplicationArea = FOODBasic;
                    Visible = Quality;
                }
                field("Data Element Code"; "Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Data Element Type"; "Data Element Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Critical; Critical)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                }
                // P800122712
                field("Sample Quantity"; Rec."Sample Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Visible = SampleFieldVisible;
                }
                field("Unit of Measure Code"; Rec."Sample Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sample Unit of Measure Code';
                    Visible = SampleFieldVisible;
                }
                field("Combine Samples"; Rec."Combine Samples")
                {
                    ApplicationArea = FOODBasic;
                    Visible = SampleFieldVisible;
                }
                // P800122712
            }
            group("Target Values")
            {
                Caption = 'Target Values';
                field("Boolean Target Value"; "Boolean Target Value")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Boolean';
                    Editable = AllowBoolean;
                }
                field("Lookup Target Value"; "Lookup Target Value")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lookup';
                    Editable = AllowLookup;
                }
                field("Text Target Value"; "Text Target Value")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Text';
                    Editable = AllowText;
                }
                group(Control37002011)
                {
                    ShowCaption = false;
                    field("Numeric High-High Value"; "Numeric High-High Value")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Numeric High-High';
                        Editable = AllowNumeric;
                    }
                    field("Numeric High Value"; "Numeric High Value")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Numeric High';
                        Editable = AllowNumeric;
                    }
                    field("Numeric Target Value"; "Numeric Target Value")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Numeric Target';
                        Editable = AllowNumeric;
                    }
                    field("Numeric Low Value"; "Numeric Low Value")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Numeric Low';
                        Editable = AllowNumeric;
                    }
                    field("Numeric Low-Low Value"; "Numeric Low-Low Value")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Numeric Low-Low';
                        Editable = AllowNumeric;
                    }
                }
            }
            group(Recurrence)
            {
                Caption = 'Recurrence';
                Visible = Production OR Log;
                field("Order or Line"; "Order or Line")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Production;
                    HideValue = NOT Production;
                }
                field(Control37002031; Recurrence)
                {
                    ApplicationArea = FOODBasic;
                    ShowCaption = false;

                    trigger OnValidate()
                    begin
                        Scheduled := Recurrence = Recurrence::Scheduled;
                        CurrPage.Update(true);
                    end;
                }
                field(Frequency; Frequency)
                {
                    ApplicationArea = FOODBasic;
                    Editable = Scheduled;
                    HideValue = NOT Scheduled;
                }
                field("Scheduled Type"; "Scheduled Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Scheduled;
                    HideValue = NOT Scheduled;
                }
                field("Schedule Base"; "Schedule Base")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Scheduled;
                    HideValue = NOT Scheduled;
                }
            }
            group(Alerts)
            {
                Caption = 'Alerts';
                field("Level 1 Alert Group"; "Level 1 Alert Group")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Level 1';
                    Editable = AllowNumeric;
                }
                field("Level 2 Alert Group"; "Level 2 Alert Group")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Level 2';
                    Editable = AllowBoolean OR AllowLookup OR AllowNumeric OR AllowText;
                }
                field("Missed Collection Alert Group"; "Missed Collection Alert Group")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Missed Collection';
                    Editable = Scheduled;
                    HideValue = NOT Scheduled;
                }
                field("Grace Period"; "Grace Period")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Scheduled;
                    HideValue = NOT Scheduled;
                }
            }
            group(Quality)
            {
                Caption = 'Quality';
                Visible = Quality;
                field("Certificate of Analysis"; "Certificate of Analysis")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Must Pass"; "Must Pass")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Re-Test Requires Reason Code"; "Re-Test Requires Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Log)
            {
                Caption = 'Log';
                Visible = Log;
                field("Log Group Code"; "Log Group Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Group Code';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002008; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002009; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Co&mments")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Co&mments';
                Image = Comment;
                RunObject = Page "Data Collection Comments";
                RunPageLink = "Source ID" = CONST(0),
                              "Source Key 1" = FIELD("Template Code"),
                              "Variant Type" = FIELD("Variant Type"),
                              "Data Element Code" = FIELD("Data Element Code");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        AllowBoolean := "Data Element Type" = "Data Element Type"::Boolean;
        AllowLookup := "Data Element Type" = "Data Element Type"::"Lookup";
        AllowText := "Data Element Type" = "Data Element Type"::Text;
        AllowNumeric := "Data Element Type" = "Data Element Type"::Numeric;

        Scheduled := Recurrence = Recurrence::Scheduled;
    end;

    trigger OnOpenPage()
    var
        DataCollectionTemplate: Record "Data Collection Template";
    begin
        FilterGroup(9);
        DataCollectionTemplate.Get(GetRangeMax("Template Code"));
        FilterGroup(0);

        Quality := DataCollectionTemplate.Type = DataCollectionTemplate.Type::"Q/C";
        Shipping := DataCollectionTemplate.Type = DataCollectionTemplate.Type::Shipping;
        Receiving := DataCollectionTemplate.Type = DataCollectionTemplate.Type::Receiving;
        Production := DataCollectionTemplate.Type = DataCollectionTemplate.Type::Production;
        Log := DataCollectionTemplate.Type = DataCollectionTemplate.Type::Log;
        SampleFieldVisible := Rec.SamplesEnabled(); // P800122712
    end;

    var
        [InDataSet]
        Quality: Boolean;
        [InDataSet]
        Shipping: Boolean;
        [InDataSet]
        Receiving: Boolean;
        [InDataSet]
        Production: Boolean;
        [InDataSet]
        Log: Boolean;
        [InDataSet]
        AllowBoolean: Boolean;
        [InDataSet]
        AllowLookup: Boolean;
        [InDataSet]
        AllowText: Boolean;
        [InDataSet]
        AllowNumeric: Boolean;
        [InDataSet]
        Scheduled: Boolean;
        SampleFieldVisible: Boolean; // P800122712
}

