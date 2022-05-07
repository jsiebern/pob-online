module TestComponent = {
  @react.component
  let make = () => <div> {React.string("React test")} </div>
}

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<TestComponent />, root)
| None => ()
}

type scale = {
  x: float,
  y: float,
}
type coordinate = {
  x: int,
  y: int,
}
let worldToScreen = (~cWorld: coordinate, offset: coordinate): coordinate => {
  x: cWorld.x - offset.x,
  y: cWorld.y - offset.y,
}
let screenToWorld = (~cScreen: coordinate, offset: coordinate): coordinate => {
  x: cScreen.x + offset.x,
  y: cScreen.y + offset.y,
}

@val external document: 'a = "document"

let deltaY: ref<array<float>> = ref([])
document["addEventListener"](."wheel", event => {
  let dY: float = event["deltaY"]
  deltaY.contents |> Js.Array.push(dY)
})

open Reprocessing

type renderState = {cOffset: coordinate, startPan: option<coordinate>, deltaY: float, scale: scale}

let setup = env => {
  Env.size(~width=720, ~height=468, env)
  {cOffset: {x: 0, y: 0}, startPan: None, deltaY: 0.0, scale: {x: 1.0, y: 1.0}}
}

let draw = (state, env) => {
  let state = switch deltaY.contents->Js.Array.shift {
  | None => {...state, deltaY: 0.0}
  | Some(dY) =>
    let factor = 1. -. dY /. 1000.
    {
      ...state,
      deltaY: dY,
      scale: {
        x: dY > 0. ? state.scale.x *. factor : state.scale.x *. factor,
        y: dY > 0. ? state.scale.y *. factor : state.scale.y *. factor,
      },
    }
  }

  Draw.background(Constants.black, env)
  Draw.fill(Constants.red, env)

  let rectPosW = {x: 50, y: 50}
  let rectPosS = worldToScreen(~cWorld=rectPosW, state.cOffset)
  Draw.rect(
    ~pos=(
      int_of_float(float_of_int(rectPosS.x) *. state.scale.x),
      int_of_float(float_of_int(rectPosS.y) *. state.scale.y),
    ),
    ~width=int_of_float(100. *. state.scale.x),
    ~height=int_of_float(100. *. state.scale.y),
    env,
  )
  state
}

run(
  ~setup,
  ~draw,
  ~mouseDown=(state, env) => {
    let (x, y) = env->Env.mouse
    {...state, startPan: Some({x: x, y: y})}
  },
  ~mouseDragged=(state, env) => {
    let (x, y) = env->Env.mouse
    switch state.startPan {
    | Some(pan) => {
        ...state,
        cOffset: {x: state.cOffset.x - (x - pan.x), y: state.cOffset.y - (y - pan.y)},
        startPan: Some({x: x, y: y}),
      }
    | None => state
    }
  },
  ~mouseUp=(state, _env) => {...state, startPan: None},
  (),
)
