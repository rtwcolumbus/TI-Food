table 37002052 "Cust./Item Price/Disc. Group"
{
    // PR5.00
    // P8000545A, VerticalSoft, Don Bresee, 13 NOV 07
    //   New table for price and disc. group associations for customers and item categories/product groups
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Cust./Item Price/Disc. Group';

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(2; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            NotBlank = true;
            TableRelation = "Item Category";
        }
        field(4; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            TableRelation = "Customer Price Group";
        }
        field(5; "Customer Disc. Group"; Code[10])
        {
            Caption = 'Customer Disc. Group';
            TableRelation = "Customer Discount Group";
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Item Category Code")
        {
        }
        key(Key2; "Item Category Code")
        {
        }
    }

    fieldgroups
    {
    }
}

