page 50000 "TNP_Container Import"
{

    ApplicationArea = All;
    Caption = 'Container Import';
    PageType = List;
    SourceTable = "TNP_Container Buffer";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Select; Select)
                {
                    ApplicationArea = All;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ApplicationArea = All;
                }
                field("PO Line No."; Rec."PO Line No.")
                {
                    ApplicationArea = All;
                }
                field("SPN Item No."; Rec."SPN Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = All;
                }
                field("Batch No."; Rec."Batch No.")
                {
                    ApplicationArea = All;
                }
                field("Order Complete"; Rec."Order Complete")
                {
                    ApplicationArea = All;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Import)
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Import;
                trigger OnAction()
                var
                    ContainerImport: Codeunit TNP_ContainerImport;
                begin
                    ContainerImport.Run();
                end;
            }
            action("Select All")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Import;
                trigger OnAction()
                var
                    ContainerRec: Record "TNP_Container Buffer";
                begin
                    ContainerRec.Reset();
                    if ContainerRec.FindSet() then
                        repeat
                            ContainerRec.Select := true;
                            ContainerRec.Modify();
                        until ContainerRec.Next() = 0;
                end;

            }
            action("Update Orders")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = UpdateShipment;
                trigger OnAction()
                var
                    PurchaseHdr: Record "Purchase Header";
                    PurchaseLine: Record "Purchase Line";
                    PurchReleaseCU: Codeunit "Release Purchase Document";
                    ReservEntry: Record "Reservation Entry";
                    resentryno: Integer;
                begin
                    if Rec.Select then
                        repeat
                            PurchaseHdr.Reset();
                            PurchaseHdr.SetRange("Document Type", PurchaseHdr."Document Type"::Order);
                            PurchaseHdr.SetRange("No.", "Purchase Order No.");
                            if PurchaseHdr.FindFirst() then begin
                                PurchReleaseCU.SetSkipCheckReleaseRestrictions();
                                PurchReleaseCU.Reopen(PurchaseHdr);
                                PurchaseLine.Reset();
                                PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                                PurchaseLine.SetRange("Document No.", PurchaseHdr."No.");
                                PurchaseLine.SetRange("Line No.", "PO Line No.");
                                if PurchaseLine.FindFirst() then begin
                                    PurchaseLine.CalcFields("Reserved Quantity");
                                    PurchaseLine.Validate(Quantity, "Qty. to Receive");
                                    PurchaseLine.Validate("Qty. to Receive", "Qty. to Receive");
                                    PurchaseLine."Bin Code" := 'AT SEA';
                                    PurchaseLine.Modify();
                                    if not ReservEntry.FindLast() then
                                        resentryno := 1
                                    else
                                        resentryno := ReservEntry."Entry No.";
                                    if PurchaseLine."Reserved Quantity" = -0 then begin
                                        ReservEntry.Init();
                                        ReservEntry."Entry No." := resentryno + 1;
                                        ReservEntry.Positive := true;
                                        ReservEntry."Item No." := "Item No.";
                                        ReservEntry.Quantity := "Qty. to Receive";
                                        ReservEntry."Location Code" := PurchaseLine."Location Code";
                                        ReservEntry."Reservation Status" := ReservEntry."Reservation Status"::Surplus;
                                        ReservEntry."Source Type" := 39;
                                        ReservEntry."Source Subtype" := 1;
                                        ReservEntry."Source ID" := "Purchase Order No.";
                                        ReservEntry."Source Ref. No." := "PO Line No.";
                                        Evaluate(ReservEntry."Lot No.", "Batch No.");
                                        ReservEntry.VALIDATE(Quantity, "Qty. to Receive");
                                        ReservEntry."Quantity (Base)" := "Qty. to Receive";
                                        ReservEntry."Qty. to Handle (Base)" := "Qty. to Receive";
                                        ReservEntry."Qty. to Invoice (Base)" := "Qty. to Receive";
                                        ReservEntry.Description := Description;
                                        ReservEntry.Insert();
                                    end else begin
                                        ReservEntry.Init();
                                        ReservEntry."Entry No." := resentryno + 1;
                                        ReservEntry.Positive := true;
                                        ReservEntry."Item No." := "Item No.";
                                        ReservEntry.Quantity := "Qty. to Receive";
                                        ReservEntry."Location Code" := PurchaseLine."Location Code";
                                        ReservEntry."Reservation Status" := ReservEntry."Reservation Status"::Reservation;
                                        ReservEntry."Source Type" := 39;
                                        ReservEntry."Source Subtype" := 1;
                                        ReservEntry."Source ID" := "Purchase Order No.";
                                        ReservEntry."Source Ref. No." := "PO Line No.";
                                        Evaluate(ReservEntry."Lot No.", "Batch No.");
                                        ReservEntry.VALIDATE(Quantity, "Qty. to Receive");
                                        ReservEntry."Quantity (Base)" := "Qty. to Receive";
                                        ReservEntry."Qty. to Handle (Base)" := "Qty. to Receive";
                                        ReservEntry."Qty. to Invoice (Base)" := "Qty. to Receive";
                                        ReservEntry.Description := Description;
                                        ReservEntry.Insert();

                                        ReservEntry.Init();
                                        ReservEntry."Entry No." := resentryno + 1;
                                        ReservEntry.Positive := false;
                                        ReservEntry."Item No." := "Item No.";
                                        ReservEntry.Quantity := "Qty. to Receive";
                                        ReservEntry."Location Code" := PurchaseLine."Location Code";
                                        ReservEntry."Reservation Status" := ReservEntry."Reservation Status"::Reservation;
                                        ReservEntry."Source Type" := 37;
                                        ReservEntry."Source Subtype" := 1;
                                        ReservEntry."Source ID" := "Purchase Order No.";
                                        ReservEntry."Source Ref. No." := "PO Line No.";
                                        // Evaluate(ReservEntry."Lot No.", "Batch No.");
                                        ReservEntry.VALIDATE(Quantity, "Qty. to Receive");
                                        ReservEntry."Quantity (Base)" := "Qty. to Receive";
                                        ReservEntry."Qty. to Handle (Base)" := "Qty. to Receive";
                                        ReservEntry."Qty. to Invoice (Base)" := "Qty. to Receive";
                                        ReservEntry.Description := Description;
                                        ReservEntry.Insert();
                                    end;
                                end;
                                PurchReleaseCU.SetSkipCheckReleaseRestrictions();
                                PurchReleaseCU.Run(PurchaseHdr);
                            end;
                        until Rec.Next() = 0;
                end;
            }
            action("Post Receipts")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Post;

                trigger OnAction()
                var
                    PurchHeader: Record "Purchase Header";
                    GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
                    PurchReleaseCU: Codeunit "Release Purchase Document";
                begin
                    PurchHeader.Reset();
                    PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                    PurchHeader.SetRange("No.", "Purchase Order No.");
                    if PurchHeader.FindFirst() then begin
                        PurchReleaseCU.SetSkipCheckReleaseRestrictions();
                        PurchReleaseCU.Run(PurchHeader);
                        GetSourceDocInbound.CreateFromPurchOrder(PurchHeader);
                    end;

                end;


            }
            action("View Order")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Order;

                trigger OnAction()
                var
                    PurchaseDoc: Page "Purchase Order";
                    PurchHeader: Record "Purchase Header";
                begin
                    PurchHeader.Reset();
                    PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                    PurchHeader.SetRange("No.", "Purchase Order No.");
                    PurchaseDoc.SetTableView(PurchHeader);
                    PurchaseDoc.Run();
                end;

            }
        }
    }
}
