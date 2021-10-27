tableextension 50000 TNP_SalesHeaderExt extends "Sales Header"
{
    fields
    {
        field(50000; "Order Expiry Date"; Date)
        {
            Caption = 'Order Expiry Date';
            DataClassification = CustomerContent;
        }
    }
}
