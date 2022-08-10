codeunit 37002012 "Process 800 Signal Functions"
{
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 03 JUN 10
    //   Consolidate timer logic
    // 
    // PRW16.00.05
    // P8000940, Columbus IT, Jack Reynolds, 05 MAY 11
    //   Support for Signal controls
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 04 FEB 19
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Removing support for Signal Functions codeunit

    ObsoleteState = Pending;
    ObsoleteReason = 'No longer required.';
    ObsoleteTag = 'FOOD0-21';

    trigger OnRun()
    begin
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure Signal(Index: Integer)
    begin
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure ClearControl(Index: Integer)
    begin
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure GetControlID(Index: Integer): Text[50]
    begin
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure EventPending(Index: Integer): Boolean
    begin
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure AddEvent(Index: Integer; MsgText: Text[250])
    begin
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure GetNextEvent(Index: Integer): Text[250]
    begin
    end;
}

