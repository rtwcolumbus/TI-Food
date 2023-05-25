enum 99000772 "Production BOM Line Type"
{
    #region
    // PRW117.3
    // P80096165, To Increase, Jack Reynolds, 16 FEB 21
    //   Upgrade to 17 - options to enums
    #endregion

    Extensible = true;
    AssignmentCompatibility = true;

    value(0; " ") { }
    value(1; "Item") { Caption = 'Item'; }
    value(7; FOODUnapprovedItem) { Caption = 'Unapproved Item'; } // P80096165
    value(2; "Production BOM") { Caption = 'Production BOM'; }
    value(8; FOODVariable) { Caption = 'Variable'; } // P80096165
}