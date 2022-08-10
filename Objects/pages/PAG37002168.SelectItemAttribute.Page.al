page 37002168 "Select Item Attribute"
{
    // PRW110.0
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes

    Caption = 'Select Item Attribute';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Item Attribute Value";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Select; Select)
                {
                    ApplicationArea = FOODBasic;
                    ShowCaption = false;

                    trigger OnValidate()
                    begin
                        Mark(not Mark); // P8007750
                    end;
                }
                field(Value; Value)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Select All")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Select All';
                Image = SelectEntries;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ItemAttributeValue: Record "Item Attribute Value";
                begin
                    ItemAttributeValue := Rec;
                    if FindFirst then
                        repeat
                            Mark(true); // P8007750
                        until Next = 0;
                    Rec := ItemAttributeValue;
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Select := Mark; // P8007750
    end;

    var
        [InDataSet]
        Select: Boolean;

    procedure SetAttribute(AttrID: Integer; var MarkedAttribute: Record "Item Attribute Value")
    begin
        MarkedAttribute.SetRange("Attribute ID", AttrID); // P8007750
        MarkedAttribute.MarkedOnly(false);
        if MarkedAttribute.FindSet then
            repeat
                Rec := MarkedAttribute;
                Insert;
                Mark(MarkedAttribute.Mark); // P8007750
            until MarkedAttribute.Next = 0;
        FindFirst;
    end;

    procedure MarkSelectedAttributes(var ItemAttributeValue: Record "Item Attribute Value")
    begin
        if FindSet then
            repeat
                ItemAttributeValue := Rec;
                ItemAttributeValue.Mark(Mark); // P8007750
            until Next = 0;
    end;
}

