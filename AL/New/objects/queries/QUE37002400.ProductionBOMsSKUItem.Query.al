query 37002400 "Production BOMs-SKU/Item"
{
    QueryType = Normal;

    elements
    {
        dataitem(SKU; "Stockkeeping Unit")
        {

            DataItemTableFilter = "Production BOM No." = filter(<> '');

            column(SKUItemNo; "Item No.")
            {
            }
            column(SKUVariantCode; "Variant Code")
            {
            }
            column(SKULocationCode; "Location Code")
            {
            }
            column(SKUProductionBOMNo; "Production BOM No.")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = SKU."Item No.";

                column(ItemLowLevelCode; "Low-Level Code")
                {
                }
                dataitem(ProductionBOMHeader; "Production BOM Header")
                {
                    DataItemLink = "No." = SKU."Production BOM No.";

                    column(BOMStatus; Status)
                    {
                    }
                    column(BOMLowLevelCode; "Low-Level Code")
                    {
                    }
                }
            }
        }
    }
}