import Lake
open Lake DSL

/-! # rcllean_mathlib_examples

Like `rcllean_examples`, but the package also depends on Mathlib.  The
preamble below reads what the plugin and the installed packages' hooks set,
and falls back to ordinary Lake behaviour when those variables are absent.

Mathlib is pinned to the tag matching `lean-toolchain`.  Its `post_update`
hook runs `lake exe cache get`, so the build downloads oleans instead of
compiling Mathlib.
-/

-- Lake configuration fields are pure, so the environment is read through an
-- `opaque` backed by an unsafe implementation.
private unsafe def envImpl (key : String) : String :=
  match unsafeBaseIO (IO.getEnv key) with
  | some v => v
  | none => ""

@[implemented_by envImpl]
opaque amentEnv (key : String) : String

def amentBuildDir : String :=
  let d := amentEnv "AMENT_LEAN_BUILD_DIR"
  if d.isEmpty then ".lake/build" else d

def amentPackage (name : String) : String :=
  amentEnv s!"AMENT_LEAN_PKG_{name.toUpper}"

/-- Linker flags for the ROS 2 libraries and every Lean dependency, from
the environment hooks of the installed packages.
Tab-separated, not space-separated, because a flag may carry a path containing
spaces.

Wrapped in a linker group: static archives resolve left to right, and the order
among a Lean library, its interface bindings and the C shim varies. -/
def amentLinkArgs : Array String :=
  let args := ((amentEnv "AMENT_LEAN_LINK_ARGS").splitOn "\t"
    |>.filter (!·.isEmpty)).toArray
  if args.isEmpty then #[]
  else #["-Wl,--start-group"] ++ args ++ #["-Wl,--end-group"]

require rcllean from amentPackage "rcllean"
require rcllean_example_interfaces from amentPackage "rcllean_example_interfaces"

-- The tag has to track `lean-toolchain`: Mathlib's cache is keyed on the
-- compiler, and a mismatch falls back to building Mathlib from source.
require mathlib from git "https://github.com/leanprover-community/mathlib4" @ "v4.33.1"

package rcllean_mathlib_examples where
  version := v!"0.1.0"
  description := "A Lean 4 ROS 2 node resting on a Mathlib proof"
  buildDir := amentBuildDir
  moreLinkArgs := amentLinkArgs

/-- Installed under `share/rcllean_mathlib_examples/launch`. -/
@[default_target]
input_dir launch

/-- Every module under `RclleanMathlibExamples/`, including the node. -/
@[default_target]
lean_lib RclleanMathlibExamples where
  srcDir := "."
  roots := #[`RclleanMathlibExamples]
  globs := #[.andSubmodules `RclleanMathlibExamples]

@[default_target]
lean_exe «heartbeat-auditor» where
  root := `RclleanMathlibExamples.HeartbeatAuditor
