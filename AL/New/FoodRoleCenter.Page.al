page 37002000 "Food Role Center"
{
    // PRW118.1
    // P800129613, To Increase, Jack Reynolds, 20 SEP 21
    //   Creatre Sub-Lot Wizard
    
    Caption = 'Food Role Center';
    PageType = RoleCenter;
    actions
    {
        area(Sections)
        {
            group("Admin")
            {
                Caption = 'Administration';
            }
            group("Finance")
            {
                Caption = 'Finance';
                group("FinanceDedMgmnt")
                {
                    Caption = 'Deduction Management';
                    action("PaymentApplication")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Payment Application';
                        RunObject = page "Ded. Management - Application";
                    }
                    action("DeductionResolution")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Deduction Resolution';
                        RunObject = page "Ded. Management - Resolution";
                    }
                }
                group("FinanceSetup")
                {
                    Caption = 'Setup';
                    action("FinanaceSetupOffInvoiceAllowances")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Off-Invoice Allowances';
                        RunObject = page "Off-Invoice Allowance List";
                    }
                    action("AccountScheduleUnits")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Account Schedule Units';
                        RunObject = page "Acc. Schedule Units";
                    }
                }
            }
            group("HR")
            {
                Caption = 'Human Resources';
            }
            group("Maint")
            {
                Caption = 'Maintenance';
                group("MaintAssests")
                {
                    Caption = 'Assets';
                    action("Assets")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Assets';
                        RunObject = page "Asset List";
                    }
                    action("PreventiveMaintenanceOrders")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Preventive Maintenance Orders';
                        RunObject = page "Preventive Maintenance Orders";
                    }
                    group("MaintAssestsRpts")
                    {
                        Caption = 'Reports';
                        action("AssetList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Asset List';
                            RunObject = report "Asset List";
                        }
                        action("PMMasterSchedule")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'PM Master Schedule';
                            RunObject = report "PM Master Schedule";
                        }
                    }
                }
                group("MaintPlanning")
                {
                    Caption = 'Planning';
                    action("WorkOrderSchedule")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Work Order Schedule';
                        RunObject = page "Work Order Schedule";
                    }
                    action("PMWorksheet")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'PM Worksheet';
                        RunObject = page "PM Worksheet";
                    }
                }
                group("MaintOperations")
                {
                    Caption = 'Operations';
                    action("OpenWorkOrders")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Open Work Orders';
                        RunObject = page "Open Work Order List";
                    }
                    action("LaborJournal")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Labor Journal';
                        RunObject = page "Maintenance Labor Journal";
                    }
                    action("MaterialJournal")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Material Journal';
                        RunObject = page "Maintenance Material Journal";
                    }
                    action("ContractlJournal")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contract Journal';
                        RunObject = page "Maintenance Contract Journal";
                    }
                    action("MaintenanceJournal")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Maintenance Journal';
                        RunObject = page "Maintenance Journal";
                    }
                    group("MaintOperationsRpts")
                    {
                        Caption = 'Reports';
                        action("PMPastDue")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'PM Past Due';
                            RunObject = report "PM Past Due";
                        }
                    }
                    group("MaintOperationsDocs")
                    {
                        Caption = 'Documents';
                        action("WorkOrder")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Work Order';
                            RunObject = report "Maintenance Work Order";
                        }
                    }
                }
                group("MaintHistory")
                {
                    Caption = 'Registers/Entries';
                    action("CompletedWorkOrders")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Completed Work Orders';
                        RunObject = page "Completed Work Order List";
                    }
                    action("MaintRegisters")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Registers';
                        RunObject = page "Maintenance Registers";
                    }
                    group("MaintHistoryRpts")
                    {
                        Caption = 'Reports';
                        action("AssetCostSummary")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Asset Cost Summary';
                            RunObject = report "Asset Cost Summary";
                        }
                        action("AssetHistory")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Asset History';
                            RunObject = report "Asset History";
                        }
                        action("WorkOrderSummary")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Work Order Summary';
                            RunObject = report "Work Order Summary";
                        }
                        action("WorkOrderHistory")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Work Order History';
                            RunObject = report "Work Order History";
                        }
                    }
                }
                group("MaintSetup")
                {
                    Caption = 'Setup';
                    action("MaintenanceSetup")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Maintenance Setup';
                        RunObject = page "Maintenance Setup";
                    }
                    action("AssetCategories")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Asset Categories';
                        RunObject = page "Asset Categories";
                    }
                    action("MaintenanceTrades")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Maintenance Trades';
                        RunObject = page "Maintenance Trades";
                    }
                    action("WorkOrderFaultCodes")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Work Order Fault Codes';
                        RunObject = page "Work Order Fault Codes";
                    }
                    action("WorkOrderCauseCodes")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Work Order Cause Codes';
                        RunObject = page "Work Order Cause Codes";
                    }
                    action("WorkOrderActionCodes")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Work Order Action Codes';
                        RunObject = page "Work Order Action Codes";
                    }
                    action("PMFrequencies")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'PM Frequencies';
                        RunObject = page "PM Frequencies";
                    }
                    action("ReportSelectionMaintenance")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Report Selection - Maintenance';
                        RunObject = page "Report Selection - Maintenance";
                    }
                }
            }
            group("Mfg")
            {
                Caption = 'Manufacturing';
                group("MfgDesign")
                {
                    Caption = 'Product Design';
                    action("UnapprovedItems")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Unapproved Items';
                        RunObject = page "Unapproved Item List";
                    }
                    action("Formulas")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Formulas';
                        RunObject = page "Production Formula List";
                    }
                    action("ItemProcesses")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item Processes';
                        RunObject = page "Item Process List";
                    }
                    action("CoProductByProductProcesses")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Co-Product/By-Product Processes';
                        RunObject = page "Co-Product Process List";
                    }
                    action("PackageBOMs")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Package BOMs';
                        RunObject = page "Package BOM List";
                    }
                    group("MfgDesignRpts")
                    {
                        Caption = 'Reports';
                        action("FormulaList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Formula List';
                            RunObject = report "Formula List";
                        }
                        action("FormulaVersionDetails")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Formula Version Details';
                            RunObject = report "Formula Version Details";
                        }
                        action("ProcessList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Process List';
                            RunObject = report "Process List";
                        }
                        action("ProcessVersionDetails")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Process Version Details';
                            RunObject = report "Process Version Details";
                        }
                        action("PackagingBOMList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Packaging BOM List';
                            RunObject = report "Packaging BOM List";
                        }
                        action("PackagingBOMVersionDetails")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Packaging BOM Version Details';
                            RunObject = report "Packaging BOM Version Details";
                        }
                        action("QuantityExplosionofFormula")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Quantity Explosion of Formula';
                            RunObject = report "Quantity Explosion of Formula";
                        }
                        action("WhereUsedinFormula")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Where Used in Formula';
                            RunObject = report "Where Used in Formula";
                        }
                    }
                }
                group("MfgPlanning")
                {
                    Caption = 'Planning';
                    action("ProductionForecast")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Production Forecast';
                        RunObject = page "Item Forecast";
                    }
                    action("QuickPlanner")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quick Planner';
                        RunObject = report "Create Quick Planner Worksheet";
                    }
                    action("BatchPlanningWorksheet")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Batch Planning Worksheet';
                        RunObject = page "Batch Planning Worksheet";
                    }
                    action("ProductionSequence")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Production Sequence';
                        RunObject = page "Production Sequence";
                    }
                    action("SupplyDrivenPlanning")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Supply Driven Planning';
                        RunObject = page "Supply Driven Planning";
                    }
                    action("DailyProductionPlanning")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Daily Production Planning';
                        RunObject = page "Daily Production Planning";
                    }
                    action("GeneratePreProcessActivity")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Generate Pre-Process Activity';
                        RunObject = report "Generate Pre-Process Activity";
                    }
                    group("MfgPlanningRpts")
                    {
                        Caption = 'Reports';
                        action("DailyProductionPlan")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Daily Production Plan';
                            RunObject = report "Daily Production Plan";
                        }
                    }
                }
                group("MfgOperations")
                {
                    Caption = 'Operations';
                    action("PreProcessActivities")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Pre-Process Activities';
                        RunObject = page "Pre-Process Activity List";
                    }
                    action("BatchReporting")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Batch Reporting';
                        RunObject = page "Batch Reporting";
                    }
                    action("ProcessReporting")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Process Reporting';
                        RunObject = page "Process Reporting";
                    }
                    // action("ProductionTimeEntryJournal")
                    // {
                    //     Caption = 'Production Time Entry Journal';
                    //     RunObject = page "Production Time Entry Journal";
                    // }
                    group("MfgOperationsRpts")
                    {
                        Caption = 'Reports';
                        action("ProductionTicket")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Production Ticket';
                            RunObject = report "Production Ticket";
                        }
                        action("ProductionYieldCostReport")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Production Yield & Cost Report';
                            RunObject = report "Production Yield & Cost Report";
                        }
                        action("ProductionOrderSummary")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Production Order Summary';
                            RunObject = report "Production Order Summary";
                        }
                        action("ConsumptionHistorySummary")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Consumption History Summary';
                            RunObject = report "Consumption History Summary";
                        }
                    }
                }
                group("MfgCosting")
                {
                    Caption = 'Costing';
                    action("MfgCostingCommodityCostPeriods")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Commodity Cost Periods';
                        RunObject = page "Commodity Cost Periods";
                    }
                    action("CommodityCostQCErrors")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Commodity Cost Q/C Errors';
                        RunObject = report "Commodity Cost Q/C Errors";
                    }
                    group("MfgCostingRpts")
                    {
                        Caption = 'Reports';
                        action("ProductionItemCosts")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Production Item Costs';
                            RunObject = report "Production Item Costs";
                        }
                    }
                }
                group("MfgHistory")
                {
                    Caption = 'Registers/Entries';
                    action("RegisteredPreProcessActivities")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Registered Pre-Process Activities';
                        RunObject = page "Reg. Pre-Process Activity List";
                    }
                }
                group("MfgSetup")
                {
                    Caption = 'Setup';
                    action("ProcessSetup")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Process Setup';
                        RunObject = page "Process Setup";
                    }
                    action("PackageVariables")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Package Variables';
                        RunObject = page "Package Variables";
                    }
                    action("ProductionSequenceCodes")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Production Sequence Codes';
                        RunObject = page "Production Sequence Codes";
                    }
                    action("MfgSetupAllergens")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Allergens';
                        RunObject = page "Allergens";
                    }
                    action("ProductionPlanningEvents")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Production Planning Events';
                        RunObject = page "Production Planning Events";
                    }
                    action("PreProcessTypes")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Pre-Process Types';
                        RunObject = page "Pre-Process Types";
                    }
                    action("MfgSetupCommodityClasses")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Commodity Classes';
                        RunObject = page "Commodity Classes";
                    }
                    action("MfgSetupCommodityCostComponents")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Commodity Cost Components';
                        RunObject = page "Comm. Cost Components";
                    }
                }

            }
            group("MktgPlan")
            {
                Caption = 'Marketing Plans';
                group("MktgPlanPlans")
                {
                    Caption = 'Plans';
                    action("CustomerRebatesPromos")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Customer Rebates/Promos';
                        RunObject = page "Customer Accrual Plan List";
                    }
                    action("SalesCommissions")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales Commissions';
                        RunObject = page "Sales Comm. Accrual Plan List";
                    }
                    action("VendorRebatesPromos")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Vendor Rebates/Promos';
                        RunObject = page "Vendor Accrual Plan List";
                    }
                }
                group("MktgPlanOperations")
                {
                    Caption = 'Operations';
                    action("PlanJournal")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Plan Journal';
                        RunObject = page "Accrual Journal Template List";
                    }
                    action("RecurringJournals")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Recurring Journals';
                        RunObject = page "Recurring Accrual Journal";
                    }
                    action("CreateAccrualPaymentDocuments")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Create Accrual Payment Documents';
                        RunObject = report "Suggest Purchase Payments";
                    }
                    action("CreateScheduledAccrualPaymentDocuments")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Create Scheduled Accrual Payment Documents';
                        RunObject = report "Suggest Schd. Accrual Entries";
                    }
                    action("UnpostedAccrualPaymentDocuments")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Unposted Accrual Payment Documents';
                        RunObject = page "Unposted Accrual Payment Docs.";
                    }
                }
                group("MktgPlanHistory")
                {
                    Caption = 'Registers/Entries';
                    action("MktgPlanHistoryRegisters")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Registers';
                        RunObject = page "Accrual Registers";
                    }
                }
                group("MktgPlanRpts")
                {
                    Caption = 'Reports';
                    action("AccrualPlanDetail")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Accrual Plan Detail';
                        RunObject = report "Accrual Plan Detail";
                    }
                    action("CompareAccrualPlantoView")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Compare Accrual Plan to View';
                        RunObject = report "Compare Accrual Plan to View";
                    }
                }
                group("MktgPlanSetup")
                {
                    Caption = 'Setup';
                    action("AccrualSetup")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Accrual Setup';
                        RunObject = page "Accrual Setup";
                    }
                    action("AccrualPostingGroups")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Accrual Posting Groups';
                        RunObject = page "Accrual Posting Groups";
                    }
                    action("AccrualComputationGroups")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Accrual Computation Groups';
                        RunObject = page "Accrual Computation Groups";
                    }
                    action("AccrualCharges")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Accrual Charges';
                        RunObject = page "Accrual Charges";
                    }
                    action("AccrualJournalTemplates")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Accrual Journal Templates';
                        RunObject = page "Accrual Journal Templates";
                    }
                    group("MktgPlanSetupGroups")
                    {
                        Caption = 'Plan Groups';
                        action("CustomerGroups")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Customer Groups';
                            RunObject = page "Customer Accrual Groups";
                        }
                        action("VendorGroups")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Vendor Groups';
                            RunObject = page "Vendor Accrual Groups";
                        }
                        action("ItemGroups")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Item Groups';
                            RunObject = page "Item Accrual Groups";
                        }
                        action("PaymentGroups")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Payment Groups';
                            RunObject = page "Accrual Payment Groups";
                        }
                    }
                }
            }
            group("Project")
            {
                Caption = 'Project';
            }
            group("Purch")
            {
                Caption = 'Purchasing';
                group("PurchOrderProcessing")
                {
                    Caption = 'Order Processing';
                    action("PurchOrderReceiving")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Order Receiving';
                        RunObject = page "Order Receiving";
                    }
                    action("PurchTruckloadReceiving")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Truckload Receiving';
                        RunObject = page "Truckload Receiving";
                    }
                    action("PurchOrderShipping")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Order Shipping';
                        RunObject = page "Order Shipping";
                    }
                    action("VendorCertifications")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Vendor Certifications';
                        RunObject = page "Vendor Certifications";
                    }
                }
                group("PurchCommodities")
                {
                    Caption = 'Commodities';
                    action("CommodityPurchaseOrders")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Commodity Purchase Orders';
                        RunObject = page "Commodity Purchase Order List";
                    }
                    action("PurchCommodityCostPeriods")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Commodity Cost Periods';
                        RunObject = page "Commodity Cost Periods";
                    }
                    action("UpdateCommodityOrders")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Update Commodity Orders';
                        RunObject = report "Update Commodity Orders";
                    }
                    action("CommodityPaymentQCErrors")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Commodity Payment Q/C Errors';
                        RunObject = report "Commodity Payment Q/C Errors";
                    }
                }
                group("PurchSetup")
                {
                    Caption = 'Setup';
                    action("VendorCertificationTypes")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Vendor Certification Types';
                        RunObject = page "Vendor Certification Types";
                    }
                    action("ExtraCharges")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Extra Charges';
                        RunObject = page "Extra Charges";
                    }
                    action("PurchCommodityClasses")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Commodity Classes';
                        RunObject = page "Commodity Classes";
                    }
                    action("PurchCommodityCostComponents")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Commodity Cost Components';
                        RunObject = page "Comm. Cost Components";
                    }
                    action("ProducerZones")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Producer Zones';
                        RunObject = page "Producer Zones";
                    }
                    action("TransportCostComponents")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Transport Cost Components';
                        RunObject = page "N138 Transport Cost Components";
                    }
                    action("TransportCostComponentTemplates")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Transport Cost Component Templates';
                        RunObject = page "N138 Trans Cost Comp Templates";
                    }
                }
            }
            group("QC")
            {
                Caption = 'Quality Control and Compliance';
                group("QCQualityControl")
                {
                    Caption = 'Quality Control';
                    action("OpenQualityControlActivities")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Open Quality Control Activities';
                        RunObject = page "Open Q/C Activity List";
                    }
                    // action("ItemQualityTests")
                    // {
                    //     Caption = 'Item Quality Tests';
                    //     RunObject = page "Item Quality Tests";
                    // }
                    action("ItemQualityTests")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item Quality Tests';
                        RunObject = page "Item Quality Tests";
                    }
                    action("CompletedQualityControlActivities")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Completed Quality Control Activities';
                        RunObject = page "Completed Q/C Activity List";
                    }
                    action("IncidentSearch")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Incident Search';
                        RunObject = page "Incident Search";
                    }
                    action("IncidentEntries")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Incident Entries';
                        RunObject = page "Incident Entries";
                    }
                    group("QCQualityControlRpts")
                    {
                        Caption = 'Reports';
                        action("ItemLotsPending")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Item Lots Pending';
                            RunObject = report "Item Lots Pending";
                        }
                        action("QCItemLotsbyExpirationDate")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Item Lots by Expiration Date';
                            RunObject = report "Item Lots by Expiration Date";
                        }
                        action("ItemTestResults")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Item Test Results';
                            RunObject = report "Item Test Results";
                        }
                        action("QualityControlTestResults")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Quality Control Test Results';
                            RunObject = report "Quality Control Test Results";
                        }
                    }
                    group("QCQualityControlDocs")
                    {
                        Caption = 'Documents';
                        action("QualityControlWorksheet")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Quality Control Worksheet';
                            RunObject = report "Quality Control Worksheet";
                        }
                        action("CertificateofAnalysis")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Certificate of Analysis';
                            RunObject = report "Certificate of Analysis";
                        }
                        action("CertificateofAnalysisbyShipment")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Certificate of Analysis by Shipment';
                            RunObject = report "Cert. of Analysis by Shipment";
                        }
                    }
                    group("QCQualityControlSetup")
                    {
                        Caption = 'Setup';
                        action("QualityControlTechnicians")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Quality Control Technicians';
                            RunObject = page "Quality Control Technicians";
                        }
                        action("SkipLogicSetupList ")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Skip Logic Setup List';
                            RunObject = page "Skip Logic Setup List";
                        }
                        action("ItemQualitySkipLogicTemplate")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Item Quality Skip Logic Template';
                            RunObject = page "Item Q/C Skip Logic Lines";
                        }
                        action("IncidentReasonCodes")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Incident Reason Codes';
                            RunObject = page "Incident Reason Codes";
                        }
                        action("IncidentClassificationCodes")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Incident Classification Codes';
                            RunObject = page "Incident Classification Codes";
                        }
                    }
                }
                group("QCDataCollection")
                {
                    Caption = 'Process Data Collection';
                    action("OpenDataSheets")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Open Data Sheets';
                        RunObject = page "Open Data Sheets";
                    }
                    action("OpenDataCollectionAlerts")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Open Data Collection Alerts';
                        RunObject = page "Open Data Collection Alerts";
                    }
                    action("DataCollectionLogGroups")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Data Collection Log Groups';
                        RunObject = page "Data Collection Log Groups";
                    }
                    action("CompletedDataSheets")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Completed Data Sheets';
                        RunObject = page "Completed Data Sheets";
                    }
                    action("ClosedDataCollectionAlerts")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Closed Data Collection Alerts';
                        RunObject = page "Closed Data Collection Alerts";
                    }
                    group("QCDataCollectionSetup")
                    {
                        Caption = 'Setup';
                        action("DataCollectionDataElements")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Data Collection Data Elements';
                            RunObject = page "Data Collection Data Elements";
                        }
                        action("SetupDataCollectionLogGroups")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Data Collection Log Groups';
                            RunObject = page "Data Collection Log Groups";
                        }
                        action("DataCollectionAlertGroups")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Data Collection Alert Groups';
                            RunObject = page "Data Collection Alert Groups";
                        }
                        action("DataCollectionTemplates")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Data Collection Templates';
                            RunObject = page "Data Collection Templates";
                        }
                    }
                }
            }
            group("Resource")
            {
                Caption = 'Resource';
                // action("TimeEntryJournal")
                // {
                //     Caption = 'Time Entry Journal';
                //     RunObject = page "Production Time Entry Journal";
                // }
            }
            group("Sales")
            {
                Caption = 'Sales and Marketing';
                group("SalesOrderProcessing")
                {
                    Caption = 'Order Processing';
                    action("StandingSalesOrders")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Standing Sales Orders';
                        RunObject = page "Standing Orders";
                    }
                    action("TerminalMarketSalesOrders")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Terminal Market Sales Orders';
                        RunObject = page "Term. Market Sales Order List";
                    }
                    action("SalesPayments")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales Payments';
                        RunObject = page "Sales Payment List";
                    }
                    action("SalesMakeDeliveryOrders")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Make Delivery Orders';
                        RunObject = report "Make Delivery Orders";
                    }
                    action("SalesOrderShipping")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Order Shipping';
                        RunObject = page "Order Shipping";
                    }
                    action("SalesOrderReceiving")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Order Receiving';
                        RunObject = page "Order Receiving";
                    }
                    action("SalesBoard")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales Board';
                        RunObject = page "Sales Board";
                    }
                    group("SalesOrderProcessingHistory")
                    {
                        Caption = 'Registers/Entries';
                        action("PostedSalesPayments")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Posted Sales Payments';
                            RunObject = page "Posted Sales Payment List";
                        }
                        action("PostedSalesPaymentsReport")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Sales Payments';
                            RunObject = report "Sales Payment - Posted";
                        }
                    }
                    group("SalesOrderProcessingRpts")
                    {
                        Caption = 'Reports';
                        action("SalesPaymentDailyDetail")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Sales Payment - Daily Detail';
                            RunObject = report "Sales Payment - Daily Detail";
                        }
                    }
                }
                group("SalesInventoryPricing")
                {
                    Caption = 'Inventory and Pricing';
                    action("SalesContractS")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales Contracts';
                        RunObject = page "Sales Contract List";
                    }
                    action("SalesInventoryPricingOffInvoiceAllowances")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Off-Invoice Allowances';
                        RunObject = page "Off-Invoice Allowance List";
                    }
                    action("SalesPrices")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales Prices';
                        RunObject = page "Sales Prices";
                    }
                    action("SalesPriceWorksheet")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales Price Worksheet';
                        RunObject = page "Enhanced Sales Price Worksheet";
                    }
                    action("UpdateSalesDocumentCost")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Update Sales Document Cost';
                        RunObject = report "Update Sales Document Cost";
                    }
                    group("SalesInventoryPricingRpts")
                    {
                        Caption = 'Reports';
                        action("QuantitySalesbyCustomerItem")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Quantity Sales by Customer/Item';
                            RunObject = report "Qty. Sales by Customer/Item";
                        }
                        action("QuantitySalesbyItemCategory")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Quantity Sales by Item Category';
                            RunObject = report "Qty. Sales by Item Category";
                        }
                        action("SalesBelowPrice")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Sales Below Price';
                            RunObject = report "Sales Below Price";
                        }
                        action("CustomerPriceList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Customer Price List';
                            RunObject = report "Customer Price List";
                        }
                        action("PriceGroupPriceList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Price Group Price List';
                            RunObject = report "Price Group Price List";
                        }
                    }
                    group("SalesinventoryPricingSetup")
                    {
                        Caption = 'Setup';
                        action("RecurringPriceTemplates")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Recurring Price Templates';
                            RunObject = page "Recurring Price Template List";
                        }
                        action("CostCalculationMethods")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Cost Calculation Methods';
                            RunObject = page "Cost Calculation Method List";
                        }
                        action("ItemPriceListSequence")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Item Price List Sequence';
                            RunObject = page "Item Price List Sequence";
                        }
                        action("SalesinventoryPricingSetupOffInvoiceAllowances")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Off-Invoice Allowances';
                            RunObject = page "Off-Invoice Allowance List";
                        }
                        action("CustomerItemAlternates")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Customer Item Alternates';
                            RunObject = page "Customer Item Alternates";
                        }
                        
                        action("CustomerItemAlternatesList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Customer Item Alternates List';
                            RunObject = page "Customer Item Alternates List";
                        }
                        action("CostBases")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Cost Bases';
                            RunObject = page "Cost Basis List";
                        }
                        action("ItemCostBases")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Item Cost Bases';
                            RunObject = page "Item Cost Basis List";
                        }
                        action("CustomerItemGroupEntry")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Customer/Item Group Entry';
                            RunObject = page "Customer/Item Group Entry";
                        }
                    }
                }
            }
            group("Service")
            {
                Caption = 'Service';
            }
            group("Whse")
            {
                Caption = 'Warehouse';
                group("WhsePlanning")
                {
                    Caption = 'Planning and Execution';
                    action("BinStatus")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Bin Status';
                        RunObject = page "Bin Status";
                    }
                    action("WhseOrderReceiving")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Order Receiving';
                        RunObject = page "Order Receiving";
                    }
                    action("WhseOrderShipping")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Order Shipping';
                        RunObject = page "Order Shipping";
                    }
                    action("ProductionPicking")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Production Picking';
                        RunObject = page "Production Picking";
                    }
                    action("WarehouseStagedPicks")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Warehouse Staged Picks';
                        RunObject = page "Whse. Staged Pick List";
                    }
                    action("BinReclassificationJournal")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Bin Reclassification Journal';
                        RunObject = page "Bin Reclass. Journal";
                    }
                    group("WhsePlanningRpts")
                    {
                        Caption = 'Reports';
                        action("PutAwayMoveList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Put-Away Move List';
                            RunObject = report "Put-Away Move List";
                        }
                        action("ShptReplenishmentMoveList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Shpt. Replenishment/Move List';
                            RunObject = report "Shpt. Replenishment/Move List";
                        }
                        action("ShptMoveListbyOrder")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Shpt. Move List by Order';
                            RunObject = report "Shpt. Move List by Order";
                        }
                        action("ShptMoveListbyRoute")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Shpt. Move List by Route';
                            RunObject = report "Shpt. Move List by Route";
                        }
                        action("ProdReplenishmentMoveList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Prod. Replenishment/Move List';
                            RunObject = report "Prod. Replenishment/Move List";
                        }
                    }
                }
                group("WhseDistr")
                {
                    Caption = 'Distribution Planning';
                    group("WhseDistrInbound")
                    {
                        Caption = 'Inbound';
                        action("PickupLoads")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Pickup Loads';
                            RunObject = page "Pickup Load List";
                        }
                        action("WhseTruckloadReceiving")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Truckload Receiving';
                            RunObject = page "Truckload Receiving";
                        }
                    }
                    group("WhseDistrOutbound")
                    {
                        Caption = 'Outbound';
                        action("DeliveryTripList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Delivery Trips';
                            RunObject = page "N138 Delivery Trip List";
                        }
                        action("WhseDistrOutboundMakeDeliveryOrders")
                        {
                            ApplicationArea = FOODBasic;                            
                            Caption = 'Make Delivery Orders';
                            RunObject = report "Make Delivery Orders";
                        }
                        action("PostedDeliveryRouteReview")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Posted Delivery Route Review';
                            RunObject = page "Posted Delivery Route Review";
                        }
                    }
                    group("WhseDistrRpts")
                    {
                        Caption = 'Reports';
                        action("ProjectedShortageList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Projected Shortage List';
                            RunObject = report "Projected Shortage List";
                        }
                        action("TruckLoadingSheet")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Truck Loading Sheet';
                            RunObject = report "Truck Loading Sheet";
                        }
                        action("DeliveryTripRouteSheet")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Delivery Trip Route Sheet';
                            RunObject = report "Delivery Trip Route Sheet";
                        }
                        action("PickupLoadSheet")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Pickup Load Sheet';
                            RunObject = report "Pickup Load Sheet";
                        }
                    }
                    group("WhseDistrSetup")
                    {
                        Caption = 'Setup';
                        action("TransportManagementSetup")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Transport Management Setup';
                            RunObject = page "N138 Transport Mgt. Setup";
                        }
                        action("DeliveryRoutes")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Delivery Routes';
                            RunObject = page "Delivery Route List";
                        }
                        action("DeliveryDrivers")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Delivery Drivers';
                            RunObject = page "Delivery Driver List";
                        }
                        action("DeliveryTrucks")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Delivery Trucks';
                            RunObject = page "Delivery Truck List";
                        }
                        action("PickClasses")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Pick Classes';
                            RunObject = page "Pick Classes";
                        }
                        action("LoadingDocks")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Loading Docks';
                            RunObject = page "N138 Loading Docks";
                        }
                    }
                }
                group("WhseInv")
                {
                    Caption = 'Inventory';
                    group("WhseInvContainers")
                    {
                        Caption = 'Containers';
                        action("Containers")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Containers';
                            RunObject = page "Containers";
                        }
                        action("ContainerJournal")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Container Journal';
                            RunObject = page "Container Journal";
                        }
                        action("ShippedContainers")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Shipped Containers';
                            RunObject = page "Shipped Containers";
                        }
                        group("WhseInvContainersRpts")
                        {
                            Caption = 'Reports';
                            action("ContainerJournalTest")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Container Journal - Test';
                                RunObject = report "Container Journal - Test";
                            }
                            action("ContainerRegister")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Container Register';
                                RunObject = report "Container Register";
                            }
                        }
                    }
                    group("WhseInvRepack")
                    {
                        Caption = 'Repack';
                        action("OpenRepackOrders")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Open Repack Orders';
                            RunObject = page "Open Repack Orders";
                        }
                        action("FinishedRepackOrders")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Finished Repack Orders';
                            RunObject = page "Finished Repack Orders";
                        }
                        group("WhseInvRepackRpts")
                        {
                            Caption = 'Reports';
                            action("RepackOrderSummary")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Repack Order Summary';
                                RunObject = report "Repack Order Summary";
                            }
                        }
                        group("WhseInvRepackDocs")
                        {
                            Caption = 'Documents';
                            action("RepackOrder")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Repack Order';
                                RunObject = report "Repack Order";
                            }
                        }
                    }
                    group("WhseInvLots")
                    {
                        Caption = 'Lots';
                        action("LotHistory")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Lot History';
                            RunObject = page "Lots";
                        }
                        action("ItemLotAvailability")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Item Lot Availability';
                            RunObject = page "Item Lot Availability";
                        }
                        action("ItemLotReservations")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Item Lot Reservations';
                            RunObject = page "Item Lot Reservations";
                        }
                        action("LotSummary")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Lot Summary';
                            RunObject = page "Lot Summary";
                        }
                        action("LotTracing")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Lot Tracing';
                            RunObject = page "Lot Tracing";
                        }
                        action("MultipleLotTrace")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Multiple Lot Trace';
                            RunObject = page "Multiple Lot Trace";
                        }
                        // P800129613
                        action(CreateSubLot)
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Create Sub-Lot';
                            Ellipsis = true;
                            Image = LotProperties;
                            RunObject = page "Create Sub-Lot Wizard";
                        }
                        action("ConvertItemstoLotControlled")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Convert Items to Lot Controlled';
                            RunObject = page "Lot Control Items";
                        }
                        group("WhseInvLotsRpts")
                        {
                            Caption = 'Reports';
                            action("WhseInvLotsRptsItemLotsbyExpirationDate")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Item Lots by Expiration Date';
                                RunObject = report "Item Lots by Expiration Date";
                            }
                            action("ItemLotAvailabilityReport")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Item Lot Availability';
                                RunObject = report "Item Lot Availability";
                            }
                            action("LotSettlementReport")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Lot Settlement Report';
                                RunObject = report "Lot Settlement Report";
                            }
                        }
                    }
                    group("WhseInvCommodities")
                    {
                        Caption = 'Commodities';
                        action("CommodityManifests")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Commodity Manifests';
                            RunObject = page "Commodity Manifest List";
                        }
                        action("PostedCommodityManifestList")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Posted Commodity Manifest List';
                            RunObject = page "Posted Comm. Manifest List";
                        }
                    }
                    group("WhseInvSetup")
                    {
                        Caption = 'Setup';
                        action("ContainerTypes")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Container Types';
                            RunObject = page "Container Types";
                        }
                        action("ContainerCharges")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Container Charges';
                            RunObject = page "Container Charges";
                        }
                        action("SupplyChainGroups")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Supply Chain Groups';
                            RunObject = page "Supply Chain Groups";
                        }
                        action("PurchasingGroups")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Purchasing Groups';
                            RunObject = page "Purchasing Groups";
                        }
                        action("UsageFormulas")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Usage Formulas';
                            RunObject = page "Usage Formulas";
                        }
                        action("LotNoCustomFormats")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Lot No. Custom Formats';
                            RunObject = page "Lot No. Custom Formats";
                        }
                        action("LotNoSegmentValues")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Lot No. Segment Values';
                            RunObject = page "Lot No. Segment Values";
                        }
                        action("LotStatusCodes")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Lot Status Codes';
                            RunObject = page "Lot Status Codes";
                        }
                        action("LotAgingCategories")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Lot Aging Categories';
                            RunObject = page "Lot Aging Categories";
                        }
                        action("LotAgingProfiles")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Lot Aging Profiles';
                            RunObject = page "Lot Aging Profiles";
                        }
                        action("Variants")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Variants';
                            RunObject = page "Variants";
                        }
                        action("ProperShippingNames")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Proper Shipping Names';
                            RunObject = page "Proper Shipping Names";
                        }
                        action("WhseInvSetupAllergens")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Allergens';
                            RunObject = page "Allergens";
                        }
                        action("ContainerJournalTemplates")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Container Journal Templates';
                            RunObject = page "Container Journal Templates";
                        }
                    }
                }
            }
        }
    }
}