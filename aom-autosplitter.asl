// todo: aot & vanilla
state("AoMX", "EE")
{
    // todo: mission number for full campaign runs
    float missionTimer: 0x00352038, 0x0; // in seconds
    int isInCutScene: 0x00831BD8, 0x1D0;// is 0 when in cut scene, 1 otherwise
    int victory: 0x007F8288, 0x54C, 0x14; // goes from 1->0 when "You are Victorious!" is displayed
    int isInMenu: 0x0085CDB8, 0x0, 0x4, 0x4; // is 0 when in menu, > 0 otherwise (strictly increases, maybe related to timer?)
}

init
{
    vars.cutSceneOffset = -1;
}

start
{
    if (
        current.isInMenu != 0
        && old.isInCutScene == 0
        && current.isInCutScene == 1
    ) {
        vars.cutSceneOffset = current.missionTimer;
        return true;
    }
}

startup
{
    // todo: each campaign?
    // todo: fps?
    // todo: IL vs full campaign
    // settings.Add("Individual Level");
    // settings.SetToolTip("Individual Level", "Check this box for IL runs - it will reset the timer without having to go back to the menu");

    //Asks the user to set their timer to game time on livesplit, which is needed for verification
    if (timer.CurrentTimingMethod == TimingMethod.RealTime) // Inspired by the Modern warfare 3 Autosplitter
    {        
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time? This will make verification easier.",
            "LiveSplit | Age of Mythology",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question);
        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }
}

split
{
    if (
        current.isInMenu != 0
        && current.victory == 0
        && old.victory == 1
    ) {
        return true;
    }
    
}

reset
{
}

gameTime
{
    return TimeSpan.FromSeconds(current.missionTimer - vars.cutSceneOffset);
}