pageextension 50000 TNP_SalesOrderExt extends "Sales Order"
{
    layout
    {
        addafter("Due Date")
        {
            field("Order Expiry Date"; "Order Expiry Date")
            {
                ApplicationArea = All;
            }
        }
    }
}
