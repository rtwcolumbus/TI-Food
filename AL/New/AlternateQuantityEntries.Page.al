page 37002081 "Alternate Quantity Entries"
{
    // PR3.10
    //   Create form for posted alternate quantities
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    //
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory documents

    Caption = 'Alternate Quantity Entries';
    DataCaptionExpression = GetCaption;
    Editable = false;
    PageType = List;
    SourceTable = "Alternate Quantity Entry";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Line No."; SeqNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Line No.';
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Invoiced Qty. (Base)"; "Invoiced Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Invoiced Qty. (Alt.)"; "Invoiced Qty. (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        AltQtyEntry.SetRange("Table No.", "Table No.");
        AltQtyEntry.SetRange("Document No.", "Document No.");
        AltQtyEntry.SetRange("Source Line No.", "Source Line No.");
        AltQtyEntry.SetFilter("Line No.", '<%1', "Line No.");
        SeqNo := AltQtyEntry.Count + 1;
    end;

    var
        SeqNo: Integer;
        AltQtyEntry: Record "Alternate Quantity Entry";
        Text001: Label 'Sales Shipment %1';
        Text002: Label 'Sales Invoice %1';
        Text003: Label 'Sales Credit Memo %1';
        Text004: Label 'Sales Return Receipt %1';
        Text005: Label 'Purchase Receipt %1';
        Text006: Label 'Purchase Invoice %1';
        Text007: Label 'Purchase Credit Memo %1';
        Text008: Label 'Purchase Return Shipment %1';
        Text009: Label 'Inventory Receipt %1';
        Text010: Label 'Inventory Shipment %1';


    local procedure GetCaption(): Text[250]
    var
        ObjectInfo: Record "Object Translation";
        TableNo: Integer;
        TableName: Text[250];
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        if (GetFilter("Table No.") = '') then
            exit;
        TableNo := GetRangeMin("Table No.");
        if TableNo = DATABASE::"Item Ledger Entry" then begin
            TableName := ObjectInfo.TranslateObject(ObjectInfo."Object Type"::Table, TableNo);
            if (GetFilter("Source Line No.") = '') then
                exit(TableName);
            TableName := StrSubstNo('%1 %2', TableName, GetRangeMin("Source Line No."));
            if (GetFilter("Lot No.") = '') then
                exit(TableName);
            exit(StrSubstNo('%1 - %2 %3', TableName, FieldCaption("Lot No."), GetRangeMin("Lot No.")));
        end;
        if (GetFilter("Document No.") = '') then
            exit(ObjectInfo.TranslateObject(ObjectInfo."Object Type"::Table, TableNo));
        case TableNo of
            DATABASE::"Sales Shipment Line":
                exit(StrSubstNo(Text001, GetRangeMin("Document No.")));
            DATABASE::"Sales Invoice Line":
                exit(StrSubstNo(Text002, GetRangeMin("Document No.")));
            DATABASE::"Sales Cr.Memo Line":
                exit(StrSubstNo(Text003, GetRangeMin("Document No.")));
            DATABASE::"Return Receipt Line":
                exit(StrSubstNo(Text004, GetRangeMin("Document No.")));
            DATABASE::"Purch. Rcpt. Line":
                exit(StrSubstNo(Text005, GetRangeMin("Document No.")));
            DATABASE::"Purch. Inv. Line":
                exit(StrSubstNo(Text006, GetRangeMin("Document No.")));
            DATABASE::"Purch. Cr. Memo Line":
                exit(StrSubstNo(Text007, GetRangeMin("Document No.")));
            DATABASE::"Return Shipment Line":
                exit(StrSubstNo(Text008, GetRangeMin("Document No.")));
            // P800127049
            Database::"Invt. Receipt Line":
                exit(StrSubstNo(Text009, GetRangeMin("Document No.")));
            Database::"Invt. Shipment Line":
                exit(StrSubstNo(Text010, GetRangeMin("Document No.")));
        // P800127049
        end;
    end;
}

