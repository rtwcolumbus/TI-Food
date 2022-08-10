codeunit 37002002 "Text Functions"
{
    // PR3.60
    //   NotePad - changed syntax of SHELL command
    // 
    // PR3.70.06
    // P8000094A, Myers Nissi, Jack Reynolds, 20 AUG 04
    //   NotePad - on returning from Notepad test the line count for both the original and new text and if both are
    //     zero then exit with no change
    // 
    // P8000099A, Myers Nissi, Jack Reynolds, 23 AUG 04
    //   Fix permission problem with creating temporary file for Notepad
    // 
    // PR4.00.03
    // P8000330A, VerticalSoft, Jack Reynolds, 04 MAY 06
    //   AddText - exit (and return 0) if ID is zero and Text is blank
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   GetFileName - modify to use TEMPORARYPATH
    // 
    // PRW15.00.01
    // P8000597A, VerticalSoft, Jack Reynolds, 13 APR 08
    //   Modified to use BigText variables to simplify and generalize the functions
    // 
    // PRW15.00.03
    // P8000627A, VerticalSoft, Jack Reynolds, 25 AUG 08
    //   Modified to use RecordRef rather than specific table for extended text
    // 
    // PRW16.00.20
    // P8000675, VerticalSoft, Jack Reynolds, 13 FEB 09
    //   Modified for RTC.  Replace SHELL and issues with where temporary files are created
    // 
    // PRW16.00.03
    // P8000819, VerticalSoft, Jack Reynolds, 30 APR 10
    //   Modifications to support multi-line textbox
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001215, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Remove Notepad functionality
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // This code unit contains utility functions for managing the Extended Text table.
    // 
    //   newid := CopyNote(id)                 // Makes copy of existing note (id) and assigns it to a
    //                                            new ID (newid).
    // 
    //            AppendNote(targ,src,blanks)  // Appends the text of an existing note (src) to another
    //                                            existing note (targ).  Insert blank line between notes if
    //                                            requested (blanks)
    // 
    //   newid := CreateNote(text)             // Creates a single line note from a text string (text) and
    //                                            assigns it to a new ID (newid).
    // 
    //            DeleteNote(id)               // Deletes an existing note (id).
    // 
    //   newid := AddText(id,len,text)         // Case 1 - id <> 0, add text to existing note (id), returns
    //                                              ID of note
    //                                            Case 2 - id = 0, add text to new note, returns ID of new
    //                                              note
    // 
    //                                            Adds text variale (text) to note wrapped to specified
    //                                            length (0).
    // 
    //   text  := FirstLine(id)                // Returns first line of text for an existing note (id)
    // 
    //            GetNote(id,TextRec,len)      // Returns note (id) as records in the (TextRec) variable which is
    //                                         // a temporary table based on the Extended Text.  If (len) is 0
    //                                         // then the note is returned as stored; otherwise it is re-wrapped
    //                                         // to that length
    // 
    //   found := SearchNote(id,string,case)   // Returns Boolean indicating if (string) is found as a
    //                                            substring in a note (id).  If (case) is TRUE then search
    //                                            will be case sensitive


    trigger OnRun()
    begin
    end;

    var
        NoteTable: Integer;

    procedure NoteToBigText(ID: Integer; var BigText: BigText)
    var
        TextRec: RecordRef;
        FldRef: FieldRef;
    begin
        // P8000819
        if ID = 0 then
            Clear(BigText)
        else begin
            OpenTable(TextRec);
            FldRef := TextRec.Field(10);
            FldRef.SetRange(ID);
            RecordToBigText(TextRec, false, BigText);
            TextRec.Close;
        end;
    end;

    procedure NoteToText(ID: Integer) NoteText: Text
    var
        TextRec: RecordRef;
        FldRef: FieldRef;
    begin
        // P8001132
        if ID = 0 then
            Clear(NoteText)
        else begin
            OpenTable(TextRec);
            FldRef := TextRec.Field(10);
            FldRef.SetRange(ID);
            NoteText := RecordToText(TextRec, false);
            TextRec.Close;
        end;
    end;

    procedure BigTextToNote(var ID: Integer; MaxLen: Integer; BigText: BigText)
    var
        TextRec: RecordRef;
        FldRef: FieldRef;
        TempTextRec: Record "Extended Text" temporary;
    begin
        // P8000819
        OpenTable(TextRec);
        if ID <> 0 then begin
            FldRef := TextRec.Field(10);
            FldRef.SetRange(ID);
            TextRec.DeleteAll;
        end;

        if BigText.Length = 0 then begin
            ID := 0;
            exit;
        end;

        BigTextToRecord(BigText, TempTextRec, MaxLen);

        if not TempTextRec.FindSet then begin
            ID := 0;
            TextRec.Close;
            exit;
        end;

        TextRec.LockTable;
        if ID = 0 then begin
            TextRec.Reset;
            if TextRec.FindLast then begin
                FldRef := TextRec.Field(10);
                ID := FldRef.Value;
                ID += 1;
            end else
                ID := 1;
        end;

        AssignField(TextRec, 10, ID);
        repeat
            AssignField(TextRec, 20, TempTextRec.LineNo);
            AssignField(TextRec, 30, TempTextRec.Spaces);
            AssignField(TextRec, 40, TempTextRec.NewLine);
            AssignField(TextRec, 50, TempTextRec.Line);
            TextRec.Insert;
        until TempTextRec.Next = 0;
        TextRec.Close;
    end;

    procedure TextToNote(var ID: Integer; MaxLen: Integer; Text: Text)
    var
        TextRec: RecordRef;
        FldRef: FieldRef;
        TempTextRec: Record "Extended Text" temporary;
    begin
        // P8001132
        OpenTable(TextRec);
        if ID <> 0 then begin
            FldRef := TextRec.Field(10);
            FldRef.SetRange(ID);
            TextRec.DeleteAll;
        end;

        if StrLen(Text) = 0 then begin
            ID := 0;
            exit;
        end;

        TextToRecord(Text, TempTextRec, MaxLen);

        if not TempTextRec.FindSet then begin
            ID := 0;
            TextRec.Close;
            exit;
        end;

        TextRec.LockTable;
        if ID = 0 then begin
            TextRec.Reset;
            if TextRec.FindLast then begin
                FldRef := TextRec.Field(10);
                ID := FldRef.Value;
                ID += 1;
            end else
                ID := 1;
        end;

        AssignField(TextRec, 10, ID);
        repeat
            AssignField(TextRec, 20, TempTextRec.LineNo);
            AssignField(TextRec, 30, TempTextRec.Spaces);
            AssignField(TextRec, 40, TempTextRec.NewLine);
            AssignField(TextRec, 50, TempTextRec.Line);
            TextRec.Insert;
        until TempTextRec.Next = 0;
        TextRec.Close;
    end;

    procedure CopyNote(ID: Integer) NewID: Integer
    var
        TextRec1: RecordRef;
        TextRec2: RecordRef;
        FldRef1: FieldRef;
        FldRef2: FieldRef;
        fld: Integer;
    begin
        // P8000627A - Rewritten for RecordRef
        if ID = 0 then begin
            NewID := 0;
            exit;
        end;

        OpenTable(TextRec1);
        OpenTable(TextRec2);
        FldRef1 := TextRec1.Field(10);
        FldRef1.SetRange(ID, ID);
        if TextRec1.FindSet then begin

            TextRec2.LockTable;
            TextRec2.FindLast;
            FldRef2 := TextRec2.Field(10);
            NewID := FldRef2.Value;
            NewID += 1;
            AssignField(TextRec2, 10, NewID);

            repeat
                for fld := 2 to 5 do begin
                    FldRef1 := TextRec1.FieldIndex(fld);
                    FldRef2 := TextRec2.FieldIndex(fld);
                    FldRef2.Value := FldRef1.Value;
                end;
                TextRec2.Insert;
            until TextRec1.Next = 0;

        end else
            NewID := 0;

        TextRec1.Close;
        TextRec2.Close;
    end;

    procedure CreateNote(text: Text[80]) NewID: Integer
    var
        TextRec: RecordRef;
        FieldRef: FieldRef;
    begin
        // P8000627A - Rewritten for RecordRef
        OpenTable(TextRec);
        TextRec.LockTable;
        if TextRec.FindLast then begin
            FieldRef := TextRec.Field(10);
            NewID := FieldRef.Value;
            NewID += 1;
        end else
            NewID := 1;

        TextRec.Init;
        AssignField(TextRec, 10, NewID);
        AssignField(TextRec, 20, 1);
        AssignField(TextRec, 50, text);
        TextRec.Insert;

        TextRec.Close;
    end;

    procedure AppendNote(targ: Integer; src: Integer; blanks: Boolean)
    var
        TextRec1: RecordRef;
        TextRec2: RecordRef;
        FieldRef1: FieldRef;
        FieldRef2: FieldRef;
        no: Integer;
        firstline: Boolean;
        fld: Integer;
    begin
        // P8000627A - Rewritten for RecordRef
        if (targ = 0) or (src = 0) then
            exit;

        OpenTable(TextRec1);
        FieldRef1 := TextRec1.Field(10);
        FieldRef1.SetRange(src);
        if TextRec1.FindSet then begin

            OpenTable(TextRec2);
            TextRec2.LockTable;
            FieldRef2 := TextRec2.Field(10);
            FieldRef2.SetRange(targ);
            if TextRec2.FindLast then begin
                FieldRef2 := TextRec2.Field(20);
                no := FieldRef2.Value;
                no += 1;
            end else
                no := 0;

            if (no <> 0) and blanks then begin
                TextRec2.Init;
                AssignField(TextRec2, 10, targ);
                AssignField(TextRec2, 20, no);
                AssignField(TextRec2, 40, true);
                TextRec2.Insert;
            end;

            firstline := true;
            repeat
                no := no + 1;
                AssignField(TextRec2, 10, targ);
                AssignField(TextRec2, 20, no);
                for fld := 3 to 5 do begin
                    FieldRef1 := TextRec1.FieldIndex(fld);
                    FieldRef2 := TextRec2.FieldIndex(fld);
                    FieldRef2.Value := FieldRef1.Value;
                end;
                if firstline then
                    AssignField(TextRec2, 40, true);
                TextRec2.Insert;
                firstline := false;
            until TextRec1.Next = 0;

            TextRec2.Close;
        end;

        TextRec1.Close;
    end;

    procedure DeleteNote(ID: Integer)
    var
        TextRec: RecordRef;
        FldRef: FieldRef;
    begin
        // P8000627A - Rewritten for RecordRef
        OpenTable(TextRec);
        if ID <> 0 then begin
            FldRef := TextRec.Field(10);
            FldRef.SetRange(ID);
            TextRec.DeleteAll;
        end;
    end;

    procedure AddText(ID: Integer; MaxLen: Integer; Text: Text[250]) NewID: Integer
    var
        TextRec: RecordRef;
        FieldRef: FieldRef;
        NextLine: Text[250];
        LineNo: Integer;
        Spaces: Integer;
        Line: Text[120];
    begin
        // P8000627A - Rewritten for RecordRef
        OpenTable(TextRec);
        if ID <> 0 then begin
            FieldRef := TextRec.Field(10);
            FieldRef.SetRange(ID);
            if not TextRec.FindLast then;
            NewID := ID;
        end else begin
            if Text = '' then begin // P8000330A
                TextRec.Close;
                exit;                 // P8000330A
            end;
            TextRec.LockTable;
            if TextRec.FindLast then begin
                FieldRef := TextRec.Field(10);
                NewID := FieldRef.Value;
                NewID += 1;
            end else
                NewID := 1;
            AssignField(TextRec, 20, 0);
        end;

        AssignField(TextRec, 10, NewID);
        AssignField(TextRec, 40, ID <> 0);

        if MaxLen = 0 then begin
            FieldRef := TextRec.Field(50);
            MaxLen := FieldRef.Length;
        end;

        FieldRef := TextRec.Field(20);
        LineNo := FieldRef.Value;
        while 0 < StrLen(Text) do begin
            WrapText(Line, Spaces, Text, MaxLen);
            AssignField(TextRec, 30, Spaces);
            AssignField(TextRec, 50, Line);
            LineNo += 1;
            AssignField(TextRec, 20, LineNo);
            TextRec.Insert;
            AssignField(TextRec, 40, false);
        end;

        TextRec.Close;
    end;

    procedure FirstLine(ID: Integer) Line: Text[250]
    var
        TextRec: RecordRef;
        FieldRef: FieldRef;
    begin
        // P8000627A - Rewritten for RecordRef
        OpenTable(TextRec);
        AssignField(TextRec, 10, ID);
        AssignField(TextRec, 20, 1);
        if TextRec.Find then begin
            FieldRef := TextRec.Field(50);
            Line := FieldRef.Value;
        end;
        TextRec.Close;
    end;

    procedure GetNote(ID: Integer; var TempTextRec: Record "Extended Text" temporary; MaxLen: Integer)
    var
        TextRec: RecordRef;
        FieldRef: FieldRef;
        NoteText: BigText;
    begin
        // P8000597A
        // P8000627A - Rewritten for RecordRef
        TempTextRec.Reset;
        if not TempTextRec.IsEmpty then
            exit;

        if ID = 0 then
            exit;

        OpenTable(TextRec);
        FieldRef := TextRec.Field(10);
        FieldRef.SetRange(ID);
        if MaxLen = 0 then begin
            if TextRec.FindSet then
                repeat
                    TempTextRec.ID := 0;
                    FieldRef := TextRec.Field(20);
                    TempTextRec.LineNo := FieldRef.Value;
                    FieldRef := TextRec.Field(30);
                    TempTextRec.Spaces := FieldRef.Value;
                    FieldRef := TextRec.Field(40);
                    TempTextRec.NewLine := FieldRef.Value;
                    FieldRef := TextRec.Field(50);
                    TempTextRec.Line := FieldRef.Value;
                    TempTextRec.Insert;
                until TextRec.Next = 0;
        end else begin
            RecordToBigText(TextRec, false, NoteText);
            BigTextToRecord(NoteText, TempTextRec, MaxLen);
        end;

        TextRec.Close;
        TempTextRec.FindFirst;
    end;

    procedure SearchNote(ID: Integer; FindWhat: Text[250]; MatchCase: Boolean): Boolean
    var
        TextRec: RecordRef;
        FieldRef: FieldRef;
        NoteText: BigText;
    begin
        // P8000597A - FindWhat parameter changed to 250, restructured to use BigText
        // P8000627A - Rewritten for RecordRef
        if FindWhat = '' then
            exit(true);

        if not MatchCase then
            FindWhat := UpperCase(FindWhat);

        OpenTable(TextRec);
        FieldRef := TextRec.Field(10);
        FieldRef.SetRange(ID);
        RecordToBigText(TextRec, not MatchCase, NoteText);
        TextRec.Close;
        exit(0 <> NoteText.TextPos(FindWhat));
    end;

    local procedure RecordToBigText(var TextRec: RecordRef; UCase: Boolean; var NoteText: BigText)
    var
        CRLF: Text[2];
        FromChars: Text[46];
        ToChars: Text[46];
        FldRef: FieldRef;
        Line: Text[250];
        NewLine: Boolean;
        Spaces: Integer;
    begin
        // P8000597A
        // P8000627A - Rewritten for RecordRef
        // P8000819 - renamed from NoteToBigText
        Clear(NoteText);
        if not TextRec.FindSet then
            exit;

        CRLF[1] := 13;
        CRLF[2] := 10;

        FromChars := ANSI;
        ToChars := OEM;
        repeat
            FldRef := TextRec.Field(50);
            Line := FldRef.Value;
            FldRef := TextRec.Field(40);
            NewLine := FldRef.Value;
            FldRef := TextRec.Field(30);
            Spaces := FldRef.Value;
            if UCase then
                Line := UpperCase(Line);
            Line := ConvertStr(Line, FromChars, ToChars);
            if NewLine then
                NoteText.AddText(CRLF);
            NoteText.AddText(Line);
            NoteText.AddText(PadStr('', Spaces, ' '));
        until TextRec.Next = 0;
    end;

    local procedure RecordToText(var TextRec: RecordRef; UCase: Boolean) NoteText: Text
    var
        CRLF: Text[2];
        FromChars: Text[46];
        ToChars: Text[46];
        FldRef: FieldRef;
        Line: Text[250];
        NewLine: Boolean;
        Spaces: Integer;
    begin
        // P8001132
        Clear(NoteText);
        if not TextRec.FindSet then
            exit;

        CRLF[1] := 13;
        CRLF[2] := 10;

        FromChars := ANSI;
        ToChars := OEM;
        repeat
            FldRef := TextRec.Field(50);
            Line := FldRef.Value;
            FldRef := TextRec.Field(40);
            NewLine := FldRef.Value;
            FldRef := TextRec.Field(30);
            Spaces := FldRef.Value;
            if UCase then
                Line := UpperCase(Line);
            Line := ConvertStr(Line, FromChars, ToChars);
            if NewLine then
                NoteText := NoteText + CRLF;
            NoteText := NoteText + Line;
            NoteText := NoteText + PadStr('', Spaces, ' ');
        until TextRec.Next = 0;
    end;

    local procedure BigTextToRecord(NoteText: BigText; var TextRec: Record "Extended Text" temporary; MaxLen: Integer)
    var
        NextChar: Char;
        LastChar: Char;
        FromChars: Text[46];
        ToChars: Text[46];
        NextWord: Text[250];
        SpaceCnt: Integer;
        TextBuffer: Text[1000];
        NoteTextPos: Integer;
        i: Integer;
    begin
        // P8000597A
        // P8000819 - renamed from BigTextToNote
        TextRec.Reset;
        TextRec.DeleteAll;

        if MaxLen = 0 then
            MaxLen := MaxStrLen(TextRec.Line);

        LastChar := 0;

        FromChars := OEM;
        ToChars := ANSI;

        TextRec.Init;
        TextRec.LineNo := 1;

        NoteTextPos := 1;
        while NoteTextPos <= NoteText.Length do begin
            // GETSUBTEXT does not seem to populate a CHAR variable.  Therefore, we will move the text into a TextBuffer and then
            // run through the buffer character by character.
            NoteTextPos += NoteText.GetSubText(TextBuffer, NoteTextPos, MaxStrLen(TextBuffer));
            for i := 1 to StrLen(TextBuffer) do begin
                NextChar := TextBuffer[i];
                case NextChar of
                    10:
                        ; // Line Feed - Ignore (it should always follow a carriage return)

                    13:
                        begin
                            // Carriage Return - First figure out what to do with current line based on the
                            // last character read
                            case LastChar of
                                0:       // Beginning of file - no previous line, but we will increment the line
                                         // number so we must change it to zero
                                    TextRec.LineNo := 0;

                                32:       // Trailing spaces - insert line as is
                                    TextRec.Insert;

                                else begin // End of word - add word to end of line if it will fit and insert the
                                           // line; otherwise, insert the line as is and then insert another with
                                           // the word that wouldn't fit
                                        if (StrLen(TextRec.Line) + TextRec.Spaces + StrLen(NextWord)) < MaxLen then begin
                                            TextRec.Line := TextRec.Line + PadStr('', TextRec.Spaces) + ConvertStr(NextWord, FromChars, ToChars);
                                            TextRec.Spaces := 0;
                                            TextRec.Insert;
                                        end else begin
                                            TextRec.Insert;
                                            TextRec.LineNo := TextRec.LineNo + 1;
                                            TextRec.Spaces := 0;
                                            TextRec.NewLine := false;
                                            TextRec.Line := ConvertStr(NextWord, FromChars, ToChars);
                                            TextRec.Insert;
                                        end;
                                    end;
                            end;
                            // Now initialize the next line
                            TextRec.LineNo := TextRec.LineNo + 1;
                            TextRec.NewLine := true;
                            TextRec.Spaces := 0;
                            TextRec.Line := '';
                            NextWord := '';
                        end;

                    9, 32:
                        begin // Tab, Space - This will mark the end of a word or continue a sequence of spaces
                            if NextChar = 9 then begin
                                SpaceCnt := 8 - (StrLen(TextRec.Line) + TextRec.Spaces + StrLen(NextWord)) mod 8;
                                //IF SpaceCnt = 0 THEN
                                //  SpaceCnt := 8;
                            end else
                                SpaceCnt := 1;
                            case LastChar of
                                0:       // Beginning of file
                                    TextRec.Spaces := SpaceCnt;
                                10:       // Line Feed - beginning of line
                                    TextRec.Spaces := SpaceCnt;
                                13:       // Carriage Return - beginning of line
                                    TextRec.Spaces := SpaceCnt;
                                32:       // Space - increment the space counter
                                    TextRec.Spaces := TextRec.Spaces + SpaceCnt;
                                else begin // Marks end of word - if the word will fit on the current line, add it;
                                           // otherwise, insert the current line and start another with the word
                                           // that wouldn't fit
                                        if (StrLen(TextRec.Line) + TextRec.Spaces + StrLen(NextWord)) < MaxLen then begin
                                            TextRec.Line := TextRec.Line + PadStr('', TextRec.Spaces) + ConvertStr(NextWord, FromChars, ToChars);
                                            TextRec.Spaces := SpaceCnt;
                                        end else begin
                                            TextRec.Insert;
                                            TextRec.LineNo := TextRec.LineNo + 1;
                                            TextRec.NewLine := false;
                                            TextRec.Spaces := SpaceCnt;
                                            TextRec.Line := ConvertStr(NextWord, FromChars, ToChars);
                                        end;
                                        NextWord := '';
                                    end;
                            end;
                        end;
                    else       // Continuation (start) of next word
                        NextWord := NextWord + Format(NextChar);
                end;
                LastChar := NextChar;
                if LastChar = 9 then // tabs are treated like spaces
                    LastChar := 32;
            end;
        end;

        // Final action depends onlast character read
        case LastChar of
            0:
                ;     // Beginning of file - zero length file
            10:       // Line Feed - insert final line
                TextRec.Insert;
            13:       // Carriage Return - insert final line
                TextRec.Insert;
            32:       // Space - insert final line
                TextRec.Insert;
            else begin // If the final word will fit on the current line add and insert the line;
                       // otherwise, insert the line and another with the final word.
                    if (StrLen(TextRec.Line) + TextRec.Spaces + StrLen(NextWord)) < MaxLen then begin
                        TextRec.Line := TextRec.Line + PadStr('', TextRec.Spaces) + ConvertStr(NextWord, FromChars, ToChars);
                        TextRec.Spaces := 0;
                        TextRec.Insert;
                    end else begin
                        TextRec.Insert;
                        TextRec.LineNo := TextRec.LineNo + 1;
                        TextRec.NewLine := false;
                        TextRec.Spaces := 0;
                        TextRec.Line := ConvertStr(NextWord, FromChars, ToChars);
                        TextRec.Insert;
                    end;
                end;
        end;
    end;

    local procedure TextToRecord(NoteText: Text; var TextRec: Record "Extended Text" temporary; MaxLen: Integer)
    var
        NextChar: Char;
        LastChar: Char;
        FromChars: Text[46];
        ToChars: Text[46];
        NextWord: Text[250];
        SpaceCnt: Integer;
        i: Integer;
    begin
        // P8001132
        TextRec.Reset;
        TextRec.DeleteAll;

        if MaxLen = 0 then
            MaxLen := MaxStrLen(TextRec.Line);

        LastChar := 0;

        FromChars := OEM;
        ToChars := ANSI;

        TextRec.Init;
        TextRec.LineNo := 1;

        for i := 1 to StrLen(NoteText) do begin
            NextChar := NoteText[i];
            case NextChar of
                10:
                    ; // Line Feed - Ignore (it should always follow a carriage return)

                13:
                    begin
                        // Carriage Return - First figure out what to do with current line based on the
                        // last character read
                        case LastChar of
                            0:       // Beginning of file - no previous line, but we will increment the line
                                     // number so we must change it to zero
                                TextRec.LineNo := 0;

                            32:       // Trailing spaces - insert line as is
                                TextRec.Insert;

                            else begin // End of word - add word to end of line if it will fit and insert the
                                       // line; otherwise, insert the line as is and then insert another with
                                       // the word that wouldn't fit
                                    if (StrLen(TextRec.Line) + TextRec.Spaces + StrLen(NextWord)) < MaxLen then begin
                                        TextRec.Line := TextRec.Line + PadStr('', TextRec.Spaces) + ConvertStr(NextWord, FromChars, ToChars);
                                        TextRec.Spaces := 0;
                                        TextRec.Insert;
                                    end else begin
                                        TextRec.Insert;
                                        TextRec.LineNo := TextRec.LineNo + 1;
                                        TextRec.Spaces := 0;
                                        TextRec.NewLine := false;
                                        TextRec.Line := ConvertStr(NextWord, FromChars, ToChars);
                                        TextRec.Insert;
                                    end;
                                end;
                        end;
                        // Now initialize the next line
                        TextRec.LineNo := TextRec.LineNo + 1;
                        TextRec.NewLine := true;
                        TextRec.Spaces := 0;
                        TextRec.Line := '';
                        NextWord := '';
                    end;

                9, 32:
                    begin // Tab, Space - This will mark the end of a word or continue a sequence of spaces
                        if NextChar = 9 then begin
                            SpaceCnt := 8 - (StrLen(TextRec.Line) + TextRec.Spaces + StrLen(NextWord)) mod 8;
                            //IF SpaceCnt = 0 THEN
                            //  SpaceCnt := 8;
                        end else
                            SpaceCnt := 1;
                        case LastChar of
                            0:       // Beginning of file
                                TextRec.Spaces := SpaceCnt;
                            10:       // Line Feed - beginning of line
                                TextRec.Spaces := SpaceCnt;
                            13:       // Carriage Return - beginning of line
                                TextRec.Spaces := SpaceCnt;
                            32:       // Space - increment the space counter
                                TextRec.Spaces := TextRec.Spaces + SpaceCnt;
                            else begin // Marks end of word - if the word will fit on the current line, add it;
                                       // otherwise, insert the current line and start another with the word
                                       // that wouldn't fit
                                    if (StrLen(TextRec.Line) + TextRec.Spaces + StrLen(NextWord)) < MaxLen then begin
                                        TextRec.Line := TextRec.Line + PadStr('', TextRec.Spaces) + ConvertStr(NextWord, FromChars, ToChars);
                                        TextRec.Spaces := SpaceCnt;
                                    end else begin
                                        TextRec.Insert;
                                        TextRec.LineNo := TextRec.LineNo + 1;
                                        TextRec.NewLine := false;
                                        TextRec.Spaces := SpaceCnt;
                                        TextRec.Line := ConvertStr(NextWord, FromChars, ToChars);
                                    end;
                                    NextWord := '';
                                end;
                        end;
                    end;
                else       // Continuation (start) of next word
                    NextWord := NextWord + Format(NextChar);
            end;
            LastChar := NextChar;
            if LastChar = 9 then // tabs are treated like spaces
                LastChar := 32;
        end;

        // Final action depends onlast character read
        case LastChar of
            0:
                ;     // Beginning of file - zero length file
            10:       // Line Feed - insert final line
                TextRec.Insert;
            13:       // Carriage Return - insert final line
                TextRec.Insert;
            32:       // Space - insert final line
                TextRec.Insert;
            else begin // If the final word will fit on the current line add and insert the line;
                       // otherwise, insert the line and another with the final word.
                    if (StrLen(TextRec.Line) + TextRec.Spaces + StrLen(NextWord)) < MaxLen then begin
                        TextRec.Line := TextRec.Line + PadStr('', TextRec.Spaces) + ConvertStr(NextWord, FromChars, ToChars);
                        TextRec.Spaces := 0;
                        TextRec.Insert;
                    end else begin
                        TextRec.Insert;
                        TextRec.LineNo := TextRec.LineNo + 1;
                        TextRec.NewLine := false;
                        TextRec.Spaces := 0;
                        TextRec.Line := ConvertStr(NextWord, FromChars, ToChars);
                        TextRec.Insert;
                    end;
                end;
        end;
    end;

    local procedure WrapText(var NextLine: Text[250]; var Spaces: Integer; var RemainingText: Text[250]; Length: Integer)
    var
        CntSpaces: Boolean;
        i: Integer;
    begin
        if StrLen(RemainingText) <= Length then
            NextLine := RemainingText
        else
            NextLine := CopyStr(RemainingText, 1, Length);
        RemainingText := CopyStr(RemainingText, 1 + StrLen(NextLine));
        Spaces := 0;

        CntSpaces := Spaces < StrLen(RemainingText);
        while CntSpaces do begin
            if RemainingText[Spaces + 1] = ' ' then begin
                Spaces := Spaces + 1;
                CntSpaces := Spaces < StrLen(RemainingText);
            end else
                CntSpaces := false;
        end;

        if Spaces <> 0 then
            RemainingText := CopyStr(RemainingText, Spaces + 1);

        if (Spaces = 0) and (RemainingText <> '') then begin
            i := StrLen(NextLine);
            while (0 < i) and (NextLine[i] <> ' ') do
                i -= 1;
            RemainingText := CopyStr(NextLine, i + 1) + RemainingText;
            while (0 < i) and (NextLine[i] = ' ') do begin
                Spaces += 1;
                i -= 1;
            end;
            NextLine := CopyStr(NextLine, 1, i);
        end;
    end;

    procedure SetTable(TableNo: Integer)
    begin
        // P8000627A
        NoteTable := TableNo;
    end;

    procedure OpenTable(var TextRec: RecordRef)
    begin
        // P8000627A
        if NoteTable = 0 then
            NoteTable := DATABASE::"Extended Text";

        TextRec.Open(NoteTable);
    end;

    procedure AssignField(var RecordRef: RecordRef; FieldNo: Integer; FieldValue: Variant)
    var
        FieldRef: FieldRef;
    begin
        // P8000627A
        FieldRef := RecordRef.Field(FieldNo);
        FieldRef.Value := FieldValue;
    end;

    local procedure OEM() Map: Text[46]
    begin
        Map := '';
        Map[1] := 192;
        Map[2] := 193;
        Map[3] := 196;
        Map[4] := 197;
        Map[5] := 198;
        Map[6] := 199;
        Map[7] := 200;
        Map[8] := 201;
        Map[9] := 202;
        Map[10] := 203;
        Map[11] := 204;
        Map[12] := 205;
        Map[13] := 206;
        Map[14] := 207;
        Map[15] := 209;
        Map[16] := 210;
        Map[17] := 211;
        Map[18] := 212;
        Map[19] := 214;
        Map[20] := 220;
        Map[21] := 223;
        Map[22] := 224;
        Map[23] := 225;
        Map[24] := 226;
        Map[25] := 228;
        Map[26] := 229;
        Map[27] := 230;
        Map[28] := 231;
        Map[29] := 232;
        Map[30] := 233;
        Map[31] := 234;
        Map[32] := 235;
        Map[33] := 236;
        Map[34] := 237;
        Map[35] := 238;
        Map[36] := 239;
        Map[37] := 241;
        Map[38] := 242;
        Map[39] := 243;
        Map[40] := 244;
        Map[41] := 245;
        Map[42] := 246;
        Map[43] := 249;
        Map[44] := 250;
        Map[45] := 251;
        Map[46] := 252;
    end;

    local procedure ANSI() Map: Text[46]
    begin
        Map := '';
        Map[1] := 183;
        Map[2] := 181;
        Map[3] := 142;
        Map[4] := 143;
        Map[5] := 146;
        Map[6] := 128;
        Map[7] := 212;
        Map[8] := 144;
        Map[9] := 210;
        Map[10] := 211;
        Map[11] := 222;
        Map[12] := 214;
        Map[13] := 215;
        Map[14] := 216;
        Map[15] := 165;
        Map[16] := 227;
        Map[17] := 224;
        Map[18] := 226;
        Map[19] := 153;
        Map[20] := 154;
        Map[21] := 225;
        Map[22] := 133;
        Map[23] := 160;
        Map[24] := 131;
        Map[25] := 132;
        Map[26] := 134;
        Map[27] := 145;
        Map[28] := 135;
        Map[29] := 138;
        Map[30] := 130;
        Map[31] := 136;
        Map[32] := 137;
        Map[33] := 141;
        Map[34] := 161;
        Map[35] := 140;
        Map[36] := 139;
        Map[37] := 164;
        Map[38] := 149;
        Map[39] := 162;
        Map[40] := 147;
        Map[41] := 228;
        Map[42] := 148;
        Map[43] := 151;
        Map[44] := 163;
        Map[45] := 150;
        Map[46] := 129;
    end;
}

