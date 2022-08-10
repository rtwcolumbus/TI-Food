enum 27 "Item Type"
{
    #region
    // PRW117.3
    // P80096165, To Increase, Jack Reynolds, 16 FEB 21
    //   Upgrade to 17 - options to enums
    #endregion

    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Inventory") { Caption = 'Inventory'; }
    value(4; FOODContainer) { Caption = 'Container'; } // P80096165
    value(1; "Service") { Caption = 'Service'; }
    value(2; "Non-Inventory") { Caption = 'Non-Inventory'; }
}