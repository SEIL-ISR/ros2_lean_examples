import Rcllean
import RclleanExampleInterfaces

open Rcllean

/-- Serves the custom `rcllean_example_interfaces/srv/AddThreeInts`.

```
ros2 run rcllean_examples add-three-ints-server
ros2 service call /add_three_ints \
  rcllean_example_interfaces/srv/AddThreeInts "{a: 1, b: 2, c: 3}"
```
-/
def main (args : List String) : IO Unit := do
  let ctx ← Rcllean.init args
  let node ← Node.create ctx "add_three_ints_server"

  let srv ← node.createService RclleanExampleInterfaces.Srv.AddThreeInts
    topic!"add_three_ints" fun req => do
      node.logInfo s!"{req.a} + {req.b} + {req.c}"
      return { sum := req.a + req.b + req.c }

  let ex ← Executor.create ctx
  ex.addService srv
  node.logInfo s!"ready on {← srv.name}"
  ex.spin

  -- Destroy the node before the context; `Node.destroy` says why.
  srv.destroy
  node.destroy
  ctx.shutdown
