codeunit 37002008 "Process 800 System Globals"
{
    // PR3.70.02
    //   Add PrinterOverride
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 25 MAY 04
    //   MultipleLotCode - return string signifying multiple lots
    // 
    // PRW15.00.01
    // P8000563A, VerticalSoft, Jack Reynolds, 29 JAN 08
    //   Added ADC Message Position
    // 
    // PRW16.00.03
    // P8000814, VerticalSoft, Jack Reynolds, 14 APR 10
    //   Add function DeveloperLicenseNo
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00
    // P8001141, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Cleanup ADC for NAV 2013
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 18 NOV 14
    //   Update Developer License No

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        ADCDebugMode: Boolean;
        PrinterOverride: Text[250];
        ADCMsgPos: array[2] of Integer;

    procedure SetPrinterOverride(PrinterName: Text[250])
    begin
        PrinterOverride := PrinterName; // PR3.70.02
    end;

    procedure GetPrinterOverride(): Text[250]
    begin
        exit(PrinterOverride); // PR3.70.02
    end;

    procedure MultipleLotCode(): Code[20]
    var
        Text001: Label '*MULTIPLE*';
    begin
        exit(Text001); // PR3.7.04
    end;

    procedure DeveloperLicenseNo(): Text[20]
    begin
        // P8000814
        exit('5215109   '); // P8001352
    end;
}

