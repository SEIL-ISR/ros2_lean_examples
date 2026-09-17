import Lake
open Lake DSL

/-! # rcllean_examples

A Lean ROS 2 package built by colcon through colcon-ros-lake.  The preamble
below reads the environment the plugin and the installed packages' hooks set
up, and falls back to ordinary Lake behaviour when those variables are absent,
so `lake build` and `colcon build` both work from this one file.
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

package rcllean_examples where
  version := v!"0.1.0"
  description := "Lean 4 ROS 2 nodes built with colcon"
  buildDir := amentBuildDir
  moreLinkArgs := amentLinkArgs

/-- Installed under `share/rcllean_examples/launch`. -/
@[default_target]
input_dir launch

/-- Every module under `RclleanExamples/`, including the node programs. -/
@[default_target]
lean_lib RclleanExamples where
  srcDir := "."
  roots := #[`RclleanExamples]
  globs := #[.andSubmodules `RclleanExamples]

@[default_target]
lean_exe «heartbeat-publisher» where
  root := `RclleanExamples.HeartbeatPublisher

@[default_target]
lean_exe «heartbeat-monitor» where
  root := `RclleanExamples.HeartbeatMonitor

@[default_target]
lean_exe «add-three-ints-server» where
  root := `RclleanExamples.AddThreeIntsServer
