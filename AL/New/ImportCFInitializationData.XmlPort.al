xmlport 14014900 "Import CF Initialization Data"
{
    // PRW16.00.03
    // P8000833, VerticalSoft, Jack Reynolds, 11 JUN 10
    //   XMLport to import VerticalSoft Initialization Data
    // 
    // PRW16.00.05
    // P8000995, Columbus IT, Jack Reynolds, 07 NOV 11
    //   Renamed from "Import VS Initialization Data"
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10
    // P8001216, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Remove support for Key Groups
    // 
    // P8001217, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Remove Company from Chart table
    // 
    // PRW110.0.02
    // P80046447, To Increase, Jack Reynolds, 15 SEP 17
    //   Update Client Add-ins
    //
	//   PRW114.00.03
	//   P80094323, To Increase, Jack Reynolds, 18 FEB 20
	//     Fix order of Add-in fields

    Caption = 'Import CF Initialization Data';
    Direction = Import;
    ObsoleteReason = 'Replaced by PermissionSet objects and Install codeunits';
    ObsoleteState = Pending;
    ObsoleteTag = '18.0';

    schema
    {
        textelement(NAVFood)
        {
            textelement(MeasuringSystem)
            {
                tableelement("<measuring system>"; "Measuring System")
                {
                    XmlName = 'Unit';
                    UseTemporary = true;
                    fieldattribute(System; "<Measuring System>"."Measuring System")
                    {
                    }
                    fieldattribute(Type; "<Measuring System>".Type)
                    {
                    }
                    fieldelement(UnitOfMeasure; "<Measuring System>".UOM)
                    {
                    }
                    fieldelement(Description; "<Measuring System>".Description)
                    {
                    }
                    fieldelement(Conversion; "<Measuring System>"."Conversion to Other")
                    {
                    }

                    trigger OnAfterInsertRecord()
                    var
                        MeasuringSystem: Record "Measuring System";
                    begin
                        MeasuringSystem := "<Measuring System>";
                        if not MeasuringSystem.Insert then
                            MeasuringSystem.Modify;
                    end;
                }
            }
            textelement(Profiles)
            {
                tableelement("<profile>"; Profile)
                {
                    XmlName = 'Profile';
                    SourceTableView = WHERE("Role Center ID" = FILTER(37002000 .. 37002999));
                    UseTemporary = true;
                    fieldattribute(ID; "<Profile>"."Profile ID")
                    {
                    }
                    fieldelement(Description; "<Profile>".Description)
                    {
                    }
                    fieldelement(RoleCenterID; "<Profile>"."Role Center ID")
                    {
                    }

                    trigger OnAfterInsertRecord()
                    var
                        "Profile": Record "Profile";
                    begin
                        Profile := "<Profile>";
                        if not Profile.Insert then
                            Profile.Modify;
                    end;
                }
            }
            textelement(Charts)
            {
                tableelement("<chart>"; Chart)
                {
                    XmlName = 'Chart';
                    SourceTableView = WHERE(ID = FILTER('37002???-??'));
                    UseTemporary = true;
                    fieldattribute(ID; "<Chart>".ID)
                    {
                    }
                    fieldelement(Name; "<Chart>".Name)
                    {
                    }
                    textelement(chartdefinition)
                    {
                        TextType = BigText;
                        XmlName = 'Definition';

                        trigger OnAfterAssignVariable()
                        var
                            OutStr: OutStream;
                        begin
                            if ChartDefinition.Length <> 0 then begin
                                ChartDefinition.GetSubText(ChartDefinition, 11);
                                ChartDefinition.GetSubText(ChartDefinition, 1, ChartDefinition.Length - 4);
                                "<Chart>".BLOB.CreateOutStream(OutStr);
                                ChartDefinition.Write(OutStr);
                            end;
                        end;
                    }

                    trigger OnAfterInsertRecord()
                    var
                        Chart: Record Chart;
                    begin
                        Chart := "<Chart>";
                        if not Chart.Insert then
                            Chart.Modify;
                    end;
                }
            }
            textelement(ClientAddIns)
            {
                tableelement("<client add-in>"; "Add-in")
                {
                    XmlName = 'AddIn';
                    UseTemporary = true;
                    fieldattribute(Name; "<Client Add-in>"."Add-in Name")
                    {
                    }
                    fieldattribute(PublicKeyToken; "<Client Add-in>"."Public Key Token")
                    {
                    }
                    fieldelement(Category; "<Client Add-in>".Category)
                    {
                    }
                    fieldelement(Description; "<Client Add-in>".Description)
                    {
                    }

                    trigger OnAfterInsertRecord()
                    var
                        ClientAddIn: Record "Add-in";
                    begin
                        ClientAddIn := "<Client Add-in>";
                        if not ClientAddIn.Insert then
                            ClientAddIn.Modify;
                    end;
                }
            }
            textelement(UserRoles)
            {
                tableelement("<user role>"; "Permission Set")
                {
                    XmlName = 'Role';
                    UseTemporary = true;
                    fieldattribute(ID; "<User Role>"."Role ID")
                    {
                    }
                    fieldelement(Name; "<User Role>".Name)
                    {
                    }
                    textelement(Tables)
                    {
                        tableelement("<permission>"; Permission)
                        {
                            LinkFields = "Role ID" = FIELD("Role ID");
                            LinkTable = "<User Role>";
                            XmlName = 'Table';
                            SourceTableView = SORTING("Role ID", "Object Type", "Object ID") WHERE("Object Type" = CONST("Table Data"));
                            UseTemporary = true;
                            fieldattribute(ID; "<Permission>"."Object ID")
                            {
                            }
                            fieldelement(Read; "<Permission>"."Read Permission")
                            {
                            }
                            fieldelement(Insert; "<Permission>"."Insert Permission")
                            {
                            }
                            fieldelement(Modify; "<Permission>"."Modify Permission")
                            {
                            }
                            fieldelement(Delete; "<Permission>"."Delete Permission")
                            {
                            }
                            fieldelement(Execute; "<Permission>"."Execute Permission")
                            {
                            }

                            trigger OnAfterInsertRecord()
                            var
                                Permission: Record Permission;
                            begin
                                Permission := "<Permission>";
                                if not Permission.Insert then
                                    Permission.Modify;
                            end;
                        }
                    }

                    trigger OnAfterInsertRecord()
                    var
                        UserRole: Record "Permission Set";
                    begin
                        UserRole := "<User Role>";
                        if not UserRole.Insert then
                            UserRole.Modify;
                    end;
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }
}

