type rec t = {
  name: string,
  color: color,
  description: string,
  skillTypes: array<skillType>,
  castTime: float,
  baseFlags: baseFlags,
  baseMods: array<unit>,
  qualityStats: Belt.Map.String.t<array<(string, float)>>,
  stats: array<string>,
  levels: array<level>,
}
and color = White | Green | Blue | Red
and skillType = Spell | Movement | Duration | Travel
and baseFlags = {
  spell: bool,
  movement: bool,
  duration: bool,
  travel: bool,
}
and level = {
  data: (int, int, int, int, int),
  levelRequirement: int,
  duration: float,
  cooldown: int,
  statInterpolation: (int, int, int, int, int),
  cost: cost,
}
and cost = {mana: int}
