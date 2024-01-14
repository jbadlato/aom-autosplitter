// todo: aot & vanilla
state("AoMX", "EE")
{
    int missionState: 0x007F828C, 0x348, 0xDD4;
    float missionTimer: 0x00352038, 0x0; // in seconds
    int isInCutScene: 0x00831BD8, 0x1D0;// is 0 when in cut scene, 1 otherwise
    int missionLoadScreen: 0x000612F4, 0x0; // is 0 when loading, 256 otherwise
    // todo: remove load time
    // todo: add (real time) pause times + menu times
    int victory: 0x007F8288, 0x54C, 0x14; // goes from 1->0 when "You are Victorious!" is displayed
    int isInMenu: 0x0085CDB8, 0x0, 0x4, 0x4; // is 0 when in menu, > 0 otherwise (strictly increases, maybe related to timer?)
}

startup
{
    settings.Add("Individual Level");
    settings.SetToolTip("Individual Level", "Check this box for IL runs");

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
        {29, 16}, // Good Advice Part 2
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
    Func<dynamic, dynamic, bool> defaultStartFunc = (oldState, currentState) => {
        if (
            (oldState.missionTimer <= 0 && currentState.isInCutScene != 0 && currentState.missionTimer > 0)
            || (oldState.isInCutScene == 0 && currentState.isInCutScene != 0 && currentState.missionTimer > 0)
        ) {
            vars.cutSceneOffset = currentState.missionTimer;
            return true;
        }
        return false;
        };
    vars.defaultStartFunc = defaultStartFunc;
    foreach (int missionNumber in vars.missionStateToMissionNumber.Values) {
        if (!vars.missionNumberToStartFunc.ContainsKey(missionNumber)) {
            vars.missionNumberToStartFunc.Add(missionNumber, defaultStartFunc);
        }
    }

    vars.missionNumberToSplitFunc = new Dictionary<int, Func<dynamic, dynamic, bool>>() {};
    // Default split detection (this works for most missions)
    Func<dynamic, dynamic, bool> defaultSplitFunc = (oldState, currentState) => {
            if (
                currentState.missionState > oldState.missionState
            ) {
                return true;
            }
            return false;
        };
    vars.defaultSplitFunc = defaultSplitFunc;
    // Good Advice has two parts, mission state goes from 28 -> 29 -> 30.
    // Need to add up the mission times of 28->29 & 29->30
    // We can exploit cutScene offset for this, using a negative one.
    Func<dynamic, dynamic, bool> goodAdviceSplitFunc = (oldState, currentState) => {
        if (currentState.missionState == 30) {
            return true;
        }
        if (oldState.missionState == 28 && currentState.missionState == 29) {
            vars.cutSceneOffset = vars.cutSceneOffset - currentState.missionTimer;
        }
        if (currentState.missionState == 29 && oldState.isInCutScene == 0 && currentState.isInCutScene == 1) {
            vars.cutSceneOffset = vars.cutSceneOffset + currentState.missionTimer;
        }
        return false;
    };
    vars.missionNumberToSplitFunc.Add(16, goodAdviceSplitFunc);
    foreach (int missionNumber in vars.missionStateToMissionNumber.Values) {
        if (!vars.missionNumberToSplitFunc.ContainsKey(missionNumber)) {
            vars.missionNumberToSplitFunc.Add(missionNumber, defaultSplitFunc);
        }
    }
    vars.timingAcknowledgement = false;
}

update {
    //Asks the user to set their timer to game time on livesplit, which is needed for verification
    if (
        !vars.timingAcknowledgement
        && timer.CurrentTimingMethod == TimingMethod.RealTime
        && settings["Individual Level"]
    ) // Inspired by the Modern warfare 3 Autosplitter
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
        } else {
            vars.timingAcknowledgement = true;
        }
    }
    if (
        !vars.timingAcknowledgement
        && timer.CurrentTimingMethod == TimingMethod.GameTime
        && !settings["Individual Level"]
    ) 
    {        
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Real Time? This will make verification easier.",
            "LiveSplit | Age of Mythology",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question);
        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.RealTime;
        } else {
            vars.timingAcknowledgement = true;
        }
    }
}

init
{
    vars.cutSceneOffset = -1;
}

start
{
    if (settings["Individual Level"]) {
        if (!vars.missionStateToMissionNumber.ContainsKey(current.missionState)) {
            return vars.defaultStartFunc(old, current);
        }
        return vars.missionNumberToStartFunc[vars.missionStateToMissionNumber[current.missionState]](old, current);
    } else {
        if (
            current.missionState == 1 && (
                (old.missionTimer <= 0 && current.isInCutScene != 0 && current.missionTimer > 0)
                || (old.isInCutScene == 0 && current.isInCutScene != 0 && current.missionTimer > 0)
            )
        ) {
            return true;
        }
    }
}

split
{
    if (settings["Individual Level"]) {
        if (!vars.missionStateToMissionNumber.ContainsKey(current.missionState)) {
            return vars.defaultSplitFunc(old, current);
        }
        return vars.missionNumberToSplitFunc[vars.missionStateToMissionNumber[current.missionState]](old, current);
    } else {
        if (
            vars.missionStateToMissionNumber.ContainsKey(old.missionState)
            && current.missionState > old.missionState
            && old.missionState != 28 // Don't split after first part of good advice
        ) {
            return true;
        }
        return false;
    }
}

gameTime
{
    return TimeSpan.FromSeconds(current.missionTimer - vars.cutSceneOffset);
}