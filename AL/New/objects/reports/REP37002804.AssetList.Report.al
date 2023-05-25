report 37002804 "Asset List" // Version: FOODNA
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This is a listing of assets with an option to show details
    // 
    // PRW16.00.01
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Added downtime
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Set RDLC PageWidth and PageHeight to proper values for Landscape
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Asset List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Asset; Asset)
        {
            RequestFilterFields = "No.", Type, "Asset Category Code", "Location Code", "Date Filter";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(DateFilter; DateFilter)
            {
            }
            column(AssetNo; "No.")
            {
                IncludeCaption = true;
            }
            column(AssetDesc; Description)
            {
                IncludeCaption = true;
            }
            column(AssetType; Type)
            {
                IncludeCaption = true;
            }
            column(AssetLocationCode; "Location Code")
            {
                IncludeCaption = true;
            }
            column(AssetStatus; Status)
            {
                IncludeCaption = true;
            }
            column(AssetAssetCategoryCode; "Asset Category Code")
            {
            }
            column(AssetUsageUOM; "Usage Unit of Measure")
            {
            }
            column(AssetTotalCost; "Total Cost")
            {
                IncludeCaption = true;
            }
            column(AssetLaborCost; "Labor Cost")
            {
                IncludeCaption = true;
            }
            column(AssetMaterialCost; "Material Cost")
            {
                IncludeCaption = true;
            }
            column(AssetContractCost; "Contract Cost")
            {
                IncludeCaption = true;
            }
            column(AssetPhysicalLocation; "Physical Location")
            {
                IncludeCaption = true;
            }
            column(AssetDowntimeHrs; "Downtime (Hours)")
            {
                IncludeCaption = true;
            }
            column(AssetManufacturerCode; "Manufacturer Code")
            {
                IncludeCaption = true;
            }
            column(AssetModelNo; "Model No.")
            {
                IncludeCaption = true;
            }
            column(AssetSerialNo; "Serial No.")
            {
                IncludeCaption = true;
            }
            column(AssetVendorNo; "Vendor No.")
            {
                IncludeCaption = true;
            }
            column(AssetManufactureDate; "Manufacture Date")
            {
                IncludeCaption = true;
            }
            column(AssetPurchaseDate; "Purchase Date")
            {
                IncludeCaption = true;
            }
            column(AssetInstallationDate; "Installation Date")
            {
                IncludeCaption = true;
            }
            column(AssetOverhaulDate; "Overhaul Date")
            {
                IncludeCaption = true;
            }
            column(AssetWarrantyDate; "Warranty Date")
            {
                IncludeCaption = true;
            }
            column(HideEquipment; HideEquipment)
            {
            }
            column(AssetModelYear; "Model Year")
            {
                IncludeCaption = true;
            }
            column(AssetVIN; VIN)
            {
                IncludeCaption = true;
            }
            column(AssetRegistrationNo; "Registration No.")
            {
                IncludeCaption = true;
            }
            column(AssetRegistrationExpDate; "Registration Expiration Date")
            {
            }
            column(AssetGrossWeight; "Gross Weight")
            {
            }
            column(AssetGrossWeightUOM; "Gross Weight Unit of Measure")
            {
            }
            column(HideVehicle; HideVehicle)
            {
            }
            column(AssetAreaUOM; "Area Unit of Measure")
            {
            }
            column(AssetArea; Area)
            {
                IncludeCaption = true;
            }
            column(HideFacility; HideFacility)
            {
            }

            trigger OnAfterGetRecord()
            begin
                // P8000671
                HideEquipment := (not ShowDetail) or (Type <> Type::Equipment);
                HideVehicle := (not ShowDetail) or (Type <> Type::Vehicle);
                HideFacility := (not ShowDetail) or (Type <> Type::Facility);
                // P8000671
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
                    field(ShowDetail; ShowDetail)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Detail';
                    }
                }
            }
        }

        actions
        {
        }
    }

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/AssetList.rdlc';
        }
    }

    labels
    {
        DateFormat = 'MM/dd/yy';
        AssetCaption = 'Asset';
        OFCaption = 'of';
        PageNoCaption = 'Page';
        AssetCategoryCaption = 'Asset Category';
        UsageUOMCaption = 'Usage UOM';
        RegistrationExpDateCaption = 'Reg. Exp. Date';
        GrossWeightCaption = 'Gross Wt.';
    }

    trigger OnPreReport()
    begin
        DateFilter := Asset.GetFilter("Date Filter");
    end;

    var
        DateFilter: Text[250];
        ShowDetail: Boolean;
        [InDataSet]
        HideEquipment: Boolean;
        [InDataSet]
        HideVehicle: Boolean;
        [InDataSet]
        HideFacility: Boolean;
}

