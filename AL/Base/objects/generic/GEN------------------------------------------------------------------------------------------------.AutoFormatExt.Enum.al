// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

// PRW118.01
// P800128960, To Increase, Jack Reynolds, 24 AUG 21
//   Decimal precision on alternate quantity data entry

enumextension 60 "Auto Format Ext" extends "Auto Format"
{
    value(1; AmountFormat) { }
    value(2; UnitAmountFormat) { }
    value(10; CurrencySymbolFormat) { }
    value(37002000; FoodFormat) { } // P800-MegaApp
    value(37002080; FoodAltQty) { } // P800128960
}