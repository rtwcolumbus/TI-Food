codeunit 37002007 "Process 800 Utility Functions"
{
    // PR3.70.06
    // P8000116A, Myers Nissi, Steve Post, 03 AUG 04
    //   Added FolderNameAssistEdit Function
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Utility function to encrypt a password
    // 
    // PRW15.00.02
    // P8000623A, VerticalSoft, Jack Reynolds, 12 AUG 08
    //   FolderNameAssistEdit - rewritten to use NAV forms instead of automation
    // 
    // PRW16.00.02
    // P8000746, VerticalSoft, Jack Reynolds, 23 FEB 10
    //   EncryptPassword - works differently under NAV Server
    // 
    // PRW16.00.03
    // P8000811, VerticalSoft, Jack Reynolds, 05 APR 10
    //   Use Windows Shell for BrowseForFolder
    // 
    // PRW16.00.05
    // P8000960, Columbus IT, Jack Reynolds, 26 JUN 11
    //   Functions for evaluating arithmetic expressions
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.00.01
    // P8001197, Columbus IT, Jack Reynolds, 22 AUG 13
    //   Change to Crypto DLL
    // 
    // PRW17.10
    // P8001224, Columbus IT, Jack Reynolds, 27 SEP 13
    //   Move Last Alt. Qty. Transaction No. from Inventory Setup
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //    Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 31 MAR 16
    //   Update add-in assembly version references
    // 
    // PRW10.0
    // P8007755, To-Increase, Jack Reynolds, 22 NOV 16
    //   Update add-in assembly version references
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0


    trigger OnRun()
    begin
    end;

    procedure RecordsAreEqual(Record1: RecordRef; Record2: RecordRef): Boolean
    var
        Field1: FieldRef;
        Field2: FieldRef;
        i: Integer;
    begin
        if Record1.Number <> Record2.Number then
            exit(false);

        for i := 1 to Record2.FieldCount do begin
            Field1 := Record1.FieldIndex(i);
            if Format(Field1.Class) = 'Normal' then begin
                Field2 := Record2.FieldIndex(i);
                if Field1.Value <> Field2.Value then
                    exit(false);
            end;
        end;

        exit(true);
    end;

    [Obsolete('This is not used in the FOOD Application and relies on "File Management" functions that no longer exist.', 'FOOD-21')]
    procedure FolderNameAssistEdit(WindowTitle: Text; AllowNewFolder: Boolean; var FolderName: Text)
    begin
    end;

    procedure EvaluateNumericExpression(var DecimalValue: Decimal; Expression: Text[250]): Boolean
    var
        OperatorList: Text[8];
        OperatorPrecedence: Text[8];
        Numbers: Text[250];
        Operators: Text[250];
        Index: Integer;
        Position: Integer;
        NumberStack: array[20] of Decimal;
        StackPosition: Integer;
        OperatorStack: Text[250];
        Precedence: Char;
        Eval: Boolean;
        LastCharacter: Char;
    begin
        // P8000960
        // NumberStack is 20-element decimal array; this should be large enough but can be enlarged if necessary
        OperatorList := '_*/+-() ';
        OperatorPrecedence := '32211000';

        // Process expression to find unary use of - and convert to _
        //   Binary - cannot immediately follow another operator except right parenthesis
        Expression := DelChr(Expression, '<>', ' ');
        if 0 < StrLen(Expression) then begin
            if Expression[1] = '-' then
                Expression[1] := '_';
            LastCharacter := Expression[1];
            for Index := 2 to StrLen(Expression) do begin
                if Expression[Index] = '-' then
                    if LastCharacter in ['_', '*', '/', '+', '-', '('] then
                        Expression[Index] := '_';
                if Expression[Index] <> ' ' then
                    LastCharacter := Expression[Index];
            end;
        end;

        // Separate the numbers from the operators in the expression.
        // Blanks in the Numbers string represent the positions of operators
        Numbers := ConvertStr(Expression, OperatorList, PadStr('', StrLen(OperatorList)));
        Operators := DelChr(Expression, '=', '0123456789.,');

        while 0 < StrLen(Numbers) do begin
            if Numbers[1] = ' ' then begin
                // Blanks indicate an operator
                case Operators[1] of
                    ' ':
                        ; // Blank operator does nothing, just a place holder
                    '(':   // Push onto operator stack
                        OperatorStack := '(' + OperatorStack;
                    ')':   // Evaluate operators on stack until next right parenthesis
                        begin
                            Position := StrPos(OperatorStack, '(');
                            if Position > 0 then begin
                                for Index := 1 to Position - 1 do
                                    if not EvaluateOperator(OperatorStack[Index], NumberStack, StackPosition) then
                                        exit(false);
                                OperatorStack := CopyStr(OperatorStack, Position + 1);
                            end else
                                exit(false); // No matching right parenthesis
                        end;
                    else begin
                            // Evaluate operators on stack until one of lesser precedence is encountered,
                            // then push current operator onto the stack
                            Precedence := OperatorPrecedence[StrPos(OperatorList, CopyStr(Operators, 1, 1))];
                            Eval := true;
                            while (0 < StrLen(OperatorStack)) and Eval do begin
                                Eval := Precedence <= OperatorPrecedence[StrPos(OperatorList, Format(OperatorStack[1]))];
                                if Eval then begin
                                    if not EvaluateOperator(OperatorStack[1], NumberStack, StackPosition) then
                                        exit(false);
                                    OperatorStack := CopyStr(OperatorStack, 2);
                                end;
                            end;
                            OperatorStack := CopyStr(Operators, 1, 1) + OperatorStack;
                        end;
                end;
                Operators := CopyStr(Operators, 2);
                Numbers := CopyStr(Numbers, 2);
            end else begin
                // Numbers are pushed onto the number stack
                StackPosition += 1;
                Index := StrPos(Numbers, ' ');
                if Index = 0 then begin
                    if not Evaluate(NumberStack[StackPosition], Numbers) then
                        exit(false);
                    Numbers := '';
                end else begin
                    if not Evaluate(NumberStack[StackPosition], CopyStr(Numbers, 1, Index - 1)) then
                        exit(false);
                    Numbers := CopyStr(Numbers, Index);
                end;
            end;
        end;

        // Evaluate any remaining operators on the operator stack
        while 0 < StrLen(OperatorStack) do begin
            if OperatorStack[1] = '(' then
                exit(false); // There should be no parenthesis left; if there are then they were mismatched
            if not EvaluateOperator(OperatorStack[1], NumberStack, StackPosition) then
                exit(false);
            OperatorStack := CopyStr(OperatorStack, 2);
        end;

        if StackPosition <> 1 then // Should only be one number left on the stack - the result
            exit(false);

        DecimalValue := NumberStack[1];
        exit(true);
    end;

    procedure EvaluateIntegerExpression(var IntegerValue: Integer; Expression: Text[250]): Boolean
    var
        DecimalValue: Decimal;
    begin
        // P8000960
        if EvaluateNumericExpression(DecimalValue, Expression) then begin
            IntegerValue := DecimalValue div 1;
            if DecimalValue = IntegerValue then
                exit(true)
            else
                IntegerValue := 0;
        end;
    end;

    local procedure EvaluateOperator(Operator: Char; var Stack: array[20] of Decimal; var Position: Integer): Boolean
    begin
        // P8000960
        case Operator of
            // This is the only unary operator; the top number on the stack is operated on and the result placed
            // back in the same position on the stack
            '_':
                begin
                    if Position = 0 then
                        exit(false);
                    Stack[Position] := -Stack[Position];
                end;
            // All other operators are binary and the two top numbers are popped off of the stack, operated on,
            // and the result is pushed back onto the stack
            '*', '/', '+', '-':
                begin
                    if Position < 2 then
                        exit(false);
                    Position -= 1;
                    case Operator of
                        '*':
                            Stack[Position] := Stack[Position] * Stack[Position + 1];
                        '/':
                            if Stack[Position + 1] <> 0 then
                                Stack[Position] := Stack[Position] / Stack[Position + 1]
                            else
                                exit(false);
                        '+':
                            Stack[Position] := Stack[Position] + Stack[Position + 1];
                        '-':
                            Stack[Position] := Stack[Position] - Stack[Position + 1];
                    end;
                end;
        end;
        exit(true);
    end;

    procedure GetNextTransNo(): Integer
    begin
        exit(NumberSequence.Next('FOODTransactionNumber')); // P800122976
    end;

    // P800122976
    procedure InitializeFOODTransactionNumber()
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ItemJournalLine: Record "Item Journal Line";
        TransferLine: Record "Transfer Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        InvtDocumentLine: Record "Invt. Document Line";
        RepackOrder: Record "Repack Order";
        RepackOrderLine: Record "Repack Order Line";
        LastTransNo: Integer;
    begin
        if NumberSequence.Exists('FOODTransactionNumber') then
            exit;

        if SalesLine.ReadPermission() then begin
            SalesLine.SetCurrentKey("Alt. Qty. Transaction No.");
            SalesLine.SetFilter("Alt. Qty. Transaction No.", '>0');
            if SalesLine.FindLast() then
                if SalesLine."Alt. Qty. Transaction No." > LastTransNo then
                    LastTransNo := SalesLine."Alt. Qty. Transaction No.";
        end;

        if PurchaseLine.ReadPermission() then begin
            PurchaseLine.SetCurrentKey("Alt. Qty. Transaction No.");
            PurchaseLine.SetFilter("Alt. Qty. Transaction No.", '>0');
            if PurchaseLine.FindLast() then
                if PurchaseLine."Alt. Qty. Transaction No." > LastTransNo then
                    LastTransNo := PurchaseLine."Alt. Qty. Transaction No.";
        end;

        if ItemJournalLine.ReadPermission() then begin
            ItemJournalLine.SetCurrentKey("Alt. Qty. Transaction No.");
            ItemJournalLine.SetFilter("Alt. Qty. Transaction No.", '>0');
            if ItemJournalLine.FindLast() then
                if ItemJournalLine."Alt. Qty. Transaction No." > LastTransNo then
                    LastTransNo := ItemJournalLine."Alt. Qty. Transaction No.";
        end;

        if TransferLine.ReadPermission() then begin
            TransferLine.SetCurrentKey("Alt. Qty. Trans. No. (Ship)");
            TransferLine.SetFilter("Alt. Qty. Trans. No. (Ship)", '>0');
            if TransferLine.FindLast() then
                if TransferLine."Alt. Qty. Trans. No. (Ship)" > LastTransNo then
                    LastTransNo := TransferLine."Alt. Qty. Trans. No. (Ship)";

            TransferLine.Reset();
            TransferLine.SetCurrentKey("Alt. Qty. Trans. No. (Receive)");
            TransferLine.SetFilter("Alt. Qty. Trans. No. (Receive)", '>0');
            if TransferLine.FindLast() then
                if TransferLine."Alt. Qty. Trans. No. (Receive)" > LastTransNo then
                    LastTransNo := TransferLine."Alt. Qty. Trans. No. (Receive)";
        end;

        if WarehouseActivityLine.ReadPermission() then begin
            WarehouseActivityLine.SetCurrentKey("Alt. Qty. Transaction No.");
            WarehouseActivityLine.SetFilter("Alt. Qty. Transaction No.", '>0');
            if WarehouseActivityLine.FindLast() then
                if WarehouseActivityLine."Alt. Qty. Transaction No." > LastTransNo then
                    LastTransNo := WarehouseActivityLine."Alt. Qty. Transaction No.";
        end;

        if InvtDocumentLine.ReadPermission() then begin
            InvtDocumentLine.SetCurrentKey("FOOD Alt. Qty. Transaction No.");
            InvtDocumentLine.SetFilter("FOOD Alt. Qty. Transaction No.", '>0');
            if InvtDocumentLine.FindLast() then
                if InvtDocumentLine."FOOD Alt. Qty. Transaction No." > LastTransNo then
                    LastTransNo := InvtDocumentLine."FOOD Alt. Qty. Transaction No.";
        end;

        if RepackOrder.ReadPermission() then begin
            RepackOrder.SetCurrentKey("Alt. Qty. Transaction No.");
            RepackOrder.SetFilter("Alt. Qty. Transaction No.", '>0');
            if RepackOrder.FindLast() then
                if RepackOrder."Alt. Qty. Transaction No." > LastTransNo then
                    LastTransNo := RepackOrder."Alt. Qty. Transaction No.";
        end;

        if RepackOrderLine.ReadPermission() then begin
            RepackOrderLine.SetCurrentKey("Alt. Qty. Trans. No. (Trans)");
            RepackOrderLine.SetFilter("Alt. Qty. Trans. No. (Trans)", '>0');
            if RepackOrderLine.FindLast() then
                if RepackOrderLine."Alt. Qty. Trans. No. (Trans)" > LastTransNo then
                    LastTransNo := RepackOrderLine."Alt. Qty. Trans. No. (Trans)";

            RepackOrderLine.Reset();
            RepackOrderLine.SetCurrentKey("Alt. Qty. Trans. No. (Consume)");
            RepackOrderLine.SetFilter("Alt. Qty. Trans. No. (Consume)", '>0');
            if RepackOrderLine.FindLast() then
                if RepackOrderLine."Alt. Qty. Trans. No. (Consume)" > LastTransNo then
                    LastTransNo := RepackOrderLine."Alt. Qty. Trans. No. (Consume)";
        end;

        NumberSequence.Insert('FOODTransactionNumber', LastTransNo + 1, 1);
    end;

    procedure IsOnCallStack(ObjectType: Text; ObjectID: Integer; FunctionName: Text): Boolean
    var
        CallStackEntry: Text;
        CallStack: Text;
    begin
        // P80053245
        CallStackEntry := StrSubstNo('(%1 %2)', ObjectType, ObjectID);
        if FunctionName <> '' then
            CallStackEntry := CallStackEntry + '.' + FunctionName;

        if CallStackThrowError then;
        CallStack := GetLastErrorCallstack;
        ClearLastError;
        exit(0 <> StrPos(UpperCase(CallStack), UpperCase(CallStackEntry)));
    end;

    [TryFunction]
    local procedure CallStackThrowError()
    begin
        // P80053245
        Error('CALLSTACK');
    end;

    [TryFunction]
    procedure CheckAllowedPostingDate(PostingDate: Date)
    var
        UserSetupManagement: Codeunit "User Setup Management";
    begin
        // P80066030
        UserSetupManagement.CheckAllowedPostingDate(PostingDate);
    end;

    procedure MakeTimeText(var TimeText: Text): Integer
    var
        PartOfText: Text;
        Position: Integer;
        Length: Integer;
    begin
        Position := 1;
        Length := STRLEN(TimeText);
        ReadCharacter(' ', TimeText, Position, Length);
        if not FindText(PartOfText, TimeText, Position, Length) then
            exit(0);
        if PartOfText <> COPYSTR(TimeText, 1, STRLEN(PartOfText)) then
            exit(0);
        Position := Position + STRLEN(PartOfText);
        ReadCharacter(' ', TimeText, Position, Length);
        if Position <= Length then
            exit(Position);
        TimeText := Format(000000T + ROUND(Time - 000000T, 1000));
        exit(0);
    end;

    local procedure ReadCharacter(Character: Text; Text: Text; var Position: Integer; Length: Integer)
    begin
        while (Position <= Length) and (StrPos(Character, UpperCase(CopyStr(Text, Position, 1))) <> 0) DO
            Position := Position + 1;
    end;

    local procedure FindText(var PartOfText: Text; Text: Text; Position: Integer; Length: Integer): Boolean
    var
        Position2: Integer;
        AlphabetText: Label 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    begin
        Position2 := Position;
        ReadCharacter(AlphabetText, Text, Position, Length);
        IF Position = Position2 THEN
            exit(false);
        PartOfText := UPPERCASE(COPYSTR(Text, Position2, Position - Position2));
        exit(true);
    end;

    procedure CheckCodeunitTable(CodeunitID: Integer; RequiredTableID: Integer; CodeunitDescription: Text)
    var
        CodeUnitMetadata: Record "CodeUnit Metadata";
        RecRef: RecordRef;
        ErrWrongTable: Label 'The table for the "%1 Codeunit" must be "%2".';
    begin
        if CodeunitID = 0 then
            exit;

        CodeUnitMetadata.Get(CodeunitID);
        if CodeUnitMetadata.TableNo <> RequiredTableID then begin
            RecRef.Open(RequiredTableID);
            Error(ErrWrongTable, CodeunitDescription, RecRef.Caption);
        end;
    end;

    procedure GetObjectCaption(ObjectType: Integer; ObjectID: Integer): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if AllObjWithCaption.Get(ObjectType, ObjectID) then
            exit(AllObjWithCaption."Object Caption");
    end;

}

