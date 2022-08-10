page 37002870 "Data Collection Lines"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001149, Columbus IT, Don Bresee, 26 APR 13
    //   Use lookup mode for Data Collection Templates page
    // 
    // PRW17.10.03
    // P8001311, Columbus IT, Jack Reynolds, 08 APR 14
    //   Fix problem with editablility of controls
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW19.00.01
    // P8007128, To-Increase, Dayakar Battini, 02 JUN 16
    //   HideValues property cleanup
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method
    //
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Data Collection Lines';
    DataCaptionExpression = Caption;
    DelayedInsert = true;
    PageType = ListPlus;
    SourceTable = "Data Collection Line";

    layout
    {
        area(content)
        {
            field(SheetTypeQSRP; SheetTypeQSRP)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Type';
                Visible = ShowSheetTypeQSRP;

                trigger OnValidate()
                begin
                    SetSheetType;
                    CurrPage.Update(false);
                end;
            }
            field(SheetTypeSRPL; SheetTypeSRPL)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Type';
                Visible = ShowSheetTypeSRPL;

                trigger OnValidate()
                begin
                    SetSheetType;
                    CurrPage.Update(false);
                end;
            }
            field(SheetTypeSR; SheetTypeSR)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Type';
                Visible = ShowSheetTypeSR;

                trigger OnValidate()
                begin
                    SetSheetType;
                    CurrPage.Update(false);
                end;
            }
            field(SheetTypeP; SheetTypeP)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Type';
                Visible = ShowSheetTypeP;

                trigger OnValidate()
                begin
                    SetSheetType;
                    CurrPage.Update(false);
                end;
            }
            field(SheetTypeL; SheetTypeL)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Type';
                Visible = ShowSheetTypeL;

                trigger OnValidate()
                begin
                    SetSheetType;
                    CurrPage.Update(false);
                end;
            }
            field(SheetTypeSRP; SheetTypeSRP)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Type';
                Visible = ShowSheetTypeSRP;

                trigger OnValidate()
                begin
                    SetSheetType;
                    CurrPage.Update(false);
                end;
            }
            repeater(Group)
            {
                field("Variant Type"; "Variant Type")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = Quality;
                }
                field("Data Element Code"; "Data Element Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;

                        SetFields; // P8001311
                    end;
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
                field(Active; Active)
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
                field("Source Template Code"; "Source Template Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Measuring Method"; "Measuring Method")
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
            group(Target)
            {
                Caption = 'Target';
                Editable = CodeEntered;
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
                group(Control37002017)
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
                Editable = CodeEntered;
                Visible = Production OR Log;
                field("Order or Line"; "Order or Line")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Production;
                }
                field(Control37002045; Recurrence)
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
                }
                field("Scheduled Type"; "Scheduled Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Scheduled;
                }
                field("Schedule Base"; "Schedule Base")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Scheduled;
                }
            }
            group(Alerts)
            {
                Caption = 'Alerts';
                Editable = CodeEntered;
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
                }
                field("Grace Period"; "Grace Period")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Scheduled;
                }
            }
            group(Quality)
            {
                Caption = 'Quality';
                Editable = CodeEntered;
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
                Editable = CodeEntered;
                Visible = Log;
                field("Log Group Code"; "Log Group Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Log Group Code';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002011; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002012; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Templates)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Select Templates';
                Ellipsis = true;
                Image = SelectEntries;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    DataCollectionTemplate: Record "Data Collection Template";
                    DataCollectionTemplates: Page "Data Collection Templates";
                    DataCollectionMgmt: Codeunit "Data Collection Management";
                begin
                    DataCollectionTemplate.FilterGroup(9);
                    if Quality then
                        DataCollectionTemplate.SetRange(Type, DataCollectionTemplate.Type::"Q/C")
                    else
                        if Shipping then
                            DataCollectionTemplate.SetRange(Type, DataCollectionTemplate.Type::Shipping)
                        else
                            if Receiving then
                                DataCollectionTemplate.SetRange(Type, DataCollectionTemplate.Type::Receiving)
                            else
                                if Production then
                                    DataCollectionTemplate.SetRange(Type, DataCollectionTemplate.Type::Production)
                                else
                                    if Log then
                                        DataCollectionTemplate.SetRange(Type, DataCollectionTemplate.Type::Log);

                    DataCollectionTemplates.SetTableView(DataCollectionTemplate);
                    if SourceID = DATABASE::Item then
                        DataCollectionTemplates.SetItem(SourceKey[1]);
                    // P8001149
                    // IF DataCollectionTemplates.RUNMODAL = ACTION::OK THEN BEGIN
                    DataCollectionTemplates.LookupMode(true);
                    if DataCollectionTemplates.RunModal = ACTION::LookupOK then begin
                        // P8001149
                        DataCollectionTemplates.GetSelectedTemplates(DataCollectionTemplate);
                        if DataCollectionTemplate.FindSet then begin
                            repeat
                                DataCollectionMgmt.CopyTemplateToLines(DataCollectionTemplate, SourceID, SourceKey[1], SourceKey[2]);
                            until DataCollectionTemplate.Next = 0;
                            CurrPage.Update(false);
                        end;
                    end;
                end;
            }
            action(Copy)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Copy';
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    CopyDataCollectionLines: Report "Copy Data Collection Lines";
                begin
                    CopyDataCollectionLines.SetTarget(SourceID, SourceKey[1], SourceKey[2]);
                    CopyDataCollectionLines.RunModal;
                end;
            }
            action(History)
            {
                ApplicationArea = FOODBasic;
                Caption = 'History';
                Image = History;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Data Collection History";
                RunPageLink = "Data Element Code" = FIELD("Data Element Code"),
                              "Source ID" = FIELD("Source ID"),
                              "Source Key 1" = FIELD("Source Key 1"),
                              "Source Key 2" = FIELD("Source Key 2"),
                              Type = FIELD(Type);
                RunPageView = SORTING("Data Element Code", "Source ID", "Source Key 1", "Source Key 2", Type);
            }
        }
        area(navigation)
        {
            action("Co&mments")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Co&mments';
                Image = Comment;
                RunObject = Page "Data Collection Comments";
                RunPageLink = "Source ID" = FIELD("Source ID"),
                              "Source Key 1" = FIELD("Source Key 1"),
                              "Source Key 2" = FIELD("Source Key 2"),
                              Type = FIELD(Type),
                              "Data Element Code" = FIELD("Data Element Code"),
                              "Data Collection Line No." = FIELD("Line No.");
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetFields; // P8001311
    end;

    trigger OnOpenPage()
    begin
        SetSource;
        SampleFieldVisible := Rec.SamplesEnabled(); // P800122712
    end;

    var
        DataCollectinMgmt: Codeunit "Data Collection Management";
        SourceID: Integer;
        SourceKey: array[2] of Code[20];
        Caption: Text[1024];
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
        CodeEntered: Boolean;
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
        SheetTypeQSRP: Option Quality,Shipping,Receiving,Production;
        SheetTypeSRPL: Option Shipping,Receiving,Production,Log;
        SheetTypeSR: Option Shipping,Receiving;
        SheetTypeP: Option Production;
        SheetTypeL: Option Log;
        SheetTypeSRP: Option Shipping,Receiving,Production;
        [InDataSet]
        ShowSheetTypeQSRP: Boolean;
        [InDataSet]
        ShowSheetTypeSRPL: Boolean;
        [InDataSet]
        ShowSheetTypeSR: Boolean;
        [InDataSet]
        ShowSheetTypeP: Boolean;
        [InDataSet]
        ShowSheetTypeL: Boolean;
        Text001: Label '%1 • %2';
        [InDataSet]
        ShowSheetTypeSRP: Boolean;
        SampleFieldVisible: Boolean; // P800122712

    procedure SetSource()
    var
        DataCollectionLine: Record "Data Collection Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        SourceDesc: array[2] of Text[100];
        [InDataSet]
        ShowSource2: Boolean;
    begin
        DataCollectionLine.Copy(Rec);

        FilterGroup(4);
        SetFilter("Source ID", DataCollectionLine.GetFilter("Source ID"));
        SetFilter("Source Key 1", DataCollectionLine.GetFilter("Source Key 1"));
        SetFilter("Source Key 2", DataCollectionLine.GetFilter("Source Key 2"));
        FilterGroup(0);

        SourceID := DataCollectionLine.GetRangeMax("Source ID");
        SourceKey[1] := DataCollectionLine.GetRangeMax("Source Key 1");
        ShowSource2 := DataCollectionLine.GetFilter("Source Key 2") <> '';
        if ShowSource2 then
            SourceKey[2] := DataCollectionLine.GetRangeMax("Source Key 2");

        if SourceID = DATABASE::Item then begin
            Item.Get(SourceKey[1]);
            if ItemTrackingCode.Get(Item."Item Tracking Code") and ItemTrackingCode."Lot Specific Tracking" then
                ShowSheetTypeQSRP := true
            else
                ShowSheetTypeSRP := true;
        end;
        ShowSheetTypeSRPL := SourceID in [DATABASE::Location, DATABASE::Resource];
        ShowSheetTypeSR := SourceID in [DATABASE::Customer, DATABASE::Vendor];
        ShowSheetTypeP := SourceID in [DATABASE::"Work Center", DATABASE::"Machine Center"];
        ShowSheetTypeL := SourceID in [DATABASE::Zone, DATABASE::Bin, DATABASE::Asset];

        SetSheetType;

        DataCollectinMgmt.SourceDescription(SourceID, SourceKey[1], SourceKey[2], Caption, SourceDesc[1], SourceDesc[2]);
        Caption := Caption + ' - ' + StrSubstNo(Text001, SourceKey[1], SourceDesc[1]);
        if ShowSource2 then
            Caption := Caption + ', ' + StrSubstNo(Text001, SourceKey[2], SourceDesc[2]);
    end;

    procedure SetSheetType()
    begin
        if ShowSheetTypeQSRP then begin
            Quality := SheetTypeQSRP = SheetTypeQSRP::Quality;
            Shipping := SheetTypeQSRP = SheetTypeQSRP::Shipping;
            Receiving := SheetTypeQSRP = SheetTypeQSRP::Receiving;
            Production := SheetTypeQSRP = SheetTypeQSRP::Production;
        end else
            if ShowSheetTypeSRPL then begin
                Shipping := SheetTypeSRPL = SheetTypeSRPL::Shipping;
                Receiving := SheetTypeSRPL = SheetTypeSRPL::Receiving;
                Production := SheetTypeSRPL = SheetTypeSRPL::Production;
                Log := SheetTypeSRPL = SheetTypeSRPL::Log;
            end else
                if ShowSheetTypeSRP then begin
                    Shipping := SheetTypeSRP = SheetTypeSRP::Shipping;
                    Receiving := SheetTypeSRP = SheetTypeSRP::Receiving;
                    Production := SheetTypeSRP = SheetTypeSRP::Production;
                end else
                    if ShowSheetTypeSR then begin
                        Shipping := SheetTypeSR = SheetTypeSR::Shipping;
                        Receiving := SheetTypeSR = SheetTypeSR::Receiving;
                    end else
                        if ShowSheetTypeP then begin
                            Production := SheetTypeP = SheetTypeP::Production;
                        end else
                            if ShowSheetTypeL then begin
                                Log := SheetTypeL = SheetTypeL::Log;
                            end;

        FilterGroup(4);
        if Quality then
            SetRange(Type, Type::"Q/C")
        else
            if Shipping then
                SetRange(Type, Type::Shipping)
            else
                if Receiving then
                    SetRange(Type, Type::Receiving)
                else
                    if Production then
                        SetRange(Type, Type::Production)
                    else
                        if Log then
                            SetRange(Type, Type::Log);
        FilterGroup(0);

        if FindFirst then;
    end;

    procedure SetFields()
    begin
        // P8001311
        CodeEntered := "Data Element Code" <> '';
        AllowBoolean := "Data Element Type" = "Data Element Type"::Boolean;
        AllowLookup := "Data Element Type" = "Data Element Type"::"Lookup";
        AllowText := "Data Element Type" = "Data Element Type"::Text;
        AllowNumeric := "Data Element Type" = "Data Element Type"::Numeric;

        Scheduled := Recurrence = Recurrence::Scheduled;
    end;
}

