page 37002160 "Supply Chain Groups"
{
    // PRW16.00.05
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Supply Chain Groups';
    PageType = List;
    Permissions = TableData "Supply Chain Group User" = rimd;
    SourceTable = "Supply Chain Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(MyGroup; MyGroup)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Include';

                    trigger OnValidate()
                    begin
                        SupplyChainGroupUser."User ID" := UserId;
                        SupplyChainGroupUser."Supply Chain Group Code" := Code;
                        if MyGroup then
                            SupplyChainGroupUser.Insert
                        else
                            SupplyChainGroupUser.Delete;
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002005; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002006; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Users)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Users';
                Image = Users;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Supply Chain Group Users";
                RunPageLink = "Supply Chain Group Code" = FIELD(Code);
                RunPageView = SORTING("Supply Chain Group Code");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        MyGroup := SupplyChainGroupUser.Get(UserId, Code);
    end;

    var
        SupplyChainGroupUser: Record "Supply Chain Group User";
        [InDataSet]
        MyGroup: Boolean;
}

