report 37002045 "Calc. Cost Basis Values"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Calculate cost values for a Cost Basis
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
    //
    // PRW116.00.05
    // P800103616, To-Increase, Gangabhushan, 04 FEB 21
    //  Enhance inventory costing with Book Cost 

    DefaultRenderingLayout = StandardRDLCLayout;

    Caption = 'Calc. Cost Basis Values';

    dataset
    {
        dataitem(ItemLoop; Item)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Item Category Code";
            column(ItemLoopNo; "No.")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = FIELD("No.");
                DataItemTableView = SORTING("No.");
                column(ItemNo; "No.")
                {
                }
                column(ItemDesc; Description)
                {
                }
                column(ItemCostBasisCostValue; ItemCostBasis."Cost Value")
                {
                    DecimalPlaces = 2 : 5;
                }
                column(ItemCostBasisAuditText; ItemCostBasis."Audit Text")
                {
                }
                column(ItemBody; 'Item Body 1')
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not CreateItemCostBasis("No.", '') then
                        CurrReport.Skip;
                end;
            }
            dataitem("Item Variant"; "Item Variant")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", Code);
                column(ItemVariantItemNo; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(ItemVariantCode; Code)
                {
                }
                column(ItemVariantDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(ItemVariantItemCostBasisCostValue; ItemCostBasis."Cost Value")
                {
                    DecimalPlaces = 2 : 5;
                }
                column(ItemVariantItemCostBasisAuditText; ItemCostBasis."Audit Text")
                {
                }
                column(ItemVariantBody; 'Item Variant Body 1')
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not CreateItemCostBasis("Item No.", Code) then
                        CurrReport.Skip;
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Cost Basis Code"; CostBasis.Code)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Cost Basis Code';
                        TableRelation = "Cost Basis" WHERE("Calc. Codeunit ID" = FILTER(<> 0));
                    }
                    field("Cost Date"; CostDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Cost Date';
                    }
                    field("Reference Date"; ReferenceDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Reference Date';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if (ExtCostBasisCode <> '') then
                CostBasis.Code := ExtCostBasisCode;
        end;
    }

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/CalcCostBasisValues.rdlc';
        }
    }

    labels
    {
        VariantCodeCaption = 'Variant Code';
        CostValueCaption = 'Cost Value';
        AuditTextCaption = 'Audit Text';
    }

    trigger OnPreReport()
    begin
        if (CostBasis.Code = '') then
            Error(Text000);
        CostBasis.Get(CostBasis.Code);
        CostBasis.TestField("Calc. Codeunit ID");

        if (CostDate = 0D) then
            Error(Text001);

        if (ReferenceDate = 0D) then
            Error(Text002);
    end;

    var
        CostBasis: Record "Cost Basis";
        CostDate: Date;
        ReferenceDate: Date;
        ItemCostBasis: Record "Item Cost Basis";
        ExtCostBasisCode: Code[20];
        Text000: Label 'You must specify a Cost Basis Code.';
        Text001: Label 'You must specify an Effective Date.';
        Text002: Label 'You must specify a Reference Date.';

    local procedure CreateItemCostBasis(ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        CurrencyExchRate: Record "Currency Exchange Rate";
        CurrencyFactor: Decimal;
    begin
        ItemCostBasis."Cost Basis Code" := CostBasis.Code;
        ItemCostBasis."Item No." := ItemNo;
        ItemCostBasis."Variant Code" := VariantCode;
        ItemCostBasis."Cost Date" := CostDate;
        ItemCostBasis."Reference Date" := ReferenceDate;
        ItemCostBasis."Cost Value" := 0;
        ItemCostBasis."Audit Text" := '';
        ItemCostBasis."Reference Cost Basis Code" := CostBasis."Reference Cost Basis Code"; // P800103616
        CODEUNIT.Run(CostBasis."Calc. Codeunit ID", ItemCostBasis);
        if (ItemCostBasis."Cost Value" = 0) then
            exit(false);
        if (CostBasis."Currency Code" <> '') then begin
            CurrencyFactor :=
              CurrencyExchRate.ExchangeRate(ReferenceDate, CostBasis."Currency Code");
            ItemCostBasis."Cost Value" :=
              CurrencyExchRate.ExchangeAmtLCYToFCY(
                ReferenceDate, CostBasis."Currency Code", ItemCostBasis."Cost Value", CurrencyFactor);
        end;
        if not ItemCostBasis.Insert(true) then
            ItemCostBasis.Modify(true);
        exit(true);
    end;

    procedure SetCostBasisCode(NewCostBasisCode: Code[20])
    begin
        ExtCostBasisCode := NewCostBasisCode;
    end;
}

