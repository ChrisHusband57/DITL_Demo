codeunit 50000 TNP_ContainerImport
{

    trigger OnRun()
    begin
        ImportContainerData();
    end;

    var
        Rec_ExcelBuffer: Record "Excel Buffer";
        Rows: Integer;
        Columns: Integer;
        Fileuploaded: Boolean;
        UploadIntoStream: InStream;
        FileName: Text;
        Sheetname: Text;
        UploadResult: Boolean;
        DialogCaption: Text;
        Name: Text;
        NVInStream: InStream;
        GenJnl: Record "Gen. Journal Line";
        RowNo: Integer;
        TxtDate: Text;
        DocumentDate: Date;
        LineNo: Integer;
        item: Record Item;
        PurchLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        DocumentNo: Code[20];
        PurchLineNo: Integer;
        LineQty: Decimal;
        ContainerBuffer: Record "TNP_Container Buffer";

    procedure ImportContainerData()
    begin
        Rec_ExcelBuffer.DeleteAll();
        Rows := 0;
        Columns := 0;
        DialogCaption := 'Select File to upload';
        UploadResult := UploadIntoStream(DialogCaption, '', '', Name, NVInStream);
        If Name <> '' then
            Sheetname := Rec_ExcelBuffer.SelectSheetsNameStream(NVInStream)
        else
            exit;
        Rec_ExcelBuffer.Reset();
        Rec_ExcelBuffer.OpenBookStream(NVInStream, Sheetname);
        Rec_ExcelBuffer.ReadSheet();
        Commit();
        Rec_ExcelBuffer.Reset();
        Rec_ExcelBuffer.SetRange("Column No.", 2);
        If Rec_ExcelBuffer.FindFirst() then
            repeat
                Rows := Rows + 1;
            until Rec_ExcelBuffer.Next() = 0;
        Rec_ExcelBuffer.Reset();
        Rec_ExcelBuffer.SetRange("Row No.", 3);
        if Rec_ExcelBuffer.FindFirst() then
            repeat
                Columns := Columns + 1;
            until Rec_ExcelBuffer.Next() = 0;
        for RowNo := 1 to Rows do begin
            Clear(DocumentNo);
            Clear(PurchLineNo);
            Clear(LineQty);
            Evaluate(LineQty, GetValueAtIndex(RowNo, 6));
            DocumentNo := GetValueAtIndex(RowNo, 1);
            Evaluate(PurchLineNo, GetValueAtIndex(RowNo, 2));
            ContainerBuffer.Init();
            ContainerBuffer."Purchase Order No." := DocumentNo;
            ContainerBuffer."PO Line No." := PurchLineNo;
            ContainerBuffer."SPN Item No." := GetValueAtIndex(RowNo, 3);
            ContainerBuffer."Item No." := GetValueAtIndex(RowNo, 4);
            ContainerBuffer.Description := GetValueAtIndex(RowNo, 5);
            ContainerBuffer."Qty. to Receive" := LineQty;
            ContainerBuffer."Batch No." := GetValueAtIndex(RowNo, 7);
            if GetValueAtIndex(RowNo, 8) = 'Y' then
                ContainerBuffer."Order Complete" := true
            else
                ContainerBuffer."Order Complete" := false;
            PurchaseHeader.Reset();
            PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
            PurchaseHeader.SetRange("No.", DocumentNo);
            if PurchaseHeader.FindFirst() then begin
                ContainerBuffer."Bin Code" := 'AT SEA';
                ContainerBuffer."Location Code" := PurchaseHeader."Location Code";
            end;
            if not ContainerBuffer.Insert() then
                ContainerBuffer.Modify();
        End;
    end;


    local procedure GetValueAtIndex(RowNo: Integer;
    ColNo: Integer): Text
    var
        Rec_ExcelBuffer: Record "Excel Buffer";
    begin
        Rec_ExcelBuffer.Reset();
        If Rec_ExcelBuffer.Get(RowNo, ColNo) then exit(Rec_ExcelBuffer."Cell Value as Text");
    end;

}
