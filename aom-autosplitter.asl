// todo: aot & vanilla
state("AoMX", "EE")
{
    /*
        Fall of the Trident mission number -> name -> value:
        0   Prologue                0
        1   Omens                   1
        2   Consequences            3
        3   Scratching the Surface  5
        4   A Fine Plan             6
        5   Just Enough Rope        7
        6   I Hope This Works       9
        7   More Bandits            12
        8   Bad News                14
        9   Revelation              16
        10  Strangers               18
        11  The Lost Relic          21
        12  Light Sleeper           23
        13  Tug of War              24
        14  "Isis, Hear My Plea"    25
        15  Let's Go                27
        16  Good Advice             28
        17  The Jackal's Stronghold 31
        18  A Long Way From Home    33
        19  Watch That First Step   34
        20  Where They Belong       36
        21  Old Friends             38
        22  North                   41
        23  The Dwarven Forge       43
        24  Not From Around Here    46
        25  Welcoming Committee     47
        26  Union                   48
        27  The Well of Urd         49
        28  Beneath the Surface     51
        29  Unlikely Heroes         53
        30  All Is Not Lost         55
        31  Welcome Back            57
        32  A Place in My Dreams    58
    */
    int missionNumber: 0x007F828C, 0x348, 0xDD4;

    float missionTimer: 0x00352038, 0x0; // in seconds
    int isInCutScene: 0x00831BD8, 0x1D0;// is 0 when in cut scene, 1 otherwise
    // todo: remove cut scene time
    // todo: add (real time) pause times + menu times
    int victory: 0x007F8288, 0x54C, 0x14; // goes from 1->0 when "You are Victorious!" is displayed
    // todo: victory depends on mission number
    int isInMenu: 0x0085CDB8, 0x0, 0x4, 0x4; // is 0 when in menu, > 0 otherwise (strictly increases, maybe related to timer?)
}

startup
{
    settings.Add("Individual Level");
    settings.SetToolTip("Individual Level", "Check this box for IL runs");
    // todo: campaign selection in settings

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

    // mission number state to displayed mission number:
    vars.missionStateToMissionNumber = new Dictionary<int, int>() {
        {0, 0}, // Prologue
        {1, 1}, // Omens
        {3, 2}, // Consequences
        {5, 3}, // Scratching the Surface
        {6, 4}, // A Fine Plan
        {7, 5}, // Just Enough Rope
        {9, 6}, // I Hope This Works
        {12, 7}, // More Bandits
        {14, 8}, // Bad News
        {16, 9}, // Revelation
        {18, 10}, // Strangers
        {21, 11}, // The Lost Relic
        {23, 12}, // Light Sleeper
        {24, 13}, // Tug of War
        {25, 14}, // "Isis, Hear My Plea"
        {27, 15}, // Let's Go
        {28, 16}, // Good Advice
        {31, 17}, // The Jackal's Stronghold
        {33, 18}, // A Long Way From Home
        {34, 19}, // Watch That First Step
        {36, 20}, // Where They Belong
        {38, 21}, // Old Friends
        {41, 22}, // North
        {43, 23}, // The Dwarven Forge
        {46, 24}, // Not From Around Here
        {47, 25}, // Welcoming Committee
        {48, 26}, // Union
        {49, 27}, // The Well of Urd
        {51, 28}, // Beneath the Surface
        {53, 29}, // Unlikely Heroes
        {55, 30}, // All Is Not Lost
        {57, 31}, // Welcome Back
        {58, 32}, // A Place in My Dreams
    };
}

init
{
    vars.cutSceneOffset = -1;
}

start
{
    if (settings["Individual Level"]) {

    }
    // if (
    //     current.isInMenu != 0
    //     && old.isInCutScene == 0
    //     && current.isInCutScene == 1
    // ) {
    //     vars.cutSceneOffset = current.missionTimer;
    //     return true;
    // }
}

split
{
    if (settings["Individual Level"]) {

    }
    // if (
    //     current.isInMenu != 0
    //     && current.victory == 0
    //     && old.victory == 1
    // ) {
    //     return true;
    // }
    
}

gameTime
{
    return TimeSpan.FromSeconds(current.missionTimer - vars.cutSceneOffset);
}