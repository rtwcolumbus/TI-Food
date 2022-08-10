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


    trigger OnRun()
    begin
    end;

    var
        ControlID: Record "Process 800 Signal" temporary;
        EventQueue: Record "Process 800 Signal" temporary;
        // [RunOnClient]
        // SignalControl1: DotNet ISignalWebControlAddIn;
        // [RunOnClient]
        // SignalControl2: DotNet ISignalWebControlAddIn;

    procedure Signal(Index: Integer)
    begin
        // // P80059471
        // if ControlID.Get(Index) then
        //     if ControlID.Message <> '' then
        //         case Index of
        //             1:
        //                 SignalControl1.Signal(ControlID.Message);
        //             2:
        //                 SignalControl2.Signal(ControlID.Message);
        //         end;
    end;

    // procedure SetControl(Index: Integer; ID: Text[50]; Control: DotNet ISignalWebControlAddIn)
    // begin
    //     // P80059471
    //     if ControlID.Get(Index) then
    //         ControlID.Delete;
    //     ControlID.Index := Index;
    //     ControlID.Message := ID;
    //     ControlID.Insert;

    //     case Index of
    //         1:
    //             SignalControl1 := Control;
    //         2:
    //             SignalControl2 := Control;
    //     end;
    // end;

    procedure ClearControl(Index: Integer)
    begin
        // // P80059471
        // if ControlID.Get(Index) then
        //     ControlID.Delete;

        // case Index of
        //     1:
        //         Clear(SignalControl1);
        //     2:
        //         Clear(SignalControl2);
        // end;
    end;

    procedure GetControlID(Index: Integer): Text[50]
    begin
        // P8000940
        if ControlID.Get(Index) then
            exit(ControlID.Message);
    end;

    procedure EventPending(Index: Integer): Boolean
    begin
        // P8000940
        EventQueue.SetRange(Index, Index);
        exit(not EventQueue.IsEmpty);
    end;

    procedure AddEvent(Index: Integer; MsgText: Text[250])
    begin
        // P8000940
        EventQueue.SetRange(Index, Index);
        if EventQueue.FindLast then
            EventQueue."Entry No." += 1
        else begin
            EventQueue.Index := Index;
            EventQueue."Entry No." := 1;
        end;
        EventQueue.Message := MsgText;
        EventQueue.Insert;
    end;

    procedure GetNextEvent(Index: Integer): Text[250]
    begin
        // P8000940
        EventQueue.SetRange(Index, Index);
        if EventQueue.FindFirst then begin
            EventQueue.Delete;
            exit(EventQueue.Message);
        end;
    end;

    // trigger SignalControl1::AddInReady(guid: Text)
    // begin
    // end;

    // trigger SignalControl1::OnSignal()
    // begin
    // end;

    // trigger SignalControl2::AddInReady(guid: Text)
    // begin
    // end;

    // trigger SignalControl2::OnSignal()
    // begin
    // end;
}

