page 37002162 "Create New Customer"
{
    // PRW16.00.05
    // P8000952, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Wizard to create customers based on template
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001213, Columbus IT, Jack Reynolds, 26 SEP 13
    //   NAV 2013 R2 changes
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00.01
    // P80060684, To-Increase, Jack Reynolds, 08 AUG 18
    //   Fix problem with templates
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Create New Customer';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    SourceTable = Customer;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Step1)
            {
                InstructionalText = 'Specify a customer template and the customer name.';
                Visible = Step1Visible;
                field(TemplateCode; TemplateCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Template';
                    TableRelation = "Config. Template Header" WHERE("Table ID" = CONST(18));

                    trigger OnValidate()
                    begin
                        if TemplateCode <> '' then
                            TemplateHeader.Get(TemplateCode);
                        SetEnabled;
                    end;
                }
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        SetEnabled;
                    end;
                }
            }
            group(Step2)
            {
                Visible = Step2Visible;
                field(Address; Address)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = FOODBasic;
                }
                field(City; City)
                {
                    ApplicationArea = FOODBasic;
                }
                field(County; County)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Contact; Contact)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Customer Posting Group"; "Customer Posting Group")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Customer Price Group"; "Customer Price Group")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Back)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Back';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    SetStep(CurrentStep - 1);
                end;
            }
            action(Next)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Next';
                Enabled = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    SetStep(CurrentStep + 1);
                end;
            }
            action(Finish)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Finish';
                Enabled = FinishEnabled;
                Image = Stop;
                InFooterBar = true;

                trigger OnAction()
                begin
                    if CurrentStep = 1 then
                        ProcessStep1;

                    Customer.Insert(true);
                    Customer.TransferFields(Rec, false);
                    Customer.Modify(true);

                    InsertDimensionsFromTemplate; // P80060684

                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        MaxSteps := 2;
    end;

    trigger OnOpenPage()
    begin
        Rec.Init;
        Rec.Insert;
        SetStep(1);
    end;

    var
        TemplateHeader: Record "Config. Template Header";
        TemplatesUsed: Record "Config. Template Header" temporary;
        TemplateCode: Code[10];
        Customer: Record Customer;
        [InDataSet]
        Step1Visible: Boolean;
        [InDataSet]
        Step2Visible: Boolean;
        [InDataSet]
        BackEnabled: Boolean;
        [InDataSet]
        NextEnabled: Boolean;
        [InDataSet]
        FinishEnabled: Boolean;
        CurrentStep: Integer;
        MaxSteps: Integer;

    procedure SetStep(Step: Integer)
    begin
        if CurrentStep = Step then
            exit;

        case CurrentStep of
            1:
                begin
                    ProcessStep1;
                    Step1Visible := false;
                end;
            2:
                Step2Visible := false;
        end;

        case Step of
            1:
                begin
                    ClearStep1;
                    Step1Visible := true;
                end;
            2:
                Step2Visible := true;
        end;

        CurrentStep := Step;
        SetEnabled;
    end;

    procedure SetEnabled()
    begin
        BackEnabled := CurrentStep > 1;
        FinishEnabled := (TemplateCode <> '') and (Name <> '');
        NextEnabled := (CurrentStep < MaxSteps) and FinishEnabled;
    end;

    procedure ProcessStep1()
    begin
        ApplyTemplate(TemplateHeader.Code, true); // P80060684
    end;

    procedure ClearStep1()
    begin
        ApplyTemplate(TemplateHeader.Code, false); // P80060684
    end;

    procedure ApplyTemplate(TemplateHeaderCode: Code[10]; UseDefaultValue: Boolean)
    var
        TemplateLine: Record "Config. Template Line";
        CustomerRec: RecordRef;
        CustomerField: FieldRef;
        ConfigValidation: Codeunit "Config. Validate Management";
        CustomerName: Text[100];
    begin
        // P80060684 - Add parameter for TemplateHeaderCode
        if UseDefaultValue then begin
            // P80060684
            TemplatesUsed.Code := TemplateHeaderCode;
            if TemplatesUsed.Insert then;
            // P80060684
            CustomerRec.GetTable(Rec);
            TemplateLine.SetRange("Data Template Code", TemplateHeaderCode); // P80060684
            if TemplateLine.FindSet then
                repeat
                    // P80060684
                    case TemplateLine.Type of
                        TemplateLine.Type::Field:
                            begin
                                CustomerField := CustomerRec.Field(TemplateLine."Field ID");
                                ConfigValidation.ValidateFieldValue(CustomerRec, CustomerField, TemplateLine."Default Value", false, GlobalLanguage); // P8001132, P8001213
                            end;
                        TemplateLine.Type::Template:
                            begin
                                CustomerRec.SetTable(Rec);
                                ApplyTemplate(TemplateLine."Template Code", true);
                                CustomerRec.GetTable(Rec);
                            end;
                    end;
                    // P80060684
                until TemplateLine.Next = 0;
            CustomerRec.SetTable(Rec);
        end else begin
            CustomerName := Name;
            Init;
            Validate(Name, CustomerName);

            // P80060684
            TemplatesUsed.Reset;
            TemplatesUsed.DeleteAll;
            // P80060684
        end;
    end;

    procedure GetCustomerNo(): Code[20]
    begin
        exit(Customer."No.");
    end;

    local procedure InsertDimensionsFromTemplate()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        DimensionsTemplate: Record "Dimensions Template";
    begin
        // P80060684
        if TemplatesUsed.FindSet then
            repeat
                ConfigTemplateHeader.Get(TemplatesUsed.Code);
                DimensionsTemplate.InsertDimensionsFromTemplates(ConfigTemplateHeader, Customer."No.", DATABASE::Customer);
            until TemplatesUsed.Next = 0;
    end;
}

