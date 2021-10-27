tableextension 50002 TNP_WarehouseActivityLineExt extends "Warehouse Activity Line"
{
    fields
    {
        field(50000; "Qty. Remaining"; Decimal)
        {
            Caption = 'Qty. Remaining';
            DataClassification = SystemMetadata;
        }
    }
}
