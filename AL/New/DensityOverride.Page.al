page 37002479 "Density Override"
{
    // PR1.00.02
    //   Rearrange buttons
    // 
    // PR1.20.01
    //   Adjust alignment of controls
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed from Form
    // 
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Density Override';
    PageType = Card;

    layout
    {
        area(content)
        {
            field("BOMVars.Hold"; BOMVars.Hold)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Hold Constant';
                ValuesAllowed = Weight, Volume, Density;

                trigger OnValidate()
                begin
                    SetHold;
                end;
            }
            group(Weight)
            {
                Caption = 'Weight';
                field(TotalWeight; BOMVars."Output Weight")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Batch Size';
                    Editable = WeightEditable;

                    trigger OnValidate()
                    begin
                        BOMVars.Validate("Output Weight");
                    end;
                }
                field(WeightGL; BOMVars."Weight Yield")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Yield %';
                    Editable = WeightEditable;

                    trigger OnValidate()
                    begin
                        BOMVars.Validate("Weight Yield");
                    end;
                }
                field("BOMVars.""Weight Text"""; BOMVars."Weight Text")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Units';
                    Enabled = false;
                }
            }
            group(Volume)
            {
                Caption = 'Volume';
                field(TotalVolume; BOMVars."Output Volume")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Batch Size';
                    Editable = VolumeEditable;

                    trigger OnValidate()
                    begin
                        BOMVars.Validate("Output Volume");
                    end;
                }
                field(VolumeGL; BOMVars."Volume Yield")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Yield %';
                    Editable = VolumeEditable;

                    trigger OnValidate()
                    begin
                        BOMVars.Validate("Volume Yield");
                    end;
                }
                field("BOMVars.""Volume Text"""; BOMVars."Volume Text")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Units';
                    Enabled = false;
                }
            }
            group(Control37002001)
            {
                Caption = 'Density';
                field(Density; BOMVars.Density)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Density';
                    Editable = DensityEditable;

                    trigger OnValidate()
                    begin
                        BOMVars.Validate(Density);
                    end;
                }
                field("BOMVars.""Density Text"""; BOMVars."Density Text")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Units';
                    Enabled = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        DensityEditable := true;
        VolumeEditable := true;
        WeightEditable := true;
    end;

    trigger OnOpenPage()
    begin
        SetHold;
    end;

    var
        BOMVars: Record "BOM Variables";
        BatchSize: array[2] of Decimal;
        [InDataSet]
        WeightEditable: Boolean;
        [InDataSet]
        VolumeEditable: Boolean;
        [InDataSet]
        DensityEditable: Boolean;

    procedure SetVariables(rec: Record "BOM Variables")
    begin
        BOMVars := rec;
        BOMVars."Output Weight (Before Yield)" := BOMVars."Output Weight" / (BOMVars."Weight Yield" / 100);
        BOMVars."Output Volume (Before Yield)" := BOMVars."Output Volume" / (BOMVars."Volume Yield" / 100);
    end;

    procedure ReturnVariables(var rec: Record "BOM Variables")
    begin
        rec."Weight Yield" := BOMVars."Weight Yield";
        rec."Volume Yield" := BOMVars."Volume Yield";
    end;

    procedure SetHold()
    begin
        WeightEditable := BOMVars.Hold <> BOMVars.Hold::Weight;
        VolumeEditable := BOMVars.Hold <> BOMVars.Hold::Volume;
        DensityEditable := BOMVars.Hold <> BOMVars.Hold::Density;
        CurrPage.Update;
    end;
}

