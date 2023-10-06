type TValue = data;

enum PromiseState { PENDING, RESOLVED, REJECTED, REJECTED_CANCELED, REJECTED_TIMED_OUT }

event ResolvePromiseRequest: TResolvePromiseRequest;
type TResolvePromiseRequest = (id: int, value: TValue, worker: Worker);

event RejectPromiseRequest: TRejectPromiseRequest;
type TRejectPromiseRequest = (id: int, worker: Worker);

// event CancelPromiseRequest: TCancelPromiseRequest;
// type TCancelPromiseRequest =(id: int, worker: Worker);

event GetPromiseRequest: TGetPromiseRequest;
type TGetPromiseRequest = (id: int, client: machine);

event GetPromiseResponse: TGetPromiseResponse;
type TGetPromiseResponse = (id: int, status: PromiseState, value: TValue );

machine Promise
{
  var id: int;
  var value: TValue;

  start state Init {
    entry (_id: int) {
      id = _id;
      goto Pending;
    }
  }

  state Pending {
    on ResolvePromiseRequest do (request: TResolvePromiseRequest) {
      if (request.id == id && value == null) {
        value = request.value;
        announce PromiseStateChanged, (id = id, status = RESOLVED, value = value);
        goto Resolved;
      }
    }

    on RejectPromiseRequest do (request: TRejectPromiseRequest) {
      if (request.id == id) {
        announce PromiseStateChanged, (id = id, status = REJECTED, value = value);
        goto Rejected;
      }
    }

    on eTimeOut goto Rejected with {
      announce PromiseStateChanged, (id = id, status = REJECTED_TIMED_OUT, value = value);
    }
    
    // on CancelPromiseRequest do (request: TCancelPromiseRequest) {
	    //   if (request.id == id) {
	    //     goto RejectedCanceled;
    //   }
    // }
  }

  state Resolved {
    on GetPromiseRequest do (request: TGetPromiseRequest) {
      if (request.id == id) {
        send request.client, GetPromiseResponse, (id = id, status = RESOLVED, value = value);
      }
    }
    ignore RejectPromiseRequest, ResolvePromiseRequest, eTimeOut;
  }

  state Rejected {
    on GetPromiseRequest do (request: TGetPromiseRequest) {
      if (request.id == id) {
        send request.client, GetPromiseResponse, (id = id, status = REJECTED, value = value);
      }
	  }
    ignore RejectPromiseRequest, ResolvePromiseRequest, eTimeOut;
  }

  // state RejectedCanceled {
	//   on GetPromiseRequest do (request: TGetPromiseRequest) {
		// 	  if (request.id == id) {
		// 	    send request.client, GetPromiseResponse, (id = id, status = REJECTED_CANCELED, value = value);
  //     }
	//   }
  // }
}
