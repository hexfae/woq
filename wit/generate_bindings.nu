const SELF = path self | path join .. | path expand
const DEFINITIONS = ["graphics-context" "surface" "frame-buffer" "webgpu"]

export def main [] {
  help main
}

export def "main rust" [] {
 let graphics_context = $SELF | path join definitions graphics-context
 for item in $DEFINITIONS {
    let path = $SELF | path join definitions $item
   wit-bindgen rust --generate-all $path --out-dir ($SELF | path join guest_bindings $item rust )
 }
}
