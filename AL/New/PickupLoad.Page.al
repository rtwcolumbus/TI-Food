page 37002075 "Pickup Load"
{
    // PR3.70.06
    // P8000080A, Myers Nissi, Steve Post, 30 AUG 04
    //   For Pickup Load Planning
    // 
    // PR3.70.08
    // P8000182A, Myers Nissi, Jack Reynolds, 14 FEB 05
    //   Rather than setting entire form editable property, call function to set property on individual controls
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Add controls for Location Code and Delivery Trip No.
    // 
    // P8000761, VerticalSoft, Maria Maslennikova, 28 JAN 10
    //   TabControl General added
    //   DeliveryTripNoEditable added to "Editable" property
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW110.0.02
    // P80038979, To-Increase, Dayakar Battini, 18 DEC 17
    //   Adding Pickup load management functionality

    Caption = 'Pickup Load';
    PageType = Document;
    SourceTable = "Pickup Load Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "No.Editable";

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit then
                            CurrPage.Update;
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Trip No."; "Delivery Trip No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Carrier; Carrier)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Pickup Date"; "Pickup Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Pickup DateEditable";
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Due DateEditable";
                }
                field("Due Time"; "Due Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Due TimeEditable";
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
            }
            part(LoadSub; "Pickup Load Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Pickup Load No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Print)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Load: Record "Pickup Load Header";
                begin
                    TestField(Status, Status::Open);

                    Load.SetRange("No.", "No.");
                    REPORT.Run(REPORT::"Pickup Load Sheet", true, true, Load);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        SetEditable(Status = Status::Open); // P8000182A
    end;

    trigger OnInit()
    begin
        LoadSubEditable := true;
        TemperatureEditable := true;
        "Due TimeEditable" := true;
        "Due DateEditable" := true;
        "Pickup DateEditable" := true;
        "Freight ChargeEditable" := true;
        CarrierEditable := true;
        "Truck TypeEditable" := true;
        "No.Editable" := true;
        //DeliveryTripNoEditable := FALSE; //P8000761  // P80038979
    end;

    var
        [InDataSet]
        "No.Editable": Boolean;
        [InDataSet]
        "Truck TypeEditable": Boolean;
        [InDataSet]
        CarrierEditable: Boolean;
        [InDataSet]
        "Freight ChargeEditable": Boolean;
        [InDataSet]
        "Pickup DateEditable": Boolean;
        [InDataSet]
        "Due DateEditable": Boolean;
        [InDataSet]
        "Due TimeEditable": Boolean;
        [InDataSet]
        TemperatureEditable: Boolean;
        [InDataSet]
        LoadSubEditable: Boolean;
        [InDataSet]
        DeliveryTripNoEditable: Boolean;

    procedure SetEditable(Editable: Boolean)
    begin
        // P8000182A
        "No.Editable" := Editable;
        "Truck TypeEditable" := Editable;
        CarrierEditable := Editable and ("Delivery Trip No." = '');  // P80038979
        "Freight ChargeEditable" := Editable;
        "Pickup DateEditable" := Editable;
        "Due DateEditable" := Editable;
        "Due TimeEditable" := Editable;
        TemperatureEditable := Editable;
        LoadSubEditable := Editable;
    end;
}

