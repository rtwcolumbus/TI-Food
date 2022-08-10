codeunit 37002560 "Copy Container"
{
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        CopiedContainer: Record "Container Header" temporary;

    procedure CopiedContainersExist(): Boolean
    begin
        exit(not CopiedContainer.IsEmpty);
    end;

    procedure GetCopiedContainers(var ContainerHeader: Record "Container Header" temporary): Boolean
    begin
        ContainerHeader.Reset;
        ContainerHeader.DeleteAll;

        if CopiedContainer.FindSet then begin
            repeat
                ContainerHeader := CopiedContainer;
                ContainerHeader.Insert;
            until CopiedContainer.Next = 0;
            exit(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Container Header", 'OnAfterInsertEvent', '', true, false)]
    local procedure ContainerHeader_OnAfterInsert(var Rec: Record "Container Header"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        CopiedContainer := Rec;
        CopiedContainer.Insert;
    end;
}

