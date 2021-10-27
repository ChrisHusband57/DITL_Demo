table 50000 "TNP_Container Buffer"
{
    Caption = 'Container Buffer';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            DataClassification = SystemMetadata;
        }
        field(2; "PO Line No."; Integer)
        {
            Caption = 'PO Line No.';
            DataClassification = SystemMetadata;
        }
        field(3; "SPN Item No."; Text[250])
        {
            Caption = 'SPN Item No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(6; "Qty. to Receive"; Decimal)
        {
            Caption = 'Qty. to Receive';
            DataClassification = SystemMetadata;
        }
        field(7; "Batch No."; Code[20])
        {
            Caption = 'Batch No.';
            DataClassification = SystemMetadata;
        }
        field(8; "Order Complete"; Boolean)
        {
            Caption = 'Order Complete';
            DataClassification = SystemMetadata;
        }
        field(9; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
        }
        field(10; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = SystemMetadata;
        }
        field(11; Select; Boolean)
        {
            Caption = 'Select';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Purchase Order No.", "PO Line No.")
        {
            Clustered = true;
        }
    }

}
