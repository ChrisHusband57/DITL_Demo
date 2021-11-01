pageextension 50003 TNP_ManufacturingSetupPageExt extends "Manufacturing Setup"
{
    layout
    {
        addafter("Default Safety Lead Time")
        {
            field("Default Minimum Roll Length"; "Default Minimum Roll Length")
            {
                ApplicationArea = All;
            }
            field("Default Cutting Journal"; "Default Cutting Journal")
            {
                ApplicationArea = All;
            }
            field("Auto-Post Cutting Jnl"; "Auto-Post Cutting Jnl")
            {
                ApplicationArea = All;
            }
        }
    }
}