query 37002403 "Production BOMs-Co/By-Product"
{
    QueryType = Normal;

    elements
    {
        dataitem(ProductionBOMHeader; "Production BOM Header")
        {
            DataItemTableFilter = "Mfg. BOM Type" = const(Process), "Output Type" = const(Family);

            column(BOMNo; "No.")
            {
            }
            column(BOMStatus; Status)
            {
            }
            column(BOMLowLevelCode; "Low-Level Code")
            {
            }
            dataitem(Family; Family)
            {
                DataItemLink = "No." = ProductionBOMHeader."No.";
                DataItemTableFilter = "Process Family" = const(true);

                dataitem(FamilyLine; "Family Line")
                {
                    DataItemLink = "Family No." = Family."No.";
                    DataItemTableFilter = "Item No." = filter(<> '');

                    column(FamilyLineItemNo; "Item No.")
                    {
                    }
                    dataitem(Item; Item)
                    {
                        DataItemLink = "No." = FamilyLine."Item No.";

                        column(ItemLowLevelCode; "Low-Level Code")
                        {
                        }
                    }
                }
            }
        }
    }
}