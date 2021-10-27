pageextension 50004 "Whse. Pick Subform Ext" extends "Whse. Pick Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("Qty. Remaining"; "Qty. Remaining")
            {
                ApplicationArea = All;
            }
        }
    }
}
