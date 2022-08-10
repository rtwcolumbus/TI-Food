report 37002463 "Create Quick Planner Worksheet"
{
    // PR1.00.05
    //   Caption changed on request form
    // 
    // PR1.20
    //   Function to report that the report was processed (as opposed to cancelled)
    // 
    // PR2.00.05
    //   Pull in entries for item variants
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // PRW16.00.04
    // P8000875, VerticalSoft, Jack Reynolds, 14 OCT 10
    //   Remove support for Sales Order in Forecast
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues Property in the Request Page.
    // 
    // PRW17.10.02
    // P8001299, Columbus IT, Jack Reynolds, 26 FEB 14
    //   Add limited support for SKUS

    Caption = 'Create Quick Planner Worksheet';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Item Type", "Manufacturing Policy";
            dataitem("Item Variant"; "Item Variant")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", Code);

                trigger OnAfterGetRecord()
                begin
                    // P8001299
                    if (LocationCode <> '') and SKU.Get(LocationCode, Item."No.", Code) then
                        Include := SKU."Replenishment System" = SKU."Replenishment System"::"Prod. Order"
                    else
                        Include := Item."Replenishment System" = Item."Replenishment System"::"Prod. Order";

                    if Include then begin
                        // P8001299
                        // PR2.00.05 Begin
                        QuickPlanner."User ID" := UserId;
                        QuickPlanner."Item No." := "Item No.";
                        QuickPlanner."Variant Code" := Code;
                        QuickPlanner."Item Description" := Description;
                        QuickPlanner."Unit of Measure Code" := Item."Base Unit of Measure";
                        // P880875
                        //QuickPlanner."Safety Stock" := 0;
                        //QuickPlanner."Sales Order in Forecast" := IncludeSOInFcst;
                        // P880875
                        QuickPlanner.Insert;
                        // PR2.00.05 End
                    end; // P8001299
                end;
            }

            trigger OnAfterGetRecord()
            begin
                // P8001299
                Window.Update(1, "No.");

                if (LocationCode <> '') and SKU.Get(LocationCode, "No.", '') then
                    Include := SKU."Replenishment System" = SKU."Replenishment System"::"Prod. Order"
                else
                    Include := "Replenishment System" = "Replenishment System"::"Prod. Order";

                if Include then begin
                    // P8001299
                    QuickPlanner."User ID" := UserId;
                    QuickPlanner."Item No." := "No.";
                    QuickPlanner."Variant Code" := ''; // PR2.00.05
                    QuickPlanner."Item Description" := Description;
                    QuickPlanner."Unit of Measure Code" := "Base Unit of Measure";
                    // P880875
                    //QuickPlanner."Safety Stock" := "Safety Stock Quantity";
                    //QuickPlanner."Sales Order in Forecast" := IncludeSOInFcst;
                    // P880875
                    QuickPlanner.Insert;
                end; // P8001299
            end;

            trigger OnPostDataItem()
            begin
                Window.Close; // P8001299
            end;

            trigger OnPreDataItem()
            begin
                QuickPlanner.SetRange("User ID", UserId);
                QuickPlanner.DeleteAll;

                Window.Open(Text001); // P8001299
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Processed := true; // PR1.20
    end;

    var
        QuickPlanner: Record "Quick Planner Worksheet";
        SKU: Record "Stockkeeping Unit";
        IncludeSOInFcst: Boolean;
        Processed: Boolean;
        LocationCode: Code[10];
        Include: Boolean;
        Window: Dialog;
        Text001: Label 'Selecting Items: #1#############';

    procedure ReportProcessed(): Boolean
    begin
        exit(Processed); // PR1.20
    end;

    procedure SetLocation(LocCode: Code[10])
    begin
        // P8001299
        LocationCode := LocCode;
    end;
}

