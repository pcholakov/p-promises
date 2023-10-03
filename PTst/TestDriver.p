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
    var promiseId: (id: int);

    i = 1;
    while (i <= numWorkers) {
      promise = new Promise(i);
      worker = new Worker((promiseId = i, promise = promise));
      
      // Ugh – workaround for announce ..., (id = i) causing "no viable alternative at input 'id=i)'"
      promiseId.id = i;
      announce PromiseInit, promiseId;

      i = i + 1;
    }
}
