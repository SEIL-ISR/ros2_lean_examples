import RclleanMathlibExamples
import Rcllean
import RclleanExampleInterfaces

open Rcllean RclleanMathlibExamples

/-- Subscribes to `/heartbeat` and reports whether the sequence number
advanced by one, counting missed beats across the 2^32 wrap.

```
ros2 run rcllean_mathlib_examples heartbeat-auditor
```
-/
def main (args : List String) : IO Unit := do
  let ctx ← Rcllean.init args
  let node ← Node.create ctx "heartbeat_auditor"
  let last ← IO.mkRef (none : Option UInt32)

  let sub ← node.createSubscription RclleanExampleInterfaces.Msg.Heartbeat
    topic!"heartbeat" fun msg => do
      match ← last.modifyGet fun prev => (prev, some msg.sequence) with
      | none => node.logInfo s!"#{msg.sequence} first beat, nothing to compare"
      | some prev =>
        -- `gap_eq_zero_iff` : this test holds exactly when the counter
        -- advanced by one in `ZMod (2^32)`.
        let missed := gap prev msg.sequence
        if missed == 0 then
          node.logInfo s!"#{prev} -> #{msg.sequence} consecutive"
        else
          node.logWarn s!"#{prev} -> #{msg.sequence} missed {missed}"

  let ex ← Executor.create ctx
  ex.addSubscription sub
  node.logInfo s!"auditing {← sub.topicName}"
  ex.spin

  -- Destroy the node before the context; `Node.destroy` says why.
  sub.destroy
  node.destroy
  ctx.shutdown
