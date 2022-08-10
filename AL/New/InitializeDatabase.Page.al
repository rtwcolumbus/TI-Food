page 14014900 "Initialize Database"
{
    // PRW17.00.01
    // P8001199, Columbus IT, Jack Reynolds, 23 AUG 13
    //   Modify to initialize company specific data for existing companies
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // P80094323, To Increase, Jack Reynolds, 18 FEB 20
    //     Support for web client

    ApplicationArea = FOODBasic;
    Caption = 'Initialize Database';
    ObsoleteReason = 'Replaced by PermissionSet objects and Install codeunits';
    ObsoleteState = Pending;
    ObsoleteTag = '18.0';
    PageType = Card;
    UsageCategory = Tasks;

    trigger OnOpenPage()
    var
        NotUsed: Label 'This page is no longer used.\\It''s function has been replaced by "PermissionSet" objects and "Install" codeunits.';
    begin
        Message(NotUsed);
    end;
}

