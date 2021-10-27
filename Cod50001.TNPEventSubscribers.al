codeunit 50001 TNP_EventSubscribers
{
    [EventSubscriber(ObjectType::Codeunit, codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', true, true)]
    local procedure CheckForRemainingStock(var ItemJournalLine: Record "Item Journal Line")
    var
        Items: Record Item;
        WarehouseEntry: Record "Warehouse Entry";
        ReservationEntry: Record "Reservation Entry";
        RemainingQty: Decimal;
        ManfacturingSetup: Record "Manufacturing Setup";
    begin
        if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Consumption then begin
            Clear(RemainingQty);
            Items.Reset();
            Items.SetRange("No.", ItemJournalLine."Item No.");
            if Items.FindFirst() then begin
                ReservationEntry.Reset();
                ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Prospect);
                ReservationEntry.SetRange("Item No.", ItemJournalLine."Item No.");
                ReservationEntry.SetRange("Source ID", 'CONSUMPTIO');
                ReservationEntry.SetRange("Source Type", 83);
                ReservationEntry.SetRange("Source Subtype", 5);
                ReservationEntry.SetRange("Source Ref. No.", ItemJournalLine."Line No.");
                if ReservationEntry.FindFirst() then begin
                    WarehouseEntry.Reset();
                    WarehouseEntry.SetRange("Item No.", ItemJournalLine."Item No.");
                    WarehouseEntry.SetRange("Lot No.", ReservationEntry."Lot No.");
                    WarehouseEntry.SetRange("Location Code", ItemJournalLine."Location Code");
                    WarehouseEntry.SetRange("Bin Code", ItemJournalLine."Bin Code");
                    WarehouseEntry.SetFilter(Quantity, '>%1', 0);
                    if WarehouseEntry.FindFirst() then begin
                        ManfacturingSetup.Get();
                        RemainingQty := WarehouseEntry.Quantity - ItemJournalLine.Quantity;
                        if RemainingQty <= ManfacturingSetup."Default Minimum Roll Length" then
                            Message('The roll is below %1. Please re-measure the remaining roll', ManfacturingSetup."Default Minimum Roll Length");
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnBeforeCode', '', true, true)]
    local procedure CheckForRemainingStockPick(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        Items: Record Item;
        WarehouseEntry: Record "Warehouse Entry";
        ReservationEntry: Record "Reservation Entry";
        RemainingQty: Decimal;
        ManfacturingSetup: Record "Manufacturing Setup";
        WhseJournalLine: Record "Warehouse Journal Line";
        WhseItemTracking: Record "Whse. Item Tracking Line";
        JournalQty: Decimal;
    begin
        if WarehouseActivityLine."Activity Type" = WarehouseActivityLine."Activity Type"::Pick then begin
            WarehouseActivityLine.SetRange("Action Type", WarehouseActivityLine."Action Type"::Take);
            if WarehouseActivityLine."Qty. Remaining" = 0 then begin
                Clear(RemainingQty);
                Items.Reset();
                Items.SetRange("No.", WarehouseActivityLine."Item No.");
                if Items.FindFirst() then begin
                    WarehouseEntry.Reset();
                    WarehouseEntry.SetRange("Item No.", WarehouseActivityLine."Item No.");
                    WarehouseEntry.SetRange("Lot No.", WarehouseActivityLine."Lot No.");
                    WarehouseEntry.SetRange("Location Code", WarehouseActivityLine."Location Code");
                    WarehouseEntry.SetRange("Bin Code", WarehouseActivityLine."Bin Code");
                    WarehouseEntry.SetFilter(Quantity, '>%1', 0);
                    if WarehouseEntry.FindFirst() then begin
                        ManfacturingSetup.Get();
                        RemainingQty := WarehouseEntry.Quantity - WarehouseActivityLine."Qty. to Handle";
                        if RemainingQty <= ManfacturingSetup."Default Minimum Roll Length" then
                            Error('The roll is below %1. Please re-measure the remaining roll and enter Qty. Remaining', ManfacturingSetup."Default Minimum Roll Length");
                    end;
                end;
            end else begin
                Clear(RemainingQty);
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
                        begin
                            WhseJournalLine."Journal Template Name" := 'ITEM';
                            WhseJournalLine."Journal Batch Name" := 'DEFAULT';
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
                            WhseItemTracking."Lot No." := WarehouseActivityLine."Lot No.";
                            WhseItemTracking.Insert();
                        end;
                    end;
                end;
            end;
        end;
    end;
}
