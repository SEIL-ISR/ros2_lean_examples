import Mathlib.Data.ZMod.Basic

/-!
# Heartbeat sequence numbers

`Heartbeat.sequence` is a `uint32` that increments once per beat and wraps at
2^32.  `gap` counts the beats missed between two of them, and the auditor
treats `gap = 0` as consecutive.  `gap_eq_zero_iff` is the statement that makes
that test right across the wrap; `gap_toZMod` gives the count itself.

`UInt32` is a `BitVec 32`, `ZMod (2^32)` is `Fin (2^32)` by definition, and
Mathlib's ring structure on it is the wrapping arithmetic `UInt32` already
does, so `toZMod` is the identity on representations and every bridging lemma
below is `rfl` or one core `BitVec` rewrite.
-/

namespace RclleanMathlibExamples

/-- Beats missed between `last` and `next`.  `UInt32` subtraction wraps, so
`gap s (s + 1) = 0` for every `s`, 4294967295 included. -/
def gap (last next : UInt32) : Nat := (next - last - 1).toNat

/-- A sequence number as a residue modulo 2^32. -/
def toZMod (u : UInt32) : ZMod (2 ^ 32) := u.toFin

theorem toZMod_inj {a b : UInt32} : toZMod a = toZMod b ↔ a = b :=
  UInt32.toFin_inj

theorem toZMod_sub (a b : UInt32) : toZMod (a - b) = toZMod a - toZMod b := by
  show (a - b).toFin = _
  rw [UInt32.toFin_sub]
  rfl

theorem toZMod_zero : toZMod 0 = 0 := rfl

theorem toZMod_one : toZMod 1 = 1 := rfl

theorem natCast_gap (last next : UInt32) :
    ((gap last next : Nat) : ZMod (2 ^ 32)) = toZMod (next - last - 1) := by
  show ((ZMod.val (toZMod (next - last - 1)) : Nat) : ZMod (2 ^ 32)) = _
  simp [ZMod.natCast_val, ZMod.cast_id]

/-- The count the auditor reports is the modular difference minus one. -/
theorem gap_toZMod (last next : UInt32) :
    ((gap last next : Nat) : ZMod (2 ^ 32)) = toZMod next - toZMod last - 1 := by
  rw [natCast_gap, toZMod_sub, toZMod_sub, toZMod_one]

/-- The auditor's test: `gap = 0` exactly when the counter advanced by one
modulo 2^32. -/
theorem gap_eq_zero_iff (last next : UInt32) :
    gap last next = 0 ↔ toZMod next = toZMod last + 1 := by
  rw [gap, show (0 : Nat) = (0 : UInt32).toNat from rfl, UInt32.toNat_inj,
    ← toZMod_inj, toZMod_sub, toZMod_sub, toZMod_one, toZMod_zero, sub_sub,
    sub_eq_zero]

/-- The same test over `Fin (2^32)`, the representation `UInt32` carries. -/
theorem gap_eq_zero_iff_toFin (last next : UInt32) :
    gap last next = 0 ↔ next.toFin = last.toFin + 1 :=
  gap_eq_zero_iff last next

example : gap 5 7 = 1 := by decide
example : gap 4294967295 0 = 0 := by decide

-- Both report: propext, Quot.sound.
-- #print axioms gap_eq_zero_iff
-- #print axioms gap_toZMod

end RclleanMathlibExamples
