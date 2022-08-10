codeunit 14014999 "Food Installer"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    begin
        InitializeMeasuringSystem();
    end;

    trigger OnInstallAppPerCompany()
    var
        EnableApplicationArea: Codeunit "Enable FOODAppArea Extension";
        P800Utility: Codeunit "Process 800 Utility Functions";
    begin
        if (not EnableApplicationArea.IsFOODdBasicApplicationAreaEnabled()) then
            EnableApplicationArea.EnableFoodBasicExtension();
        P800Utility.InitializeFOODTransactionNumber(); // P800122976
    end;

    local procedure InitializeMeasuringSystem()
    var
        MeasuringSystem: Record "Measuring System";
    begin
        if MeasuringSystem.Get() then
            exit;

        InsertMeasuringSystem(MeasuringSystem."Measuring System"::Conventional, MeasuringSystem.Type::Length, 'FT', 'Foot', 0.3048);
        InsertMeasuringSystem(MeasuringSystem."Measuring System"::Conventional, MeasuringSystem.Type::Weight, 'LB', 'Pound', 453.592909435639);
        InsertMeasuringSystem(MeasuringSystem."Measuring System"::Conventional, MeasuringSystem.Type::Volume, 'GAL', 'Gallon', 3.78541253425798);
        InsertMeasuringSystem(MeasuringSystem."Measuring System"::Metric, MeasuringSystem.Type::Length, 'M', 'Meter', 3.28083989501312);
        InsertMeasuringSystem(MeasuringSystem."Measuring System"::Metric, MeasuringSystem.Type::Weight, 'G', 'Gram', 0.00220462);
        InsertMeasuringSystem(MeasuringSystem."Measuring System"::Metric, MeasuringSystem.Type::Volume, 'L', 'Liter', 0.264172);
    end;

    local procedure InsertMeasuringSystem(MeasuringSys: Integer; Type: Integer; UOM: Code[10]; Description: Text[50]; ConvToOther: Decimal)
    var
        MeasuringSystem: Record "Measuring System";
    begin
        MeasuringSystem."Measuring System" := MeasuringSys;
        MeasuringSystem.Type := Type;
        MeasuringSystem.UOM := UOM;
        MeasuringSystem.Description := Description;
        MeasuringSystem."Conversion to Other" := ConvToOther;
        if MeasuringSystem.Insert() then;
    end;
}