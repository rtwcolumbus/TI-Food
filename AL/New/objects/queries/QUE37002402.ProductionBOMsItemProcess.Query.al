query 37002402 "Production BOMs-Item Process"
{
    QueryType = Normal;

    elements
    {
        dataitem(ProductionBOMHeader; "Production BOM Header")
        {
            DataItemTableFilter = "Mfg. BOM Type" = const(Process), "Output Type" = const(Item);

            column(BOMNo; "No.")
            {
            }
            column(BOMOutputItemNo; "Output Item No.")
            {
            }
            column(BOMStatus; Status)
            {
            }
            column(BOMLowLevelCode; "Low-Level Code")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = ProductionBOMHeader."Output Item No.";

                column(ItemLowLevelCode; "Low-Level Code")
                {
                }
            }
        }
    }
}