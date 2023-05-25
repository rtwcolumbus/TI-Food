report 37002870 "Copy Data Collection Lines"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Copy Data Collection Lines';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(Key1; SourceKey1)
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = '3,' + Key1Caption;
                        Caption = 'Source Key 1';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupKey1;
                        end;

                        trigger OnValidate()
                        begin
                            ValidateKey1;
                        end;
                    }
                    field(Key2; SourceKey2)
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = '3,' + Key2Caption;
                        Caption = 'Source Key 2';
                        Visible = ShowKey2;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupKey2;
                        end;

                        trigger OnValidate()
                        begin
                            ValidateKey2;
                        end;
                    }
                    field(Quality; Quality)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Quality';
                        Enabled = AllowQuality;
                    }
                    field(Shipping; Shipping)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shipping';
                        Enabled = AllowShipping;
                    }
                    field(Receiving; Receiving)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Receiving';
                        Enabled = AllowReceiving;
                    }
                    field(Production; Production)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Production';
                        Enabled = AllowProduction;
                    }
                    field(Log; Log)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Log';
                        Enabled = AllowLog;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = ACTION::OK then begin
                if SourceKey1 = '' then
                    Error(Text001, Key1Caption);
                if (TargetID in [DATABASE::Zone, DATABASE::Bin]) and (SourceKey2 = '') then
                    Error(Text001, Key2Caption);
                if (SourceKey1 = TargetKey1) and (SourceKey2 = TargetKey2) then
                    Error(Text002, EntityDesc);
                exit(true);
            end else
                exit(true);
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        DataCollectionMgmt.CopyLinesToLines(TargetID, TargetKey1, TargetKey2, SourceKey1, SourceKey2,
          Quality, Shipping, Receiving, Production, Log);
    end;

    var
        Location: Record Location;
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        Resource: Record Resource;
        Zone: Record Zone;
        Bin: Record Bin;
        Asset: Record Asset;
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
        DataCollectionMgmt: Codeunit "Data Collection Management";
        TargetID: Integer;
        TargetKey1: Code[20];
        TargetKey2: Code[20];
        EntityDesc: Text[100];
        Key1Caption: Text[100];
        Key2Caption: Text[100];
        SourceKey1: Code[20];
        SourceKey2: Code[20];
        Quality: Boolean;
        Shipping: Boolean;
        Receiving: Boolean;
        Production: Boolean;
        Log: Boolean;
        [InDataSet]
        ShowKey2: Boolean;
        [InDataSet]
        AllowQuality: Boolean;
        [InDataSet]
        AllowShipping: Boolean;
        [InDataSet]
        AllowReceiving: Boolean;
        [InDataSet]
        AllowProduction: Boolean;
        [InDataSet]
        AllowLog: Boolean;
        Text001: Label '%1 must be specified.';
        Text002: Label 'The source %1 must be different than the target %1.';

    procedure SetTarget(ID: Integer; Key1: Code[20]; Key2: Code[20])
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        TargetID := ID;
        TargetKey1 := Key1;
        TargetKey2 := Key2;

        case TargetID of
            DATABASE::Location:
                begin
                    EntityDesc := Location.TableCaption;
                    Key1Caption := StrSubstNo('%1 %2', EntityDesc, Location.FieldCaption(Code));
                end;

            DATABASE::Customer:
                begin
                    EntityDesc := Customer.TableCaption;
                    Key1Caption := StrSubstNo('%1 %2', EntityDesc, Customer.FieldCaption("No."));
                end;

            DATABASE::Vendor:
                begin
                    EntityDesc := Vendor.TableCaption;
                    Key1Caption := StrSubstNo('%1 %2', EntityDesc, Vendor.FieldCaption("No."));
                end;

            DATABASE::Item:
                begin
                    EntityDesc := Item.TableCaption;
                    Key1Caption := StrSubstNo('%1 %2', EntityDesc, Item.FieldCaption("No."));
                end;

            DATABASE::Resource:
                begin
                    EntityDesc := Resource.TableCaption;
                    Key1Caption := StrSubstNo('%1 %2', EntityDesc, Resource.FieldCaption("No."));
                end;

            DATABASE::Zone:
                begin
                    EntityDesc := Zone.TableCaption;
                    Key1Caption := Zone.FieldCaption("Location Code");
                    Key2Caption := StrSubstNo('%1 %2', EntityDesc, Zone.FieldCaption(Code));
                    SourceKey1 := Key1;
                end;

            DATABASE::Bin:
                begin
                    EntityDesc := Bin.TableCaption;
                    Key1Caption := Bin.FieldCaption("Location Code");
                    Key2Caption := StrSubstNo('%1 %2', EntityDesc, Bin.FieldCaption(Code));
                    SourceKey1 := Key1;
                end;

            DATABASE::Asset:
                begin
                    EntityDesc := Asset.TableCaption;
                    Key1Caption := StrSubstNo('%1 %2', EntityDesc, Asset.FieldCaption("No."));
                end;

            DATABASE::"Work Center":
                begin
                    EntityDesc := WorkCenter.TableCaption;
                    Key1Caption := StrSubstNo('%1 %2', EntityDesc, WorkCenter.FieldCaption("No."));
                end;

            DATABASE::"Machine Center":
                begin
                    EntityDesc := MachineCenter.TableCaption;
                    Key1Caption := StrSubstNo('%1 %2', EntityDesc, MachineCenter.FieldCaption("No."));
                end;
        end;

        ShowKey2 := Key2Caption <> '';

        if TargetID = DATABASE::Item then begin
            Item.Get(TargetKey1);
            if Item."Item Tracking Code" <> '' then begin
                ItemTrackingCode.Get(Item."Item Tracking Code");
                AllowQuality := ItemTrackingCode."Lot Specific Tracking";
            end;
        end;
        AllowShipping := TargetID in [DATABASE::Location, DATABASE::Customer, DATABASE::Vendor, DATABASE::Item, DATABASE::Resource];
        AllowReceiving := TargetID in [DATABASE::Location, DATABASE::Customer, DATABASE::Vendor, DATABASE::Item];
        AllowProduction := TargetID in [DATABASE::Location, DATABASE::Item, DATABASE::Resource,
          DATABASE::"Work Center", DATABASE::"Machine Center"];
        AllowLog := TargetID in [DATABASE::Location, DATABASE::Resource, DATABASE::Zone, DATABASE::Bin, DATABASE::Asset];

        Quality := AllowQuality;
        Shipping := AllowShipping;
        Receiving := AllowReceiving;
        Production := AllowProduction;
        Log := AllowLog;
    end;

    procedure ValidateKey1()
    begin
        if SourceKey1 = '' then
            exit;

        case TargetID of
            DATABASE::Location, DATABASE::Zone, DATABASE::Bin:
                begin
                    Location.Get(SourceKey1);
                    SourceKey2 := '';
                end;
            DATABASE::Customer:
                Customer.Get(SourceKey1);
            DATABASE::Vendor:
                Vendor.Get(SourceKey1);
            DATABASE::Item:
                Item.Get(SourceKey1);
            DATABASE::Resource:
                Resource.Get(SourceKey1);
            DATABASE::Asset:
                Asset.Get(SourceKey1);
            DATABASE::"Work Center":
                WorkCenter.Get(SourceKey1);
            DATABASE::"Machine Center":
                MachineCenter.Get(SourceKey1);
        end;
    end;

    procedure ValidateKey2()
    begin
        if SourceKey2 = '' then
            exit;

        case TargetID of
            DATABASE::Zone:
                Zone.Get(SourceKey1, SourceKey2);
            DATABASE::Bin:
                Bin.Get(SourceKey1, SourceKey2);
        end;
    end;

    procedure LookupKey1()
    begin
        case TargetID of
            DATABASE::Location, DATABASE::Zone, DATABASE::Bin:
                begin
                    Location.SetRange("Use As In-Transit", false);
                    if PAGE.RunModal(0, Location) = ACTION::LookupOK then begin
                        SourceKey1 := Location.Code;
                        SourceKey2 := '';
                    end;
                end;
            DATABASE::Customer:
                if PAGE.RunModal(0, Customer) = ACTION::LookupOK then
                    SourceKey1 := Customer."No.";
            DATABASE::Vendor:
                if PAGE.RunModal(0, Vendor) = ACTION::LookupOK then
                    SourceKey1 := Vendor."No.";
            DATABASE::Item:
                if PAGE.RunModal(0, Item) = ACTION::LookupOK then
                    SourceKey1 := Item."No.";
            DATABASE::Resource:
                if PAGE.RunModal(0, Resource) = ACTION::LookupOK then
                    SourceKey1 := Resource."No.";
            DATABASE::Asset:
                if PAGE.RunModal(0, Asset) = ACTION::LookupOK then
                    SourceKey1 := Asset."No.";
            DATABASE::"Work Center":
                if PAGE.RunModal(0, WorkCenter) = ACTION::LookupOK then
                    SourceKey1 := WorkCenter."No.";
            DATABASE::"Machine Center":
                if PAGE.RunModal(0, MachineCenter) = ACTION::LookupOK then
                    SourceKey1 := MachineCenter."No.";
        end;
    end;

    procedure LookupKey2()
    begin
        case TargetID of
            DATABASE::Zone:
                begin
                    Zone.Reset;
                    if SourceKey1 <> '' then
                        Zone.SetRange("Location Code", SourceKey1);
                    if PAGE.RunModal(0, Zone) = ACTION::LookupOK then begin
                        SourceKey1 := Zone."Location Code";
                        SourceKey2 := Zone.Code;
                    end;
                end;
            DATABASE::Bin:
                begin
                    Bin.Reset;
                    if SourceKey1 <> '' then
                        Bin.SetRange("Location Code", SourceKey1);
                    if PAGE.RunModal(0, Bin) = ACTION::LookupOK then begin
                        SourceKey1 := Bin."Location Code";
                        SourceKey2 := Bin.Code;
                    end;
                end;
        end;
    end;
}

