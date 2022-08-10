page 37002803 "Asset Picture"
{
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Asset Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = Asset;

    layout
    {
        area(content)
        {
            field(Picture; Picture)
            {
                ApplicationArea = FOODBasic;
                ShowCaption = false;
                ToolTip = 'Specifies the picture that has been inserted for the asset.';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(TakePicture)
            {
                ApplicationArea = All;
                Caption = 'Take';
                Image = Camera;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Activate the camera on the device.';
                Visible = CameraAvailable AND (HideActions = FALSE);

                trigger OnAction()
                begin
                    TakeNewPicture;
                end;
            }
            action(ImportPicture)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a picture file.';
                Visible = HideActions = FALSE;

                trigger OnAction()
                begin
                    ImportFromDevice;
                end;
            }
            action(ExportFile)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Enabled = DeleteExportEnabled;
                Image = Export;
                ToolTip = 'Export the picture to a file.';
                Visible = HideActions = FALSE;

                trigger OnAction()
                var
                    DummyPictureEntity: Record "Picture Entity";
                    FileManagement: Codeunit "File Management";
                    ToFile: Text;
                    ExportPath: Text;
                begin
                    TestField("No.");
                    TestField(Description);

                    ToFile := DummyPictureEntity.GetDefaultMediaDescription(Rec);
                    ExportPath := TemporaryPath + "No." + Format(Picture.MediaId);
                    Picture.ExportFile(ExportPath + '.' + DummyPictureEntity.GetDefaultExtension);

                    FileManagement.ExportImage(ExportPath, ToFile);
                end;
            }
            action(DeletePicture)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                Enabled = DeleteExportEnabled;
                Image = Delete;
                ToolTip = 'Delete the record.';
                Visible = HideActions = FALSE;

                trigger OnAction()
                begin
                    DeleteItemPicture;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEditableOnPictureActions;
    end;

    trigger OnOpenPage()
    begin
        CameraAvailable := CameraProvider.IsAvailable;
        if CameraAvailable then
            CameraProvider := CameraProvider.Create;
    end;

    var
        [RunOnClient]
        [WithEvents]
        CameraProvider: DotNet CameraProvider;
        CameraAvailable: Boolean;
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        DeleteImageQst: Label 'Are you sure you want to delete the picture?';
        SelectPictureTxt: Label 'Select a picture to upload';
        DeleteExportEnabled: Boolean;
        HideActions: Boolean;

    [Scope('Personalization')]
    procedure TakeNewPicture()
    var
        CameraOptions: DotNet CameraOptions;
    begin
        Find;
        TestField("No.");
        TestField(Description);

        if not CameraAvailable then
            exit;

        CameraOptions := CameraOptions.CameraOptions;
        CameraOptions.Quality := 50;
        CameraProvider.RequestPictureAsync(CameraOptions);
    end;

    procedure ImportFromDevice()
    var
        FileManagement: Codeunit "File Management";
        FileName: Text;
        ClientFileName: Text;
    begin
        Find;
        TestField("No.");
        TestField(Description);

        if Picture.Count > 0 then
            if not Confirm(OverrideImageQst) then
                Error('');

        ClientFileName := '';
        FileName := FileManagement.UploadFile(SelectPictureTxt, ClientFileName);
        if FileName = '' then
            Error('');

        Clear(Picture);
        Picture.ImportFile(FileName, ClientFileName);
        if not Insert(true) then
            Modify(true);

        if FileManagement.DeleteServerFile(FileName) then;
    end;

    local procedure SetEditableOnPictureActions()
    begin
        DeleteExportEnabled := Picture.Count <> 0;
    end;

    [Scope('Personalization')]
    procedure IsCameraAvailable(): Boolean
    begin
        exit(CameraProvider.IsAvailable);
    end;

    [Scope('Personalization')]
    procedure SetHideActions()
    begin
        HideActions := true;
    end;

    procedure DeleteItemPicture()
    begin
        TestField("No.");

        if not Confirm(DeleteImageQst) then
            exit;

        Clear(Picture);
        Modify(true);
    end;

    trigger CameraProvider::PictureAvailable(PictureName: Text; PictureFilePath: Text)
    var
        File: File;
        Instream: InStream;
    begin
        if (PictureName = '') or (PictureFilePath = '') then
            exit;

        if Picture.Count > 0 then
            if not Confirm(OverrideImageQst) then begin
                if Erase(PictureFilePath) then;
                exit;
            end;

        File.Open(PictureFilePath);
        File.CreateInStream(Instream);

        Clear(Picture);
        Picture.ImportStream(Instream, PictureName);
        if not Modify(true) then
            Insert(true);

        File.Close;
        if Erase(PictureFilePath) then;
    end;
}

