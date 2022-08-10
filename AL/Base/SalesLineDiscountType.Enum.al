enum 7021 "Sales Line Discount Type"
{
    #region
    // PRW117.3
    // P80096165, To Increase, Jack Reynolds, 16 FEB 21
    //   Upgrade to 17 - options to enums
    #endregion

    Extensible = true;
    AssignmentCompatibility = true;

    // P80096165
    value(4; FOODAllItems)
    {
        Caption = 'All Items';
    }
    value(0; Item)
    {
        Caption = 'Item';
    }
    // P80096165
    value(1; FOODItemCategory)
    {
        Caption = 'Item Category';
    }
    value(3; "Item Disc. Group")
    {
        Caption = 'Item Discount Group';
    }

}