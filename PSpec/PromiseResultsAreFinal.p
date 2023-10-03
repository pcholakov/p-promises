event PromiseInit: (id: int);

event PromiseStateChanged: TPromiseStateChanged;
type TPromiseStateChanged = (id: int, status: PromiseState, value: TValue);

// Promise safety property: once a promise result is set, it can never be set again
spec PromiseResultNeverChangesOnceSet observes PromiseInit, ResolvePromiseRequest, RejectPromiseRequest {
  var promises: map[int, (status: PromiseState, value: TValue)];

  start state Init {
    on PromiseInit goto ObservePromises with (config: ( id: int )) {
        promises[config.id] = (status = PENDING, value = default(TValue));
    }
  }

  state ObservePromises {
    on ResolvePromiseRequest do (request: TResolvePromiseRequest) {
      assert request.id in promises,
        format ("Unknown promise id {0}. Valid ids = {1}", request.id, keys(promises));
    }

    on RejectPromiseRequest do (request: TRejectPromiseRequest) {
      assert request.id in promises,
        format ("Unknown promise id {0}. Valid ids = {1}", request.id, keys(promises));
    }

    on PromiseStateChanged do (input: TPromiseStateChanged) {
      assert input.status == RESOLVED || input.status == REJECTED,
        format ("Invalid promise state {0}", input.status);
      assert promises[input.id].status == PENDING || (promises[input.id].status == input.status && promises[input.id].value == input.value),
        format ("Promise {0} already settled: {1}, but attempt to change to: {2}", input.id, promises[input.id], input);
      promises[input.id] = (status = input.status, value = input.value);
    }
  }
}

// Promise liveness property: an outstanding promise will eventually be resolved
spec PendingPromisesAreEventuallySettled observes PromiseInit, ResolvePromiseRequest, RejectPromiseRequest {
  var pendingPromises: set[int];

  start state Init {
    on PromiseInit do (config: ( id: int )) {
        pendingPromises += (config.id);
        goto ObservePromises;
    }
  }

  hot state ObservePromises {
    on ResolvePromiseRequest do (request: TResolvePromiseRequest) {
      assert request.id in pendingPromises,
        format ("Unknown promise id {0}. Valid ids = {1}", request.id, pendingPromises);
    }

    on RejectPromiseRequest do (request: TRejectPromiseRequest) {
      assert request.id in pendingPromises,
        format ("Unknown promise id {0}. Valid ids = {1}", request.id, pendingPromises);
    }

    on PromiseStateChanged do (input: TPromiseStateChanged) {
      assert input.status == RESOLVED || input.status == REJECTED,
        format ("Invalid promise state {0}", input.status);
      assert input.id in pendingPromises,
        format ("Promise {0} is not pending", input.id);
      pendingPromises -= (input.id);
      if (sizeof(pendingPromises) == 0) {
        goto AllSettled;
      }
    }
  }

  cold state AllSettled {
    // Final state
  }
}