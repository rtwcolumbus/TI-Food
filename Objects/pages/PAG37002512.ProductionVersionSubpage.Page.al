page 37002512 "Production Version Subpage"
{
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00.03
    // P80080907, To-Increase, Gangabhushan, 22 AUG 19
    //   CS00073596 - Users are unable to create new versions IN Package BOM

    Caption = 'Production Version Subpage';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Production BOM Version";

    layout
    {
        area(content)
        {
            repeater(Control37002006)
            {
                ShowCaption = false;
                field("Version Code"; "Version Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = IsActive;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Style = Attention;
                    StyleExpr = IsActive;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Style = Attention;
                    StyleExpr = IsActive;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Style = Attention;
                    StyleExpr = IsActive;
                    Visible = HideFormulaFields;
                }
                field("Primary UOM"; "Primary UOM")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Style = Attention;
                    StyleExpr = IsActive;
                    Visible = ShowFormulaFields;
                }
                field("Weight UOM"; "Weight UOM")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Style = Attention;
                    StyleExpr = IsActive;
                    Visible = ShowFormulaFields;
                }
                field("Volume UOM"; "Volume UOM")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Style = Attention;
                    StyleExpr = IsActive;
                    Visible = ShowFormulaFields;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = IsActive;

                    trigger OnValidate()
                    begin
                        SetEditable;
                        CurrPage.Update;
                    end;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = IsActive;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(New)
            {
                ApplicationArea = FOODBasic;
                Caption = 'New Version';
                Image = NewDocument;

                trigger OnAction()
                var
                    BOMHeader: Record "Production BOM Header";
                    BOMVersion: Record "Production BOM Version";
                    VersionCode: Code[10];
                    NewVersion: Page "New Version";
                    ProdBomFilter: Text[25];
                    Strvalue: Label '''';
                begin
                    FilterGroup(4);
                    // P80080907
                    ProdBomFilter := DelChr(GetFilter("Production BOM No."), '=', Strvalue);
                    BOMHeader.Get(ProdBomFilter);
                    // P80080907
                    FilterGroup(0);
                    if BOMHeader."Auto Version Numbering" then
                        VersionCode := BOMHeader.GetNextVersion
                    else begin
                        if (NewVersion.RunModal <> ACTION::Yes) then
                            exit;
                        VersionCode := NewVersion.ReturnVersionNo;
                    end;

                    BOMVersion.Validate("Production BOM No.", BOMHeader."No.");
                    BOMVersion.Validate("Version Code", VersionCode);
                    BOMVersion.Validate(Type, BOMHeader."Mfg. BOM Type");
                    BOMVersion.Insert(true);

                    EditVersion(BOMVersion);
                end;
            }
            action(Edit)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Edit Version';
                Image = Edit;
                ShortCutKey = 'Shift+F7';

                trigger OnAction()
                begin
                    EditVersion(Rec);
                end;
            }
            action(Delete)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Delete Version';
                Image = Delete;
                ShortCutKey = 'Ctrl+D';

                trigger OnAction()
                begin
                    if Confirm(Text000, false) then
                        Delete(true);
                end;
            }
            separator(Separator37002000)
            {
            }
            action(Print)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print';
                Ellipsis = true;
                Image = Print;

                trigger OnAction()
                begin
                    PrintVersion(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsActive := ("Version Code" = VersionMgt.GetBOMVersion("Production BOM No.", WorkDate, true));
        SetEditable;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        VersionEditable := true;
    end;

    trigger OnOpenPage()
    begin
        HideFormulaFields := not ShowFormulaFields;
    end;

    var
        [InDataSet]
        IsActive: Boolean;
        VersionMgt: Codeunit VersionManagement;
        [InDataSet]
        VersionEditable: Boolean;
        Text000: Label 'Delete Version?';
        [InDataSet]
        ShowFormulaFields: Boolean;
        [InDataSet]
        HideFormulaFields: Boolean;

    procedure SetFormulaMode()
    begin
        ShowFormulaFields := true;
    end;

    procedure SetEditable()
    begin
        VersionEditable := not (Status in [Status::Certified, Status::Closed]);
    end;

    local procedure EditVersion(var BOMVersion: Record "Production BOM Version")
    var
        BOMHeader: Record "Production BOM Header";
        FormulaVersion: Page "Production Formula Version";
        ItemProcessVersion: Page "Item Process Version";
        PackageBOMVersion: Page "Package BOM Version";
        CoProductProcessVersion: Page "Co-Product Process Version";
    begin
        BOMHeader.Get(BOMVersion."Production BOM No.");
        case BOMHeader."Mfg. BOM Type" of
            BOMHeader."Mfg. BOM Type"::Formula:
                begin
                    FormulaVersion.SetTableView(BOMVersion);
                    FormulaVersion.SetRecord(BOMVersion);
                    FormulaVersion.Run;
                end;
            BOMHeader."Mfg. BOM Type"::Process:
                case BOMHeader."Output Type" of
                    BOMHeader."Output Type"::Item:
                        begin
                            ItemProcessVersion.SetTableView(BOMVersion);
                            ItemProcessVersion.SetRecord(BOMVersion);
                            ItemProcessVersion.Run;
                        end;
                    BOMHeader."Output Type"::Family:
                        begin
                            CoProductProcessVersion.SetTableView(BOMVersion);
                            CoProductProcessVersion.SetRecord(BOMVersion);
                            CoProductProcessVersion.Run;
                        end;
                end;
            BOMHeader."Mfg. BOM Type"::BOM:
                begin
                    PackageBOMVersion.SetTableView(BOMVersion);
                    PackageBOMVersion.SetRecord(BOMVersion);
                    PackageBOMVersion.Run;
                end;
        end;
    end;

    procedure PrintVersion(BOMVersion: Record "Production BOM Version")
    var
        BOMHeader: Record "Production BOM Header";
    begin
        BOMHeader.Get(BOMVersion."Production BOM No.");
        BOMVersion.SetRecFilter;
        case BOMHeader."Mfg. BOM Type" of
            BOMHeader."Mfg. BOM Type"::Formula:
                REPORT.Run(REPORT::"Formula Version Details", true, false, BOMVersion);
            BOMHeader."Mfg. BOM Type"::Process:
                REPORT.Run(REPORT::"Process Version Details", true, false, BOMVersion);
            BOMHeader."Mfg. BOM Type"::BOM:
                REPORT.Run(REPORT::"Packaging BOM Version Details", true, false, BOMVersion);
        end;
    end;
}

