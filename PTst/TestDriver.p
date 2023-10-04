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

    i = 1;
    while (i <= numWorkers) {
      promise = new Promise(i);
      worker = new Worker((promiseId = i, promise = promise));
      announce PromiseInit, (id = i,);
      i = i + 1;
    }
}
