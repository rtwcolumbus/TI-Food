report 10131 "Availability Status" // Version: FOODNA
{
    // PR3.60
    //   Add logic for alternate quantities
    // 
    // PRNA6.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRNA7.10
    // P8001252, Columbus IT, Jack Reynolds, 09 JAN 14
    //   Layout cleaned up
    
    DefaultLayout = RDLC;
    RDLCLayout = './layout/local/AvailabilityStatus.rdlc';
    Caption = 'Availability Status';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Search Description", "Inventory Posting Group", "Vendor No.", "Location Filter";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(TIME; Time)
            {
            }
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(USERID; UserId)
            {
            }
            column(Item_TABLECAPTION__________ItemFilter; Item.TableCaption + ': ' + ItemFilter)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(GroupKey; GroupKey)
            {
            }
            column(Item__Inventory_Posting_Group_; "Inventory Posting Group")
            {
            }
            column(Item_Item_Description; Item.Description)
            {
            }
            column(Item__No__; "No.")
            {
            }
            column(Item__Base_Unit_of_Measure_; "Base Unit of Measure")
            {
            }
            column(Item_Inventory; Inventory)
            {
                DecimalPlaces = 0 : 5;
            }
            column(Qty__on_Sales_Order_; -"Qty. on Sales Order")
            {
                DecimalPlaces = 0 : 5;
            }
            column(Item__Qty__on_Purch__Order_; "Qty. on Purch. Order")
            {
                DecimalPlaces = 0 : 5;
            }
            column(QtyAvailable; QtyAvailable)
            {
                DecimalPlaces = 0 : 5;
            }
            column(Item__Reorder_Point_; "Reorder Point")
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantityOnRelProdOrd; QuantityOnRelProdOrd)
            {
                DecimalPlaces = 0 : 5;
            }
            column(QuantityOnPlanProdOrd; QuantityOnPlanProdOrd)
            {
                DecimalPlaces = 0 : 5;
            }
            column(Qty__on_Service_Order_; -"Qty. on Service Order")
            {
                DecimalPlaces = 0 : 5;
            }
            column(Availability_StatusCaption; Availability_StatusCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Item__Base_Unit_of_Measure_Caption; FieldCaption("Base Unit of Measure"))
            {
            }
            column(Item_InventoryCaption; FieldCaption(Inventory))
            {
            }
            column(Qty__on_Sales_Order_Caption; Qty__on_Sales_Order_CaptionLbl)
            {
            }
            column(Item__Qty__on_Purch__Order_Caption; FieldCaption("Qty. on Purch. Order"))
            {
            }
            column(QtyAvailableCaption; QtyAvailableCaptionLbl)
            {
            }
            column(Item__Reorder_Point_Caption; FieldCaption("Reorder Point"))
            {
            }
            column(Item__No__Caption; FieldCaption("No."))
            {
            }
            column(QuantityOnRelProdOrdCaption; QuantityOnRelProdOrdCaptionLbl)
            {
            }
            column(QuantityOnPlanProdOrdCaption; QuantityOnPlanProdOrdCaptionLbl)
            {
            }
            column(Qty__on_Prod__Ord_Caption; Qty__on_Prod__Ord_CaptionLbl)
            {
            }
            column(Qty__on_Service_Order_Caption; Qty__on_Service_Order_CaptionLbl)
            {
            }
            column(Item__Inventory_Posting_Group_Caption; FieldCaption("Inventory Posting Group"))
            {
            }
            column(AvailableForText; AvailableForText)
            {
            }

            trigger OnAfterGetRecord()
            begin
                LotStatusMgmt.SetInboundExclusions(Item, LotStatusMgmt.AvailableForToFieldNo(AvailableFor), // P8001083
                  ExcludePurch, ExcludeSalesRet, ExcludeOutput);                                             // P8001083

                CalcFields(Inventory, "Qty. on Sales Order", "Qty. on Purch. Order", "Qty. on Service Order",
                  "Scheduled Receipt (Qty.)", "Scheduled Need (Qty.)",
                  "Rel. Scheduled Receipt (Qty.)", "Rel. Scheduled Need (Qty.)");

                CalcFields("Quantity on Hand (Alt.)");                                         // P8001083
                LotStatusMgmt.AdjustItemFlowFields(Item, LotStatusExclusionFilter, true, false, 0, // P8001083
                  ExcludePurch, ExcludeSalesRet, ExcludeOutput);                                 // P8001083
                QuantityOnRelProdOrd := "Rel. Scheduled Receipt (Qty.)" - "Rel. Scheduled Need (Qty.)";
                QuantityOnPlanProdOrd := "Scheduled Receipt (Qty.)" - "Scheduled Need (Qty.)" - QuantityOnRelProdOrd;

                // PR3.60
                if CostInAlternateUnits() then begin
                    "Base Unit of Measure" := "Alternate Unit of Measure";
                    //CALCFIELDS("Quantity on Hand (Alt.)"); // P8001083
                    Inventory := "Quantity on Hand (Alt.)";
                    "Qty. on Sales Order" := "Qty. on Sales Order" * CostingQtyPerBase();
                    "Qty. on Purch. Order" := "Qty. on Purch. Order" * CostingQtyPerBase();
                    "Qty. on Service Order" := "Qty. on Service Order" * CostingQtyPerBase();
                    QuantityOnRelProdOrd := QuantityOnRelProdOrd * CostingQtyPerBase();
                    QuantityOnPlanProdOrd := QuantityOnPlanProdOrd * CostingQtyPerBase();
                    "Reorder Point" := "Reorder Point" * CostingQtyPerBase();
                end;
                // PR3.60

                QtyAvailable := Inventory - "Qty. on Sales Order" + "Qty. on Purch. Order"
                  - "Qty. on Service Order" + QuantityOnRelProdOrd + QuantityOnPlanProdOrd;
            end;

            trigger OnPreDataItem()
            begin
                if StrPos(Item.CurrentKey, FieldCaption("Inventory Posting Group")) = 0 then
                    GroupKey := false
                else
                    GroupKey := true;
            end;
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
                    field(AvailableFor; AvailableFor)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Available for';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        ItemFilter := Item.GetFilters();
        CompanyInformation.Get();

        // P8001083
        LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatusMgmt.AvailableForToFieldNo(AvailableFor));
        if AvailableFor <> 0 then
            AvailableForText := StrSubstNo(Text37002000, AvailableFor);
        // P8001083
    end;

    var
        CompanyInformation: Record "Company Information";
        ItemFilter: Text;
        QuantityOnRelProdOrd: Decimal;
        QuantityOnPlanProdOrd: Decimal;
        QtyAvailable: Decimal;
        GroupKey: Boolean;
        Text37002000: Label 'Available for %1';
        Availability_StatusCaptionLbl: Label 'Availability Status';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Qty__on_Sales_Order_CaptionLbl: Label 'Qty. on Sales Order';
        QtyAvailableCaptionLbl: Label 'Quantity Available';
        QuantityOnRelProdOrdCaptionLbl: Label 'Released';
        QuantityOnPlanProdOrdCaptionLbl: Label 'Planned';
        Qty__on_Prod__Ord_CaptionLbl: Label 'Qty. on Prod. Ord.';
        Qty__on_Service_Order_CaptionLbl: Label 'Qty. on Service Order';
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: Text[1024];
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;
        AvailableFor: Option " ",Sale,"Purchase Return",Transfer,Consumption,Adjustment,Planning;
        AvailableForText: Text[100];
}

