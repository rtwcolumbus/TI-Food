codeunit 37002129 "Accrual Search Management"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.01
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan
    // 
    // PR4.00.03
    // P8000324A, VerticalSoft, Jack Reynolds, 06 APR 06
    //   Maintain plan type on accrual search line
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add support for accrual groups
    // 
    // PRW16.00.03
    // P8000794, VerticalSoft, Don Bresee, 18 MAR 10
    //   Add INIT to AddSearchLine routine
    // 
    // P8000828, VerticalSoft, Don Bresee, 09 JUN 10
    //   Move insert/delete logic to form/page

    Permissions = TableData "Accrual Plan" = r,
                  TableData "Accrual Plan Line" = r,
                  TableData "Accrual Plan Source Line" = r,
                  TableData "Accrual Plan Search Line" = rimd;

    trigger OnRun()
    begin
        if Confirm(Text000) then
            RebuildAll;
    end;

    var
        TempSearchLine: Record "Accrual Plan Search Line" temporary;
        Text000: Label 'Rebuild search lines for all accrual plans?';

    procedure DeletePlan(var Plan: Record "Accrual Plan")
    begin
        if IsSearchPlan(Plan) then
            DeletePlanSearchLines(Plan);
    end;

    local procedure DeletePlanSearchLines(var Plan: Record "Accrual Plan")
    var
        SearchLine: Record "Accrual Plan Search Line";
    begin
        with SearchLine do begin
            SetRange("Accrual Plan Type", Plan.Type);
            SetRange("Accrual Plan No.", Plan."No.");
            DeleteAll;
        end;
    end;

    procedure ModifyPlan(var Plan: Record "Accrual Plan"; OldPlan: Record "Accrual Plan")
    var
        SearchLine: Record "Accrual Plan Search Line";
    begin
        if (IsSearchPlan(Plan) <> IsSearchPlan(OldPlan)) then
            if IsSearchPlan(Plan) then
                RebuildPlan(Plan)
            else
                DeletePlanSearchLines(Plan)
        else begin
            if (Plan."Computation Level" <> OldPlan."Computation Level") or
               (Plan."Date Type" <> OldPlan."Date Type") or
               (Plan."Plan Type" <> OldPlan."Plan Type") or // P8000324A
               (Plan."Source Selection Type" <> OldPlan."Source Selection Type")
            then
                with SearchLine do begin
                    SetRange("Accrual Plan Type", Plan.Type);
                    SetRange("Accrual Plan No.", Plan."No.");
                    if Find('-') then
                        repeat
                            "Computation Level" := Plan."Computation Level";
                            "Date Type" := Plan."Date Type";
                            "Plan Type" := Plan."Plan Type"; // P8000324A
                            "Source Selection Type" := Plan."Source Selection Type";
                            Modify;
                        until (Next = 0);
                end;

            if (Plan."Start Date" <> OldPlan."Start Date") or
               (Plan."End Date" <> OldPlan."End Date")
            then
                UpdatePlanDates(Plan);
        end;
    end;

    procedure InsertPlanLine(var PlanLine: Record "Accrual Plan Line")
    var
        Plan: Record "Accrual Plan";
        SourceLine: Record "Accrual Plan Source Line";
    begin
        if GetSearchPlan(PlanLine."Accrual Plan Type", PlanLine."Accrual Plan No.", Plan) then begin
            DeletePlanLineSearchLines(PlanLine);

            InitSearchLines;
            with SourceLine do begin
                SetRange("Accrual Plan Type", Plan.Type);
                SetRange("Accrual Plan No.", Plan."No.");
                if Find('-') then
                    repeat
                        AddSearchLine(Plan, PlanLine, SourceLine);
                    until (Next = 0);
            end;
            InsertSearchLines;
        end;
    end;

    procedure ModifyPlanLine(var PlanLine: Record "Accrual Plan Line"; OldPlanLine: Record "Accrual Plan Line")
    var
        Plan: Record "Accrual Plan";
    begin
        with PlanLine do
            if GetSearchPlan("Accrual Plan Type", "Accrual Plan No.", Plan) then
                if ("Start Date" <> OldPlanLine."Start Date") or
                   ("End Date" <> OldPlanLine."End Date")
                then
                    UpdatePlanLineDates(Plan, PlanLine);
    end;

    procedure DeletePlanLine(var PlanLine: Record "Accrual Plan Line")
    var
        Plan: Record "Accrual Plan";
    begin
        if GetSearchPlan(PlanLine."Accrual Plan Type", PlanLine."Accrual Plan No.", Plan) then
            if not PlanLine.OtherItemLinesExist() then
                DeletePlanLineSearchLines(PlanLine);
    end;

    local procedure DeletePlanLineSearchLines(var PlanLine: Record "Accrual Plan Line")
    var
        SearchLine: Record "Accrual Plan Search Line";
    begin
        with SearchLine do begin
            SetCurrentKey("Accrual Plan Type", "Accrual Plan No.", "Item Code");
            SetRange("Accrual Plan Type", PlanLine."Accrual Plan Type");
            SetRange("Accrual Plan No.", PlanLine."Accrual Plan No.");
            if PlanLine."Item Selection" = PlanLine."Item Selection"::"Accrual Group" then // P8000355A
                SetRange("Item Accrual Group Code", PlanLine."Item Code")                     // P8000355A
            else                                                                           // P8000355A
                SetFilter("Item Code", '%1', PlanLine."Item Code");
            DeleteAll;
        end;
    end;

    procedure InsertSourceLine(var SourceLine: Record "Accrual Plan Source Line")
    var
        Plan: Record "Accrual Plan";
    begin
        with SourceLine do
            if GetSearchPlan("Accrual Plan Type", "Accrual Plan No.", Plan) then
                InsertSourceLineSearchLines(Plan, SourceLine);
    end;

    local procedure InsertSourceLineSearchLines(var Plan: Record "Accrual Plan"; var SourceLine: Record "Accrual Plan Source Line")
    var
        PlanLine: Record "Accrual Plan Line";
    begin
        InitSearchLines;
        with PlanLine do begin
            SetRange("Accrual Plan Type", Plan.Type);
            SetRange("Accrual Plan No.", Plan."No.");
            if Find('-') then
                repeat
                    AddSearchLine(Plan, PlanLine, SourceLine);
                    SetFilter("Item Code", '%1', "Item Code");
                    Find('+');
                    SetRange("Item Code");
                until (Next = 0);
        end;
        InsertSearchLines;
    end;

    procedure ModifySourceLine(var SourceLine: Record "Accrual Plan Source Line"; OldSourceLine: Record "Accrual Plan Source Line")
    var
        Plan: Record "Accrual Plan";
    begin
        with SourceLine do
            if GetSearchPlan("Accrual Plan Type", "Accrual Plan No.", Plan) then
                if ("Start Date" <> OldSourceLine."Start Date") or
                   ("End Date" <> OldSourceLine."End Date")
                then
                    UpdateSourceLineDates(Plan, SourceLine);
    end;

    procedure DeleteSourceLine(var SourceLine: Record "Accrual Plan Source Line")
    var
        Plan: Record "Accrual Plan";
        SearchLine: Record "Accrual Plan Search Line";
    begin
        if GetSearchPlan(SourceLine."Accrual Plan Type", SourceLine."Accrual Plan No.", Plan) then
            with SearchLine do begin
                SetRange("Accrual Plan Type", SourceLine."Accrual Plan Type");
                SetRange("Accrual Plan No.", SourceLine."Accrual Plan No.");
                if SourceLine."Source Selection" = SourceLine."Source Selection"::"Accrual Group" then // P8000355A
                    SetRange("Source Accrual Group Code", SourceLine."Source Code")                       // P8000355A
                else begin                                                                             // P8000355A
                    SetFilter("Source Code", '%1', SourceLine."Source Code");
                    SetFilter("Source Ship-to Code", '%1', SourceLine."Source Ship-to Code");
                end;                                                                                   // P8000355A
                DeleteAll;
            end;
    end;

    procedure RebuildPlan(var Plan: Record "Accrual Plan")
    var
        SearchLine: Record "Accrual Plan Search Line";
        SourceLine: Record "Accrual Plan Source Line";
    begin
        with SearchLine do begin
            SetRange("Accrual Plan Type", Plan.Type);
            SetRange("Accrual Plan No.", Plan."No.");
            DeleteAll;
        end;

        if IsSearchPlan(Plan) then
            with SourceLine do begin
                SetRange("Accrual Plan Type", Plan.Type);
                SetRange("Accrual Plan No.", Plan."No.");
                if Find('-') then
                    repeat
                        InsertSourceLineSearchLines(Plan, SourceLine);
                    until (Next = 0);
            end;
    end;

    procedure RebuildAll()
    var
        SearchLine: Record "Accrual Plan Search Line";
        Plan: Record "Accrual Plan";
    begin
        with SearchLine do
            DeleteAll;

        with Plan do
            if Find('-') then
                repeat
                    RebuildPlan(Plan);
                until (Next = 0);
    end;

    local procedure UpdatePlanDates(var Plan: Record "Accrual Plan")
    var
        SourceLine: Record "Accrual Plan Source Line";
    begin
        with SourceLine do begin
            SetRange("Accrual Plan Type", Plan.Type);
            SetRange("Accrual Plan No.", Plan."No.");
            if Find('-') then
                repeat
                    UpdateSourceLineDates(Plan, SourceLine);
                until (Next = 0);
        end;
    end;

    local procedure UpdatePlanLineDates(var Plan: Record "Accrual Plan"; var PlanLine: Record "Accrual Plan Line")
    var
        SearchLine: Record "Accrual Plan Search Line";
        SourceLine: Record "Accrual Plan Source Line";
    begin
        with SearchLine do begin
            SetRange("Accrual Plan Type", Plan.Type);
            SetRange("Accrual Plan No.", Plan."No.");
            if PlanLine."Item Selection" = PlanLine."Item Selection"::"Accrual Group" then // P8000355A
                SetRange("Item Accrual Group Code", PlanLine."Item Code")                     // P8000355A
            else                                                                           // P8000355A
                SetFilter("Item Code", '%1', PlanLine."Item Code");
            if Find('-') then
                repeat
                    // P8000355A
                    if "Source Accrual Group Code" <> '' then
                        SourceLine.Get(
                          "Accrual Plan Type", "Accrual Plan No.",
                          "Source Accrual Group Code", '')
                    else
                        // P8000355A
                        SourceLine.Get(
                  "Accrual Plan Type", "Accrual Plan No.",
                  "Source Code", "Source Ship-to Code");
                    if SetSearchDates(SearchLine, Plan, SourceLine, PlanLine) then
                        Modify;
                until (Next = 0);
        end;
    end;

    local procedure UpdateSourceLineDates(var Plan: Record "Accrual Plan"; var SourceLine: Record "Accrual Plan Source Line")
    var
        SearchLine: Record "Accrual Plan Search Line";
        PlanLine: Record "Accrual Plan Line";
        PlanLineItemCode: Code[20];
    begin
        with PlanLine do begin
            SetRange("Accrual Plan Type", Plan.Type);
            SetRange("Accrual Plan No.", Plan."No.");
        end;

        with SearchLine do begin
            SetRange("Accrual Plan Type", Plan.Type);
            SetRange("Accrual Plan No.", Plan."No.");
            if SourceLine."Source Selection" = SourceLine."Source Selection"::"Accrual Group" then // P8000355A
                SetRange("Source Accrual Group Code", SourceLine."Source Code")                       // P8000355A
            else begin                                                                             // P8000355A
                SetFilter("Source Code", '%1', SourceLine."Source Code");
                SetFilter("Source Ship-to Code", '%1', SourceLine."Source Ship-to Code");
            end;                                                                                   // P8000355A
            if Find('-') then
                repeat
                    // P8000355A
                    if "Item Accrual Group Code" = '' then
                        PlanLineItemCode := "Item Code"
                    else
                        PlanLineItemCode := "Item Accrual Group Code";
                    // P8000355A
                    if (PlanLine."Item Code" <> PlanLineItemCode) then begin   // P8000355A
                        PlanLine.SetFilter("Item Code", '%1', PlanLineItemCode); // P8000355A
                        PlanLine.Find('-');
                    end;
                    if SetSearchDates(SearchLine, Plan, SourceLine, PlanLine) then
                        Modify;
                until (Next = 0);
        end;
    end;

    local procedure SetSearchDates(var SearchLine: Record "Accrual Plan Search Line"; var Plan: Record "Accrual Plan"; var SourceLine: Record "Accrual Plan Source Line"; var PlanLine: Record "Accrual Plan Line"): Boolean
    var
        NewStartDate: Date;
        NewEndDate: Date;
    begin
        NewStartDate := Plan.GetStartDate(SourceLine, PlanLine."Start Date"); // P8000274A
        NewEndDate := Plan.GetEndDate(SourceLine, PlanLine."End Date");       // P8000274A

        with SearchLine do
            if ("Start Date" <> NewStartDate) or ("End Date" <> NewEndDate) then begin
                "Start Date" := NewStartDate;
                "End Date" := NewEndDate;
                exit(true);
            end;
        exit(false);
    end;

    local procedure InitSearchLines()
    begin
        with TempSearchLine do begin
            Reset;
            DeleteAll;
        end;
    end;

    local procedure AddSearchLine(var Plan: Record "Accrual Plan"; var PlanLine: Record "Accrual Plan Line"; var SourceLine: Record "Accrual Plan Source Line")
    var
        TempSearchLine2: Record "Accrual Plan Search Line" temporary;
        SourceGroupLine: Record "Accrual Group Line";
        ItemGroupLine: Record "Accrual Group Line";
    begin
        with TempSearchLine do begin
            Init; // P8000794
            "Accrual Plan Type" := Plan.Type;
            "Accrual Plan No." := Plan."No.";
            "Computation Level" := Plan."Computation Level";
            "Date Type" := Plan."Date Type";
            "Plan Type" := Plan."Plan Type"; // P8000324A

            "Source Selection Type" := SourceLine."Source Selection Type";
            "Source Selection" := SourceLine."Source Selection";
            "Source Code" := SourceLine."Source Code";
            "Source Ship-to Code" := SourceLine."Source Ship-to Code";

            "Item Selection" := PlanLine."Item Selection";
            "Item Code" := PlanLine."Item Code";

            SetSearchDates(TempSearchLine, Plan, SourceLine, PlanLine);

            // P8000355A
            if SourceLine."Source Selection" = SourceLine."Source Selection"::"Accrual Group" then begin
                SourceGroupLine.SetRange("Accrual Group Type", Plan.Type);
                SourceGroupLine.SetRange("Accrual Group Code", SourceLine."Source Code");
                "Source Selection" := "Source Selection"::Specific;
                "Source Ship-to Code" := '';
                "Source Accrual Group Code" := SourceLine."Source Code";
            end;
            if PlanLine."Item Selection" = PlanLine."Item Selection"::"Accrual Group" then begin
                ItemGroupLine.SetRange("Accrual Group Type", ItemGroupLine."Accrual Group Type"::Item);
                ItemGroupLine.SetRange("Accrual Group Code", PlanLine."Item Code");
                "Item Selection" := "Item Selection"::"Specific Item";
                "Item Accrual Group Code" := PlanLine."Item Code";
            end;
            if SourceLine."Source Selection" = SourceLine."Source Selection"::"Accrual Group" then begin
                if SourceGroupLine.Find('-') then
                    repeat
                        "Source Code" := SourceGroupLine."No.";
                        if PlanLine."Item Selection" = PlanLine."Item Selection"::"Accrual Group" then begin
                            if ItemGroupLine.Find('-') then
                                repeat
                                    "Item Code" := ItemGroupLine."No.";
                                    Insert;
                                until ItemGroupLine.Next = 0;
                        end else
                            Insert;
                    until SourceGroupLine.Next = 0;
            end else
                if PlanLine."Item Selection" = PlanLine."Item Selection"::"Accrual Group" then begin
                    if ItemGroupLine.Find('-') then
                        repeat
                            "Item Code" := ItemGroupLine."No.";
                            Insert;
                        until ItemGroupLine.Next = 0;
                end else
                    Insert;
            // P8000355A
        end;
    end;

    local procedure InsertSearchLines()
    var
        SearchLine: Record "Accrual Plan Search Line";
    begin
        with TempSearchLine do begin
            Reset;
            if Find('-') then
                repeat
                    SearchLine := TempSearchLine;
                    SearchLine.Insert;
                    Delete;
                until (Next = 0);
        end;
    end;

    local procedure GetSearchPlan(AccrualPlanType: Integer; AccrualPlanNo: Code[20]; var Plan: Record "Accrual Plan"): Boolean
    begin
        with Plan do
            if Get(AccrualPlanType, AccrualPlanNo) then
                exit(IsSearchPlan(Plan));
        exit(false);
    end;

    local procedure IsSearchPlan(var Plan: Record "Accrual Plan"): Boolean
    begin
        with Plan do
            exit(("Plan Type" <> "Plan Type"::Reporting) and
                 (not "Use Accrual Schedule") and ("Computation Level" <> "Computation Level"::Plan));
    end;

    procedure InsertGroupLine(GroupLine: Record "Accrual Group Line")
    var
        AccrualGroupLine: Record "Accrual Group Line";
        AccrualPlanLine: Record "Accrual Plan Line";
        AccrualSourceLine: Record "Accrual Plan Source Line";
        AccrualSearchLine: Record "Accrual Plan Search Line";
        AccrualSearchLine2: Record "Accrual Plan Search Line";
        FirstLineInGroup: Boolean;
    begin
        // P8000355A
        AccrualGroupLine.SetRange("Accrual Group Type", GroupLine."Accrual Group Type");
        AccrualGroupLine.SetRange("Accrual Group Code", GroupLine."Accrual Group Code");
        FirstLineInGroup := not AccrualGroupLine.Find('-');
        // P8000828
        /*
        GroupLine.INSERT; // This function is called from the OnInsert of the Accrual Group Line table so the group line has
                          // not been inserted yet.  However, if this is the first line of the group I want to utilize
                          // InsertPlanLine or InsertSourceLine to create the first search lines for the plan.  These
                          // functions require the group line to already exist, so I put it there; I'll get rid of it later
                          // so the actual insertion into the Accrual Group Line table will succeed.
        */
        // P8000828
        if GroupLine."Accrual Group Type" = GroupLine."Accrual Group Type"::Item then begin
            AccrualSearchLine.SetCurrentKey("Accrual Plan Type", "Accrual Plan No.", "Item Code");

            AccrualPlanLine.SetCurrentKey("Item Selection", "Item Code");
            AccrualPlanLine.SetRange("Item Selection", AccrualPlanLine."Item Selection"::"Accrual Group");
            AccrualPlanLine.SetRange("Item Code", GroupLine."Accrual Group Code");
            if AccrualPlanLine.Find('-') then
                repeat
                    if FirstLineInGroup then
                        InsertPlanLine(AccrualPlanLine)
                    else begin
                        AccrualSearchLine.SetRange("Accrual Plan Type", AccrualPlanLine."Accrual Plan Type");
                        AccrualSearchLine.SetRange("Accrual Plan No.", AccrualPlanLine."Accrual Plan No.");
                        AccrualSearchLine.SetRange("Item Accrual Group Code", GroupLine."Accrual Group Code");
                        if AccrualSearchLine.Find('-') then begin
                            AccrualSearchLine.SetRange("Item Code", AccrualSearchLine."Item Code");
                            repeat
                                AccrualSearchLine2 := AccrualSearchLine;
                                AccrualSearchLine2."Item Code" := GroupLine."No.";
                                AccrualSearchLine2.Insert;
                            until AccrualSearchLine.Next = 0;
                            AccrualSearchLine.SetRange("Item Code");
                        end;
                    end;
                    AccrualPlanLine.SetRange("Accrual Plan Type", AccrualPlanLine."Accrual Plan Type");
                    AccrualPlanLine.SetRange("Accrual Plan No.", AccrualPlanLine."Accrual Plan No.");
                    AccrualPlanLine.Find('+');
                    AccrualPlanLine.SetRange("Accrual Plan Type");
                    AccrualPlanLine.SetRange("Accrual Plan No.");
                until AccrualPlanLine.Next = 0;
        end else begin
            AccrualSearchLine.SetCurrentKey("Accrual Plan Type", "Accrual Plan No.", "Source Code");
            AccrualSearchLine.SetRange("Accrual Plan Type", GroupLine."Accrual Group Type");

            AccrualSourceLine.SetCurrentKey("Source Selection", "Source Code");
            AccrualSourceLine.SetRange("Source Selection", AccrualSourceLine."Source Selection"::"Accrual Group");
            AccrualSourceLine.SetRange("Source Code", GroupLine."Accrual Group Code");
            AccrualSourceLine.SetRange("Accrual Plan Type", GroupLine."Accrual Group Type");
            if AccrualSourceLine.Find('-') then
                repeat
                    if FirstLineInGroup then
                        InsertSourceLine(AccrualSourceLine)
                    else begin
                        AccrualSearchLine.SetRange("Accrual Plan No.", AccrualSourceLine."Accrual Plan No.");
                        AccrualSearchLine.SetRange("Source Accrual Group Code", GroupLine."Accrual Group Code");
                        if AccrualSearchLine.Find('-') then begin
                            AccrualSearchLine.SetRange("Source Code", AccrualSearchLine."Source Code");
                            repeat
                                AccrualSearchLine2 := AccrualSearchLine;
                                AccrualSearchLine2."Source Code" := GroupLine."No.";
                                AccrualSearchLine2.Insert;
                            until AccrualSearchLine.Next = 0;
                            AccrualSearchLine.SetRange("Source Code");
                        end;
                    end;
                    AccrualSourceLine.SetRange("Accrual Plan No.", AccrualSourceLine."Accrual Plan No.");
                    AccrualSourceLine.Find('+');
                    AccrualSourceLine.SetRange("Accrual Plan No.");
                until AccrualSourceLine.Next = 0;
        end;
        // GroupLine.DELETE; // See comments above // P8000828

    end;

    procedure DeleteGroupLine(GroupLine: Record "Accrual Group Line")
    var
        AccrualPlanLine: Record "Accrual Plan Line";
        AccrualSourceLine: Record "Accrual Plan Source Line";
        AccrualSearchLine: Record "Accrual Plan Search Line";
    begin
        // P8000355A
        if GroupLine."Accrual Group Type" = GroupLine."Accrual Group Type"::Item then begin
            AccrualSearchLine.SetCurrentKey("Accrual Plan Type", "Accrual Plan No.", "Item Code");
            AccrualSearchLine.SetRange("Item Code", GroupLine."No.");

            AccrualPlanLine.SetCurrentKey("Item Selection", "Item Code");
            AccrualPlanLine.SetRange("Item Selection", AccrualPlanLine."Item Selection"::"Accrual Group");
            AccrualPlanLine.SetRange("Item Code", GroupLine."Accrual Group Code");
            if AccrualPlanLine.Find('-') then
                repeat
                    AccrualSearchLine.SetRange("Accrual Plan Type", AccrualPlanLine."Accrual Plan Type");
                    AccrualSearchLine.SetRange("Accrual Plan No.", AccrualPlanLine."Accrual Plan No.");
                    AccrualSearchLine.DeleteAll;
                    AccrualPlanLine.SetRange("Accrual Plan Type", AccrualPlanLine."Accrual Plan Type");
                    AccrualPlanLine.SetRange("Accrual Plan No.", AccrualPlanLine."Accrual Plan No.");
                    AccrualPlanLine.Find('+');
                    AccrualPlanLine.SetRange("Accrual Plan Type");
                    AccrualPlanLine.SetRange("Accrual Plan No.");
                until AccrualPlanLine.Next = 0;
        end else begin
            AccrualSearchLine.SetCurrentKey("Accrual Plan Type", "Accrual Plan No.", "Source Code");
            AccrualSearchLine.SetRange("Accrual Plan Type", GroupLine."Accrual Group Type");
            AccrualSearchLine.SetRange("Source Code", GroupLine."No.");

            AccrualSourceLine.SetCurrentKey("Source Selection", "Source Code");
            AccrualSourceLine.SetRange("Source Selection", AccrualSourceLine."Source Selection"::"Accrual Group");
            AccrualSourceLine.SetRange("Source Code", GroupLine."Accrual Group Code");
            AccrualSourceLine.SetRange("Accrual Plan Type", GroupLine."Accrual Group Type");
            if AccrualSourceLine.Find('-') then
                repeat
                    AccrualSearchLine.SetRange("Accrual Plan No.", AccrualSourceLine."Accrual Plan No.");
                    AccrualSearchLine.DeleteAll;
                    AccrualSourceLine.SetRange("Accrual Plan No.", AccrualSourceLine."Accrual Plan No.");
                    AccrualSourceLine.Find('+');
                    AccrualSourceLine.SetRange("Accrual Plan No.");
                until AccrualSourceLine.Next = 0;
        end;
    end;
}

