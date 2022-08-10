codeunit 37002133 "Batch Update Accrual Plans"
{
    // PRW16.00.04
    // P8000882, VerticalSoft, Ron Davidson, 22 NOV 10
    //   Spin through Accrual Plans and update according to current Views.
    // 
    // PRW19.00.01
    // P8007287, To-Increase, Dayakar Battini, 21 JUN 16
    //   Wrong declaration of Text Constant Text002 fixed.


    trigger OnRun()
    begin
        if GuiAllowed then
            Confirmed := Confirm(Text000, false)
        else
            Confirmed := true;
        if Confirmed then begin
            UpdatePlans;
            if GuiAllowed then
                Message(Text001);
        end;
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        Text000: Label 'This will update Accrual Plans with their current Customer, Vendor, and Item Views.';
        Text001: Label 'Accrual Plans were updated successfully!';
        Window: Dialog;
        Text002: Label 'Now Processing Accrual Plan No.: #1###########';
        Confirmed: Boolean;
        AccrualPlan: Record "Accrual Plan";

    procedure UpdatePlans()
    begin
        with AccrualPlan do begin
            if GuiAllowed then
                Window.Open(Text002);
            SetRange("Source Selection", "Source Selection"::Specific);
            SetFilter("Start Date", '<= %1', Today);
            SetFilter("End Date", '%1|>= %1', 0D, Today);
            if Find('-') then
                repeat
                    if GuiAllowed then
                        Window.Update(1, "No.");
                    case Type of
                        Type::Sales:
                            if LoadCustomerView(Customer) then
                                UpdateCustomersOnPlan;
                        Type::Purchase:
                            if LoadVendorView(Vendor) then
                                UpdateVendorsOnPlan;
                    end;
                until Next = 0;
            SetRange("Source Selection");
            SetRange("Item Selection", "Item Selection"::"Specific Item");
            if Find('-') then
                repeat
                    if GuiAllowed then
                        Window.Update(1, "No.");
                    if LoadItemView(Item) then begin
                        UpdateItemsOnPlan;
                    end;
                until Next = 0;
        end;
    end;

    procedure UpdateCustomersOnPlan()
    var
        SourceLine: Record "Accrual Plan Source Line";
    begin
        SourceLine.SetRange("Accrual Plan Type", AccrualPlan.Type);
        SourceLine.SetRange("Accrual Plan No.", AccrualPlan."No.");
        SourceLine.SetRange("Manual Entry", false);
        if SourceLine.Find('-') then
            repeat
                SourceLine.Mark(true);
            until SourceLine.Next = 0;
        if Customer.Find('-') then
            repeat
                SourceLine.SetRange("Source Code", Customer."No.");
                if SourceLine.FindSet then begin
                    repeat
                        SourceLine.Mark(false);
                    until SourceLine.Next = 0;
                end else begin
                    SourceLine.Init;
                    SourceLine."Accrual Plan Type" := AccrualPlan.Type;
                    SourceLine."Accrual Plan No." := AccrualPlan."No.";
                    SourceLine."Source Code" := '';
                    SourceLine."Source Ship-to Code" := '';
                    SourceLine.SetUpNewLine(SourceLine);
                    SourceLine.Validate("Source Code", Customer."No.");
                    SourceLine.Insert(true);
                end;
            until (Customer.Next = 0);
        SourceLine.SetRange("Source Code");
        SourceLine.MarkedOnly(true);
        SourceLine.DeleteAll(true);
    end;

    procedure UpdateVendorsOnPlan()
    var
        SourceLine: Record "Accrual Plan Source Line";
    begin
        SourceLine.SetRange("Accrual Plan Type", AccrualPlan.Type);
        SourceLine.SetRange("Accrual Plan No.", AccrualPlan."No.");
        SourceLine.SetRange("Manual Entry", false);
        if SourceLine.Find('-') then
            repeat
                SourceLine.Mark(true);
            until SourceLine.Next = 0;
        if Vendor.Find('-') then
            repeat
                SourceLine.SetRange("Source Code", Vendor."No.");
                if SourceLine.FindSet then begin
                    repeat
                        SourceLine.Mark(false);
                    until SourceLine.Next = 0;
                end else begin
                    SourceLine.Init;
                    SourceLine."Accrual Plan Type" := AccrualPlan.Type;
                    SourceLine."Accrual Plan No." := AccrualPlan."No.";
                    SourceLine."Source Code" := '';
                    SourceLine."Source Ship-to Code" := '';
                    SourceLine.SetUpNewLine(SourceLine);
                    SourceLine.Validate("Source Code", Vendor."No.");
                    SourceLine.Insert(true);
                end;
            until (Vendor.Next = 0);
        SourceLine.SetRange("Source Code");
        SourceLine.MarkedOnly(true);
        SourceLine.DeleteAll(true);
    end;

    procedure UpdateItemsOnPlan()
    var
        PlanLine: Record "Accrual Plan Line";
    begin
        PlanLine.SetRange("Accrual Plan Type", AccrualPlan.Type);
        PlanLine.SetRange("Accrual Plan No.", AccrualPlan."No.");
        PlanLine.SetRange("Manual Entry", false);
        if PlanLine.Find('-') then
            repeat
                PlanLine.Mark(true);
            until PlanLine.Next = 0;
        if Item.Find('-') then
            repeat
                PlanLine.SetRange("Item Code", Item."No.");
                if PlanLine.FindSet then begin
                    repeat
                        PlanLine.Mark(false);
                    until PlanLine.Next = 0;
                end else begin
                    PlanLine.Init;
                    PlanLine."Accrual Plan Type" := AccrualPlan.Type;
                    PlanLine."Accrual Plan No." := AccrualPlan."No.";
                    PlanLine."Item Code" := '';
                    PlanLine."Minimum Value" := 0;
                    PlanLine.SetUpNewLine(PlanLine);
                    PlanLine.Validate("Item Code", Item."No.");
                    PlanLine.Insert(true);
                end;
            until (Item.Next = 0);
        PlanLine.SetRange("Item Code");
        PlanLine.MarkedOnly(true);
        PlanLine.DeleteAll(true);
    end;
}

