import Rcllean
import StdMsgs
import RclleanExampleInterfaces

open Rcllean

namespace RclleanExamples

/-- Build a heartbeat for this node.  The load figures are clamped into
`[0, 100]`; `clampLoad_cases` below proves the clamp total. -/
def mkHeartbeat (nodeName : String) (sequence : UInt32) (raw : Vector Float 3)
    (healthy : Bool) : RclleanExampleInterfaces.Msg.Heartbeat :=
  { header := {}
    node_name := nodeName
    sequence := sequence
    load := raw.map clampLoad
    healthy := healthy }
where
  /-- Clamp an untrusted reading into `[0, 100]`; NaN becomes `0.0`. -/
  clampLoad (x : Float) : Float :=
    if x.isNaN then 0.0
    else if x < 0.0 then 0.0
    else if x > 100.0 then 100.0
    else x

/-- The clamp returns `0.0`, `100.0`, or its argument unchanged.  Stated
case-wise because core Lean's `Float` carries no order lemmas. -/
theorem clampLoad_cases (x : Float) :
    mkHeartbeat.clampLoad x = 0.0 ∨ mkHeartbeat.clampLoad x = 100.0 ∨
    mkHeartbeat.clampLoad x = x := by
  unfold mkHeartbeat.clampLoad
  split
  · exact Or.inl rfl
  · split
    · exact Or.inl rfl
    · split
      · exact Or.inr (Or.inl rfl)
      · exact Or.inr (Or.inr rfl)

end RclleanExamples
