page 37002831 "Preventive Maintenance Order"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard card style form for PM orders
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Add controls for material and contract account
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 11 FEB 09
    //   Transformed from form
    //   Changes made to page after transformation
    // 
    // PRw16.00.03
    // P8000819, VerticalSoft, Jack Reynolds, 30 APR 10
    //   Replace part for work request with multi-line text box
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Preventive Maintenance Order';
    PageType = Card;
    SourceTable = "Preventive Maintenance Order";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Asset No."; "Asset No.")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field(AssetDescription; AssetDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Asset Description';
                }
                field(AssetLocation; AssetLocation)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                }
                field(AssetPhysicalLocation; AssetPhysicalLocation)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Physical Location';
                }
                field(Originator; Originator)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Priority; Priority)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Group Code"; "Group Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Frequency Code"; "Frequency Code")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        SetControlProperties;
                    end;
                }
                field("Last PM Date"; "Last PM Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = PMDateEditable;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        SetControlProperties;
                    end;
                }
                field("Last PM Usage"; "Last PM Usage")
                {
                    ApplicationArea = FOODBasic;
                    BlankNumbers = BlankNeg;
                    Editable = PMUsageEditable;
                }
                field("Last Work Order"; "Last Work Order")
                {
                    ApplicationArea = FOODBasic;
                }
                field(NextPMDate; NextPMDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Next PM Date';
                    Importance = Promoted;
                }
                field("Current Work Order"; "Current Work Order")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Override Date"; "Override Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = overrideeditable;
                }
                group("Planned Cost")
                {
                    Caption = 'Planned Cost';
                    field("""Labor Cost (Planned)"" + ""Material Cost (Planned)"" + ""Contract Cost (Planned)"""; "Labor Cost (Planned)" + "Material Cost (Planned)" + "Contract Cost (Planned)")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Total';
                    }
                    field("Labor Cost (Planned)"; "Labor Cost (Planned)")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Labor';
                    }
                    field("Material Cost (Planned)"; "Material Cost (Planned)")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Material';
                    }
                    field("Contract Cost (Planned)"; "Contract Cost (Planned)")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contract';
                    }
                }
                group("Work Requested")
                {
                    Caption = 'Work Requested';
                    field(WorkRequest; WorkRequest)
                    {
                        ApplicationArea = FOODBasic;
                        MultiLine = true;
                        ShowCaption = false;
                        ShowMandatory = true;

                        trigger OnValidate()
                        var
                            TextFns: Codeunit "Text Functions";
                        begin
                            // P8000819
                            TextFns.TextToNote("Work Requested", 80, WorkRequest); // P8001132
                            "Work Requested (First Line)" := TextFns.FirstLine("Work Requested");
                        end;
                    }
                }
            }
            part(Control37002017; "PM Labor Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "PM Entry No." = FIELD("Entry No.");
            }
            part(MaterialLines; "PM Material Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "PM Entry No." = FIELD("Entry No.");
            }
            part(ContractLines; "PM Contract Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "PM Entry No." = FIELD("Entry No.");
            }
        }
        area(factboxes)
        {
            part(Control1900000007; "Asset Details Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Asset No.");
                Visible = true;
            }
            part(AssetUsageFactBox; "Asset Usage FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Asset No.");
                Visible = false;
            }
            systempart(Control1900000009; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
            systempart(Control1900000010; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&PM")
            {
                Caption = '&PM';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(FOODPMOrder),
                                  "No." = FIELD("Entry No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(37002819),
                                  "No." = FIELD("Entry No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                }
            }
        }
        area(processing)
        {
            action("Create &Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Create &Order';
                Image = CreateDocument;

                trigger OnAction()
                var
                    WorkOrder: Record "Work Order";
                begin
                    CreateWorkOrder(WorkOrder, WorkDate, Time, WorkDate);
                    CurrPage.SaveRecord;
                    Message(Text001, WorkOrder.TableCaption, WorkOrder.FieldCaption("No."), WorkOrder."No.");
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        TextFns: Codeunit "Text Functions";
    begin
        // P8001132
        CurrPage.ContractLines.PAGE.SetPMOrder("Entry No.");
        CurrPage.MaterialLines.PAGE.SetPMOrder("Entry No.");

        WorkRequest := TextFns.NoteToText("Work Requested"); // P8000819, P8001132
    end;

    trigger OnAfterGetRecord()
    begin
        SetControlProperties;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if GetFilter("Asset No.") <> '' then
            if GetRangeMin("Asset No.") = GetRangeMax("Asset No.") then
                Validate("Asset No.", GetRangeMin("Asset No."));
        SetControlProperties;
    end;

    var
        Frequency: Record "PM Frequency";
        Text001: Label '%1 %2 %3 created.';
        WorkRequest: Text;
        [InDataSet]
        PMDateEditable: Boolean;
        [InDataSet]
        PMUsageEditable: Boolean;
        [InDataSet]
        OverrideEditable: Boolean;

    procedure SetControlProperties()
    begin
        if ("Frequency Code" = '') or ("Last Work Order" <> '') then begin
            PMDateEditable := false;
            PMUsageEditable := false;
        end else begin
            PMDateEditable := true;
            if "Last PM Date" <> 0D then begin
                Frequency.Get("Frequency Code");
                PMUsageEditable := Frequency.Type in [Frequency.Type::Usage, Frequency.Type::Combined];
            end;
        end;
        OverrideEditable := "Frequency Code" <> '';
    end;
}

