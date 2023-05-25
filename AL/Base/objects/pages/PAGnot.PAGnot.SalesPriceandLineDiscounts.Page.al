#if not CLEAN21
page 1345 "Sales Price and Line Discounts"
{
    // PRW110.0
    // P8007998, To-Increase, Jack Reynolds, 15 DEC 16
    //   Modified for additional Food fields
    //   Running enhanced pages

    Caption = 'Sales Prices';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Sales Price and Line Disc Buff";
    SourceTableTemporary = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
    ObsoleteTag = '16.0';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = Basic, Suite;
                    OptionCaption = ' ,Discount,Price';
                    ToolTip = 'Specifies if the line is for a sales price or a sales line discount.';
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sales type of the price or discount. The sales type defines whether the sales price or discount is for an individual customer, a customer discount group, or for all customers.';
                }
                field("Sales Code"; Rec."Sales Code")
                {
                    ApplicationArea = All;
                    Enabled = SalesCodeIsVisible;
                    ToolTip = 'Specifies the sales code of the price or discount. The sales code depends on the value in the Sales Type field. The code can represent an individual customer, a customer discount group, or for all customers.';
                    Visible = SalesCodeIsVisible;
                }
                field(Type; Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the discount is valid for an item or for an item discount group.';
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Enabled = CodeIsVisible;
                    ToolTip = 'Specifies a code for the sales line price or discount.';
                    Visible = CodeIsVisible;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that must be entered on the sales document to warrant the sales price or discount.';
                }
                field("Maximum Quantity"; Rec."Maximum Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Visible = EnhancedPricing;
                }
                field("Line Discount Type"; Rec."Line Discount Type")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = "Line Type" = 2;
                    Visible = EnhancedPricing;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = "Line Type" = 1;
                    HideValue = "Line Type" = 2;
                    ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = "Line Type" = 2;
                    Visible = EnhancedPricing;
                }
                field("Special Price"; Rec."Special Price")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Special Price';
                    HideValue = "Line Type" = 1;
                    Visible = EnhancedPricing;
                }
                field("Price Type"; Rec."Price Type")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = "Line Type" = 1;
                    Visible = EnhancedPricing;
                }
                field("Pricing Method"; Rec."Pricing Method")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = "Line Type" = 1;
                    Visible = EnhancedPricing;
                }
                field("Cost Adjustment"; Rec."Cost Adjustment")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = "Line Type" = 1;
                    Visible = EnhancedPricing;
                }
                field("Cost Reference"; Rec."Cost Reference")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = "Line Type" = 1;
                    Visible = EnhancedPricing;
                }
                field("Cost Calc. Method Code"; Rec."Cost Calc. Method Code")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = "Line Type" = 1;
                    Visible = EnhancedPricing;
                }
                field("Price Rounding Method"; Rec."Price Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                    HideValue = "Line Type" = 1;
                    Visible = EnhancedPricing;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = "Line Type" = 2;
                    HideValue = "Line Type" = 1;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field("FORMAT(""Use Break Charge"")"; Format(Rec."Use Break Charge"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Use Break Charge';
                    HideValue = "Line Type" = 1;
                    Visible = EnhancedPricing;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date from which the sales line discount is valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date to which the sales line discount is valid.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency that must be used on the sales document line to warrant the sales price or discount.';
                    Visible = false;
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the price that is granted includes VAT.';
                    Visible = false;
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if an invoice discount will be calculated when the sales price is offered.';
                    Visible = false;
                }
                field("VAT Bus. Posting Gr. (Price)"; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT business posting group for customers who you want to apply the sales price to. This price includes VAT.';
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the variant that must be used on the sales document line to warrant the sales price or discount.';
                    Visible = false;
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if line discounts are allowed.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Filtering)
            {
                Caption = 'Filtering';
            }
            action("Show Current Only")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Current Only';
                Image = ActivateDiscounts;
                ToolTip = 'Show only valid price and discount agreements that have ending dates later than today''s date.';

                trigger OnAction()
                begin
                    FilterToActualRecords();
                end;
            }
            action("Show All")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show All';
                Image = DeactivateDiscounts;
                ToolTip = 'Show all price and discount agreements, including those with ending dates earlier than today''s date.';

                trigger OnAction()
                begin
                    Reset();
                end;
            }
            action("Refresh Data")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh Data';
                Image = RefreshLines;
                ToolTip = 'Update sales prices or sales line discounts with values that other users may have added for the customer since you opened the window.';

                trigger OnAction()
                var
                    Customer: Record Customer;
                    Item: Record Item;
                begin
                    if GetLoadedItemNo() <> '' then
                        if Item.Get(GetLoadedItemNo()) then begin
                            LoadDataForItem(Item);
                            exit;
                        end;
                    if Customer.Get(GetLoadedCustNo()) then
                        LoadDataForCustomer(Customer)
                end;
            }
            action("Set Special Prices")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Special Prices';
                Image = Price;
                ToolTip = 'Set up different prices for items that you sell to the customer. An item price is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                trigger OnAction()
                var
                    Item: Record Item;
                    ProcessFns: Codeunit "Process 800 Functions";
                begin
                    // P8007748
                    if Item.Get("Loaded Item No.") then
                        ProcessFns.RunSalesPrices(Item, false);
                    // P8007748
                end;
            }
            action("Set Special Discounts")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Special Discounts';
                Image = LineDiscount;
                ToolTip = 'Set up different discounts for items that you sell to the customer. An item discount is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                trigger OnAction()
                var
                    Item: Record Item;
                    ProcessFns: Codeunit "Process 800 Functions";
                begin
                    // P8007748
                    if Item.Get("Loaded Item No.") then
                        ProcessFns.RunSalesLineDiscounts(Item, false);
                    // P8007748
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("Set Special Prices_Promoted"; "Set Special Prices")
                {
                }
                actionref("Set Special Discounts_Promoted"; "Set Special Discounts")
                {
                }
                actionref("Refresh Data_Promoted"; "Refresh Data")
                {
                }
                actionref("Show Current Only_Promoted"; "Show Current Only")
                {
                }
                actionref("Show All_Promoted"; "Show All")
                {
                }
            }
        }
    }

    trigger OnInit()
    var
        FeaturePriceCalculation: Codeunit "Feature - Price Calculation";
    begin
        FeaturePriceCalculation.FailIfFeatureEnabled();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if ("Loaded Customer No." = GetLoadedCustNo()) and ("Loaded Item No." = GetLoadedItemNo()) then
            exit;

        "Loaded Item No." := GetLoadedItemNo();
        "Loaded Customer No." := GetLoadedCustNo();
        "Loaded Price Group" := GetLoadedPriceGroup();
        "Loaded Disc. Group" := GetLoadedDiscGroup();
    end;

    trigger OnOpenPage()
    var
        Process800Functions: Codeunit "Process 800 Functions";
    begin
        EnhancedPricing := Process800Functions.PricingInstalled; // P8007998
    end;

    var
        loadedItemNo: Code[20];
        loadedCustNo: Code[20];
        loadedPriceGroup: Code[20];
        loadedDiscGroup: Code[20];
        CodeIsVisible: Boolean;
        SalesCodeIsVisible: Boolean;
        [InDataSet]
        EnhancedPricing: Boolean;

    procedure InitPage(ForItem: Boolean)
    begin
        if ForItem then begin
            CodeIsVisible := false;
            SalesCodeIsVisible := true;
        end else begin
            CodeIsVisible := true;
            SalesCodeIsVisible := false;
        end;
    end;

    procedure LoadItem(Item: Record Item)
    begin
        Clear(Rec);
        loadedItemNo := Item."No.";
        loadedDiscGroup := Item."Item Disc. Group";
        loadedPriceGroup := '';

        LoadDataForItem(Item);
    end;

    procedure LoadCustomer(Customer: Record Customer)
    begin
        Clear(Rec);
        loadedCustNo := Customer."No.";
        loadedPriceGroup := Customer."Customer Price Group";
        loadedDiscGroup := Customer."Customer Disc. Group";

        LoadDataForCustomer(Customer);
    end;

    procedure GetLoadedItemNo(): Code[20]
    begin
        exit(loadedItemNo)
    end;

    procedure GetLoadedCustNo(): Code[20]
    begin
        exit(loadedCustNo)
    end;

    local procedure GetLoadedDiscGroup(): Code[20]
    begin
        exit(loadedDiscGroup)
    end;

    local procedure GetLoadedPriceGroup(): Code[20]
    begin
        exit(loadedPriceGroup)
    end;

    local procedure SetSalesPriceFilters(var SalesPrice: Record "Sales Price")
    begin
        SalesPrice.SetCurrentKey("Sales Type", "Sales Code", "Item No.");
        if Rec.Find() then begin
            SalesPrice.SetRange("Sales Type", Rec."Sales Type");
            SalesPrice.SetRange("Sales Code", Rec."Sales Code");
            SalesPrice.SetRange("Item No.", Rec.Code);
        end else begin
            if loadedCustNo <> '' then begin
                SalesPrice.SetRange("Sales Type", Rec."Sales Type"::Customer);
                SalesPrice.SetRange("Sales Code", loadedCustNo);
            end;
            if loadedItemNo <> '' then
                SalesPrice.SetRange("Item No.", loadedItemNo);
        end;
    end;

    local procedure SetSalesLineDiscountFilters(var SalesLineDiscount: Record "Sales Line Discount")
    begin
        SalesLineDiscount.SetCurrentKey("Sales Type", "Sales Code", Type, Code);
        if Rec.Find() then begin
            SalesLineDiscount.SetRange("Sales Type", Rec."Sales Type");
            SalesLineDiscount.SetRange("Sales Code", Rec."Sales Code");
            SalesLineDiscount.SetRange(Type, Rec.Type);
            SalesLineDiscount.SetRange(Code, Rec.Code);
        end else begin
            if loadedCustNo <> '' then begin
                SalesLineDiscount.SetRange("Sales Type", Rec."Sales Type"::Customer);
                SalesLineDiscount.SetRange("Sales Code", loadedCustNo);
            end;
            if loadedItemNo <> '' then begin
                SalesLineDiscount.SetRange(Type, Rec.Type::Item);
                SalesLineDiscount.SetRange(Code, loadedItemNo);
            end;
        end;
    end;

    procedure RunUpdatePriceIncludesVatAndPrices(IncludesVat: Boolean)
    var
        Item: Record Item;
    begin
        Item.Get(loadedItemNo);
        UpdatePriceIncludesVatAndPrices(Item, IncludesVat);
    end;
}
#endif
