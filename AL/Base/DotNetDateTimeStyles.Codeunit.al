codeunit 3004 DotNet_DateTimeStyles
{
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    var
        DotNetDateTimeStyles: DotNet DateTimeStyles;

    procedure "None"()
    begin
        DotNetDateTimeStyles := DotNetDateTimeStyles.None
    end;

    procedure AssumeLocal()
    begin
        // P80073095
        DotNetDateTimeStyles := DotNetDateTimeStyles.AssumeLocal;
    end;
    
    [Scope('OnPrem')]
    procedure GetDateTimeStyles(var DotNetDateTimeStyles2: DotNet DateTimeStyles)
    begin
        DotNetDateTimeStyles2 := DotNetDateTimeStyles
    end;

    [Scope('OnPrem')]
    procedure SetDateTimeStyles(DotNetDateTimeStyles2: DotNet DateTimeStyles)
    begin
        DotNetDateTimeStyles := DotNetDateTimeStyles2
    end;
}

