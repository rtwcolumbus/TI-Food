page 37002738 "Create Sub-Lot Labels"
{
    // PRW118.1
    // P800129613, To Increase, Jack Reynolds, 20 SEP 21
    //   Creatre Sub-Lot Wizard
    
    Caption = 'Create Sub-Lot Labels';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Sub-Lot Buffer";
    SourceTableTemporary = true;
    SourceTableView = sorting("Bin Code", "Container License Plate", "Unit of Measure Code")
                      where("Quantity to Reclass" = filter(>0), "Label Code" = filter(<>''));

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(BinCode; Rec."Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = BinCodeVisible;
                }
                field(ContainerLicesnsePlate; Rec."Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = ContainerVisible;
                }
                field(UOMCode; Rec."Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(ReclassQuantity; Rec."Quantity to Reclass")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(LabelCode; Rec."Label Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(NoOfLabels; Rec."No. of Labels")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    var
        BinCodeVisible, ContainerVisible : Boolean;

    procedure SetSource(SubLot: Record "Sub-Lot Buffer"; var ReclassQuantity: Record "Sub-Lot Buffer" temporary)
    begin
        BinCodeVisible := SubLot.BinMandatory and (SubLot."Bin Code" = '');
        ContainerVisible := SubLot.ContainersEnabled and (SubLot.ContainerID = '');

        Rec.Copy(ReclassQuantity, true);
    end;

    procedure GetSource(var ReclassQuantity: Record "Sub-Lot Buffer" temporary)
    begin
        ReclassQuantity.Copy(Rec, true);
        Rec.Reset();
        if Rec.FindFirst() then;
    end;
}