codeunit 37002019 "Bitmap Functions"
{
    // PRW16.00.04
    // P8000889, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Create a bitmap to be displayed on the production sequencing page
    // 
    // PRW16.00.06
    // P8001094, Columbus IT, Jack Reynolds, 20 SEP 12
    //   Fix problem with index error if event start time is after timeline end time
    // 
    // P8001112, Columbus IT, Jack Reynolds, 06 NOV 12
    //   Fix problem with overlapping bitmaps
    // 
    // PRW17.00.01
    // P8001169, Columbus IT, Jack Reynolds, 01 JUN 13
    //   Fix encoding problem with the streaming of the bitmap
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    var
        StartDateTime: DateTime;
        EndDateTime: DateTime;
        Color: Text[4];
        ScaleFactor: Decimal;
        Header: array[74] of Integer;
        Bitmap: array[3, 1000] of Integer;
        Width: Integer;
        Height: Integer;
        RowMap: array[5, 3] of Integer;

    procedure Initialize(DateTime1: DateTime; DateTime2: DateTime)
    var
        BarPercent: Integer;
        Row: Integer;
        Index: Integer;
    begin
        StartDateTime := DateTime1;
        EndDateTime := DateTime2;

        Width := ArrayLen(Bitmap) / 3;
        Height := 45;
        BarPercent := 60;
        Row := (Height * (100 - BarPercent) / 100) div 2;

        RowMap[1, 1] := 1;
        RowMap[1, 2] := Row;
        RowMap[1, 3] := 1;
        RowMap[2, 1] := Row + 1;
        RowMap[2, 2] := Row + 2;
        RowMap[2, 3] := 2;
        RowMap[3, 1] := Row + 3;
        RowMap[3, 2] := Height - Row - 2;
        RowMap[3, 3] := 3;
        RowMap[4, 1] := Height - Row - 1;
        RowMap[4, 2] := Height - Row;
        RowMap[4, 3] := 2;
        RowMap[5, 1] := Height - Row + 1;
        RowMap[5, 2] := Height;
        RowMap[5, 3] := 1;

        // File Header
        AddText(Header, 'BM', 0);                     // Signature
        AddInteger(Header, 74 + Width * Height, 2, 4); // File Size
        AddInteger(Header, 74, 10, 4);                 // Offset to Pixel Array

        // Bitmap Information Header
        AddInteger(Header, 40, 14, 4);             // DIB Header Size (40)
        AddInteger(Header, Width, 18, 4);          // Image Width
        AddInteger(Header, Height, 22, 4);         // Image Height
        AddInteger(Header, 1, 26, 2);              // Number of Color Planes (1)
        AddInteger(Header, 8, 28, 2);              // Bits Per Pixel (8)
        AddInteger(Header, Width * Height, 36, 4); // Image Size
        AddInteger(Header, 5, 46, 4);              // Number of Colors (4)

        // Color Pallet
        AddInteger(Header, 16777215, 58, 3); // White
        AddInteger(Header, 0, 62, 3);        // Black
        AddInteger(Header, 65280, 66, 3);    // Green
        AddInteger(Header, 16711680, 70, 3); // Red

        ScaleFactor := Width / (EndDateTime - StartDateTime);

        for Index := 1 to 4 do
            Color[Index] := Index;
    end;

    procedure CreateBitmap(var OutStr: OutStream; var BitmapDef: Record "Bitmap Definition" temporary)
    var
        StreamWriter: Codeunit DotNet_StreamWriter;
        Encoding: Codeunit DotNet_Encoding;
        Index: Integer;
        Row: Integer;
        Column: Integer;
        Char: Char;
        StartColumn: Integer;
        EndColumn: Integer;
        LastColumn: Integer;
        BitmapText1: Text;
        BitmapText2: Text;
        BitmapText3: Text;
    begin
        // P80073095
        //StreamWriter := StreamWriter.StreamWriter(OutStr,Encoding.GetEncoding(1252)); // P8001169
        Encoding.Encoding(1252);
        StreamWriter.StreamWriter(OutStr, Encoding);
        // P80073095
        BitmapDef.SetFilter(Start, '<%1', EndDateTime); // P8001094
        Clear(Bitmap); // P8001112

        // Top and bottom border rows
        if BitmapDef.FindSet then
            repeat
                if BitmapDef.Start < StartDateTime then
                    BitmapDef.Start := StartDateTime;
                StartColumn := 1 + Round(ScaleFactor * (BitmapDef.Start - StartDateTime), 1);
                if EndDateTime < BitmapDef.Stop then
                    BitmapDef.Stop := EndDateTime;
                EndColumn := Round(ScaleFactor * (BitmapDef.Stop - StartDateTime), 1);
                for Column := StartColumn to EndColumn do
                    Bitmap[2, Column] := 1;
            until BitmapDef.Next = 0;

        // Internal rows
        if BitmapDef.FindSet then begin
            LastColumn := -1;
            repeat
                if BitmapDef.Start < StartDateTime then
                    BitmapDef.Start := StartDateTime;
                StartColumn := 1 + Round(ScaleFactor * (BitmapDef.Start - StartDateTime), 1);
                if EndDateTime < BitmapDef.Stop then
                    BitmapDef.Stop := EndDateTime;
                EndColumn := Round(ScaleFactor * (BitmapDef.Stop - StartDateTime), 1);
                if (LastColumn + 1) < StartColumn then begin
                    if LastColumn > 1 then begin
                        Bitmap[3, LastColumn - 1] := BitmapDef.Color::Black;
                        Bitmap[3, LastColumn] := BitmapDef.Color::Black;
                    end;
                    Bitmap[3, StartColumn] := BitmapDef.Color::Black;
                    Bitmap[3, StartColumn + 1] := BitmapDef.Color::Black;
                    StartColumn += 2;
                end;
                for Column := StartColumn to EndColumn do
                    Bitmap[3, Column] := BitmapDef.Color;
                LastColumn := EndColumn;
            until BitmapDef.Next = 0;
            if LastColumn > 1 then begin
                Bitmap[3, LastColumn - 1] := BitmapDef.Color::Black;
                Bitmap[3, LastColumn] := BitmapDef.Color::Black;
            end;
        end;

        for Index := 1 to ArrayLen(Header) do begin
            Char := Header[Index];
            //OutStr.WRITE(Char);     // P8001169
            StreamWriter.Write2(Char); // P8001169, P80073095
        end;

        for Column := 1 to Width do begin
            // P8001169
            //BitmapText1.ADDTEXT(COPYSTR(Color,1+Bitmap[1,Column],1));
            //BitmapText2.ADDTEXT(COPYSTR(Color,1+Bitmap[2,Column],1));
            //BitmapText3.ADDTEXT(COPYSTR(Color,1+Bitmap[3,Column],1));
            BitmapText1 := BitmapText1 + CopyStr(Color, 1 + Bitmap[1, Column], 1);
            BitmapText2 := BitmapText2 + CopyStr(Color, 1 + Bitmap[2, Column], 1);
            BitmapText3 := BitmapText3 + CopyStr(Color, 1 + Bitmap[3, Column], 1);
            // P8001169
        end;

        for Index := 1 to 5 do
            for Row := RowMap[Index, 1] to RowMap[Index, 2] do
                case RowMap[Index, 3] of
                    // P8001169
                    //1 : BitmapText1.WRITE(OutStr);
                    //2 : BitmapText2.WRITE(OutStr);
                    //3 : BitmapText3.WRITE(OutStr);
                    1:
                        StreamWriter.Write(BitmapText1);
                    2:
                        StreamWriter.Write(BitmapText2);
                    3:
                        StreamWriter.Write(BitmapText3);
                        // P8001169
                end;
    end;

    local procedure AddInteger(var Header: array[74] of Integer; IntegerValue: Integer; Offset: Integer; Bytes: Integer)
    var
        i: Integer;
    begin
        for i := (Offset + 1) to (Offset + Bytes) do begin
            Header[i] := IntegerValue mod 256;
            IntegerValue := (IntegerValue - Header[i]) div 256;
        end;
    end;

    local procedure AddText(var Header: array[74] of Integer; TextValue: Text[1024]; Offset: Integer)
    var
        i: Integer;
        Char: Char;
    begin
        for i := 1 to StrLen(TextValue) do begin
            Char := TextValue[i];
            Header[Offset + i] := Char;
        end;
    end;
}

