table 37002049 "Cost Basis"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   New table for extended cost based sales pricing mechanism
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Change TableRelation references to Object table
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW116.00.05
    // P800103616, To-Increase, Gangabhushan, 04 FEB 21
    //  Enhance inventory costing with Book Cost     

    Caption = 'Cost Basis';
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "Cost Basis List";
    LookupPageID = "Cost Basis List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(4; "Calc. Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Calc. Codeunit ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));

            trigger OnValidate()
            var
                Process800Utility: Codeunit "Process 800 Utility Functions";
                CodeunitDescription: Label 'Cost Basis Calculation';
            begin
                Process800Utility.CheckCodeunitTable("Calc. Codeunit ID", Database::"Item Cost Basis", CodeunitDescription);
            end;
        }
        field(37002040; "Reference Cost Basis Code"; Code[20])
        {
            Caption = 'Reference Cost Basis Code';
            TableRelation = "Cost Basis".Code;
            trigger OnValidate()
            var
                Text0001: Label 'When you delete this Reference Cost Basis Code, prices are not calculated correctly anymore and customers could have wrong Sales Prices. Are you sure you want to delete this Reference Cost Basis Code?';
            begin
                if (xRec."Reference Cost Basis Code" <> Rec."Reference Cost Basis Code") and 
                            (xRec."Reference Cost Basis Code" <> '') then
                    if not Confirm(Text0001) then
                        exit;

            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ItemCostBasis.Reset;
        ItemCostBasis.SetRange("Cost Basis Code", Code);
        ItemCostBasis.DeleteAll(true);

        CostCalcMethod.Reset;
        CostCalcMethod.SetCurrentKey("Cost Basis Code");
        CostCalcMethod.SetRange("Cost Basis Code", Code);
        CostCalcMethod.DeleteAll(true);
    end;

    var
        ItemCostBasis: Record "Item Cost Basis";
        CostCalcMethod: Record "Cost Calculation Method";
}

