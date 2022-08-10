codeunit 3025 DotNet_StreamWriter
{
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    var
        DotNetStreamWriter: DotNet StreamWriter;

    procedure Write(Text: Text)
    begin
        DotNetStreamWriter.Write(Text);
    end;

    procedure Write2(Char: Char)
    begin
        // P80073095
        DotNetStreamWriter.Write(Char);
    end;

    procedure WriteLine(LineText: Text)
    begin
        DotNetStreamWriter.WriteLine(LineText);
    end;

    procedure StreamWriter(var OutStream: OutStream; DotNet_Encoding: Codeunit DotNet_Encoding)
    var
        DotNetEncoding: DotNet Encoding;
    begin
        DotNet_Encoding.GetEncoding(DotNetEncoding);
        DotNetStreamWriter := DotNetStreamWriter.StreamWriter(OutStream, DotNetEncoding);
    end;

    procedure StreamWriter(var OutStream: OutStream)
    begin
        DotNetStreamWriter := DotNetStreamWriter.StreamWriter(OutStream);
    end;

    procedure Flush()
    begin
        DotNetStreamWriter.Flush;
    end;

    procedure Close()
    begin
        DotNetStreamWriter.Close;
    end;

    procedure Dispose()
    begin
        DotNetStreamWriter.Dispose;
    end;
}

