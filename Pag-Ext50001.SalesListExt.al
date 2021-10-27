pageextension 50001 TNP_SalesListExt extends "Sales Order List"
{
    layout
    {
        addafter("External Document No.")
        {
            field("Order Expiry Date"; "Order Expiry Date")
            {
                ApplicationArea = All;
            }
        }
    }
}
