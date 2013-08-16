### fsm.js

  fsm = new FSM( states: ["asleep", "awake", "standing", "sitting"], initialState: "asleep" )

  # We can transition from one or many states, but we can only transition to one state.
  fsm.event("shake",        transition: { from: "asleep", to: "awake" })
     .event("sleeperHold",  transition: { from: ["awake", "standing", "sitting"], to: "asleep" })
     .before("shake",       -> console.log("wake up, Jack!"))
     .after("sleeperHold",  -> console.log("..."))