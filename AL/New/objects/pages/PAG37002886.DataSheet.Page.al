page 37002886 "Data Sheet"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management; Cleanup action names
    // 
    // PRW118.1
    // P800130766, To-Increase, Jack Reynolds, 28 SEP 21
    //   Don't allow status change if already Complete

    Caption = 'Data Sheet';
    PageType = Document;
    SourceTable = "Data Sheet Header";
    SourceTableView = WHERE(Type = FILTER(<> Production));

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                    OptionCaption = ',,Shipping,Receiving,Production,Log';
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                group(Control37002016)
                {
                    ShowCaption = false;
                    field("Reference Type"; "Reference Type")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Reference ID"; "Reference ID")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                group(Control37002017)
                {
                    ShowCaption = false;
                    field("Document Date"; "Document Date")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Document No."; "Document No.")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                group(Control37002015)
                {
                    ShowCaption = false;
                    field("Start Date"; "Start Date")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("Start Time"; "Start Time")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("End Date"; "End Date")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                    field("End Time"; "End Time")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                    }
                }
            }
            part(Lines; "Data Sheet Lines")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                Editable = EditLines;
                SubPageLink = "Data Sheet No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            part("Line Detail"; "Data Sheet Detail")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Line Detail';
                Provider = Lines;
                SubPageLink = "Data Sheet No." = FIELD("Data Sheet No."),
                              "Prod. Order Line No." = FIELD("Prod. Order Line No."),
                              "Data Element Code" = FIELD("Data Element Code"),
                              "Line No." = FIELD("Line No."),
                              "Instance No." = FIELD("Instance No.");
            }
            systempart(Control37002019; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002020; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Alerts)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Alerts';
                Image = Alerts;
                RunObject = Page "Data Collection Alerts";
                RunPageLink = "Data Sheet No." = FIELD("No.");
                RunPageView = SORTING("Data Sheet No.", "Prod. Order Line No.", "Data Element Code", "Line No.", "Source ID", "Source Key 1", "Source Key 2", "Instance No.");
            }
            action(Print)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print';
                Enabled = PrintEnabled;
                Image = Print;

                trigger OnAction()
                begin
                    PrintDataSheet;
                end;
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Change Status")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Change Status';
                    Ellipsis = true;
                    Image = ChangeStatus;
                    Visible = Rec.Status <> Rec.Status::Complete;

                    trigger OnAction()
                    var
                        DataCollectionMgmt: Codeunit "Data Collection Management";
                    begin
                        DataCollectionMgmt.DataSheetStatusChange(Rec);
                        CurrPage.SaveRecord;
                        EditLines := Status = Status::"In Progress";
                        PrintEnabled := Status = Status::Complete;
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(ChangeStatus_Promoted; "Change Status")
            {
            }
            actionref(Alerts_Promoted; Alerts)
            {
            }
            actionref(Print_Promoted; Print)
            {
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EditLines := Status = Status::"In Progress";
        PrintEnabled := Status = Status::Complete;
    end;

    var
        [InDataSet]
        EditLines: Boolean;
        [InDataSet]
        PrintEnabled: Boolean;
}

