codeunit 50001 TNP_EventSubscribers
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnBeforeWhseJnlRegisterLine', '', true, true)]
    local procedure CheckForRemainingStockPick(WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        Items: Record Item;
        WarehouseEntry: Record "Warehouse Entry";
        ReservationEntry: Record "Reservation Entry";
        RemainingQty: Decimal;
        ManfacturingSetup: Record "Manufacturing Setup";
        WhseJournalLine: Record "Warehouse Journal Line";
        WhseItemTracking: Record "Whse. Item Tracking Line";
        JournalQty: Decimal;
        WhseJnlRegister: Codeunit "Whse. Jnl.-Register";
    begin
        if WarehouseActivityLine."Activity Type" = WarehouseActivityLine."Activity Type"::Pick then begin
            WarehouseActivityLine.SetRange("Action Type", WarehouseActivityLine."Action Type"::Take);
            ManfacturingSetup.Get();
            if ManfacturingSetup."Default Minimum Roll Length" <> 0 THEN begin
                if WarehouseActivityLine."Qty. Remaining" = 0 then begin
                    Clear(RemainingQty);
                    Items.Reset();
                    Items.SetRange("No.", WarehouseActivityLine."Item No.");
                    Items.SetFilter("Item Tracking Code", '<>%1', '');
                    if Items.FindFirst() then begin
                        WarehouseEntry.Reset();
                        WarehouseEntry.SetRange("Item No.", WarehouseActivityLine."Item No.");
                        WarehouseEntry.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
                        WarehouseEntry.SetRange("Location Code", WarehouseActivityLine."Location Code");
                        WarehouseEntry.SetRange("Bin Code", WarehouseActivityLine."Bin Code");
                        WarehouseEntry.SetFilter(Quantity, '>%1', 0);
                        if WarehouseEntry.FindFirst() then begin
                            RemainingQty := WarehouseEntry.Quantity - WarehouseActivityLine."Qty. to Handle";
                            if RemainingQty <= ManfacturingSetup."Default Minimum Roll Length" then
                                Error('The roll is below %1. Please re-measure the remaining roll and enter Qty. Remaining', ManfacturingSetup."Default Minimum Roll Length");
                        end;
                    end;
                end else begin
                    Clear(RemainingQty);
                    ManfacturingSetup.Get();
                    WarehouseEntry.Reset();
                    WarehouseEntry.SetRange("Item No.", WarehouseActivityLine."Item No.");
                    WarehouseEntry.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
                    WarehouseEntry.SetRange("Location Code", WarehouseActivityLine."Location Code");
                    WarehouseEntry.SetRange("Bin Code", WarehouseActivityLine."Bin Code");
                    WarehouseEntry.SetFilter(Quantity, '>%1', 0);
                    if WarehouseEntry.FindFirst() then begin
                        RemainingQty := WarehouseEntry.Quantity - WarehouseActivityLine."Qty. to Handle";
                        if RemainingQty > WarehouseActivityLine."Qty. Remaining" then begin
                            Clear(JournalQty);
                            JournalQty := RemainingQty - WarehouseActivityLine."Qty. Remaining";
                            WhseJournalLine.Reset();
                            WhseJournalLine.SetRange("Journal Template Name", 'ITEM');
                            WhseJournalLine.SetRange("Journal Batch Name", ManfacturingSetup."Default Cutting Journal");
                            WhseJournalLine.SetRange("Location Code", WarehouseActivityLine."Location Code");
                            WhseJournalLine.SetRange("Line No.", WarehouseActivityLine."Line No.");
                            if not WhseJournalLine.IsEmpty then
                                WhseJournalLine.Delete();
                            begin
                                ManfacturingSetup.Get();
                                WhseJournalLine.Init();
                                WhseJournalLine."Journal Template Name" := 'ITEM';
                                WhseJournalLine."Journal Batch Name" := ManfacturingSetup."Default Cutting Journal";
                                WhseJournalLine."Registering Date" := TODAY;
                                WhseJournalLine.Validate("Location Code", WarehouseActivityLine."Location Code");
                                WhseJournalLine.Validate("Item No.", WarehouseActivityLine."Item No.");
                                WhseJournalLine."Line No." := WarehouseActivityLine."Line No.";
                                WhseJournalLine."Whse. Document No." := WarehouseActivityLine."No.";
                                WhseJournalLine.Validate("Zone Code", WarehouseActivityLine."Zone Code");
                                WhseJournalLine.Validate("Bin Code", WarehouseActivityLine."Bin Code");
                                WhseJournalLine."From Zone Code" := WarehouseActivityLine."Zone Code";
                                WhseJournalLine."To Zone Code" := WarehouseActivityLine."Zone Code";
                                WhseJournalLine."From Bin Code" := WarehouseActivityLine."Bin Code";
                                WhseJournalLine."To Bin Code" := WarehouseActivityLine."Bin Code";
                                WhseJournalLine.Validate(Quantity, -JournalQty);
                                WhseJournalLine.Insert();
                                WhseItemTracking.Reset();
                                WhseItemTracking.Validate("Item No.", WhseJournalLine."Item No.");
                                WhseItemTracking."Location Code" := WarehouseActivityLine."Location Code";
                                WhseItemTracking."Source ID" := WhseJournalLine."Journal Batch Name";
                                WhseItemTracking."Source Batch Name" := WhseJournalLine."Journal Template Name";
                                WhseItemTracking."Source Type" := 7311;
                                WhseItemTracking."Source Ref. No." := WhseJournalLine."Line No.";
                                WhseItemTracking.Validate("Quantity (Base)", JournalQty);
                                WhseItemTracking.Validate("Qty. to Handle (Base)", JournalQty);
                                WhseItemTracking."Lot No." := WarehouseActivityLine."Lot No.";
                                WhseItemTracking.Insert();
                            end;
                        end;
                    end;
                end;
                ManfacturingSetup.Get();
                if ManfacturingSetup."Auto-Post Cutting Jnl" then
                    WhseJnlRegister.Run(WhseJournalLine);
            end;
        end;
    end;
}
