table 37002878 "Data Sheet Header"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001161, Columbus IT, Jack Reynolds, 24 MAY 13
    //   Change PrintDataSheet to allow request page
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Data Sheet Header';
    DataCaptionFields = "Location Code", Description;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(3; "Source ID"; Integer)
        {
            Caption = 'Source ID';
            Editable = false;
        }
        field(4; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(5; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
        }
        field(6; "Create Date"; Date)
        {
            Caption = 'Create Date';
            Editable = false;
        }
        field(7; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(9; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Pending,In Progress,Complete';
            OptionMembers = Pending,"In Progress",Complete;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = ',Q/C,Shipping,Receiving,Production,Log';
            OptionMembers = ,"Q/C",Shipping,Receiving,Production,Log;
        }
        field(11; "Reference Type"; Option)
        {
            Caption = 'Reference Type';
            Editable = false;
            OptionCaption = ' ,Customer,Vendor';
            OptionMembers = " ",Customer,Vendor;
        }
        field(12; "Reference ID"; Code[20])
        {
            Caption = 'Reference ID';
            Editable = false;
            TableRelation = IF ("Reference Type" = CONST(Customer)) Customer
            ELSE
            IF ("Reference Type" = CONST(Vendor)) Vendor;
        }
        field(13; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Editable = false;
        }
        field(14; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(15; "Document Type"; Integer)
        {
            Caption = 'Document Type';
        }
        field(21; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(22; "Start Time"; Time)
        {
            Caption = 'Start Time';
        }
        field(23; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(24; "End Time"; Time)
        {
            Caption = 'End Time';
        }
        field(25; "Start DateTime"; DateTime)
        {
            Caption = 'Start DateTime';

            trigger OnValidate()
            begin
                GetLocation;
                TimeZoneMgmt.UTC2DateAndTime("Start DateTime", Location."Time Zone", "Start Date", "Start Time");
            end;
        }
        field(26; "End DateTime"; DateTime)
        {
            Caption = 'End DateTime';

            trigger OnValidate()
            begin
                GetLocation;
                TimeZoneMgmt.UTC2DateAndTime("End DateTime", Location."Time Zone", "End Date", "End Time");
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Location Code", "Source ID", "Source Subtype", "Source No.")
        {
        }
        key(Key3; "Document Type", "Document No.")
        {
        }
        key(Key4; "Location Code", Status)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DataSheetLine: Record "Data Sheet Line";
    begin
        case Status of
            Status::"In Progress":
                begin
                    DataSheetLine.SetRange("Data Sheet No.", "No.");
                    DataSheetLine.SetFilter(Result, '<>%1', '');
                    if not DataSheetLine.IsEmpty then
                        Error(Text013);
                end;
            Status::Complete:
                Error(Text013);
        end;

        DataSheetLine.Reset;
        DataSheetLine.SetRange("Data Sheet No.", "No.");
        DataSheetLine.DeleteAll(true);
        DeleteLinks;
    end;

    trigger OnInsert()
    begin
        GetNumber;
        SetDescription;
    end;

    var
        DataCollectionSetup: Record "Data Collection Setup";
        Location: Record Location;
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        Text001: Label 'Sales Shipment %1';
        Text002: Label 'Return Shipment %1';
        Text003: Label 'Transfer Shipment %1';
        Text004: Label 'Purchase Receipt %1';
        Text005: Label 'Return Receipt %1';
        Text006: Label 'Transfer Receipt %1';
        Text007: Label 'Production Order %1';
        Text008: Label 'Sales %1 %2';
        Text009: Label 'Purchase %1 %2';
        Text010: Label 'Sales Shipment %1';
        Text011: Label 'Transfer Order %1';
        Text012: Label 'Log Group %1';
        Text013: Label 'Results have been recorded for data sheet.';
        TimeZoneMgmt: Codeunit "Time Zone Management";

    procedure GetNumber()
    begin
        if "No." = '' then begin
            DataCollectionSetup.Get;
            "No. Series" := DataCollectionSetup."Data Sheet Nos.";
            "Create Date" := Today;
            "No." := NoSeriesMgmt.GetNextNo("No. Series", "Create Date", true);
        end;
    end;

    procedure GetLocation()
    begin
        if "Location Code" <> Location.Code then
            if "Location Code" = '' then
                Clear(Location)
            else
                Location.Get("Location Code");
    end;

    procedure SetDescription()
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
    begin
        case "Document Type" of
            0:
                case "Source ID" of
                    0:
                        Description := StrSubstNo(Text012, "Source No.");
                    DATABASE::"Sales Header":
                        begin
                            SalesHeader."Document Type" := "Source Subtype";
                            Description := StrSubstNo(Text008, SalesHeader."Document Type", "Source No.");
                        end;
                    DATABASE::"Purchase Header":
                        begin
                            PurchHeader."Document Type" := "Source Subtype";
                            Description := StrSubstNo(Text009, PurchHeader."Document Type", "Source No.");
                        end;
                    DATABASE::"Transfer Header":
                        Description := StrSubstNo(Text011, "Source No.");
                    DATABASE::"Production Order":
                        Description := StrSubstNo(Text007, "Source No.");
                end;
            DATABASE::"Sales Shipment Header":
                Description := StrSubstNo(Text001, "Document No.");
            DATABASE::"Return Shipment Header":
                Description := StrSubstNo(Text002, "Document No.");
            DATABASE::"Transfer Shipment Header":
                Description := StrSubstNo(Text003, "Document No.");
            DATABASE::"Purch. Rcpt. Header":
                Description := StrSubstNo(Text004, "Document No.");
            DATABASE::"Return Receipt Header":
                Description := StrSubstNo(Text005, "Document No.");
            DATABASE::"Transfer Receipt Header":
                Description := StrSubstNo(Text006, "Document No.");
            DATABASE::"Production Order":
                Description := StrSubstNo(Text007, "Document No.");
        end;
    end;

    procedure SetDateTime(Date: Date; Time: Time): DateTime
    begin
        GetLocation;
        exit(TimeZoneMgmt.CreateUTC(Date, Time, Location."Time Zone"));
    end;

    procedure PrintDataSheet()
    var
        DataSheetHeader: Record "Data Sheet Header";
        CompletedDataSheet: Report "Completed Data Sheet";
    begin
        if Status = Status::Complete then begin
            DataSheetHeader.SetRange("No.", "No.");
            CompletedDataSheet.SetTableView(DataSheetHeader);
            //CompletedDataSheet.USEREQUESTPAGE(FALSE); // P8001161
            CompletedDataSheet.Run;
        end;
    end;
}

