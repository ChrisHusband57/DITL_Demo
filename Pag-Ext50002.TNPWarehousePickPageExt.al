pageextension 50002 "TNP_Warehouse Pick Page Ext" extends "Warehouse Pick"
{
    actions
    {
        addafter(RegisterPick)
        {
            action("Print Labels")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                var
                    myInt: Integer;
                begin
                    Message('Label will be printed');
                end;

            }
        }
    }
}
