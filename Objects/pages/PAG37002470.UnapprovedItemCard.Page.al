page 37002470 "Unapproved Item Card"
{
    // PR1.00, Myers Nissi, Jack Reynolds, 30 JUL 00, PR007
    //   Standard card form for Unapproved Items
    // 
    // PR2.00
    //   Text constants
    // 
    // PR2.00.04
    //   Document Management
    // 
    // PR3.10
    //   Unapplied in Table Name on Comment Line table has changed
    // 
    // PR3.70
    //   Unapplied in Table Name on Comment Line table has changed
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 05 FEB 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.04
    // P8000868, VerticalSoft, Rick Tweedle, 17 SEP 10
    //   Added Genesis Enhancements
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW18.00
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Unapproved Item Card';
    PageType = Card;
    SourceTable = "Unapproved Item";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        UnapprItemUOMLookup(FieldNo("Base Unit of Measure"));
                        Density := CalcDensity("Weight UOM", "Volume UOM");
                    end;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Specifications)
            {
                Caption = 'Specifications';
                group(Control37002005)
                {
                    ShowCaption = false;
                    field(Density; Density)
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = DensityCaption;
                        DecimalPlaces = 0 : 8;

                        trigger OnValidate()
                        begin
                            DensityOnAfterValidate;               // P8000664
                            if Density <= 0 then
                                Error(Text000);
                        end;
                    }
                    field("Weight UOM"; "Weight UOM")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Weight UOM';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            UnapprItemUOMLookup(FieldNo("Weight UOM"));
                            Density := CalcDensity("Weight UOM", "Volume UOM");
                        end;

                        trigger OnValidate()
                        begin
                            WeightUOMOnAfterValidate;
                        end;
                    }
                    field("Volume UOM"; "Volume UOM")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Volume UOM';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            UnapprItemUOMLookup(FieldNo("Volume UOM"));
                            Density := CalcDensity("Weight UOM", "Volume UOM");
                        end;

                        trigger OnValidate()
                        begin
                            VolumeUOMOnAfterValidate;
                        end;
                    }
                }
                group(Control37002006)
                {
                    ShowCaption = false;
                    field("Specific Gravity"; "Specific Gravity")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Specific Gravity';

                        trigger OnValidate()
                        begin
                            SpecificGravityOnAfterValidate;
                        end;
                    }
                    field(Allergens; "Allergen Set ID" <> 0)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Allergens';
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900000004; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000005; Notes)
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
            group("&Item")
            {
                Caption = '&Item';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(FOODUnapprovedItem),
                                  "No." = FIELD("No.");
                }
                separator(Separator1102603031)
                {
                }
                action("&Units of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Units of Measure';
                    Image = UnitOfMeasure;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Unappr Item Units of Measure";
                    RunPageLink = "Unapproved Item No." = FIELD("No.");
                }
                action(Allergens)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Image = Properties;

                    trigger OnAction()
                    begin
                        // P8006959
                        ShowAllergens;
                    end;
                }
                action(AllergenHistory)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergen History';
                    Image = History;
                    RunObject = Page "Allergen Set History";
                    RunPageLink = "Table No." = CONST(37002465),
                                  "Code 1" = FIELD("No.");
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord() // P800-MegaApp
    begin
        Density := CalcDensity("Weight UOM", "Volume UOM");
    end;

    trigger OnOpenPage()
    begin
        DensityCaption := Text002;                                                // P8000664
    end;

    var
        UOM: Record "Unit of Measure";
        UnapprItemUOM: Record "Unappr. Item Unit of Measure";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        Density: Decimal;
        Text000: Label 'Density must be greater than zero.';
        DensityCaption: Text[30];
        Text001: Label 'Density (%1/%2)';
        Text002: Label 'Density';

    local procedure CalcDensity(WeightUOM: Code[10]; VolumeUOM: Code[10]) Density: Decimal
    begin
        if (WeightUOM <> '') and (VolumeUOM <> '') then begin
            Clear(DensityCaption);                                                     // P8000664
            UnapprItemUOM.Get("No.", VolumeUOM);
            Density := UnapprItemUOM."Qty. per Unit of Measure";
            UnapprItemUOM.Get("No.", WeightUOM);
            Density := Density / UnapprItemUOM."Qty. per Unit of Measure";
            DensityCaption := StrSubstNo(Text001, "Weight UOM", "Volume UOM");          // P8000664
        end else
            DensityCaption := Text002;                                                // P8000664
    end;

    local procedure DensityOnAfterValidate()
    var
        AdjUnit: Code[10];
        Factor: Decimal;
    begin
        if ("Weight UOM" <> '') and ("Volume UOM" <> '') then
            Validate("Specific Gravity", Density * 0.001 * P800UOMFns.UOMtoMetricBase("Weight UOM") /
              P800UOMFns.UOMtoMetricBase("Volume UOM"));
    end;

    local procedure WeightUOMOnAfterValidate()
    begin
        Density := CalcDensity("Weight UOM", "Volume UOM");
    end;

    local procedure VolumeUOMOnAfterValidate()
    begin
        Density := CalcDensity("Weight UOM", "Volume UOM");
    end;

    local procedure SpecificGravityOnAfterValidate()
    begin
        Density := CalcDensity("Weight UOM", "Volume UOM");
    end;
}

