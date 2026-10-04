def study_skill
  $game_party.actors[0].skills=[]
  actor=$game_party.actors[0]
  case $game_variables[32]
  when 73
    actor.learn_skill(6)
  when 74
    actor.learn_skill(9)
    actor.learn_skill(10)
  when 75
    actor.learn_skill(12)
    actor.learn_skill(13)
  when 77
    actor.learn_skill(25)
  end
  if actor.weapon_id==0
    case $game_variables[29]
    when 53
      actor.learn_skill(3)
    when 54
      actor.learn_skill(2)
    when 58
      actor.learn_skill(19)
      actor.learn_skill(16)
      actor.learn_skill(17)
      actor.learn_skill(18)
    when 59
      actor.learn_skill(23)
    end
  else
    if weapon_matching_skill?
      case $game_variables[30]
      when 80
        actor.learn_skill(4) if $game_variables[29]==53
        actor.learn_skill(5) if $game_variables[29]==54
      when 81
        actor.learn_skill(8)
      when 82
        actor.learn_skill(14)
        actor.learn_skill(15)
      when 85
        actor.learn_skill(21)
        actor.learn_skill(20)
        actor.learn_skill(22)
      when 86
        actor.learn_skill(24)
      when 88
        actor.learn_skill(7)
      when 89
        actor.learn_skill(11)
      end
    end
  end
end