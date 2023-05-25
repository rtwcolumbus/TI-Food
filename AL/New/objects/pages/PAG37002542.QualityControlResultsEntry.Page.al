page 37002542 "Quality Control Results Entry"
{
    // PR1.10, Navision US, John Nozzi, 28 MAR 01, New Object
    //   This form is used as the primary method of entering QC Results into Item Lots.
    //   It is also used to mark the Q/C Process as Completed.
    //   It is intended to be called from the Item Lots form, but could also be called stand alone.
    // 
    // PR1.10.01
    //   Display line in red if schedule date is passed
    //   Complete function to call Complete Quality Control form
    // 
    // PR1.10.03
    //   Improve filters - Item and Assigned to (ClearOnLookup - No, ValidateTableRelation - No);
    //     Schedule Date (OnAfterInput - MakeDateText)
    //   Update form after validating filters
    // 
    // PR2.00
    //   Modify for Lot No. Information and Quality Control Header
    // 
    // PR3.60.02
    //   Change subform view to exclude lines with Q/C Completed
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 26 NOV 04
    //   Add logic to move Q/C results to lot specification table
    // 
    // PRW15.00.01
    // P8000575A, VerticalSoft, Jack Reynolds, 14 FEB 08
    //   Set Complete Date to WORKDATE
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 13 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW19.00.01
    // P8007513, To-Increase, Dayakar Battini, 26 JUL 16
    //   proper Lot No. Information update.
    // 
    // PRW111.00.01
    // P80037637, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop threshhold results
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Quality Control Results Entry';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "Quality Control Header";
    SourceTableView = SORTING(Status, "Schedule Date");

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Lot)
                {
                    Caption = 'Lot';
                    field("Item No."; Rec."Item No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Variant Code"; Rec."Variant Code")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Lot No."; Rec."Lot No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Document No."; Rec."Document No.")
                    {
                        ApplicationArea = FOODBasic;
                        DrillDown = false;
                    }
                    field("Posting Date"; Rec."Posting Date")
                    {
                        ApplicationArea = FOODBasic;
                        DrillDown = false;
                    }
                    field("Expected Release Date"; Rec."Expected Release Date")
                    {
                        ApplicationArea = FOODBasic;
                        DrillDown = false;
                    }
                    field("Release Date"; Rec."Release Date")
                    {
                        ApplicationArea = FOODBasic;
                        DrillDown = false;
                    }
                    field("Expiration Date"; Rec."Expiration Date")
                    {
                        ApplicationArea = FOODBasic;
                        DrillDown = false;
                    }
                    field("Lot Strength Percent"; Rec."Lot Strength Percent")
                    {
                        ApplicationArea = FOODBasic;
                        DrillDown = false;
                        Visible = false;
                    }
                    field("Quantity on Hand"; Rec."Quantity on Hand")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                group(ActivityCount)
                {
                    Caption = 'Activities';
                    field(CountOriginal; Rec.ActivityCount((false)))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Original';
                        DrillDown = false;
                    }
                    field(CountReTest; Rec.ActivityCount((true)))
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Re-Test';
                        DrillDown = false;
                    }
                }
                group(Activity)
                {
                    Caption = 'Activity';
                    field("Q/C Activity No."; Rec."Q/C Activity No.")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = Rec."Q/C Activity No." <> '';
                    }
                    field("Test No."; Rec."Test No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Re-Test"; Rec."Re-Test")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    // P800122712
                    field("Sample Quantity Posted"; Rec."Sample Quantity Posted")
                    {
                        ApplicationArea = FOODBasic;
                        Visible = SampleVisible;
                    }
                    // P800122712
                    field(Status; Rec.Status)
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Assigned To"; Rec."Assigned To")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Assigned To';
                        Editable = Allowedits;
                    }
                    field("Schedule Date"; Rec."Schedule Date")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Schedule Date';
                        Editable = Allowedits;
                    }
                }
            }
            group(Item)
            {
                Caption = 'Item';
                field("Item.""No."""; Item."No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'No.';
                    Editable = false;
                }
                field("Item.Description"; Item.Description)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    Editable = false;
                }
                field("Item.""Base Unit of Measure"""; Item."Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Base Unit of Measure';
                    Editable = false;
                }
                field("Item.""Quarantine Calculation"""; Item."Quarantine Calculation")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quarantine Period';
                    Editable = false;
                }
                field("Item.""Expiration Calculation"""; Item."Expiration Calculation")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Shelf Life';
                    Editable = false;
                }
                field("Item.""Lot Strength"""; Item."Lot Strength")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Strength';
                    Editable = false;
                }
            }
            part(Tests; "Quality Control Results Sub.")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code"),
                              "Lot No." = FIELD("Lot No."),
                              "Test No." = FIELD("Test No.");
                SubPageView = SORTING("Item No.", "Variant Code", "Lot No.", "Test No.", "Test Code");
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
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Lot")
            {
                Caption = '&Lot';
                action("Co&mment")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mment';
                    Image = Comment;
                    RunObject = Page "Item Tracking Comments";
                    RunPageLink = Type = CONST("Lot No."),
                                  "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Serial/Lot No." = FIELD("Lot No.");
                }
                action("Information Card")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Information Card';
                    Image = LotInfo;
                    RunObject = Page "Lot No. Information Card";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                }
                action("Lot &Specifications")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot &Specifications';
                    Image = LotInfo;
                    RunObject = Page "Lot Specifications";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                }
            }
        }
        area(processing)
        {
            action("&Add")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Add';
                Image = Add;

                trigger OnAction()
                begin
                    P800QCFns.AddTest(Rec);
                end;
            }
            group("&Test")
            {
                Caption = '&Test';
                action("&Complete")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Complete';
                    Ellipsis = true;
                    Enabled = AllowEdits;
                    Image = Completed;
                    ShortCutKey = 'F9';
                    Visible = AllowEdits;

                    trigger OnAction()
                    var
                        LotNoInfo: Record "Lot No. Information";
                        xLotNoInfo: Record "Lot No. Information";
                        LotStatusMgmt: Codeunit "Lot Status Management";
                        QCComplete: Page "Complete Quality Control";
                        LotNoInfo2: Record "Lot No. Information";
                        DelegateSuspend: Boolean;
                    begin
                        // PR1.10.01 Begin
                        if Rec.Status in [Rec.Status::Pass, Rec.Status::Fail] then
                            Error(Text000, Rec.FieldCaption(Status), Rec.Status);
                        // P80037637
                        P800QCFns.CheckQCLines(Rec);
                        if P800QCFns.StatusSuspendRequired(Rec, DelegateSuspend) then begin
                            if (not DelegateSuspend) then begin
                                if Rec.Status <> Rec.Status::Suspended then begin
                                    Rec.Status := Rec.Status::Suspended;
                                    Rec.Modify;
                                end;
                                Message(StatusSuspendedTxt);
                                CurrPage.Update(false);
                                exit;
                            end;
                        end;
                        // P80037637
                        QCComplete.SetVars(Rec);
                        if QCComplete.RunModal = ACTION::Yes then begin
                            QCComplete.GetVars(Rec, LotNoInfo); // PR2.00
                            Rec.Validate(Status);
                            Rec."Complete Date" := WorkDate; // P8000575A
                            Rec.Modify;
                            LotNoInfo2.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.");    // P8007513

                            xLotNoInfo := LotNoInfo;                            // P8001083
                            xLotNoInfo.Find;                                    // P8001083
                                                                                //P8007513
                            LotNoInfo2.Validate("Expiration Date", LotNoInfo."Expiration Date");
                            LotNoInfo2.Validate("Release Date", LotNoInfo."Release Date");
                            LotNoInfo2.Validate("Lot Strength Percent", LotNoInfo."Lot Strength Percent");
                            LotNoInfo2.Validate("Lot Status Code", LotNoInfo."Lot Status Code");               // P8001083
                            LotStatusMgmt.ChangeLotStatus(xLotNoInfo, LotNoInfo); // P8001083
                            LotNoInfo2.Modify; // PR2.00
                                               //P8007513
                            P800QCFns.UpdateLotSpecs(Rec); // P8000152A
                            CurrPage.Close; // P8000664
                        end;
                        // PR1.10.01 End
                    end;
                }
                action("&Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Print Worksheet';
                    Enabled = AllowEdits;
                    Image = Print;
                    Visible = AllowEdits;

                    trigger OnAction()
                    var
                        QCHeader: Record "Quality Control Header";
                    begin
                        // PR2.00 Begin
                        QCHeader.Copy(Rec);
                        QCHeader.SetRecFilter;
                        REPORT.Run(REPORT::"Quality Control Worksheet", true, true, QCHeader);
                        // PR2.00 End
                    end;
                }
                action(PrintResults)
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Print Results';
                    Enabled = not AllowEdits;
                    Image = Print;
                    Visible = not AllowEdits;

                    trigger OnAction()
                    var
                        QCHeader: Record "Quality Control Header";
                    begin
                        // PR2.00 Begin
                        QCHeader.Copy(Rec);
                        QCHeader.SetRecFilter;
                        REPORT.Run(REPORT::"Quality Control Test Results", true, true, QCHeader);
                        // PR2.00 End
                    end;
                }
                action(QCSampling)
                {
                    // P800122712
                    ApplicationArea = FOODBasic;
                    Caption = 'Quality Control Samples';
                    Enabled = AllowEdits;
                    Visible = SampleVisible;
                    trigger OnAction()
                    begin
                        P800QCFns.RunQCSample(Rec);
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(Add_Promoted; "&Add")
            {
            }
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Complete_Promoted; "&Complete")
                {
                }
                actionref(Print_Promoted; "&Print")
                {
                }
                actionref(PrintResults_Promoted; PrintResults)
                {
                }
                actionref(QCSampling_Promoted; QCSampling)
                {
                }
            }
            group(Category_Lot)
            {
                Caption = 'Lot';

                actionref(Comment_Promoted; "Co&mment")
                {
                }
                actionref(InformationCard_Promoted; "Information Card")
                {
                }
                actionref(LotSpecifications_Promoted; "Lot &Specifications")
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        AllowEdits := not (Rec.Status in [Rec.Status::Pass, Rec.Status::Fail]); // P8000664
        CurrPage.Tests.PAGE.SetAllowEdits(AllowEdits); // P8000664
    end;

    trigger OnAfterGetRecord()
    begin
        Item.Get(Rec."Item No.");
    end;

    trigger OnOpenPage()
    begin
        SampleVisible := Rec.SamplesEnabled(); // P800122712
    end;

    var
        Item: Record Item;
        ItemNoFilter: Code[50];
        SchedDateFilter: Code[50];
        AssignedTofilter: Code[50];
        Text000: Label '%1 is already %2.';
        P800QCFns: Codeunit "Process 800 Q/C Functions";
        [InDataSet]
        AllowEdits: Boolean;
        SampleVisible: Boolean; // P800122712
        StatusSuspendedTxt: Label 'You can only suspend the status. Administrator may complete the Q/C status.';
}
