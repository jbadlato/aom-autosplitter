// todo: aot & vanilla
state("AoMX", "EE")
{
    int missionState: 0x007F828C, 0x348, 0xDD4;
    float missionTimer: 0x00352038, 0x0; // in seconds
    int isInCutScene: 0x00831BD8, 0x1D0;// is 0 when in cut scene, 1 otherwise
    int missionLoadScreen: 0x000612F4, 0x0; // is 0 when loading, 256 otherwise
    int inGame: 0x001DF778, 0x0; // 59, 61, or 1 when in game. 43 in menu, 53 in cinematic? Feels like there has to be something better to watch here.
    // todo: remove cut scene time
    // todo: add (real time) pause times + menu times
    int victory: 0x007F8288, 0x54C, 0x14; // goes from 1->0 when "You are Victorious!" is displayed
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
        //{0, 0}, // Prologue
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
    vars.missionNumberToStartFunc = new Dictionary<int, Func<dynamic, dynamic, bool>>() {};
    // Default start detection (this works for most missions)
    HashSet<int> inGameValues = new HashSet<int>();
    inGameValues.Add(1);
    inGameValues.Add(59);
    inGameValues.Add(61);
    Func<dynamic, dynamic, bool> defaultStartFunc = (oldState, currentState) => {
        if (
            !inGameValues.Contains(oldState.inGame)
            && inGameValues.Contains(currentState.inGame)
            && currentState.missionTimer > 0
        ) {
            vars.cutSceneOffset = currentState.missionTimer;
            return true;
        }
        return false;
        };
    foreach (int missionNumber in vars.missionStateToMissionNumber.Values) {
        vars.missionNumberToStartFunc.Add(missionNumber, defaultStartFunc);
    }
    vars.missionNumberToSplitFunc = new Dictionary<int, Func<dynamic, dynamic, bool>>() {};
    // Default split detection (this works for most missions)
    Func<dynamic, dynamic, bool> defaultSplitFunc = (oldState, currentState) => {
            if (
                currentState.isInMenu != 0
                && currentState.victory == 0
                && oldState.victory == 1
            ) {
                return true;
            }
            return false;
        };
    foreach (int missionNumber in vars.missionStateToMissionNumber.Values) {
        vars.missionNumberToSplitFunc.Add(missionNumber, defaultSplitFunc);
    }
}

start
{
    if (settings["Individual Level"]) {
        return vars.missionNumberToStartFunc[vars.missionStateToMissionNumber[current.missionState]](old, current);
    }
}

split
{
    if (settings["Individual Level"]) {
        return vars.missionNumberToSplitFunc[vars.missionStateToMissionNumber[current.missionState]](old, current);
    }
}

gameTime
{
    return TimeSpan.FromSeconds(current.missionTimer - vars.cutSceneOffset);
}