table 37002760 "Whse. Staged Pick Header"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks
    // 
    // PR5.00
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Order Picking Options
    // 
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Whse. Staged Pick Header';
    DataCaptionFields = "No.";
    LookupPageID = "Whse. Staged Pick List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
                WhseSetup.Get;
                if "No." <> xRec."No." then begin
                    NoSeriesMgt.TestManual(WhseSetup."Whse. Staged Pick Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            var
                WhseStagedPickLine: Record "Whse. Staged Pick Line";
            begin
                if not WmsManagement.LocationIsAllowed("Location Code") then
                    Error(Text003, FieldCaption("Location Code"), "Location Code");

                CheckPickRequired("Location Code");
                if "Location Code" <> xRec."Location Code" then begin
                    "Zone Code" := '';
                    "Bin Code" := '';
                    WhseStagedPickLine.SetRange("No.", "No.");
                    if WhseStagedPickLine.Find('-') then
                        Error(
                          Text001,
                          FieldCaption("Location Code"));
                end;
                if UserId <> '' then begin
                    FilterGroup := 2;
                    SetRange("Location Code", "Location Code");
                    FilterGroup := 0;
                end;

                GetLocation("Location Code");
                if (Location."Staging Bin Code" <> '') then
                    Validate("Bin Code", Location."Staging Bin Code");
            end;
        }
        field(3; "Assigned User ID"; Code[50])
        {
            Caption = 'Assigned User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Warehouse Employee" WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            begin
                if "Assigned User ID" <> '' then begin
                    "Assignment Date" := Today;
                    "Assignment Time" := Time;
                end else begin
                    "Assignment Date" := 0D;
                    "Assignment Time" := 0T;
                end;
            end;
        }
        field(4; "Assignment Date"; Date)
        {
            Caption = 'Assignment Date';
            Editable = false;
        }
        field(5; "Assignment Time"; Time)
        {
            Caption = 'Assignment Time';
            Editable = false;
        }
        field(6; "Sorting Method"; Option)
        {
            Caption = 'Sorting Method';
            OptionCaption = ' ,Item,,Due Date';
            OptionMembers = " ",Item,,"Due Date";

            trigger OnValidate()
            begin
                if "Sorting Method" <> xRec."Sorting Method" then
                    SortWhseDoc;
            end;
        }
        field(7; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(11; Comment; Boolean)
        {
            CalcFormula = Exist("Warehouse Comment Line" WHERE("Table Name" = CONST("Staged Pick"),
                                                                Type = CONST(" "),
                                                                "No." = FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = IF ("Zone Code" = FILTER('')) Bin.Code WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            IF ("Zone Code" = FILTER(<> '')) Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                                                               "Zone Code" = FIELD("Zone Code"));

            trigger OnValidate()
            var
                Bin: Record Bin;
            begin
                TestField(Status, Status::Open);
                if "Bin Code" <> '' then begin
                    GetLocation("Location Code");
                    Location.TestField("Bin Mandatory");
                    if "Bin Code" = Location."Adjustment Bin Code" then
                        FieldError(
                          "Bin Code",
                            StrSubstNo(
                              Text005, Location.FieldCaption("Adjustment Bin Code"),
                              Location.TableCaption));
                    Bin.Get("Location Code", "Bin Code");
                    "Zone Code" := Bin."Zone Code";
                end;
            end;
        }
        field(13; "Zone Code"; Code[10])
        {
            Caption = 'Zone Code';
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
                GetLocation("Location Code");
                Location.TestField("Directed Put-away and Pick");
                "Bin Code" := '';
            end;
        }
        field(34; "Staging Status"; Option)
        {
            Caption = 'Document Status';
            Editable = false;
            OptionCaption = ' ,Partially Staged,Completely Staged';
            OptionMembers = " ","Partially Staged","Completely Staged";

            trigger OnValidate()
            var
                WhsePickRqst: Record "Whse. Pick Request";
            begin
                if "Staging Status" <> xRec."Staging Status" then begin
                    WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::FOODStagedPick);
                    WhsePickRqst.SetRange("Document No.", "No.");
                    WhsePickRqst.ModifyAll(
                      "Completely Picked", "Staging Status" = "Staging Status"::"Completely Staged");
                end;
            end;
        }
        field(35; "Order Picking Status"; Option)
        {
            Caption = 'Order Picking Status';
            Editable = false;
            OptionCaption = ' ,Partially Picked,Completely Picked';
            OptionMembers = " ","Partially Picked","Completely Picked";

            trigger OnValidate()
            var
                WhsePickRqst: Record "Whse. Pick Request";
            begin
                if "Staging Status" <> xRec."Staging Status" then begin
                    WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::FOODStagedPick);
                    WhsePickRqst.SetRange("Document No.", "No.");
                    WhsePickRqst.ModifyAll(
                      "Completely Picked", "Staging Status" = "Staging Status"::"Completely Staged");
                end;
            end;
        }
        field(36; "Due Date"; Date)
        {
            Caption = 'Due Date';

            trigger OnValidate()
            begin
                MessageIfStgdPickLinesExist(FieldCaption("Due Date"));
            end;
        }
        field(47; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Released';
            OptionMembers = Open,Released;
        }
        field(48; "Staging Type"; Option)
        {
            Caption = 'Staging Type';
            OptionCaption = 'Shipment,Production';
            OptionMembers = Shipment,Production;

            trigger OnValidate()
            begin
                ErrorIfStgdPickSrcLinesExist(FieldCaption("Staging Type"));

                if ("Staging Type" = "Staging Type"::Production) and
                   ("Order Picking Options" = "Order Picking Options"::"One Pick per Ship-to Address")
                then
                    Validate("Order Picking Options", "Order Picking Options"::" ");
            end;
        }
        field(49; "Stage Exact Qty. Needed"; Boolean)
        {
            Caption = 'Stage Exact Qty. Needed';
        }
        field(50; "Ignore Staging Bin Contents"; Boolean)
        {
            Caption = 'Ignore Staging Bin Contents';
        }
        field(52; "Order Picking Options"; Option)
        {
            Caption = 'Order Picking Options';
            OptionCaption = ' ,One Pick per Order,One Pick per Ship-to Address';
            OptionMembers = " ","One Pick per Order","One Pick per Ship-to Address";

            trigger OnValidate()
            begin
                if ("Order Picking Options" = "Order Picking Options"::"One Pick per Ship-to Address") then
                    TestField("Staging Type", "Staging Type"::Shipment);
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);
        DeleteRelatedLines;
    end;

    trigger OnInsert()
    begin
        WhseSetup.Get;
        if "No." = '' then begin
            WhseSetup.TestField("Whse. Staged Pick Nos.");
            NoSeriesMgt.InitSeries(
              WhseSetup."Whse. Staged Pick Nos.", xRec."No. Series", Today, "No.", "No. Series");
        end;
    end;

    trigger OnModify()
    begin
        UpdateLines;
    end;

    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;

    var
        Location: Record Location;
        WhseSetup: Record "Warehouse Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        WmsManagement: Codeunit "WMS Management";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        HideValidationDialog: Boolean;
        Text000: Label 'You cannot rename a %1.';
        Text001: Label 'You cannot change the %1, because the document has one or more lines.';
        Text002: Label 'You must first set up user %1 as a warehouse employee.';
        Text003: Label 'You are not allowed to use %1 %2.';
        Text005: Label 'must not be the %1 of the %2';
        Text006: Label 'You have changed %1 on the %2, but it has not been changed on the existing %3s.\';
        Text007: Label 'You must update the existing %1s manually.';
        Text008: Label 'You cannot change the %1, because the document has one or more Orders associated with it.';

    local procedure UpdateLines()
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        if ("Zone Code" <> xRec."Zone Code") or
           ("Bin Code" <> xRec."Bin Code")
        then begin
            WhseStagedPickLine.SetRange("No.", "No.");
            if WhseStagedPickLine.Find('-') then
                repeat
                    WhseStagedPickLine."Zone Code" := "Zone Code";
                    WhseStagedPickLine."Bin Code" := "Bin Code";
                    WhseStagedPickLine.Modify;
                until (WhseStagedPickLine.Next = 0);
            WhseStagedPickSourceLine.SetRange("No.", "No.");
            if WhseStagedPickSourceLine.Find('-') then
                repeat
                    WhseStagedPickSourceLine."Zone Code" := "Zone Code";
                    WhseStagedPickSourceLine."Bin Code" := "Bin Code";
                    WhseStagedPickSourceLine.Modify;
                until (WhseStagedPickSourceLine.Next = 0);
            Modify;
            RecalcStageQtys;
        end;
    end;

    procedure RecalcStageQtys()
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
    begin
        WhseStagedPickLine.SetRange("No.", "No.");
        if WhseStagedPickLine.Find('-') then
            repeat
                WhseStagedPickLine.RecalcQtyToStage(0);
                WhseStagedPickLine.Modify;
            until (WhseStagedPickLine.Next = 0);
        Find;
        "Staging Status" := GetStagingStatus(0);
        Modify(true);
    end;

    procedure AssistEdit(OldWhseStagedPickHeader: Record "Whse. Staged Pick Header"): Boolean
    var
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
    begin
        WhseSetup.Get;
        with WhseStagedPickHeader do begin
            WhseStagedPickHeader := Rec;
            WhseSetup.TestField("Whse. Staged Pick Nos.");
            if NoSeriesMgt.SelectSeries(
              WhseSetup."Whse. Staged Pick Nos.", OldWhseStagedPickHeader."No. Series", "No. Series")
            then begin
                NoSeriesMgt.SetSeries("No.");
                Rec := WhseStagedPickHeader;
                exit(true);
            end;
        end;
    end;

    procedure SortWhseDoc()
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        SequenceNo: Integer;
    begin
        with WhseStagedPickLine do begin
            SetRange("No.", Rec."No.");
            case "Sorting Method" of
                "Sorting Method"::Item:
                    SetCurrentKey("No.", "Item No.");
                "Sorting Method"::"Due Date":
                    SetCurrentKey("No.", "Due Date");
            end;

            if Find('-') then begin
                SequenceNo := 10000;
                repeat
                    "Sorting Sequence No." := SequenceNo;
                    Modify;
                    SequenceNo := SequenceNo + 10000;
                until Next = 0;
            end;
        end;
    end;

    procedure GetStagingStatus(LineNoToIgnore: Integer): Integer
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
    begin
        with WhseStagedPickLine do begin
            SetRange("No.", Rec."No.");
            if (LineNoToIgnore <> 0) then
                SetFilter("Line No.", '<>%1', LineNoToIgnore);
            if not Find('-') then
                exit(Status::" ");

            SetRange(Status, Status::"Partially Staged");
            if Find('-') then
                exit(Status::"Partially Staged");

            SetRange(Status, Status::"Completely Staged");
            if not Find('-') then
                exit(Status);

            SetFilter(Status, '<%1', Status::"Completely Staged");
            if Find('-') then
                exit(Status::"Partially Staged");
            exit(Status::"Completely Staged");
        end;
    end;

    procedure GetLineStagingStatus(var WhseStagedPickLine: Record "Whse. Staged Pick Line"): Integer
    var
        WhseStagedPickLine2: Record "Whse. Staged Pick Line";
    begin
        with WhseStagedPickLine2 do
            case WhseStagedPickLine.Status of
                Status::" ":
                    begin
                        SetRange("No.", WhseStagedPickLine."No.");
                        SetFilter("Line No.", '<>%1', WhseStagedPickLine."Line No.");
                        SetFilter(Status, '>%1', Status::" ");
                        if Find('-') then
                            exit(Status::"Partially Staged");
                        exit(Status::" ");
                    end;
                Status::"Partially Staged":
                    exit(Status::"Partially Staged");
                Status::"Completely Staged":
                    begin
                        SetRange("No.", WhseStagedPickLine."No.");
                        SetFilter("Line No.", '<>%1', WhseStagedPickLine."Line No.");
                        SetFilter(Status, '<%1', Status::"Completely Staged");
                        if Find('-') then
                            exit(Status::"Partially Staged");
                        exit(Status::"Completely Staged");
                    end;
            end;
    end;

    procedure GetOrderPickingStatus(LineNoToIgnore: Integer): Integer
    var
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        with WhseStagedPickSourceLine do begin
            SetRange("No.", Rec."No.");
            if (LineNoToIgnore <> 0) then
                SetFilter("Line No.", '<>%1', LineNoToIgnore);
            if not Find('-') then
                exit(Status::" ");

            SetRange(Status, Status::"Partially Picked");
            if Find('-') then
                exit(Status::"Partially Picked");

            SetRange(Status, Status::"Completely Picked");
            if not Find('-') then
                exit(Status);

            SetFilter(Status, '<%1', Status::"Completely Picked");
            if Find('-') then
                exit(Status::"Partially Picked");
            exit(Status::"Completely Picked");
        end;
    end;

    procedure GetLineOrderPickingStatus(var WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line"): Integer
    var
        WhseStagedPickSourceLine2: Record "Whse. Staged Pick Source Line";
    begin
        with WhseStagedPickSourceLine2 do
            case WhseStagedPickSourceLine.Status of
                Status::" ":
                    begin
                        SetRange("No.", WhseStagedPickSourceLine."No.");
                        SetFilter("Line No.", '<>%1', WhseStagedPickSourceLine."Line No.");
                        SetFilter(Status, '>%1', Status::" ");
                        if Find('-') then
                            exit(Status::"Partially Picked");
                        exit(Status::" ");
                    end;
                Status::"Partially Picked":
                    exit(Status::"Partially Picked");
                Status::"Completely Picked":
                    begin
                        SetRange("No.", WhseStagedPickSourceLine."No.");
                        SetFilter("Line No.", '<>%1', WhseStagedPickSourceLine."Line No.");
                        SetFilter(Status, '<%1', Status::"Completely Picked");
                        if Find('-') then
                            exit(Status::"Partially Picked");
                        exit(Status::"Completely Picked");
                    end;
            end;
    end;

    procedure UpdateOnRegister()
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        WhseStagedPickLine.SetRange("No.", "No.");
        WhseStagedPickLine.SetFilter("Item No.", '<>%1', '');
        if WhseStagedPickLine.Find('-') then
            repeat
                if (WhseStagedPickLine."Qty. Outstanding" <> 0) or
                   (WhseStagedPickLine."Qty. Outstanding (Base)" <> 0)
                then
                    exit;
            until (WhseStagedPickLine.Next = 0);

        WhseStagedPickSourceLine.SetRange("No.", "No.");
        if WhseStagedPickSourceLine.Find('-') then
            repeat
                if (WhseStagedPickSourceLine."Qty. Outstanding" <> 0) or
                   (WhseStagedPickSourceLine."Qty. Outstanding (Base)" <> 0)
                then
                    exit;
            until (WhseStagedPickSourceLine.Next = 0);

        DeleteRelatedLines;
        Delete;
    end;

    local procedure MessageIfStgdPickLinesExist(ChangedFieldName: Text[30])
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
    begin
        WhseStagedPickLine.SetRange("No.", "No.");
        if WhseStagedPickLine.Find('-') then
            if not HideValidationDialog then
                Message(
                  StrSubstNo(Text006, ChangedFieldName, TableCaption, WhseStagedPickLine.TableCaption) +
                  StrSubstNo(Text007, WhseStagedPickLine.TableCaption));
    end;

    local procedure ErrorIfStgdPickSrcLinesExist(ChangedFieldName: Text[30])
    var
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        WhseStagedPickSourceLine.SetRange("No.", "No.");
        if WhseStagedPickSourceLine.Find('-') then
            Error(StrSubstNo(Text008, ChangedFieldName));
    end;

    procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    procedure LookupWhseStagedPickHeader(var WhseStagedPickHeader: Record "Whse. Staged Pick Header"): Boolean
    begin
        Commit;
        if UserId <> '' then begin
            WhseStagedPickHeader.FilterGroup := 2;
            WhseStagedPickHeader.SetRange("Location Code");
        end;
        if PAGE.RunModal(0, WhseStagedPickHeader) = ACTION::LookupOK then;
        if UserId <> '' then begin
            WhseStagedPickHeader.FilterGroup := 2;
            WhseStagedPickHeader.SetRange("Location Code", WhseStagedPickHeader."Location Code");
            WhseStagedPickHeader.FilterGroup := 0;
        end;
    end;

    procedure OpenWhseStagedPickHeader(var WhseStagedPickHeader: Record "Whse. Staged Pick Header")
    var
        WhseEmployee: Record "Warehouse Employee";
        WmsManagement: Codeunit "WMS Management";
        CurrentLocationCode: Code[10];
    begin
        if UserId <> '' then begin
            WhseEmployee.SetRange("User ID", UserId);
            if not WhseEmployee.Find('-') then
                Error(Text002, UserId);

            WhseEmployee.SetRange("Location Code", WhseStagedPickHeader."Location Code");
            if WhseEmployee.Find('-') then
                CurrentLocationCode := WhseStagedPickHeader."Location Code"
            else
                CurrentLocationCode := WmsManagement.GetDefaultLocation;

            WhseStagedPickHeader.FilterGroup := 2;
            WhseStagedPickHeader.SetRange("Location Code", CurrentLocationCode);
            WhseStagedPickHeader.FilterGroup := 0;
        end;
    end;

    procedure LookupLocation(var WhseStagedPickHeader: Record "Whse. Staged Pick Header"): Boolean
    var
        Location: Record Location;
    begin
        Commit;
        Location.FilterGroup := 2;
        Location.SetRange(Code);
        if PAGE.RunModal(PAGE::"Locations with Warehouse List", Location) = ACTION::LookupOK then
            WhseStagedPickHeader.Validate("Location Code", Location.Code);
        Location.FilterGroup := 0;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure DeleteRelatedLines()
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        WhsePickRqst: Record "Whse. Pick Request";
        WhseCommentLine: Record "Warehouse Comment Line";
    begin
        WhseStagedPickLine.SetHideValidationDialog(true);
        WhseStagedPickLine.SetRange("No.", "No.");
        WhseStagedPickLine.DeleteAll(true);
        Find;

        WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::FOODStagedPick);
        WhsePickRqst.SetRange("Document No.", "No.");
        WhsePickRqst.DeleteAll;

        WhseCommentLine.SetRange("Table Name", WhseCommentLine."Table Name"::"Staged Pick");
        WhseCommentLine.SetRange(Type, WhseCommentLine.Type::" ");
        WhseCommentLine.SetRange("No.", "No.");
        WhseCommentLine.DeleteAll;

        ItemTrackingMgt.DeleteWhseItemTrkgLines(
          DATABASE::"Whse. Staged Pick Line", 0, "No.", '', 0, 0, '', false);
    end;

    procedure CheckPickRequired(LocationCode: Code[10])
    begin
        if LocationCode = '' then begin
            WhseSetup.Get;
            WhseSetup.TestField("Require Pick");
        end else begin
            GetLocation(LocationCode);
            Location.TestField("Require Pick");
        end;
    end;
}

