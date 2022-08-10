page 37002707 "No. of Labels"
{
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 08 DEC 16
    //   Utility to specify number of labels to print

    Caption = '';
    DataCaptionExpression = PageCaption;
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(NoOfLabels; NoOfLabels)
            {
                ApplicationArea = FOODBasic;
                Caption = 'No. of Labels';
                MinValue = 1;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if NoOfLabels = 0 then
            NoOfLabels := 1;
    end;

    var
        PageCaption: Text;
        NoOfLabels: Integer;
        Separator: Label '·';

    procedure SetData(SourceRec: Variant; No: Integer)
    var
        SourceRecRef: RecordRef;
        RepackOrder: Record "Repack Order";
    begin
        SourceRecRef.GetTable(SourceRec);

        case SourceRecRef.Number of
            DATABASE::"Repack Order":
                begin
                    RepackOrder := SourceRec;
                    PageCaption := StrSubstNo('%2 %1 %3', Separator, RepackOrder.TableCaption, RepackOrder."No.");
                end;
        end;

        NoOfLabels := No;
    end;

    procedure GetNoOfLables(): Integer
    begin
        exit(NoOfLabels);
    end;
}

