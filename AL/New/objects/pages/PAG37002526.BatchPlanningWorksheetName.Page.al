page 37002526 "Batch Planning Worksheet Name"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Card page used to maintain the Batch Planning Worksheet Names
    // 
    // PRW110.0
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes

    Caption = 'Batch Planning Worksheet Name';
    PageType = Card;
    SourceTable = "Batch Planning Worksheet Name";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control37002016)
                {
                    ShowCaption = false;
                    field(Name; Name)
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Days View"; "Days View")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Create Multi-line Orders"; "Create Multi-line Orders")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    grid(Parameter)
                    {
                        group(ParameterLabel)
                        {
                            Caption = ' ';
                            field(Parameter1Label; Parameter1)
                            {
                                ApplicationArea = FOODBasic;
                                ShowCaption = false;
                            }
                            field(Parameter2Label; Parameter2)
                            {
                                ApplicationArea = FOODBasic;
                                ShowCaption = false;
                            }
                            field(Parameter3Label; Parameter3)
                            {
                                ApplicationArea = FOODBasic;
                                ShowCaption = false;

                            }
                            field(BatchHighlightLabel; BatchHighlight)
                            {
                                ApplicationArea = FOODBasic;
                                ShowCaption = false;
                            }
                            field(PackageHighlightLabel; PackageHighlight)
                            {
                                ApplicationArea = FOODBasic;
                                ShowCaption = false;
                            }
                        }
                        group(ParameterType)
                        {
                            Caption = 'Type';
                            field(Parameter1Type; "Parameter 1 Type")
                            {
                                ApplicationArea = FOODBasic;
                                ShowCaption = false;

                                trigger OnValidate()
                                begin
                                    SetEditable;
                                    ClearAttributeName("Parameter 1 Field", 1);
                                end;
                            }
                            field(Parameter2Type; "Parameter 2 Type")
                            {
                                ApplicationArea = FOODBasic;
                                ShowCaption = false;

                                trigger OnValidate()
                                begin
                                    SetEditable;
                                    ClearAttributeName("Parameter 2 Field", 2);
                                end;
                            }
                            field(Parameter3Type; "Parameter 3 Type")
                            {
                                ApplicationArea = FOODBasic;
                                ShowCaption = false;

                                trigger OnValidate()
                                begin
                                    SetEditable;
                                    ClearAttributeName("Parameter 3 Field", 3);
                                end;
                            }
                        }
                        group(ParameterField)
                        {
                            Caption = 'Field';
                            field(Parameter1Field; "Parameter 1 Field")
                            {
                                ApplicationArea = FOODBasic;
                                Editable = Field1Editable;
                                ShowCaption = false;

                                trigger OnValidate()
                                begin
                                    SetEditable;
                                    ClearAttributeName("Parameter 1 Field", 1);
                                end;
                            }
                            field(Parameter2Field; "Parameter 2 Field")
                            {
                                ApplicationArea = FOODBasic;
                                Editable = Field2Editable;
                                ShowCaption = false;

                                trigger OnValidate()
                                begin
                                    SetEditable;
                                    ClearAttributeName("Parameter 2 Field", 2);
                                end;
                            }
                            field(Parameter3Field; "Parameter 3 Field")
                            {
                                ApplicationArea = FOODBasic;
                                Editable = Field3Editable;
                                ShowCaption = false;

                                trigger OnValidate()
                                begin
                                    SetEditable;
                                    ClearAttributeName("Parameter 3 Field", 3);
                                end;
                            }
                            field(BatchHighlightField; "Batch Highlight Field")
                            {
                                ApplicationArea = FOODBasic;
                                ShowCaption = false;

                                trigger OnValidate()
                                begin
                                    SetEditable;
                                    ClearAttributeName("Batch Highlight Field", 4);
                                end;
                            }
                            field(PackageHighlightField; "Package Highlight Field")
                            {
                                ApplicationArea = FOODBasic;
                                ShowCaption = false;

                                trigger OnValidate()
                                begin
                                    SetEditable;
                                    ClearAttributeName("Package Highlight Field", 5);
                                end;
                            }
                        }
                        group(ParameterAttribute)
                        {
                            Caption = 'Attribute';
                            field(Parameter1Attribute; AttributeName[1])
                            {
                                ApplicationArea = FOODBasic;
                                Editable = Attr1Editable;
                                ShowCaption = false;

                                trigger OnLookup(var Text: Text): Boolean
                                begin
                                    exit(LookupAttributeName(Text));
                                end;

                                trigger OnValidate()
                                begin
                                    "Parameter 1 Attribute" := GetAttributeID(AttributeName[1]);
                                end;
                            }
                            field(Parameter2Attribute; AttributeName[2])
                            {
                                ApplicationArea = FOODBasic;
                                Editable = Attr2Editable;
                                ShowCaption = false;

                                trigger OnLookup(var Text: Text): Boolean
                                begin
                                    exit(LookupAttributeName(Text));
                                end;

                                trigger OnValidate()
                                begin
                                    "Parameter 2 Attribute" := GetAttributeID(AttributeName[2]);
                                end;
                            }
                            field(Parameter3Attribute; AttributeName[3])
                            {
                                ApplicationArea = FOODBasic;
                                Editable = Attr3Editable;
                                ShowCaption = false;

                                trigger OnLookup(var Text: Text): Boolean
                                begin
                                    exit(LookupAttributeName(Text));
                                end;

                                trigger OnValidate()
                                begin
                                    "Parameter 3 Attribute" := GetAttributeID(AttributeName[3]);
                                end;
                            }
                            field(BatchHighlightAttribut; AttributeName[4])
                            {
                                ApplicationArea = FOODBasic;
                                Editable = AttrBatchEditable;
                                ShowCaption = false;

                                trigger OnLookup(var Text: Text): Boolean
                                begin
                                    exit(LookupAttributeName(Text));
                                end;

                                trigger OnValidate()
                                begin
                                    "Batch Highlight Attribute" := GetAttributeID(AttributeName[4]);
                                end;
                            }
                            field(PackageHighlightAAttribute; AttributeName[5])
                            {
                                ApplicationArea = FOODBasic;
                                Editable = AttrPackageEditable;
                                ShowCaption = false;

                                trigger OnLookup(var Text: Text): Boolean
                                begin
                                    exit(LookupAttributeName(Text));
                                end;

                                trigger OnValidate()
                                begin
                                    "Package Highlight Attribute" := GetAttributeID(AttributeName[5]);
                                end;
                            }
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002018; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002017; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEditable;
        SetAttributes; // P8007750
    end;

    trigger OnOpenPage()
    begin
        SetEditable;
    end;

    var
        [InDataSet]
        Field1Editable: Boolean;
        [InDataSet]
        Attr1Editable: Boolean;
        [InDataSet]
        Field2Editable: Boolean;
        [InDataSet]
        Attr2Editable: Boolean;
        [InDataSet]
        Field3Editable: Boolean;
        [InDataSet]
        Attr3Editable: Boolean;
        [InDataSet]
        AttrBatchEditable: Boolean;
        [InDataSet]
        AttrPackageEditable: Boolean;
        AttributeName: array[5] of Text[250];
        Parameter1: Label 'Parameter 1';
        Parameter2: Label 'Parameter 2';
        Parameter3: Label 'Parameter 3';
        BatchHighlight: Label 'Batch Highlight';
        PackageHighlight: Label 'Package Highlight';

    local procedure SetEditable()
    begin
        Field1Editable := "Parameter 1 Type" <> 0;
        Attr1Editable := "Parameter 1 Field" = "Parameter 1 Field"::Attribute;
        Field2Editable := "Parameter 2 Type" <> 0;
        Attr2Editable := "Parameter 2 Field" = "Parameter 2 Field"::Attribute;
        Field3Editable := "Parameter 3 Type" <> 0;
        Attr3Editable := "Parameter 3 Field" = "Parameter 3 Field"::Attribute;
        AttrBatchEditable := "Batch Highlight Field" = "Batch Highlight Field"::Attribute;
        AttrPackageEditable := "Package Highlight Field" = "Package Highlight Field"::Attribute;
    end;

    local procedure SetAttributes()
    var
        ItemAttribute: Record "Item Attribute";
    begin
        // P8007750
        if "Parameter 1 Attribute" <> 0 then
            if ItemAttribute.Get("Parameter 1 Attribute") then
                AttributeName[1] := ItemAttribute.Name;
        if "Parameter 2 Attribute" <> 0 then
            if ItemAttribute.Get("Parameter 2 Attribute") then
                AttributeName[2] := ItemAttribute.Name;
        if "Parameter 3 Attribute" <> 0 then
            if ItemAttribute.Get("Parameter 3 Attribute") then
                AttributeName[3] := ItemAttribute.Name;
        if "Batch Highlight Attribute" <> 0 then
            if ItemAttribute.Get("Batch Highlight Attribute") then
                AttributeName[4] := ItemAttribute.Name;
        if "Package Highlight Attribute" <> 0 then
            if ItemAttribute.Get("Package Highlight Attribute") then
                AttributeName[5] := ItemAttribute.Name;
    end;

    local procedure GetAttributeID(var Name: Text[250]): Integer
    var
        ItemAttribute: Record "Item Attribute";
    begin
        // P8007750
        if Name = '' then
            exit(0);

        ItemAttribute.SetFilter(Name, '@' + Name);
        if ItemAttribute.FindFirst then begin
            Name := ItemAttribute.Name;
            exit(ItemAttribute.ID);
        end else begin
            ItemAttribute.SetFilter(Name, '@' + Name + '*');
            ItemAttribute.FindFirst;
            Name := ItemAttribute.Name;
            exit(ItemAttribute.ID);
        end;
    end;

    local procedure LookupAttributeName(var Name: Text[250]): Boolean
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributes: Page "Item Attributes";
    begin
        ItemAttribute.SetFilter(Name, '@' + Name + '*', Name);
        if ItemAttribute.FindFirst then;
        ItemAttribute.SetRange(Name);
        ItemAttributes.SetTableView(ItemAttribute);
        ItemAttributes.SetRecord(ItemAttribute);
        ItemAttributes.LookupMode := true;
        if ItemAttributes.RunModal = ACTION::LookupOK then begin
            ItemAttributes.GetRecord(ItemAttribute);
            Name := ItemAttribute.Name;
            exit(true);
        end;
    end;

    local procedure ClearAttributeName(FieldType: Option; Index: Integer)
    begin
        // P8007750
        if FieldType <> "Parameter 1 Field"::Attribute then
            AttributeName[Index] := '';
        ;
    end;
}
