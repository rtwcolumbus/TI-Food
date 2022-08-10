query 37002401 "Production BOMs-Variant/Item"
{
    QueryType = Normal;

    elements
    {
        dataitem(ItemVariant; "Item Variant")
        {

            DataItemTableFilter = "Production BOM No." = filter(<> '');

            column(VariantItemNo; "Item No.")
            {
            }
            column(VariantCode; Code)
            {
            }
            column(VariantProductionBOMNo; "Production BOM No.")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = ItemVariant."Item No.";

                column(ItemLowLevelCode; "Low-Level Code")
                {
                }
                dataitem(ProductionBOMHeader; "Production BOM Header")
                {
                    DataItemLink = "No." = ItemVariant."Production BOM No.";

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