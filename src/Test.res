module TestComponent = {
  @react.component
  let make = () => <div> {React.string("React test")} </div>
}

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<TestComponent />, root)
| None => ()
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

open Reprocessing

type renderState = {cOffset: coordinate, startPan: option<coordinate>}

let setup = env => {
  Env.size(~width=720, ~height=468, env)
  {cOffset: {x: 0, y: 0}, startPan: None}
}

let draw = (state, env) => {
  Draw.background(Constants.black, env)
  Draw.fill(Constants.red, env)

  let rectPosW = {x: 50, y: 50}
  let rectPosS = worldToScreen(~cWorld=rectPosW, state.cOffset)
  Draw.rect(~pos=(rectPosS.x, rectPosS.y), ~width=100, ~height=100, env)
  state
}

run(
  ~setup,
  ~draw,
  ~mouseDown=(state, env) => {
    let (x, y) = Env.mouse(env)
    {...state, startPan: Some({x: x, y: y})}
  },
  ~mouseDragged=(state, env) => {
    let (x, y) = Env.mouse(env)
    switch state.startPan {
    | Some(pan) => {
        cOffset: {x: state.cOffset.x - (x - pan.x), y: state.cOffset.y - (y - pan.y)},
        startPan: Some({x: x, y: y}),
      }
    | None => state
    }
  },
  ~mouseUp=(state, _env) => {...state, startPan: None},
  (),
)
