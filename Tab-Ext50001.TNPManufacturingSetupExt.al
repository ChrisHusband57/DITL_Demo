tableextension 50001 "TNP_Manufacturing Setup Ext" extends "Manufacturing Setup"
{
    fields
    {
        field(50000; "Default Minimum Roll Length"; Decimal)
        {
            Caption = 'Default Minimum Roll Length';
            DataClassification = SystemMetadata;
        }
        field(50001; "Default Cutting Journal"; Code[20])
        {
            Caption = 'Default Cutting Journal';
            DataClassification = SystemMetadata;
            TableRelation = "Warehouse Journal Batch".Name where("Journal Template Name" = const('ITEM'));

        }
        field(50002; "Auto-Post Cutting Jnl"; Boolean)
        {
            Caption = 'Auto-Post Cutting Jnl';
            DataClassification = SystemMetadata;

        }
    }
}
