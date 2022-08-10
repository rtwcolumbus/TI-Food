table 37002208 Color
{
    Caption = 'Color';
    LookupPageID = Colors;
    ObsoleteState = Pending;
    ObsoleteReason = 'This was used to support color selection for the VPS which never made it to AL';
    ObsoleteTag = 'FOOD-21';
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(3; Red; Integer)
        {
            Caption = 'Red';
            MaxValue = 255;
            MinValue = 0;

            trigger OnValidate()
            begin
                SetColor;
            end;
        }
        field(4; Green; Integer)
        {
            Caption = 'Green';
            MaxValue = 255;
            MinValue = 0;

            trigger OnValidate()
            begin
                SetColor;
            end;
        }
        field(5; Blue; Integer)
        {
            Caption = 'Blue';
            MaxValue = 255;
            MinValue = 0;

            trigger OnValidate()
            begin
                SetColor;
            end;
        }
        field(11; Color; BLOB)
        {
            Caption = 'Color';
            SubType = Bitmap;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; Red, Green, Blue)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        xRec.Red := -1;
        SetColor;
    end;

    [Obsolete('This was used to support color selection for the VPS which never made it to AL', 'FOOD-21')]
    procedure AssistEdit()
    var
        [RunOnClient]
        ColorDialog: DotNet ColorDialog;
        [RunOnClient]
        Color: DotNet Color;
        [RunOnClient]
        DialogResult: DotNet DialogResult;
    begin
        ColorDialog := ColorDialog.ColorDialog;
        ColorDialog.AllowFullOpen := true;
        ColorDialog.SolidColorOnly := true;
        ColorDialog.FullOpen := true;
        ColorDialog.Color := Color.FromArgb(Red, Green, Blue);
        DialogResult := ColorDialog.ShowDialog;
        if DialogResult.CompareTo(DialogResult.OK) = 0 then begin
            Red := ColorDialog.Color.R;
            Green := ColorDialog.Color.G;
            Blue := ColorDialog.Color.B;
            SetColor;
        end;
    end;

    [Obsolete('This was used to support color selection for the VPS which never made it to AL','FOOD-21')]
    procedure SetColor()
    var
        Bitmap: DotNet Bitmap;
        Graphics: DotNet Graphics;
        Brush: DotNet SolidBrush;
        Pen: DotNet Pen;
        Color: DotNet Color;
        GraphicsUnit: DotNet GraphicsUnit;
        ImageFormat: DotNet ImageFormat;
        Width: Integer;
        Height: Integer;
        OutStr: OutStream;
    begin
        if (Red = xRec.Red) and (Green = xRec.Green) and (Blue = xRec.Blue) then
            exit;

        Width := 32;
        Height := 20;

        Bitmap := Bitmap.Bitmap(Width, Height);

        Graphics := Graphics.FromImage(Bitmap);                    // Create a drawing surface for the bitmap
        Graphics.PageUnit := GraphicsUnit.Pixel;                   // We will specify the drawing objects in pixels
        Brush := Brush.SolidBrush(Color.FromArgb(Red, Green, Blue)); // Define a brush with the specified color and
        Graphics.FillRectangle(Brush, 1, 1, Width - 2, Height - 2);        //   fill most of the bitmap with the color
        Pen := Pen.Pen(Color.FromArgb(0, 0, 0), 1);                   // Define a black pen and
        Graphics.DrawRectangle(Pen, 0, 0, Width - 1, Height - 1);          //   draw an outline of the colored portion of the bitmap

        Rec.Color.CreateOutStream(OutStr);
        Bitmap.Save(OutStr, ImageFormat.Bmp);
    end;
}

