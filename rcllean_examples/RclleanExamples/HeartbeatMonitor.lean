import RclleanExamples

open Rcllean RclleanExamples

/-- Subscribes to `/heartbeat` and reports what it sees.

```
ros2 run rcllean_examples heartbeat-monitor
```
-/
def main (args : List String) : IO Unit := do
  let ctx ← Rcllean.init args
  let node ← Node.create ctx "heartbeat_monitor"

  let sub ← node.createSubscription RclleanExampleInterfaces.Msg.Heartbeat
    topic!"heartbeat" fun msg => do
      let state := if msg.healthy then "healthy" else "UNHEALTHY"
      node.logInfo
        s!"{msg.node_name} #{msg.sequence} {state} load={msg.load.toArray.toList}"

  let ex ← Executor.create ctx
  ex.addSubscription sub
  node.logInfo s!"monitoring {← sub.topicName}"
  ex.spin

  -- Destroy the node before the context; `Node.destroy` says why.
  sub.destroy
  node.destroy
  ctx.shutdown
