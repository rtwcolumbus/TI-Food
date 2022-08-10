codeunit 37002003 "Wordwrap Functions"
{
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013


    trigger OnRun()
    begin
    end;

    var
        TextRec: Record "Extended Text";
        TextCharSize: array[224] of Integer;
        TextLineLength: Integer;
        TextBuffer: Text[250];
        TextCR: Text[1];

    procedure WrapString(CharSize: array[224] of Integer; LineLength: Integer; var TextString: Text[250]; var NextLine: Text[250]): Boolean
    var
        pos: Integer;
        LastChar: Char;
        CurrentChar: Char;
        Word: Text[250];
        WordLength: Integer;
        WordStart: Integer;
        Spaces: Text[250];
        CharSizePos: Integer;
    begin
        for pos := 1 to StrLen(TextString) do begin
            CurrentChar := TextString[pos];
            if CurrentChar = 32 then begin // Space
                if LastChar = 32 then begin // Unlimited multiple spaces can be added
                    Spaces += ' ';
                    LineLength -= CharSize[31];
                end else
                    if WordLength <= LineLength then begin // End of word, will it fit?
                        NextLine += Spaces + Word;
                        LineLength -= WordLength;
                        Clear(Word);
                        Clear(WordLength);
                        Spaces := ' ';
                        LineLength -= CharSize[31];
                    end else begin // Doesn't fit
                        TextString := CopyStr(TextString, WordStart);
                        exit(true);
                    end;
            end else begin
                if Word = '' then
                    WordStart := pos;
                Word += Format(CurrentChar);
                CharSizePos := CurrentChar - 31;     // P8001132
                WordLength += CharSize[CharSizePos]; // P8001132
            end;
            LastChar := CurrentChar;
        end;

        // Made it all the way through, will the last word fit?
        if LastChar = 32 then
            exit(false)
        else
            if WordLength <= LineLength then begin
                NextLine += Spaces + Word;
                TextString := '';
                exit(false);
            end else begin
                TextString := CopyStr(TextString, WordStart);
                exit(true);
            end;
    end;

    procedure WrapTextInitialize(CharSize: array[224] of Integer; LineLength: Integer; TextID: Integer): Boolean
    begin
        CopyArray(TextCharSize, CharSize, 1);
        TextLineLength := LineLength;
        Clear(TextBuffer);
        TextCR[1] := 13;
        TextRec.Reset;
        TextRec.SetRange(ID, TextID);
        if TextRec.Find('-') then begin
            if TextRec.NewLine then
                TextBuffer := TextCR;
            TextBuffer += TextRec.Line + PadStr('', TextRec.Spaces, ' ');
            exit(true);
        end else
            exit(false);
    end;

    procedure WrapTextNextLine(var NextLine: Text[250]): Boolean
    var
        lastrec: Boolean;
        pos: Integer;
        LastChar: Char;
        CurrentChar: Char;
        Word: Text[250];
        WordLength: Integer;
        WordStart: Integer;
        Spaces: Text[250];
        LineLength: Integer;
        CharSizePos: Integer;
    begin
        pos := 1;
        LineLength := TextLineLength;
        while pos <= StrLen(TextBuffer) do begin
            if pos = StrLen(TextBuffer) then begin
                // Read next record into buffer
                lastrec := TextRec.Next = 0;
                if not lastrec then begin
                    TextBuffer := CopyStr(TextBuffer, WordStart);
                    pos := pos - WordStart + 1;
                    WordStart := 1;
                    if TextRec.NewLine then
                        TextBuffer += TextCR;
                    TextBuffer += TextRec.Line + PadStr('', TextRec.Spaces, ' ');
                end;
            end;

            CurrentChar := TextBuffer[pos];
            case CurrentChar of
                13:
                    begin
                        if LastChar = 32 then begin
                            TextBuffer := CopyStr(TextBuffer, pos + 1);
                            exit(true);
                        end else
                            if WordLength <= LineLength then begin // Will current word fit?
                                NextLine += Spaces + Word;
                                TextBuffer := CopyStr(TextBuffer, pos + 1);
                                exit(true);
                            end else begin
                                TextBuffer := CopyStr(TextBuffer, WordStart);
                                exit(true);
                            end;
                    end;

                32:
                    begin
                        if LastChar = 32 then begin // Unlimited multiple spaces can be added
                            Spaces += ' ';
                            LineLength -= TextCharSize[31];
                        end else
                            if WordLength <= LineLength then begin // End of word, will it fit?
                                NextLine += Spaces + Word;
                                LineLength -= WordLength;
                                Clear(Word);
                                Clear(WordLength);
                                Spaces := ' ';
                                LineLength -= TextCharSize[31];
                            end else begin // Doesn't fit
                                TextBuffer := CopyStr(TextBuffer, WordStart);
                                exit(true);
                            end;
                    end;

                else begin
                        if Word = '' then
                            WordStart := pos;
                        Word += Format(CurrentChar);
                        CharSizePos := CurrentChar - 31;         // P8001132
                        WordLength += TextCharSize[CharSizePos]; // P8001132
                    end;
            end;
            LastChar := CurrentChar;
            pos += 1;
        end;

        // Made it all the way through, will the last word fit?
        if LastChar = 32 then
            exit(false)
        else
            if WordLength <= LineLength then begin
                NextLine += Spaces + Word;
                TextBuffer := '';
                exit(false);
            end else begin
                TextBuffer := CopyStr(TextBuffer, WordStart);
                exit(true);
            end;
    end;

    procedure SetCharSize(FontName: Code[10]; FontStyle: Code[10]; FontSize: Integer; var CharSize: array[224] of Integer)
    begin
        case FontName + ' - ' + FontStyle + ' - ' + Format(FontSize) of
            'ARIAL - REGULAR - 10':
                begin
                    CharSize[1] := 98;
                    CharSize[2] := 98;
                    CharSize[3] := 123;
                    CharSize[4] := 191;
                    CharSize[5] := 191;
                    CharSize[6] := 305;
                    CharSize[7] := 229;
                    CharSize[8] := 64;
                    CharSize[9] := 115;
                    CharSize[10] := 115;
                    CharSize[11] := 136;
                    CharSize[12] := 199;
                    CharSize[13] := 98;
                    CharSize[14] := 115;
                    CharSize[15] := 98;
                    CharSize[16] := 98;
                    CharSize[17] := 191;
                    CharSize[18] := 191;
                    CharSize[19] := 191;
                    CharSize[20] := 191;
                    CharSize[21] := 191;
                    CharSize[22] := 191;
                    CharSize[23] := 191;
                    CharSize[24] := 191;
                    CharSize[25] := 191;
                    CharSize[26] := 191;
                    CharSize[27] := 98;
                    CharSize[28] := 98;
                    CharSize[29] := 199;
                    CharSize[30] := 199;
                    CharSize[31] := 199;
                    CharSize[32] := 191;
                    CharSize[33] := 348;
                    CharSize[34] := 229;
                    CharSize[35] := 229;
                    CharSize[36] := 246;
                    CharSize[37] := 246;
                    CharSize[38] := 229;
                    CharSize[39] := 208;
                    CharSize[40] := 267;
                    CharSize[41] := 246;
                    CharSize[42] := 98;
                    CharSize[43] := 174;
                    CharSize[44] := 229;
                    CharSize[45] := 191;
                    CharSize[46] := 284;
                    CharSize[47] := 246;
                    CharSize[48] := 267;
                    CharSize[49] := 229;
                    CharSize[50] := 267;
                    CharSize[51] := 246;
                    CharSize[52] := 229;
                    CharSize[53] := 208;
                    CharSize[54] := 246;
                    CharSize[55] := 229;
                    CharSize[56] := 322;
                    CharSize[57] := 229;
                    CharSize[58] := 229;
                    CharSize[59] := 208;
                    CharSize[60] := 98;
                    CharSize[61] := 98;
                    CharSize[62] := 98;
                    CharSize[63] := 161;
                    CharSize[64] := 191;
                    CharSize[65] := 115;
                    CharSize[66] := 191;
                    CharSize[67] := 191;
                    CharSize[68] := 174;
                    CharSize[69] := 191;
                    CharSize[70] := 191;
                    CharSize[71] := 98;
                    CharSize[72] := 191;
                    CharSize[73] := 191;
                    CharSize[74] := 77;
                    CharSize[75] := 77;
                    CharSize[76] := 174;
                    CharSize[77] := 77;
                    CharSize[78] := 284;
                    CharSize[79] := 191;
                    CharSize[80] := 191;
                    CharSize[81] := 191;
                    CharSize[82] := 191;
                    CharSize[83] := 115;
                    CharSize[84] := 174;
                    CharSize[85] := 98;
                    CharSize[86] := 191;
                    CharSize[87] := 174;
                    CharSize[88] := 246;
                    CharSize[89] := 174;
                    CharSize[90] := 174;
                    CharSize[91] := 174;
                    CharSize[92] := 115;
                    CharSize[93] := 89;
                    CharSize[94] := 115;
                    CharSize[95] := 199;
                    CharSize[96] := 242;
                    CharSize[97] := 246;
                    CharSize[98] := 191;
                    CharSize[99] := 191;
                    CharSize[100] := 191;
                    CharSize[101] := 191;
                    CharSize[102] := 191;
                    CharSize[103] := 199;
                    CharSize[104] := 174;
                    CharSize[105] := 191;
                    CharSize[106] := 191;
                    CharSize[107] := 191;
                    CharSize[108] := 98;
                    CharSize[109] := 98;
                    CharSize[110] := 343;
                    CharSize[111] := 229;
                    CharSize[112] := 115;
                    CharSize[113] := 229;
                    CharSize[114] := 77;
                    CharSize[115] := 199;
                    CharSize[116] := 191;
                    CharSize[117] := 191;
                    CharSize[118] := 343;
                    CharSize[119] := 191;
                    CharSize[120] := 98;
                    CharSize[121] := 98;
                    CharSize[122] := 267;
                    CharSize[123] := 246;
                    CharSize[124] := 191;
                    CharSize[125] := 191;
                    CharSize[126] := 191;
                    CharSize[127] := 254;
                    CharSize[128] := 191;
                    CharSize[129] := 191;
                    CharSize[130] := 98;
                    CharSize[131] := 191;
                    CharSize[132] := 191;
                    CharSize[133] := 191;
                    CharSize[134] := 246;
                    CharSize[135] := 254;
                    CharSize[136] := 343;
                    CharSize[137] := 208;
                    CharSize[138] := 229;
                    CharSize[139] := 191;
                    CharSize[140] := 208;
                    CharSize[141] := 174;
                    CharSize[142] := 115;
                    CharSize[143] := 191;
                    CharSize[144] := 191;
                    CharSize[145] := 343;
                    CharSize[146] := 343;
                    CharSize[147] := 343;
                    CharSize[148] := 89;
                    CharSize[149] := 89;
                    CharSize[150] := 89;
                    CharSize[151] := 89;
                    CharSize[152] := 199;
                    CharSize[153] := 199;
                    CharSize[154] := 89;
                    CharSize[155] := 89;
                    CharSize[156] := 199;
                    CharSize[157] := 199;
                    CharSize[158] := 199;
                    CharSize[159] := 199;
                    CharSize[160] := 199;
                    CharSize[161] := 229;
                    CharSize[162] := 229;
                    CharSize[163] := 229;
                    CharSize[164] := 229;
                    CharSize[165] := 229;
                    CharSize[166] := 229;
                    CharSize[167] := 343;
                    CharSize[168] := 246;
                    CharSize[169] := 229;
                    CharSize[170] := 229;
                    CharSize[171] := 229;
                    CharSize[172] := 229;
                    CharSize[173] := 98;
                    CharSize[174] := 98;
                    CharSize[175] := 98;
                    CharSize[176] := 98;
                    CharSize[177] := 115;
                    CharSize[178] := 246;
                    CharSize[179] := 267;
                    CharSize[180] := 267;
                    CharSize[181] := 267;
                    CharSize[182] := 267;
                    CharSize[183] := 267;
                    CharSize[184] := 199;
                    CharSize[185] := 267;
                    CharSize[186] := 246;
                    CharSize[187] := 246;
                    CharSize[188] := 246;
                    CharSize[189] := 246;
                    CharSize[190] := 229;
                    CharSize[191] := 89;
                    CharSize[192] := 191;
                    CharSize[193] := 115;
                    CharSize[194] := 208;
                    CharSize[195] := 288;
                    CharSize[196] := 191;
                    CharSize[197] := 191;
                    CharSize[198] := 115;
                    CharSize[199] := 191;
                    CharSize[200] := 77;
                    CharSize[201] := 115;
                    CharSize[202] := 115;
                    CharSize[203] := 229;
                    CharSize[204] := 174;
                    CharSize[205] := 77;
                    CharSize[206] := 115;
                    CharSize[207] := 115;
                    CharSize[208] := 98;
                    CharSize[209] := 115;
                    CharSize[210] := 98;
                    CharSize[211] := 343;
                    CharSize[212] := 115;
                    CharSize[213] := 119;
                    CharSize[214] := 191;
                    CharSize[215] := 187;
                    CharSize[216] := 123;
                    CharSize[217] := 136;
                    CharSize[218] := 187;
                    CharSize[219] := 229;
                    CharSize[220] := 288;
                    CharSize[221] := 98;
                    CharSize[222] := 191;
                    CharSize[223] := 89;
                    CharSize[224] := 98;
                end;

            'ARIAL - BOLD - 10':
                begin
                    CharSize[1] := 98;
                    CharSize[2] := 98;
                    CharSize[3] := 123;
                    CharSize[4] := 191;
                    CharSize[5] := 191;
                    CharSize[6] := 305;
                    CharSize[7] := 229;
                    CharSize[8] := 64;
                    CharSize[9] := 115;
                    CharSize[10] := 115;
                    CharSize[11] := 136;
                    CharSize[12] := 199;
                    CharSize[13] := 98;
                    CharSize[14] := 115;
                    CharSize[15] := 98;
                    CharSize[16] := 98;
                    CharSize[17] := 191;
                    CharSize[18] := 191;
                    CharSize[19] := 191;
                    CharSize[20] := 191;
                    CharSize[21] := 191;
                    CharSize[22] := 191;
                    CharSize[23] := 191;
                    CharSize[24] := 191;
                    CharSize[25] := 191;
                    CharSize[26] := 191;
                    CharSize[27] := 98;
                    CharSize[28] := 98;
                    CharSize[29] := 199;
                    CharSize[30] := 199;
                    CharSize[31] := 199;
                    CharSize[32] := 191;
                    CharSize[33] := 348;
                    CharSize[34] := 229;
                    CharSize[35] := 229;
                    CharSize[36] := 246;
                    CharSize[37] := 246;
                    CharSize[38] := 229;
                    CharSize[39] := 208;
                    CharSize[40] := 267;
                    CharSize[41] := 246;
                    CharSize[42] := 98;
                    CharSize[43] := 174;
                    CharSize[44] := 229;
                    CharSize[45] := 191;
                    CharSize[46] := 284;
                    CharSize[47] := 246;
                    CharSize[48] := 267;
                    CharSize[49] := 229;
                    CharSize[50] := 267;
                    CharSize[51] := 246;
                    CharSize[52] := 229;
                    CharSize[53] := 208;
                    CharSize[54] := 246;
                    CharSize[55] := 229;
                    CharSize[56] := 322;
                    CharSize[57] := 229;
                    CharSize[58] := 229;
                    CharSize[59] := 208;
                    CharSize[60] := 98;
                    CharSize[61] := 98;
                    CharSize[62] := 98;
                    CharSize[63] := 161;
                    CharSize[64] := 191;
                    CharSize[65] := 115;
                    CharSize[66] := 191;
                    CharSize[67] := 191;
                    CharSize[68] := 174;
                    CharSize[69] := 191;
                    CharSize[70] := 191;
                    CharSize[71] := 98;
                    CharSize[72] := 191;
                    CharSize[73] := 191;
                    CharSize[74] := 77;
                    CharSize[75] := 77;
                    CharSize[76] := 174;
                    CharSize[77] := 77;
                    CharSize[78] := 284;
                    CharSize[79] := 191;
                    CharSize[80] := 191;
                    CharSize[81] := 191;
                    CharSize[82] := 191;
                    CharSize[83] := 115;
                    CharSize[84] := 174;
                    CharSize[85] := 98;
                    CharSize[86] := 191;
                    CharSize[87] := 174;
                    CharSize[88] := 246;
                    CharSize[89] := 174;
                    CharSize[90] := 174;
                    CharSize[91] := 174;
                    CharSize[92] := 115;
                    CharSize[93] := 89;
                    CharSize[94] := 115;
                    CharSize[95] := 199;
                    CharSize[96] := 242;
                    CharSize[97] := 246;
                    CharSize[98] := 191;
                    CharSize[99] := 191;
                    CharSize[100] := 191;
                    CharSize[101] := 191;
                    CharSize[102] := 191;
                    CharSize[103] := 199;
                    CharSize[104] := 174;
                    CharSize[105] := 191;
                    CharSize[106] := 191;
                    CharSize[107] := 191;
                    CharSize[108] := 98;
                    CharSize[109] := 98;
                    CharSize[110] := 343;
                    CharSize[111] := 229;
                    CharSize[112] := 115;
                    CharSize[113] := 229;
                    CharSize[114] := 77;
                    CharSize[115] := 199;
                    CharSize[116] := 191;
                    CharSize[117] := 191;
                    CharSize[118] := 343;
                    CharSize[119] := 191;
                    CharSize[120] := 98;
                    CharSize[121] := 98;
                    CharSize[122] := 267;
                    CharSize[123] := 246;
                    CharSize[124] := 191;
                    CharSize[125] := 191;
                    CharSize[126] := 191;
                    CharSize[127] := 254;
                    CharSize[128] := 191;
                    CharSize[129] := 191;
                    CharSize[130] := 98;
                    CharSize[131] := 191;
                    CharSize[132] := 191;
                    CharSize[133] := 191;
                    CharSize[134] := 246;
                    CharSize[135] := 254;
                    CharSize[136] := 343;
                    CharSize[137] := 208;
                    CharSize[138] := 229;
                    CharSize[139] := 191;
                    CharSize[140] := 208;
                    CharSize[141] := 174;
                    CharSize[142] := 115;
                    CharSize[143] := 191;
                    CharSize[144] := 191;
                    CharSize[145] := 343;
                    CharSize[146] := 343;
                    CharSize[147] := 343;
                    CharSize[148] := 89;
                    CharSize[149] := 89;
                    CharSize[150] := 89;
                    CharSize[151] := 89;
                    CharSize[152] := 199;
                    CharSize[153] := 199;
                    CharSize[154] := 89;
                    CharSize[155] := 89;
                    CharSize[156] := 199;
                    CharSize[157] := 199;
                    CharSize[158] := 199;
                    CharSize[159] := 199;
                    CharSize[160] := 199;
                    CharSize[161] := 229;
                    CharSize[162] := 229;
                    CharSize[163] := 229;
                    CharSize[164] := 229;
                    CharSize[165] := 229;
                    CharSize[166] := 229;
                    CharSize[167] := 343;
                    CharSize[168] := 246;
                    CharSize[169] := 229;
                    CharSize[170] := 229;
                    CharSize[171] := 229;
                    CharSize[172] := 229;
                    CharSize[173] := 98;
                    CharSize[174] := 98;
                    CharSize[175] := 98;
                    CharSize[176] := 98;
                    CharSize[177] := 115;
                    CharSize[178] := 246;
                    CharSize[179] := 267;
                    CharSize[180] := 267;
                    CharSize[181] := 267;
                    CharSize[182] := 267;
                    CharSize[183] := 267;
                    CharSize[184] := 199;
                    CharSize[185] := 267;
                    CharSize[186] := 246;
                    CharSize[187] := 246;
                    CharSize[188] := 246;
                    CharSize[189] := 246;
                    CharSize[190] := 229;
                    CharSize[191] := 89;
                    CharSize[192] := 191;
                    CharSize[193] := 115;
                    CharSize[194] := 208;
                    CharSize[195] := 288;
                    CharSize[196] := 191;
                    CharSize[197] := 191;
                    CharSize[198] := 115;
                    CharSize[199] := 191;
                    CharSize[200] := 77;
                    CharSize[201] := 115;
                    CharSize[202] := 115;
                    CharSize[203] := 229;
                    CharSize[204] := 174;
                    CharSize[205] := 77;
                    CharSize[206] := 115;
                    CharSize[207] := 115;
                    CharSize[208] := 98;
                    CharSize[209] := 115;
                    CharSize[210] := 98;
                    CharSize[211] := 343;
                    CharSize[212] := 115;
                    CharSize[213] := 119;
                    CharSize[214] := 191;
                    CharSize[215] := 187;
                    CharSize[216] := 123;
                    CharSize[217] := 136;
                    CharSize[218] := 187;
                    CharSize[219] := 229;
                    CharSize[220] := 288;
                    CharSize[221] := 98;
                    CharSize[222] := 191;
                    CharSize[223] := 89;
                    CharSize[224] := 98;
                end;

            'ARIAL - REGULAR - 9':
                begin
                    CharSize[1] := 88;
                    CharSize[2] := 88;
                    CharSize[3] := 114;
                    CharSize[4] := 177;
                    CharSize[5] := 177;
                    CharSize[6] := 283;
                    CharSize[7] := 211;
                    CharSize[8] := 59;
                    CharSize[9] := 105;
                    CharSize[10] := 105;
                    CharSize[11] := 122;
                    CharSize[12] := 186;
                    CharSize[13] := 88;
                    CharSize[14] := 105;
                    CharSize[15] := 88;
                    CharSize[16] := 88;
                    CharSize[17] := 177;
                    CharSize[18] := 177;
                    CharSize[19] := 177;
                    CharSize[20] := 177;
                    CharSize[21] := 177;
                    CharSize[22] := 177;
                    CharSize[23] := 177;
                    CharSize[24] := 177;
                    CharSize[25] := 177;
                    CharSize[26] := 177;
                    CharSize[27] := 88;
                    CharSize[28] := 88;
                    CharSize[29] := 186;
                    CharSize[30] := 186;
                    CharSize[31] := 186;
                    CharSize[32] := 177;
                    CharSize[33] := 321;
                    CharSize[34] := 211;
                    CharSize[35] := 211;
                    CharSize[36] := 228;
                    CharSize[37] := 228;
                    CharSize[38] := 211;
                    CharSize[39] := 194;
                    CharSize[40] := 245;
                    CharSize[41] := 228;
                    CharSize[42] := 88;
                    CharSize[43] := 160;
                    CharSize[44] := 211;
                    CharSize[45] := 177;
                    CharSize[46] := 262;
                    CharSize[47] := 228;
                    CharSize[48] := 245;
                    CharSize[49] := 211;
                    CharSize[50] := 245;
                    CharSize[51] := 228;
                    CharSize[52] := 211;
                    CharSize[53] := 194;
                    CharSize[54] := 228;
                    CharSize[55] := 211;
                    CharSize[56] := 300;
                    CharSize[57] := 211;
                    CharSize[58] := 211;
                    CharSize[59] := 194;
                    CharSize[60] := 88;
                    CharSize[61] := 88;
                    CharSize[62] := 88;
                    CharSize[63] := 148;
                    CharSize[64] := 177;
                    CharSize[65] := 105;
                    CharSize[66] := 177;
                    CharSize[67] := 177;
                    CharSize[68] := 160;
                    CharSize[69] := 177;
                    CharSize[70] := 177;
                    CharSize[71] := 88;
                    CharSize[72] := 177;
                    CharSize[73] := 177;
                    CharSize[74] := 71;
                    CharSize[75] := 71;
                    CharSize[76] := 160;
                    CharSize[77] := 71;
                    CharSize[78] := 262;
                    CharSize[79] := 177;
                    CharSize[80] := 177;
                    CharSize[81] := 177;
                    CharSize[82] := 177;
                    CharSize[83] := 105;
                    CharSize[84] := 160;
                    CharSize[85] := 88;
                    CharSize[86] := 177;
                    CharSize[87] := 160;
                    CharSize[88] := 228;
                    CharSize[89] := 160;
                    CharSize[90] := 160;
                    CharSize[91] := 160;
                    CharSize[92] := 105;
                    CharSize[93] := 80;
                    CharSize[94] := 105;
                    CharSize[95] := 186;
                    CharSize[96] := 224;
                    CharSize[97] := 228;
                    CharSize[98] := 177;
                    CharSize[99] := 177;
                    CharSize[100] := 177;
                    CharSize[101] := 177;
                    CharSize[102] := 177;
                    CharSize[103] := 186;
                    CharSize[104] := 160;
                    CharSize[105] := 177;
                    CharSize[106] := 177;
                    CharSize[107] := 177;
                    CharSize[108] := 88;
                    CharSize[109] := 88;
                    CharSize[110] := 317;
                    CharSize[111] := 211;
                    CharSize[112] := 105;
                    CharSize[113] := 211;
                    CharSize[114] := 71;
                    CharSize[115] := 186;
                    CharSize[116] := 177;
                    CharSize[117] := 177;
                    CharSize[118] := 317;
                    CharSize[119] := 177;
                    CharSize[120] := 88;
                    CharSize[121] := 88;
                    CharSize[122] := 245;
                    CharSize[123] := 228;
                    CharSize[124] := 177;
                    CharSize[125] := 177;
                    CharSize[126] := 177;
                    CharSize[127] := 232;
                    CharSize[128] := 177;
                    CharSize[129] := 177;
                    CharSize[130] := 88;
                    CharSize[131] := 177;
                    CharSize[132] := 177;
                    CharSize[133] := 177;
                    CharSize[134] := 228;
                    CharSize[135] := 232;
                    CharSize[136] := 317;
                    CharSize[137] := 194;
                    CharSize[138] := 211;
                    CharSize[139] := 177;
                    CharSize[140] := 194;
                    CharSize[141] := 160;
                    CharSize[142] := 105;
                    CharSize[143] := 177;
                    CharSize[144] := 177;
                    CharSize[145] := 317;
                    CharSize[146] := 317;
                    CharSize[147] := 317;
                    CharSize[148] := 80;
                    CharSize[149] := 80;
                    CharSize[150] := 80;
                    CharSize[151] := 80;
                    CharSize[152] := 186;
                    CharSize[153] := 186;
                    CharSize[154] := 80;
                    CharSize[155] := 80;
                    CharSize[156] := 186;
                    CharSize[157] := 186;
                    CharSize[158] := 186;
                    CharSize[159] := 186;
                    CharSize[160] := 186;
                    CharSize[161] := 211;
                    CharSize[162] := 211;
                    CharSize[163] := 211;
                    CharSize[164] := 211;
                    CharSize[165] := 211;
                    CharSize[166] := 211;
                    CharSize[167] := 317;
                    CharSize[168] := 228;
                    CharSize[169] := 211;
                    CharSize[170] := 211;
                    CharSize[171] := 211;
                    CharSize[172] := 211;
                    CharSize[173] := 88;
                    CharSize[174] := 88;
                    CharSize[175] := 88;
                    CharSize[176] := 88;
                    CharSize[177] := 105;
                    CharSize[178] := 228;
                    CharSize[179] := 245;
                    CharSize[180] := 245;
                    CharSize[181] := 245;
                    CharSize[182] := 245;
                    CharSize[183] := 245;
                    CharSize[184] := 186;
                    CharSize[185] := 245;
                    CharSize[186] := 228;
                    CharSize[187] := 228;
                    CharSize[188] := 228;
                    CharSize[189] := 228;
                    CharSize[190] := 211;
                    CharSize[191] := 80;
                    CharSize[192] := 177;
                    CharSize[193] := 105;
                    CharSize[194] := 194;
                    CharSize[195] := 266;
                    CharSize[196] := 177;
                    CharSize[197] := 177;
                    CharSize[198] := 105;
                    CharSize[199] := 177;
                    CharSize[200] := 71;
                    CharSize[201] := 105;
                    CharSize[202] := 105;
                    CharSize[203] := 211;
                    CharSize[204] := 160;
                    CharSize[205] := 71;
                    CharSize[206] := 105;
                    CharSize[207] := 105;
                    CharSize[208] := 88;
                    CharSize[209] := 105;
                    CharSize[210] := 88;
                    CharSize[211] := 317;
                    CharSize[212] := 105;
                    CharSize[213] := 110;
                    CharSize[214] := 177;
                    CharSize[215] := 173;
                    CharSize[216] := 114;
                    CharSize[217] := 127;
                    CharSize[218] := 173;
                    CharSize[219] := 211;
                    CharSize[220] := 266;
                    CharSize[221] := 88;
                    CharSize[222] := 173;
                    CharSize[223] := 80;
                    CharSize[224] := 88;
                end;
        end;
    end;
}

