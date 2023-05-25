table 37002712 "Ship/Prod. Container Label"
{
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Source table for the Picking Container label
    // 
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW18.00.02
    // P8004230, Columbus IT, Jack Reynolds, 02 OCT 15
    //   Label printing through BIS
    // 
    // PRW18.00.03
    // P8006373, To-Increase, Jack Reynolds, 21 JAN 16
    //   Cleanup for BIS label printing
    // 
    // PRW19.00.01
    // P8007508, To-Increase, Jack Reynolds, 01 SEP 16
    //   Primary key on printer table changed to integer
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    // 
    // PRW111.00.03
    // P80078206, To-increase, Gangabhushan, 04 JUL 19
    //   CS00069940 - Case Lableing needs GS1 (UCC128) barcodes
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Ship/Prod. Container Label';
    ReplicateData = false;

    fields
    {
        field(1; "No. Of Copies"; Integer)
        {
            Caption = 'No. Of Copies';
        }
        field(5; "Printer Name"; Text[100])
        {
            Caption = 'Printer Name';
        }
        field(101; "Container ID"; Code[20])
        {
            Caption = 'Container ID';

            trigger OnValidate()
            var
                SalesHeader: Record "Sales Header";
                PurchaseHeader: Record "Purchase Header";
                TransferHeader: Record "Transfer Header";
                ProductionOrder: Record "Production Order";
            begin
                // P8004230
                Container.Get("Container ID");

                "Container License Plate" := Container."License Plate";
                SSCC := Container.SSCC; // P80055555
                "Source Type" := Container."Document Type";
                "Source Subtype" := Container."Document Subtype";
                "Source No." := Container."Document No.";
                case "Source Type" of
                    DATABASE::"Sales Line":
                        begin
                            SalesHeader.Get("Source Subtype", "Source No.");
                            "Destination Type" := "Destination Type"::Customer;
                            "Destination No." := SalesHeader."Sell-to Customer No.";
                            "Destination Name" := SalesHeader."Sell-to Customer Name";
                        end;
                    DATABASE::"Purchase Line":
                        begin
                            PurchaseHeader.Get(Container."Document Subtype", Container."Document No.");
                            "Destination Type" := "Destination Type"::Vendor;
                            "Destination No." := PurchaseHeader."Buy-from Vendor No.";
                            "Destination Name" := PurchaseHeader."Buy-from Vendor Name";
                        end;
                    DATABASE::"Transfer Line":
                        begin
                            TransferHeader.Get(Container."Document No.");
                            "Destination Type" := "Destination Type"::Location;
                            "Destination No." := TransferHeader."Transfer-to Code";
                            "Destination Name" := TransferHeader."Transfer-to Name";
                        end;
                    // P80056709
                    DATABASE::"Prod. Order Component":
                        begin
                            ProductionOrder.Get(ProductionOrder.Status::Released, Container."Document No.");
                            "Prod. Order Description" := ProductionOrder.Description;
                            "Prod. Order Source Type" := ProductionOrder."Source Type";
                            "Prod. Order Source No." := ProductionOrder."Source No.";
                            "Prod. Order Starting Date" := ProductionOrder."Starting Date";
                            "Prod. Order Due Date" := ProductionOrder."Due Date";
                            "Prod. Order Line No." := Container."Document Line No.";
                        end;
                // P80056709
                end;

                // P8005555
                UCCBarcode.Validate("Container ID", "Container ID");
                UCCBarcode.CreateUCC('');
                UCC128 := UCCBarcode."UCC Code";
                "UCC128 (Human Readable)" := UCCBarcode."UCC Code (Human Readable)";
                // P8005555
            end;
        }
        field(102; "Container License Plate"; Code[50])
        {
            Caption = 'Container License Plate';
        }
        field(103; "Source Type"; Integer)
        {
            Caption = 'Source Type';
        }
        field(104; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            OptionCaption = '0,1,2,3,4,5,6,7,8,9';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9";
        }
        field(105; "Source No."; Code[20])
        {
            Caption = 'Source No.';
        }
        field(106; "Source Description"; Text[100])
        {
            Caption = 'Source Description';
        }
        field(107; "Destination Type"; Option)
        {
            Caption = 'Destination Type';
            OptionCaption = 'Customer,Vendor,Location';
            OptionMembers = Customer,Vendor,Location;
        }
        field(108; "Destination No."; Code[20])
        {
            Caption = 'Destination No.';
        }
        field(109; "Destination Name"; Text[100])
        {
            Caption = 'Destination Name';
        }
        field(112; SSCC; Code[18])
        {
            Caption = 'SSCC';
        }
        field(201; "Prod. Order Description"; Text[100])
        {
            Caption = 'Prod. Order Description';
        }
        field(202; "Prod. Order Source Type"; Option)
        {
            Caption = 'Prod. Order Source Type';
            OptionCaption = 'Item,Family,Sales Header';
            OptionMembers = Item,Family,"Sales Header";
        }
        field(203; "Prod. Order Source No."; Code[20])
        {
            Caption = 'Prod. Order Source No.';
        }
        field(204; "Prod. Order Starting Date"; Date)
        {
            Caption = 'Prod. Order Starting Date';
        }
        field(205; "Prod. Order Due Date"; Date)
        {
            Caption = 'Prod. Order Due Date';
        }
        field(220; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
        }
        field(600; UCC128; Code[250])
        {
            Caption = 'UCC128';
        }
        field(601; "UCC128 (Human Readable)"; Code[250])
        {
            Caption = 'UCC128 (Human Readable)';
        }
        field(99999; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Container: Record "Container Header";
        UCCBarcode: Record "UCC Barcode Data";
}

