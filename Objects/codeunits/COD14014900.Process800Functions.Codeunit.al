codeunit 14014900 "Process 800 Functions"
{
    // PR2.00
    //   Relocate CurrentRelease to Application Management codeunit
    // 
    // PR2.00.04
    //   Function to test for document management
    // 
    // PR3.60
    //   Changed functions to use License Permission table
    //   Added functions for Alternate Quantities and Co/By-Products
    // 
    // PR3.61
    //   Added functions for Accruals, Grower Accounting, Appt. Scheduling,
    //     Ag. Code, Container Tracking
    // 
    // PR3.70
    //   Remove Accrulas. Grower Accounting, Appt. Scheduling, Ag. Code
    //   Added functions for MSDS
    //   Enable demo mode permissions
    // 
    // PR3.70.01
    //   Add functions for FreshPro, Data Collection granule
    // 
    // PR3.70.02
    //   Add functions for Labels granule
    // 
    // PR3.70.03
    //   Add function for Accruals granule
    // 
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // P8000176A, Myers Nissi, Jack Reynolds, 01 FEB 05
    //   QCInstalled - check read permission on Quality Control Header
    // 
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Maintenance Management
    // 
    // P8000396A, VerticalSoft, Jack Reynolds, 03 OCT 06
    //   Function to set work date for demo companies
    // 
    // PR4.00.05
    // P8000413A, VerticalSoft, Jack Reynolds, 14 NOV 06
    //   SetUIDOffset function
    // 
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Support for repack orders
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   SetDemoPermissions - modify to use APPLICATIONPATH to fron "P800 Config.txt"
    //   Don't prompt for UID Offset if DEMO database
    // 
    // PRW15.00.01
    // P8000523A, VerticalSoft, Jack Reynolds, 14 SEP 07
    //   Change default selection for UIDOffset
    // 
    // P8000543A, VerticalSoft, Jack Reynolds, 14 NOV 07
    //   Support for Advanced Warehouse
    // 
    // PRW15.00.02
    // P8000616A, VerticalSoft, Jack Reynolds, 01 AUG 08
    //   Fix problem determining granule permission with solution developer license
    // 
    // PRW16.00.03
    // P8000814, VerticalSoft, Jack Reynolds, 14 APR 10
    //   Update for change to developer license number
    // 
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // P8000859, VerticalSoft, Jack Reynolds, 24 AUG 10
    //   Allow selection of Role Center at startup
    // 
    // P8000869, VerticalSoft, Jack Reynolds, 27 SEP 10
    //   Rename MRPInstalled to ForecastInstalled
    // 
    // PRW16.00.05
    // P8000990, Columbus IT, Jack Reynolds, 26 OCT 11
    //   Support for Default Date in ADC transactions
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001177, Columbus IT, Jack Reynolds, 03 JUL 13
    //   Remove demo permissions
    //   Use product regestration
    // 
    // PRW17.10.02
    // P8001282, Columbus IT, Jack Reynolds, 07 FEB 14
    //   Fix problem with getting system indicator from web service
    // 
    // PRW19.00.01
    // P8007118, To Increase, Jack Reynolds, 01 JUN 16
    //   Function to check for basic warehouse granule
    // 
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // P8008185, To-Increase, Dayakar Battini, 20 JAN 17
    //   Item Lifecycle Management
    // 
    // P8008186, To-Increase, Dayakar Battini, 20 JAN 17
    //   Document Lifecycle Management
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   Running enhanced pages
    // 
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    SingleInstance = true;


    local procedure IsTableReadAllowed(TableNo: Integer): Boolean
    var
        LicensePermission: Record "License Permission";
    begin
        with LicensePermission do begin
            if ("Object Number" <> TableNo) then
                Get("Object Type"::Table, TableNo); // P8000616A
            exit("Read Permission" = "Read Permission"::Yes);
        end;
    end;

    local procedure IsCodeunitReadAllowed(CodeunitNo: Integer): Boolean
    var
        LicensePermission: Record "License Permission";
    begin
        with LicensePermission do begin
            if ("Object Number" <> CodeunitNo) then
                Get("Object Type"::Codeunit, CodeunitNo);
            exit("Read Permission" = "Read Permission"::Yes);
        end;
    end;

    procedure ForecastInstalled(): Boolean
    begin
        // P8000869 - function renamed from MRPInstalled
        exit(IsTableReadAllowed(DATABASE::"Production Forecast Entry"));
    end;

    procedure TrackingInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Lot Specification"));
    end;

    procedure PricingInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Recurring Price Template"));
    end;

    procedure DistPlanningInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Delivery Route"));
    end;

    procedure AltQtyInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Alternate Quantity Line"));
    end;

    procedure ProcessInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Process Setup"));
    end;

    procedure QCInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Quality Control Header")); // P8000176A
    end;

    procedure CoProductsInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Process Order Request Line"));
    end;

    procedure ContainerTrackingInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Container Header")); //PR3.61
    end;

    procedure FreshProInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Item Lot Availability"));
    end;

    procedure AccrualsInstalled(): Boolean
    begin
        exit(IsTableReadAllowed(DATABASE::"Accrual Plan"));
    end;

    procedure DedMgtInstalled(): Boolean
    begin
        // P8000170A
        exit(IsTableReadAllowed(DATABASE::"Deduction Line"));
    end;

    procedure MaintenanceInstalled(): Boolean
    begin
        // P8000333A
        exit(IsTableReadAllowed(DATABASE::"Maintenance Ledger"));
    end;

    procedure RepackInstalled(): Boolean
    begin
        // P8000496A
        exit(IsTableReadAllowed(DATABASE::"Repack Order"));
    end;

    procedure WhseInstalled(): Boolean
    begin
        // P8007118
        exit(IsTableReadAllowed(DATABASE::"Replenishment Area"));
    end;

    procedure AdvWhseInstalled(): Boolean
    begin
        // P8000543A
        exit(IsTableReadAllowed(DATABASE::"Whse. Staged Pick Header"));
    end;

    procedure CommCostInstalled(): Boolean
    begin
        // P8000856
        exit(IsTableReadAllowed(DATABASE::"Commodity Class"));
    end;

    procedure ProcessDataCollectionInstalled(): Boolean
    begin
        // P8001090
        exit(IsTableReadAllowed(DATABASE::"Data Sheet Header"));
    end;

    procedure AllergenInstalled(): Boolean
    begin
        // P8006959
        exit(IsTableReadAllowed(DATABASE::"Allergen"));
    end;

    procedure SetDemoWorkDate()
    var
        DefaultDate: Date;
    begin
        // P8000990
        if CurrentExecutionMode = EXECUTIONMODE::Debug then
            exit;

        DefaultDate := GetDemoDate;
        if DefaultDate <> WorkDate then begin
            WorkDate := DefaultDate;
            // Message(Text37002001, WorkDate); // P800-MegaApp
        end;
    end;

    procedure GetDemoDate() DefaultDate: Date
    var
        AcctPer: Record "Accounting Period";
        P800Globals: Codeunit "Process 800 System Globals";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        // P8000990
        DefaultDate := Today;

        if SerialNumber <> P800Globals.DeveloperLicenseNo then // P8000814
            exit;

        if not CompanyInformationMgt.IsDemoCompany() then
            exit;

        if AcctPer.Find('-') then
            exit(DMY2Date(15, 7, Date2DMY(AcctPer."Starting Date", 3) + 2));
    end;

    procedure RunSalesPrices(SourceRec: Variant; Modal: Boolean)
    var
        SourceRecRef: RecordRef;
        SalesPrice: Record "Sales Price";
        CustomerPriceGroup: Record "Customer Price Group";
        Customer: Record Customer;
        Item: Record Item;
        Campaign: Record Campaign;
    begin
        // P8007748
        if SourceRec.IsRecord then begin
            SourceRecRef.GetTable(SourceRec);

            case SourceRecRef.Number of
                DATABASE::"Customer Price Group":
                    begin
                        CustomerPriceGroup := SourceRec;
                        SalesPrice.SetCurrentKey("Sales Type", "Sales Code");
                        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
                        SalesPrice.SetRange("Sales Code", CustomerPriceGroup.Code);
                        SalesPrice."Sales Type" := SalesPrice."Sales Type"::"Customer Price Group";
                        SalesPrice."Sales Code" := CustomerPriceGroup.Code;
                    end;
                DATABASE::Customer:
                    begin
                        Customer := SourceRec;
                        SalesPrice.SetCurrentKey("Sales Type", "Sales Code");
                        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Customer);
                        SalesPrice.SetRange("Sales Code", Customer."No.");
                        SalesPrice."Sales Type" := SalesPrice."Sales Type"::Customer;
                        SalesPrice."Sales Code" := Customer."No.";
                    end;
                DATABASE::Item:
                    begin
                        Item := SourceRec;
                        SalesPrice.SetCurrentKey("Item Type", "Item Code");
                        SalesPrice.SetRange("Item Type", SalesPrice."Item Type"::Item);
                        SalesPrice.SetRange("Item Code", Item."No.");
                        SalesPrice."Item Type" := SalesPrice."Item Type"::Item;
                        SalesPrice."Item Code" := Item."No.";
                    end;
                DATABASE::Campaign:
                    begin
                        Campaign := SourceRec;
                        SalesPrice.SetCurrentKey("Sales Type", "Sales Code");
                        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Campaign);
                        SalesPrice.SetRange("Sales Code", Campaign."No.");
                        SalesPrice."Sales Type" := SalesPrice."Sales Type"::Campaign;
                        SalesPrice."Sales Code" := Campaign."No.";
                    end;
            end;
        end;

        if Modal then
            PAGE.RunModal(PageToRun(PricingInstalled, PAGE::"Sales Prices", PAGE::"Enhanced Sales Prices"), SalesPrice)
        else
            PAGE.Run(PageToRun(PricingInstalled, PAGE::"Sales Prices", PAGE::"Enhanced Sales Prices"), SalesPrice);
    end;

    procedure RunSalesLineDiscounts(SourceRec: Variant; Modal: Boolean)
    var
        SourceRecRef: RecordRef;
        SalesLineDiscount: Record "Sales Line Discount";
        Customer: Record Customer;
        Item: Record Item;
        CustomerDiscountGroup: Record "Customer Discount Group";
        ItemDiscountGroup: Record "Item Discount Group";
        Campaign: Record Campaign;
    begin
        // P8007748
        if SourceRec.IsRecord then begin
            SourceRecRef.GetTable(SourceRec);

            case SourceRecRef.Number of
                DATABASE::Customer:
                    begin
                        Customer := SourceRec;
                        SalesLineDiscount.SetCurrentKey("Sales Type", "Sales Code");
                        SalesLineDiscount.SetRange("Sales Type", SalesLineDiscount."Sales Type"::Customer);
                        SalesLineDiscount.SetRange("Sales Code", Customer."No.");
                        SalesLineDiscount."Sales Type" := SalesLineDiscount."Sales Type"::Customer;
                        SalesLineDiscount."Sales Code" := Customer."No.";
                    end;
                DATABASE::Item:
                    begin
                        Item := SourceRec;
                        SalesLineDiscount.SetCurrentKey("Item Type", "Item Code");
                        SalesLineDiscount.SetRange("Item Type", SalesLineDiscount."Item Type"::Item);
                        SalesLineDiscount.SetRange("Item Code", Item."No.");
                        SalesLineDiscount."Item Type" := SalesLineDiscount."Item Type"::Item;
                        SalesLineDiscount."Item Code" := Item."No.";
                    end;
                DATABASE::"Customer Discount Group":
                    begin
                        CustomerDiscountGroup := SourceRec;
                        SalesLineDiscount.SetCurrentKey("Sales Type", "Sales Code");
                        SalesLineDiscount.SetRange("Sales Type", SalesLineDiscount."Sales Type"::"Customer Disc. Group");
                        SalesLineDiscount.SetRange("Sales Code", CustomerDiscountGroup.Code);
                        SalesLineDiscount."Sales Type" := SalesLineDiscount."Sales Type"::"Customer Disc. Group";
                        SalesLineDiscount."Sales Code" := CustomerDiscountGroup.Code;
                    end;
                DATABASE::"Item Discount Group":
                    begin
                        ItemDiscountGroup := SourceRec;
                        SalesLineDiscount.SetCurrentKey("Item Type", "Item Code");
                        SalesLineDiscount.SetRange("Item Type", SalesLineDiscount."Item Type"::"Item Disc. Group");
                        SalesLineDiscount.SetRange("Item Code", ItemDiscountGroup.Code);
                        SalesLineDiscount."Item Type" := SalesLineDiscount."Item Type"::"Item Disc. Group";
                        SalesLineDiscount."Item Code" := ItemDiscountGroup.Code;
                    end;
                DATABASE::Campaign:
                    begin
                        Campaign := SourceRec;
                        SalesLineDiscount.SetCurrentKey("Sales Type", "Sales Code");
                        SalesLineDiscount.SetRange("Sales Type", SalesLineDiscount."Sales Type"::Campaign);
                        SalesLineDiscount.SetRange("Sales Code", Campaign."No.");
                        SalesLineDiscount."Sales Type" := SalesLineDiscount."Sales Type"::Campaign;
                        SalesLineDiscount."Sales Code" := Campaign."No.";
                    end;
            end;
        end;

        if Modal then
            PAGE.RunModal(PageToRun(PricingInstalled, PAGE::"Sales Line Discounts", PAGE::"Enhanced Sales Line Discounts"), SalesLineDiscount)
        else
            PAGE.Run(PageToRun(PricingInstalled, PAGE::"Sales Line Discounts", PAGE::"Enhanced Sales Line Discounts"), SalesLineDiscount);
    end;

    procedure RunSalesPriceWorksheet(SourceRec: Variant; Modal: Boolean)
    var
        SalesPriceWorksheet: Record "Sales Price Worksheet";
        PageID: Integer;
    begin
        // P8007748
        if Modal then
            PAGE.RunModal(PageToRun(PricingInstalled, PAGE::"Sales Price Worksheet", PAGE::"Enhanced Sales Price Worksheet"), SalesPriceWorksheet)
        else
            PAGE.Run(PageToRun(PricingInstalled, PAGE::"Sales Price Worksheet", PAGE::"Enhanced Sales Price Worksheet"), SalesPriceWorksheet);
    end;

    procedure RunPhysInventoryJournal(Modal: Boolean)
    begin
        // P8007748
        if Modal then
            PAGE.RunModal(PageToRun(TrackingInstalled, PAGE::"Phys. Inventory Journal", PAGE::"Phys. Inv. Jnl. w/ Tracking"))
        else
            PAGE.Run(PageToRun(TrackingInstalled, PAGE::"Phys. Inventory Journal", PAGE::"Phys. Inv. Jnl. w/ Tracking"));
    end;

    local procedure PageToRun(Enhanced: Boolean; StandardPageID: Integer; EnhancedPageID: Integer): Integer
    begin
        // P8007748
        if Enhanced then
            exit(EnhancedPageID)
        else
            exit(StandardPageID);
    end;

    procedure CreateUpgradeTag(Version: Code[10]; Date: Date; Description: Code[200]): Code[250]
    var
        TagTemplate: Label 'FOOD-%1-%2-%3';
    begin
        exit(StrSubstNo(TagTemplate, Version, Format(Date, 9, '<Year4><Month Text,3><Day,2>'), Description));
    end;
}

