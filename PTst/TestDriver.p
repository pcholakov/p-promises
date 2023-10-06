machine TestWithSinglePromise
{
  start state Init {
    entry {
      SetupPromiseWorkers(1);
    }
  }
}

fun SetupPromiseWorkers(numWorkers: int) {
    var i: int;
    var promise: Promise;
    var worker: Worker;
    var timer: Timer;

    i = 1;
    while (i <= numWorkers) {
      promise = new Promise(i);
      announce PromiseInit, (id = i,);
      worker = new Worker((promiseId = i, promise = promise));
      timer = CreateTimer(promise);
      StartTimer(timer);
      i = i + 1;
    }
}
