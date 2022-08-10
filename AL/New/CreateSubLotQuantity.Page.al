page 37002736 "Create Sub-Lot Quantity"
{
    // PRW118.1
    // P800129613, To Increase, Jack Reynolds, 20 SEP 21
    //   Creatre Sub-Lot Wizard

    Caption = 'Create Sub-Lot Quantity';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Sub-Lot Buffer";
    SourceTableTemporary = true;
    SourceTableView = sorting("Bin Code", "Container License Plate", "Unit of Measure Code");
    
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(BinCode;Rec."Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = BinCodeVisible;
                }
                field(ContainerLicesnsePlate;Rec."Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = ContainerVisible;
                }
                field(UOMCode;Rec."Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity;Rec.Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field(QuantityAlt;Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = AltQtyVisible;
                }
                field(ReclassQuantity;Rec."Quantity to Reclass")
                {
                    ApplicationArea = FOODBasic;
                }
                field(ReclassQuantityAlt;Rec."Quantity to Reclass (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = AltQtyVisible;
                }
            }
        }
    }
    
    actions
    {
        area(Processing)
        {
            action(ReclassEntireQuantity)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reclass Entire Quantity';

                trigger OnAction()
                var
                    Selected: Record "Sub-Lot Buffer";
                begin 
                    Selected.Copy(Rec,true);
                    CurrPage.SetSelectionFilter(Selected);
                    if Selected.FindSet(true) then
                        repeat
                            Selected.Validate("Quantity to Reclass", Selected.Quantity);
                            Selected.Modify();
                        until Selected.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        BinCodeVisible, ContainerVisible, AltQtyVisible: Boolean;

    procedure SetSource(SubLot: Record "Sub-Lot Buffer"; var ReclassQuantity: Record "Sub-Lot Buffer" temporary)
    begin
        BinCodeVisible := SubLot.BinMandatory and (SubLot."Bin Code" = '');
        ContainerVisible := SubLot.ContainersEnabled and (SubLot.ContainerID = '');
        AltQtyVisible := SubLot.CatchAlternateQuantity;

        Rec.Copy(ReclassQuantity, true);
    end;

    procedure GetSource(var ReclassQuantity: Record "Sub-Lot Buffer" temporary)
    begin
        ReclassQuantity.Copy(Rec, true);
        Rec.Reset();
        if Rec.FindFirst() then;
    end;
}