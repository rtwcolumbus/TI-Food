permissionset 9221 "Customer - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Edit customers';

    IncludedPermissionSets = "Language - Read",
                             "FOOD Customer-Edit";

    Permissions = tabledata "Additional Fee Setup" = R,
                  tabledata "API Entities Setup" = RIMD,
                  tabledata "Bank Account Ledger Entry" = rm,
                  tabledata Bin = R,
                  tabledata "Check Ledger Entry" = r,
                  tabledata "Comment Line" = RIMD,
                  tabledata "Config. Template Header" = R,
                  tabledata "Config. Template Line" = R,
                  tabledata "Config. Tmpl. Selection Rules" = RIMD,
                  tabledata "Cont. Duplicate Search String" = RIMD,
                  tabledata Contact = RIM,
                  tabledata "Contact Business Relation" = ImD,
                  tabledata "Contact Duplicate" = R,
                  tabledata "Contact Profile Answer" = R,
                  tabledata "Contract Gain/Loss Entry" = rm,
                  tabledata "Country/Region" = R,
                  tabledata Currency = R,
                  tabledata "Currency Exchange Rate" = R,
                  tabledata "Cust. Invoice Disc." = R,
                  tabledata "Cust. Ledger Entry" = Rm,
                  tabledata Customer = RIMD,
                  tabledata "Customer Bank Account" = RIMD,
                  tabledata "Customer Discount Group" = RIMD,
                  tabledata "Customer Posting Group" = R,
                  tabledata "Customer Price Group" = R,
                  tabledata "Customer Templ." = rm,
#if not CLEAN19
                  tabledata "Customer Template" = r,
#endif
                  tabledata "Default Dimension" = RIMD,
                  tabledata "Detailed Cust. Ledg. Entry" = Rim,
                  tabledata "Dtld. Price Calculation Setup" = Rid,
                  tabledata "Duplicate Price Line" = Rid,
                  tabledata "Duplicate Search String Setup" = R,
                  tabledata "Employee Ledger Entry" = r,
                  tabledata "FA Ledger Entry" = rm,
                  tabledata "Filed Contract Line" = rm,
                  tabledata "Filed Service Contract Header" = rm,
                  tabledata "Finance Charge Terms" = R,
                  tabledata "Finance Charge Text" = R,
                  tabledata "G/L Entry - VAT Entry Link" = rm,
                  tabledata "G/L Entry" = rm,
                  tabledata "Gen. Business Posting Group" = R,
                  tabledata "Gen. Journal Batch" = r,
                  tabledata "Gen. Journal Line" = r,
                  tabledata "Gen. Journal Template" = r,
                  tabledata "IC Partner" = Rm,
                  tabledata "Interaction Log Entry" = R,
                  tabledata "Item Analysis View Budg. Entry" = r,
                  tabledata "Item Analysis View Entry" = rid,
                  tabledata "Item Budget Entry" = r,
#if not CLEAN19
                  tabledata "Item Cross Reference" = RIMD,
#endif
                  tabledata "Item Journal Line" = r,
                  tabledata "Item Ledger Entry" = rm,
                  tabledata "Item Reference" = RIMD,
                  tabledata Job = rm,
                  tabledata "Line Fee Note on Report Hist." = R,
                  tabledata Location = R,
                  tabledata "Maintenance Ledger Entry" = rm,
                  tabledata "My Customer" = RIMD,
#if not CLEAN20
                  tabledata "Native - Payment" = r,
