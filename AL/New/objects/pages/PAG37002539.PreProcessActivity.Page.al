page 37002539 "Pre-Process Activity"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    //
    // PRW114.00.03
    // P800100025, To-Increase, Gangabhushan, 02 JUN 20
    //   CS00109943 | Pre-Process Error    
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    Caption = 'Pre-Process Activity';
    DataCaptionExpression = GetDataCaption;
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "Pre-Process Activity";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                group(Control37002042)
                {
                    ShowCaption = false;
                    field("Prod. Order Status"; Rec."Prod. Order Status")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Prod. Order No."; Rec."Prod. Order No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Prod. Order BOM No."; Rec."Prod. Order BOM No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Location Code"; Rec."Location Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                }
                field(RegisterDate; RegisterDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Registering Date';
                    NotBlank = true;
                }
                group(Control37002043)
                {
                    ShowCaption = false;
                    field("Replenishment Area Code"; Rec."Replenishment Area Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("To Bin Code"; Rec."To Bin Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("From Bin Code"; Rec."From Bin Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
            }
            group("Pre-Process")
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = VariantCodeMandatory;
                    Visible = false;

                    // P800155629
                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Rec.IsVariantMandatory();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Pre-Process Type Code"; Rec."Pre-Process Type Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Blending; Rec.Blending)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order Specific"; Rec."Order Specific")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Auto Complete"; Rec."Auto Complete")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Blending Order Status"; Rec."Blending Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Blending Order No."; Rec."Blending Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002044)
                {
                    ShowCaption = false;
                    field(Quantity; Rec.Quantity)
                    {
                        ApplicationArea = FOODBasic;
                        Importance = Promoted;
                    }
                    field("Quantity Processed"; Rec."Quantity Processed")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Remaining Quantity"; Rec."Remaining Quantity")
                    {
                        ApplicationArea = FOODBasic;
                        Importance = Promoted;
                    }
                    field("Qty. to Process"; Rec."Qty. to Process")
                    {
                        ApplicationArea = FOODBasic;
                        Importance = Promoted;
                    }
                }
            }
            part(Lines; "Pre-Process Activity Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Activity No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            systempart(Control37002034; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002032; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action(Register)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Register';
                    Image = Register;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        ActivityRegister: Codeunit "Pre-Process Register";
                    begin
                        Rec.TestField("No.");
                        if Confirm(Text000, false, Rec."No.") then begin
                            ActivityRegister.SetRegisterDate(RegisterDate);
                            ActivityRegister.Run(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
                separator(Separator37002026)
                {
                }
                action("Blending - Batch Reporting")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Blending - Batch Reporting';
                    Enabled = BlendingOrderExists;
                    Image = Journals;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    var
                        BlendingOrder: Record "Production Order";
                        BatchReporting: Page "Batch Reporting";
                    begin
                        Rec.TestField("Blending Order Status", Rec."Blending Order Status"::Released);
                        BlendingOrder.Get(Rec."Blending Order Status", Rec."Blending Order No.");
                        BatchReporting.SetOrder(Rec."Blending Order No.");
                        BatchReporting.Run;
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Prod. Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Prod. Order';
                Image = Production;
                ShortCutKey = 'Shift+F7';

                trigger OnAction()
                begin
                    Rec.ShowProdOrder(Rec."Prod. Order Status", Rec."Prod. Order No.");
                end;
            }
            action("Blending Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Blending Order';
                Enabled = BlendingOrderExists;
                Image = GetLines;
                ShortCutKey = 'Ctrl+B';

                trigger OnAction()
                begin
                    Rec.ShowProdOrder(Rec."Blending Order Status", Rec."Blending Order No.");
                end;
            }
            action(Item)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item';
                Image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Item No.");
                RunPageMode = View;
            }
            separator(Separator37002025)
            {
            }
            action("Warehouse Entries")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Warehouse Entries';
                Image = BinLedger;
                RunObject = Page "Warehouse Entries";
                RunPageLink = "Source No." = FIELD("No.");
                RunPageView = SORTING("Source Type", "Source Subtype", "Source No.")
                              WHERE("Source Type" = CONST(37002494),
                                    "Source Subtype" = CONST("0"));
                ShortCutKey = 'Ctrl+F7';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Register_Promoted; Register)
                {
                }
                actionref(BlendingBatchReporting_Promoted; "Blending - Batch Reporting")
                {
                }
                actionref(ProdOrder_Promoted; "Prod. Order")
                {
                }
                actionref(BlendingOrder_Promoted; "Blending Order")
                {
                }
                actionref(WarehouseEntries_Promoted; "Warehouse Entries")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        Item: Record "Item";
    begin
        BlendingOrderExists := (Rec."Blending Order No." <> '');
        // P800155629
        if Rec."Variant Code" = '' then
            VariantCodeMandatory := Rec.IsVariantMandatory();
        // P800155629
    end;

    trigger OnOpenPage()
    begin
        RegisterDate := WorkDate;
    end;

    var
        [InDataSet]
        BlendingOrderExists: Boolean;
        Text000: Label 'Do you want to register Pre-Process Activity %1?';
        RegisterDate: Date;
        VariantCodeMandatory: Boolean;

    procedure GetDataCaption(): Text
    begin
        exit(StrSubstNo('(%1) %2 - %3 %4', Rec."No.", Rec."Prod. Order No.", Rec."Item No.", Rec.Description));
    end;
}

