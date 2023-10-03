type TValue = data;

enum PromiseState { PENDING, RESOLVED, REJECTED, REJECTED_CANCELED }

event ResolvePromiseRequest: TResolvePromiseRequest;
type TResolvePromiseRequest = (id: int, value: TValue, worker: Worker);

event RejectPromiseRequest: TRejectPromiseRequest;
type TRejectPromiseRequest = (id: int, worker: Worker);

event CancelPromiseRequest: TCancelPromiseRequest;
type TCancelPromiseRequest =(id: int, worker: Worker);

event GetPromiseRequest: TGetPromiseRequest;
type TGetPromiseRequest =(id: int, client: machine);

event GetPromiseResponse: TGetPromiseResponse;
type TGetPromiseResponse = (id: int, status: PromiseState, value: TValue );

machine Promise
{
  var id: int;
  var value: TValue;
  var timeout: int;

  start state Init {
    entry (config: (id: int, timeout: int)) {
      id = config.id;
      timeout = config.timeout;
      // value = null;

      goto Pending;
    }
  }

  state Pending {
    on ResolvePromiseRequest do (request: TResolvePromiseRequest) {
      if (request.id == id && value == null) {
        value = request.value;
        goto Resolved;
      }
    }

    on RejectPromiseRequest do (request: TRejectPromiseRequest) {
      if (request.id == id) {
        goto Rejected;
      }
    }
    
    on CancelPromiseRequest do (request: TCancelPromiseRequest) {
      if (request.id == id) {
        goto RejectedCanceled;
      }
    }
  }

  state Resolved {
    on GetPromiseRequest do (request: TGetPromiseRequest) {
      if (request.id == id) {
        send request.client, GetPromiseResponse, (id = id, status = RESOLVED, value = value);
      }
    }
  }

  state Rejected {
    on GetPromiseRequest do (request: TGetPromiseRequest) {
      if (request.id == id) {
        send request.client, GetPromiseResponse, (id = id, status = REJECTED, value = value);
      }
	  }
  }

  state RejectedCanceled {
    on GetPromiseRequest do (request: TGetPromiseRequest) {
      if (request.id == id) {
        send request.client, GetPromiseResponse, (id = id, status = REJECTED_CANCELED, value = value);
      }
	  }
  }
}
