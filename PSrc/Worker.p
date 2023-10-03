machine Worker
{
  var resultHolder: Promise;
  var promiseId: int;
  var computedValue: TValue;

  start state Init {
    entry (config: (promiseId: int, promise: Promise)) {
      promiseId = config.promiseId;
      resultHolder = config.promise;
      goto Computing;
    }
  }

  state Computing {
    entry {
      var outcome: int;

      // Non-determinism: we could either succeed, encounter an error (and reject the promise), or just crash
      outcome = choose(3);
      if (outcome == 0) {
        computedValue = "<result>";
        goto Completed;
      } else if (outcome == 1) {
        goto Error;
      } else {
        goto Failure;
      }
    }
  }

  cold state Completed {
    entry {
      send resultHolder, ResolvePromiseRequest, (id = promiseId, value = computedValue, worker = this);
    }
  }

  cold state Error {
    entry {
      send resultHolder, RejectPromiseRequest, (id = promiseId, worker = this);
    }
  }

  cold state Failure {
    // Crashed state
  }
}