#endif
                  tabledata Opportunity = R,
                  tabledata "Payment Method" = R,
                  tabledata "Payment Terms" = R,
                  tabledata "Price Asset" = Rid,
                  tabledata "Price Calculation Buffer" = Rid,
                  tabledata "Price Calculation Setup" = Rid,
                  tabledata "Price Line Filters" = Rid,
                  tabledata "Price List Header" = Rid,
                  tabledata "Price List Line" = Rid,
                  tabledata "Price Source" = Rid,
                  tabledata "Price Worksheet Line" = Rid,
                  tabledata "Profile Questionnaire Line" = R,
                  tabledata "Purch. Cr. Memo Hdr." = rm,
                  tabledata "Purch. Cr. Memo Line" = rm,
                  tabledata "Purch. Inv. Header" = rm,
                  tabledata "Purch. Rcpt. Header" = rm,
                  tabledata "Purchase Header" = rm,
                  tabledata "Purchase Header Archive" = r,
                  tabledata "Registered Whse. Activity Line" = rm,
                  tabledata "Reminder Level" = R,
                  tabledata "Reminder Terms" = R,
                  tabledata "Reminder Terms Translation" = R,
                  tabledata "Reminder Text" = R,
                  tabledata "Reminder/Fin. Charge Entry" = R,
                  tabledata "Res. Journal Line" = r,
                  tabledata "Res. Ledger Entry" = rm,
                  tabledata "Responsibility Center" = R,
                  tabledata "Return Receipt Header" = rm,
                  tabledata "Return Receipt Line" = rm,
                  tabledata "Return Shipment Header" = rm,
                  tabledata "Return Shipment Line" = rm,
                  tabledata "Sales Cr.Memo Header" = rm,
                  tabledata "Sales Cr.Memo Line" = rm,
                  tabledata "Sales Discount Access" = Rd,
                  tabledata "Sales Header" = rm,
                  tabledata "Sales Header Archive" = rm,
                  tabledata "Sales Invoice Header" = rm,
                  tabledata "Sales Invoice Line" = rm,
                  tabledata "Sales Line" = Rm,
#if not CLEAN21
                  tabledata "Sales Line Discount" = Rd,
                  tabledata "Sales Price" = Rid,
#endif
                  tabledata "Sales Price Access" = Rid,
                  tabledata "Sales Shipment Header" = rm,
                  tabledata "Sales Shipment Line" = rm,
                  tabledata "Salesperson/Purchaser" = R,
                  tabledata "Service Contract Header" = Rm,
                  tabledata "Service Contract Line" = Rm,
                  tabledata "Service Header" = r,
                  tabledata "Service Invoice Line" = Rm,
                  tabledata "Service Item" = Rm,
                  tabledata "Service Item Line" = Rm,
                  tabledata "Service Ledger Entry" = rm,
                  tabledata "Service Line" = r,
                  tabledata "Service Zone" = R,
                  tabledata "Ship-to Address" = RIMD,
                  tabledata "Shipment Method" = R,
                  tabledata "Shipping Agent" = R,
                  tabledata "Shipping Agent Services" = R,
                  tabledata "Sorting Table" = R,
                  tabledata "Standard Customer Sales Code" = RiD,
                  tabledata "Standard General Journal" = rm,
                  tabledata "Standard General Journal Line" = rm,
                  tabledata "Tax Area" = R,
                  tabledata Territory = R,
                  tabledata "To-do" = R,
                  tabledata "Value Entry" = rm,
                  tabledata "VAT Business Posting Group" = R,
                  tabledata "VAT Entry" = rm,
                  tabledata "VAT Reg. No. Srv Config" = rd,
                  tabledata "VAT Reg. No. Srv. Template" = RIMD,
                  tabledata "VAT Registration Log" = rd,
                  tabledata "VAT Registration Log Details" = RIMD,
                  tabledata "VAT Registration No. Format" = R,
                  tabledata "Vendor Ledger Entry" = r,
                  tabledata "Warehouse Activity Header" = rm,
                  tabledata "Warehouse Activity Line" = rm,
                  tabledata "Warehouse Request" = rm,
                  tabledata "Warehouse Shipment Line" = rm,
                  tabledata "Warranty Ledger Entry" = rm,
                  tabledata "Whse. Worksheet Line" = r;
}
