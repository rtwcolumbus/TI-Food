page 37002801 "Asset Card"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Card style form for assets
    // 
    // PRW16.00.01
    // P8000717, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Add link to fixed asset
    // 
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Add controls for downtime
    // 
    // P8000725, VerticalSoft, Jack Reynolds, 27 AUG 09
    //   Add Parent Asset No.
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 06 FEB 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001173, Columbus IT, Jack Reynolds, 20 JUN 13
    //   Support for Apply Template
    // 
    // PRW18.00
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Asset Card';
    PageType = Card;
    SourceTable = Asset;

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
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        SetType;
                        SetSpares;
                        CurrPage.Update;
                    end;
                }
                field("Asset Category Code"; "Asset Category Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Resource No."; "Resource No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Physical Location"; "Physical Location")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Fixed Asset No."; "Fixed Asset No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Parent Asset No."; "Parent Asset No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Total Cost"; "Total Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Labor Cost"; "Labor Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Material Cost"; "Material Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Contract Cost"; "Contract Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Downtime (Hours)"; "Downtime (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    DrillDownPageID = "Completed Work Order List";
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Equipment Detail")
            {
                Caption = 'Equipment Detail';
                Visible = equipment;
                field(ManufacturerCode; "Manufacturer Code")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        SetSpares;
                        CurrPage.Update;
                    end;
                }
                field(ModelNo; "Model No.")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        SetSpares;
                        CurrPage.Update;
                    end;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(VendorNo; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(ManufactureDate; "Manufacture Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(PurchaseDate; "Purchase Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(InstallationDate; "Installation Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(OverhaulDate; "Overhaul Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(WarrantyDate; "Warranty Date")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002000)
                {
                    ShowCaption = false;
                    field(UsageUnitofMeasure; "Usage Unit of Measure")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(UsageReadingFrequency; "Usage Reading Frequency")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                field(LastUsageDate; LastUsageDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Usage Date';
                    Editable = false;
                }
                field(LastUsage; LastUsage)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Last Usage';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("Average ailyUsage"; AvgDailyUsage)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Average Daily Usage';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
            }
            group("Vehicle Detail")
            {
                Caption = 'Vehicle Detail';
                Visible = vehicle;
                field(ManufacturerCode2; "Manufacturer Code")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        SetSpares;
                        CurrPage.Update;
                    end;
                }
                field(ModelNo2; "Model No.")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        SetSpares;
                        CurrPage.Update;
                    end;
                }
                field("Model Year"; "Model Year")
                {
                    ApplicationArea = FOODBasic;
                }
                field(VIN; VIN)
                {
                    ApplicationArea = FOODBasic;
                }
                field(VendorNo2; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Registration No."; "Registration No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Registration Expiration Date"; "Registration Expiration Date")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002018)
                {
                    ShowCaption = false;
                    field("Gross Weight"; "Gross Weight")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Gross Weight Unit of Measure"; "Gross Weight Unit of Measure")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                field(ManufactureDate2; "Manufacture Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(PurchaseDate2; "Purchase Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(InstallationDate2; "Installation Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(OverhaulDate2; "Overhaul Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(WarrantyDate2; "Warranty Date")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002010)
                {
                    ShowCaption = false;
                    field(UsageUnitofMeasure2; "Usage Unit of Measure")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(UsageReadingFrequency2; "Usage Reading Frequency")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                field(LastUsageDate2; LastUsageDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Usage Date';
                    Editable = false;
                }
                field(LastUsage2; LastUsage)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Last Usage';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field(AverageDailyUsage2; AvgDailyUsage)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Average Daily Usage';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
            }
            group("Facility Detail")
            {
                Caption = 'Facility Detail';
                Visible = facility;
                field("Area"; Area)
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
                field("Area Unit of Measure"; "Area Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Promoted;
                }
            }
            part(Spares; "Asset Spare Parts Subform")
            {
                ApplicationArea = FOODBasic;
                Editable = SparesEditable;
                Visible = equipmentorvehicle;
            }
            part("Preventive Maintenance"; "Preventive Maintenance Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Asset No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            part(Control37002070; "Asset Picture")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
            }
            systempart(Control37002032; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002033; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Asset")
            {
                Caption = '&Asset';
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    RunObject = Page "Maint. Ledger Entries";
                    RunPageLink = "Asset No." = FIELD("No.");
                    RunPageView = SORTING("Asset No.", "Entry Type", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                }
                action("Work Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Work Orders';
                    Image = Document;
                    RunObject = Page "Work Order List";
                    RunPageLink = "Asset No." = FIELD("No.");
                    RunPageView = SORTING("Asset No.");
                }
                action("PM Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'PM Orders';
                    Image = Document;
                    RunObject = Page "Preventive Maintenance Orders";
                    RunPageLink = "Asset No." = FIELD("No.");
                    RunPageView = SORTING("Asset No.", "Group Code", "Frequency Code");
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(FOODAsset),
                                  "No." = FIELD("No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(37002801),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                }
                separator(Separator1102603101)
                {
                }
                action("Spare Parts")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Spare Parts';
                    Image = Components;

                    trigger OnAction()
                    begin
                        ShowSpares;
                    end;
                }
                action(DataCollectionLines)
                {
                    ApplicationArea = FOODBasic;
                    AccessByPermission = TableData "Data Collection Line" = R;
                    Caption = 'Data Collection Lines';
                    Image = EditLines;
                    RunObject = Page "Data Collection Lines";
                    RunPageLink = "Source ID" = CONST(37002801),
                                  "Source Key 1" = FIELD("No.");
                }
                action(Usage)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Usage';
                    Ellipsis = true;
                    Image = Troubleshoot;

                    trigger OnAction()
                    begin
                        ShowAssetUsage;
                    end;
                }
            }
            group("&PM")
            {
                Caption = '&PM';
            }
        }
        area(creation)
        {
            action("Work Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Work Order';
                Image = Document;
                RunObject = Page "Work Order";
                RunPageLink = "Asset No." = FIELD("No.");
                RunPageMode = Create;
            }
        }
        area(processing)
        {
            action("Copy Asset")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Copy Asset';
                Ellipsis = true;
                Enabled = "No." <> '';
                Image = CopyFixedAssets;

                trigger OnAction()
                var
                    CopyAsset: Report "Copy Asset";
                begin
                    TestField("Last Date Modified", 0D);
                    CopyAsset.SetAsset(Rec);
                    CopyAsset.RunModal;
                end;
            }
            action("Apply Template")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Apply Template';
                Ellipsis = true;
                Image = ApplyTemplate;

                trigger OnAction()
                var
                    ConfigTemplateMgt: Codeunit "Config. Template Management";
                    RecRef: RecordRef;
                begin
                    // P8001173
                    RecRef.GetTable(Rec);
                    ConfigTemplateMgt.UpdateFromTemplateSelection(RecRef);
                end;
            }
        }
        area(reporting)
        {
            action("Asset History")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Asset History';
                Image = History;
                RunObject = Report "Asset History";
            }
        }
        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'New';

                actionref(WorkOrder_Promoted; "Work Order")
                {
                }
            }
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CopyAsset_Promoted; "Copy Asset")
                {
                }
                actionref(ApplyTemplate_Promoted; "Apply Template")
                {
                }
                actionref(WorkOrders_Promoted; "Work Orders")
                {
                }
                actionref(PMOrders_Promoted; "PM Orders")
                {
                }
                actionref(SpareParts_Promoted; "Spare Parts")
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Reports';

                actionref(AssetHistory_Promoted; "Asset History")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetLastUsage(LastUsageDate, LastUsage, AvgDailyUsage);

        SetType;
        SetSpares;
    end;

    var
        LastUsageDate: Date;
        LastUsage: Decimal;
        AvgDailyUsage: Decimal;
        PMActive: Boolean;
        [InDataSet]
        Equipment: Boolean;
        [InDataSet]
        Vehicle: Boolean;
        [InDataSet]
        Facility: Boolean;
        [InDataSet]
        EquipmentORVehicle: Boolean;
        [InDataSet]
        SparesEditable: Boolean;

    procedure SetType()
    begin
        Equipment := Type = Type::Equipment;
        Vehicle := Type = Type::Vehicle;
        Facility := Type = Type::Facility;
        EquipmentORVehicle := Equipment or Vehicle;
    end;

    procedure SetSpares()
    var
        Visible: Boolean;
        Editable: Boolean;
    begin
        SparesEditable := ("Manufacturer Code" <> '') and ("Model No." <> ''); // P8000844
        if EquipmentORVehicle then
            CurrPage.Spares.PAGE.SetFilter("Manufacturer Code", "Model No.");
    end;
}

