// todo: aot & vanilla
state("Age of Mythology", "EE")
{
    // todo: mission number
    int missionTimer: 0x00352038, 0x0;
    int hasControlOverUnits: 0x00274DD4, 0x0; // = 1 when in game and not a cut scene
    // todo: victory
    // int menu: 0x0013EC3C, 0x64; // = 46 when in fall of the trident campaign level select
}

init
{
    // vars.actualIGT = -1;
    vars.cutSceneOffset = -1;
}

start
{
    // if (old.menu > 0 && current.menu == 0) {
    //     return true;
    // }
    // todo: make sure starts after cut scene
    if (
        // vars.actualIGT == -1
        // && current.menu != 46
        current.hasControlOverUnits == 1
    ) {
        // vars.actualIGT = 0;
        // vars.cutSceneOffSet = current.missionTimer;
        return true;
    }
}

startup
{
    // todo: each campaign?
    // todo: fps?
    settings.Add("Individual Level");
    settings.SetToolTip("Individual Level", "Check this box for IL runs - it will reset the timer without having to go back to the menu");

    //Asks the user to set their timer to game time on livesplit, which is needed for verification
    // if (timer.CurrentTimingMethod == TimingMethod.RealTime) // Inspired by the Modern warfare 3 Autosplitter
    // {        
    //     var timingMessage = MessageBox.Show (
    //         "This game uses Time without Loads (Game Time) as the main timing method.\n"+
    //         "LiveSplit is currently set to show Real Time (RTA).\n"+
    //         "Would you like to set the timing method to Game Time? This will make verification easier.",
    //         "LiveSplit | Devil May Cry 4",
    //         MessageBoxButtons.YesNo,MessageBoxIcon.Question);
    //     if (timingMessage == DialogResult.Yes)
    //     {
    //         timer.CurrentTimingMethod = TimingMethod.GameTime;
    //     }
    // }
}

split
{
    // if (settings["Individual Level"]) {
    //     if (current.victory == 1 && old.victory == 0) {
    //         return true;
    //     }
    // }
}

reset
{
    // if (settings["Individual Level"]) {
    //     if (
    //             current.missionTimer < old.missionTimer
    //             // || current.menu == 46
    //             || current.missionNumber != old.missionNumber
    //         ) {
    //             vars.actualIGT = -1;
    //         return true;
    //     } else {
    //         return false;
    //     }
    // } else {
    //     return false; // TODO
    // }
}

gameTime
{
    // if (settings["Individual Level"]) {
    //     vars.actualIGT += current.missionTimer - old.missionTimer;
    //     return TimeSpan.FromSeconds(vars.actualIGT)
    // }
}