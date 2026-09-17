import RclleanExamples

open Rcllean RclleanExamples

/-- Publishes a custom `rcllean_example_interfaces/msg/Heartbeat` on
`/heartbeat`.

The message type comes from an interface package that mentions no Lean;
`rosidl_generator_lean` produced the bindings during its colcon build.

```
ros2 run rcllean_examples heartbeat-publisher
ros2 topic echo /heartbeat
```
-/
def main (args : List String) : IO Unit := do
  let ctx ← Rcllean.init args
  let node ← Node.create ctx "heartbeat_publisher"
  let pub ← node.createPublisher RclleanExampleInterfaces.Msg.Heartbeat
    topic!"heartbeat"
  let clock ← Clock.steady
  let count ← IO.mkRef (0 : UInt32)

  let timer ← Timer.create ctx clock (Duration.ofMillis 500) do
    let n ← count.modifyGet fun n => (n, n + 1)
    -- Out of range, to exercise the clamp.
    let raw : Vector Float 3 := #v[0.42, 1.7, 250.0]
    let msg := mkHeartbeat (← node.fullyQualifiedName) n raw true
    pub.publish msg
    node.logInfo s!"heartbeat {n} load={msg.load.toArray.toList}"

  let ex ← Executor.create ctx
  ex.addTimer timer
  node.logInfo s!"publishing on {← pub.topicName}"
  ex.spin

  -- Destroy the node before the context; `Node.destroy` says why.
  pub.destroy
  node.destroy
  ctx.shutdown
