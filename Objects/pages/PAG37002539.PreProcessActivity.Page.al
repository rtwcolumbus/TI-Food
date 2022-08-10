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
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                group(Control37002042)
                {
                    ShowCaption = false;
                    field("Prod. Order Status"; "Prod. Order Status")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Prod. Order No."; "Prod. Order No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Prod. Order BOM No."; "Prod. Order BOM No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Location Code"; "Location Code")
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
                    field("Replenishment Area Code"; "Replenishment Area Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("To Bin Code"; "To Bin Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("From Bin Code"; "From Bin Code")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
            }
            group("Pre-Process")
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Pre-Process Type Code"; "Pre-Process Type Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Blending; Blending)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order Specific"; "Order Specific")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Auto Complete"; "Auto Complete")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Blending Order Status"; "Blending Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Blending Order No."; "Blending Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002044)
                {
                    ShowCaption = false;
                    field(Quantity; Quantity)
                    {
                        ApplicationArea = FOODBasic;
                        Importance = Promoted;
                    }
                    field("Quantity Processed"; "Quantity Processed")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Remaining Quantity"; "Remaining Quantity")
                    {
                        ApplicationArea = FOODBasic;
                        Importance = Promoted;
                    }
                    field("Qty. to Process"; "Qty. to Process")
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        ActivityRegister: Codeunit "Pre-Process Register";
                    begin
                        TestField("No.");
                        if Confirm(Text000, false, "No.") then begin
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    var
                        BlendingOrder: Record "Production Order";
                        BatchReporting: Page "Batch Reporting";
                    begin
                        TestField("Blending Order Status", "Blending Order Status"::Released);
                        BlendingOrder.Get("Blending Order Status", "Blending Order No.");
                        BatchReporting.SetOrder("Blending Order No.");
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
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Shift+F7';

                trigger OnAction()
                begin
                    ShowProdOrder("Prod. Order Status", "Prod. Order No.");
                end;
            }
            action("Blending Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Blending Order';
                Enabled = BlendingOrderExists;
                Image = GetLines;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Ctrl+B';

                trigger OnAction()
                begin
                    ShowProdOrder("Blending Order Status", "Blending Order No.");
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
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Warehouse Entries";
                RunPageLink = "Source No." = FIELD("No.");
                RunPageView = SORTING("Source Type", "Source Subtype", "Source No.")
                              WHERE("Source Type" = CONST(37002494),
                                    "Source Subtype" = CONST("0"));
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        BlendingOrderExists := ("Blending Order No." <> '');
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

    procedure GetDataCaption(): Text
    begin
        exit(StrSubstNo('(%1) %2 - %3 %4', "No.", "Prod. Order No.", "Item No.", Description));
    end;
}

