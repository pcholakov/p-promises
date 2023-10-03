event PromiseCompleted: TPromiseCompleted;
type TPromiseCompleted = (result: TValue);

// Downstream client waiting on a computation reflected in a promise
machine Client
{
  var awaitedResult: Promise;
  var result: TValue;

  start state Init {
    entry (promise: Promise) {
      awaitedResult = promise;
      goto Waiting;
    }
  }

  state Waiting {
    on PromiseCompleted do (promiseResult: TValue) {
      result = promiseResult;
      goto ContinueProcessing;
	  }
  }

  state ContinueProcessing {
    entry {
      assert(result != null);

      // Get on with our work
    }
  }
}
