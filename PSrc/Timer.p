event eStartTimer;
event eCancelTimer;
event eTimeOut;
event eDelayedTimeOut;

machine Timer {
  var client: machine;
  start state Init {
    entry (_client : machine) {
      client = _client;
      goto WaitForTimerRequests;
    }
  }

  state WaitForTimerRequests {
    on eStartTimer goto TimerStarted;
    ignore eCancelTimer, eDelayedTimeOut;
  }

  state TimerStarted {
    defer eStartTimer;
    entry {
      if($) {
        send client, eTimeOut;
        goto WaitForTimerRequests;
      } else {
        send this, eDelayedTimeOut;
      }
    }
    on eDelayedTimeOut goto TimerStarted;
    on eCancelTimer goto WaitForTimerRequests;
  }
}

fun CreateTimer(client: machine): Timer {
  return new Timer(client);
}

fun StartTimer(timer: Timer) {
  send timer, eStartTimer;
}

fun CancelTimer(timer: Timer) {
  send timer, eCancelTimer;
}
