page 209 "Units of Measure"
{
    // PR1.00
    //    Type, Base per Unit of Measure, and Base Unit
    // 
    // PR3.10
    //   Add UOM captions
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.01
    // P8000678, VerticalSoft, Don Bresee, 23 FEB 09
    //   Add "Genesis Measure" field
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    AdditionalSearchTerms = 'uom';
    ApplicationArea = Basic, Suite;
    Caption = 'Units of Measure';
    PageType = List;
    SourceTable = "Unit of Measure";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    ToolTip = 'Specifies a code for the unit of measure, which you can select on item and resource cards from where it is copied to.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    ToolTip = 'Specifies a description of the unit of measure.';
                }
                field("Qty. Field Caption"; "Qty. Field Caption")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Alt. Qty. Decimal Places"; "Alt. Qty. Decimal Places")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        TypeOnAfterValidate;
                    end;
                }
                field("Base per Unit of Measure"; "Base per Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Base Unit"; "Base Unit")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Base Unit';
                    Editable = false;
                }
                field("International Standard Code"; "International Standard Code")
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    ToolTip = 'Specifies the unit of measure code expressed according to the UNECERec20 standard in connection with electronic sending of sales documents. For example, when sending sales documents through the PEPPOL service, the value in this field is used to populate the UnitCode element in the Product group.';
                }
                field("SAT UofM Classification"; "SAT UofM Classification")
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    ToolTip = 'Specifies the unit of measure required for reporting to the Mexican tax authorities (SAT)';
                }
                field("Coupled to CRM"; "Coupled to CRM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the unit of measure is coupled to a unit group in Dynamics 365 Sales.';
                    Visible = CRMIntegrationEnabled;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Unit")
            {
                Caption = '&Unit';
                Image = UnitOfMeasure;
                action(Translations)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Translations';
                    Image = Translations;
                    RunObject = Page "Unit of Measure Translation";
                    RunPageLink = Code = FIELD(Code);
                    ToolTip = 'View or edit descriptions for each unit of measure in different languages.';
                }
            }
            group(ActionGroupCRM)
            {
                Caption = 'Dynamics 365 Sales';
                Image = Administration;
                Visible = CRMIntegrationEnabled;
                action(CRMGotoUnitsOfMeasure)
                {
                    ApplicationArea = Suite;
                    Caption = 'Unit of Measure';
                    Image = CoupledUnitOfMeasure;
                    ToolTip = 'Open the coupled Dynamics 365 Sales unit of measure.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowCRMEntityFromRecordID(RecordId);
                    end;
                }
                action(CRMSynchronizeNow)
                {
                    AccessByPermission = TableData "CRM Integration Record" = IM;
                    ApplicationArea = Suite;
                    Caption = 'Synchronize';
                    Image = Refresh;
                    ToolTip = 'Send updated data to Dynamics 365 Sales.';

                    trigger OnAction()
                    var
                        UnitOfMeasure: Record "Unit of Measure";
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        UnitOfMeasureRecordRef: RecordRef;
                    begin
                        CurrPage.SetSelectionFilter(UnitOfMeasure);
                        UnitOfMeasure.Next;

                        if UnitOfMeasure.Count = 1 then
                            CRMIntegrationManagement.UpdateOneNow(UnitOfMeasure.RecordId)
                        else begin
                            UnitOfMeasureRecordRef.GetTable(UnitOfMeasure);
                            CRMIntegrationManagement.UpdateMultipleNow(UnitOfMeasureRecordRef);
                        end
                    end;
                }
                group(Coupling)
                {
                    Caption = 'Coupling', Comment = 'Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Business Central record and a Dynamics 365 Sales record.';
                    action(ManageCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Image = LinkAccount;
                        ToolTip = 'Create or modify the coupling to a Dynamics 365 Sales Unit of Measure.';

                        trigger OnAction()
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(RecordId);
                        end;
                    }
                    action(MatchBasedCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Match-Based Coupling';
                        Image = CoupledUnitOfMeasure;
                        ToolTip = 'Couple units of measure to unit groups in Dynamics 365 Sales based on criteria.';

                        trigger OnAction()
                        var
                            UnitOfMeasure: Record "Unit of Measure";
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                            RecRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(UnitOfMeasure);
                            RecRef.GetTable(UnitOfMeasure);
                            CRMIntegrationManagement.MatchBasedCoupling(RecRef);
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = D;
                        ApplicationArea = Suite;
                        Caption = 'Delete Coupling';
                        Enabled = CRMIsCoupledToRecord;
                        Image = UnLinkAccount;
                        ToolTip = 'Delete the coupling to a Dynamics 365 Sales Unit of Measure.';

                        trigger OnAction()
                        var
                            UnitofMeasure: Record "Unit of Measure";
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                            RecRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(UnitofMeasure);
                            RecRef.GetTable(UnitofMeasure);
                            CRMCouplingManagement.RemoveCoupling(RecRef);
                        end;
                    }
                }
                action(ShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization jobs for the unit of measure table.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowLog(RecordId);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
    begin
        CRMIsCoupledToRecord := CRMIntegrationEnabled;
        if CRMIsCoupledToRecord then
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(RecordId);
    end;

    trigger OnAfterGetRecord()
    begin
        // PR1.00 Begin
        if Type <> 0 then
            "Base Unit" := BaseUnits[Type]
        else
            Clear("Base Unit");
        // PR1.00 End
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear("Base Unit"); // PR1.00
    end;

    trigger OnOpenPage()
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        InvSetup: Record "Inventory Setup";
        MeasuringSystem: Record "Measuring System";
        i: Integer;
    begin
        // PR1.00 Begin
        InvSetup.Get;
        for i := 1 to 3 do begin
            MeasuringSystem.Get(InvSetup."Measuring System", i);
            BaseUnits[i] := MeasuringSystem.Description;
        end;
        // PR1.00 End
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled() and not CRMIntegrationManagement.IsUnitGroupMappingEnabled();
    end;

    var
        "Base Unit": Text[50];
        BaseUnits: array[3] of Text[50];
        CRMIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;

    local procedure TypeOnAfterValidate()
    begin
        // PR1.00 Begin
        if Type <> 0 then
            "Base Unit" := BaseUnits[Type]
        else
            Clear("Base Unit");
        // PR1.00 End
    end;
}

