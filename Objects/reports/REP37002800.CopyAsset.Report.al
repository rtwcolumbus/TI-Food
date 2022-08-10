report 37002800 "Copy Asset"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Processing only report to copy an existing asset into the current asset
    // 
    // PRW16.00.20
    // P8000674, VerticalSoft, Jack Reynolds, 09 FEB 09
    //   Request page transformed
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Copy Asset';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(AssetNo; AssetNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Asset No.';
                        TableRelation = Asset;

                        trigger OnValidate()
                        begin
                            if AssetNo = '' then
                                Clear(FromAsset)
                            else
                                FromAsset.Get(AssetNo);
                        end;
                    }
                    field("FromAsset.Description"; FromAsset.Description)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Asset Description';
                        Editable = false;
                    }
                    field(CopyDetail; CopyDetail)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Copy Detail';
                    }
                    field(CopyComments; CopyComments)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Copy Comments';
                    }
                    field(CopyPM; CopyPM)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Copy PM';

                        trigger OnValidate()
                        begin
                            CopyPMOnAfterValidate;
                        end;
                    }
                    field(CopyPMComments; CopyPMComments)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = '    Copy PM Comments';
                        Editable = CopyPMCommentsEditable;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            CopyPMCommentsEditable := true;
        end;

        trigger OnOpenPage()
        begin
            if FromAsset.Get(AssetNo) then;

            CopyPMCommentsEditable := CopyPM;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CopyAsset;
    end;

    var
        MaintSetup: Record "Maintenance Setup";
        Asset: Record Asset;
        FromAsset: Record Asset;
        CommentLine: Record "Comment Line";
        FromCommentLine: Record "Comment Line";
        PMOrder: Record "Preventive Maintenance Order";
        FromPMOrder: Record "Preventive Maintenance Order";
        PMActivity: Record "PM Activity";
        FromPMActivity: Record "PM Activity";
        PMMaterial: Record "PM Material";
        FromPMMaterial: Record "PM Material";
        TextFns: Codeunit "Text Functions";
        AssetNo: Code[20];
        CopyDetail: Boolean;
        CopyComments: Boolean;
        CopyPM: Boolean;
        CopyPMComments: Boolean;
        [InDataSet]
        CopyPMCommentsEditable: Boolean;

    procedure SetAsset(NewAsset: Record Asset)
    begin
        Asset := NewAsset;
    end;

    procedure CopyAsset()
    var
        DefaultDim: Record "Default Dimension";
        DefaultDim2: Record "Default Dimension";
    begin
        with Asset do begin
            Description := FromAsset.Description;
            "Description 2" := FromAsset."Description 2";
            "Search Description" := FromAsset."Search Description";
            "Last Date Modified" := Today;
            "Global Dimension 1 Code" := FromAsset."Global Dimension 1 Code";
            "Global Dimension 2 Code" := FromAsset."Global Dimension 2 Code";
            Type := FromAsset.Type;
            "Location Code" := FromAsset."Location Code";
            "Asset Category Code" := FromAsset."Asset Category Code";
            Picture := FromAsset.Picture;
            "Usage Unit of Measure" := FromAsset."Usage Unit of Measure";
            "Usage Reading Frequency" := FromAsset."Usage Reading Frequency";
            if CopyDetail then begin
                "Manufacturer Code" := FromAsset."Manufacturer Code";
                "Model No." := FromAsset."Model No.";
                "Model Year" := FromAsset."Model Year";
                "Vendor No." := FromAsset."Vendor No.";
                "Gross Weight" := FromAsset."Gross Weight";
                "Gross Weight Unit of Measure" := FromAsset."Gross Weight Unit of Measure";
                "Area Unit of Measure" := FromAsset."Area Unit of Measure";
                "Manufacture Date" := FromAsset."Manufacture Date";
                "Purchase Date" := FromAsset."Purchase Date";
                "Installation Date" := FromAsset."Installation Date";
                "Overhaul Date" := FromAsset."Overhaul Date";
                "Warranty Date" := FromAsset."Warranty Date";
            end;
            Modify;

            DefaultDim.SetRange("Table ID", DATABASE::Asset);
            DefaultDim.SetRange("No.", "No.");
            DefaultDim.DeleteAll;
            DefaultDim.SetRange("No.", FromAsset."No.");
            if DefaultDim.FindSet then
                repeat
                    DefaultDim2 := DefaultDim;
                    DefaultDim2."No." := "No.";
                    DefaultDim2.Insert;
                until DefaultDim.Next = 0;

            if CopyComments then begin
                FromCommentLine.SetRange("Table Name", FromCommentLine."Table Name"::FOODAsset);
                FromCommentLine.SetRange("No.", FromAsset."No.");
                if FromCommentLine.FindSet then
                    repeat
                        CommentLine := FromCommentLine;
                        CommentLine."No." := "No.";
                        CommentLine.Insert;
                    until FromCommentLine.Next = 0;
            end;

            if CopyPM then begin
                FromPMOrder.SetCurrentKey("Asset No.");
                FromPMOrder.SetRange("Asset No.", FromAsset."No.");
                if FromPMOrder.FindSet then begin
                    MaintSetup.LockTable;
                    MaintSetup.Get;
                    repeat
                        PMOrder := FromPMOrder;
                        MaintSetup."Last PM Order No." += 1;
                        MaintSetup.Modify;
                        PMOrder."Entry No." := Format(MaintSetup."Last PM Order No.");
                        PMOrder."Asset No." := "No.";
                        PMOrder."Last PM Date" := 0D;
                        PMOrder."Last PM Usage" := -1;
                        PMOrder."Last Work Order" := '';
                        PMOrder."Current Work Order" := '';
                        PMOrder."Last Date Modified" := Today;
                        PMOrder."Work Requested" := TextFns.CopyNote(PMOrder."Work Requested");
                        PMOrder.Insert;

                        DefaultDim.SetRange("Table ID", DATABASE::"Preventive Maintenance Order");
                        DefaultDim.SetRange("No.", PMOrder."Entry No.");
                        DefaultDim.DeleteAll;
                        DefaultDim.SetRange("No.", FromPMOrder."Entry No.");
                        if DefaultDim.FindSet then
                            repeat
                                DefaultDim2 := DefaultDim;
                                DefaultDim2."No." := PMOrder."Entry No.";
                                DefaultDim2.Insert;
                            until DefaultDim.Next = 0;

                        FromPMActivity.SetRange("PM Entry No.", FromPMOrder."Entry No.");
                        if FromPMActivity.FindSet then
                            repeat
                                PMActivity := FromPMActivity;
                                PMActivity."PM Entry No." := PMOrder."Entry No.";
                                PMActivity.Insert;
                            until FromPMActivity.Next = 0;

                        FromPMMaterial.SetRange("PM Entry No.", FromPMOrder."Entry No.");
                        if FromPMMaterial.FindSet then
                            repeat
                                PMMaterial := FromPMMaterial;
                                PMMaterial."PM Entry No." := PMOrder."Entry No.";
                                PMMaterial.Insert;
                            until FromPMMaterial.Next = 0;

                        if CopyPMComments then begin
                            FromCommentLine.SetRange("Table Name", FromCommentLine."Table Name"::FOODPMOrder);
                            FromCommentLine.SetRange("No.", FromPMOrder."Entry No.");
                            if FromCommentLine.FindSet then
                                repeat
                                    CommentLine := FromCommentLine;
                                    CommentLine."No." := PMOrder."Entry No.";
                                    CommentLine.Insert;
                                until FromCommentLine.Next = 0;
                        end;
                    until FromPMOrder.Next = 0;
                end;
            end;
        end;
    end;

    local procedure CopyPMOnAfterValidate()
    begin
        CopyPMCommentsEditable := CopyPM;
    end;
}

