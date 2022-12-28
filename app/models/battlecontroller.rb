class BattleInfo
  attr_accessor :id, :game
  def initialize(id, game)
    @id = id;
    @game = game;
  end
end

class Battlecontroller
  include Singleton

  def initialize
    @battles = Array.new;
    @battle_id = 0;
  end

  def create_battle(mode,player1_id,
                    player2_id,player1_setup,player2_setup)
    rand = [[player1_id,player1_setup],[player2_id,player2_setup]].shuffle;
    player1 = Player.new(rand[0][0],:white);
    player2 = Player.new(rand[1][0],:black);
    setup1 = Chess.instance.setups[rand[0][1]];
    setup2 = Chess.instance.setups[rand[1][1]];
    game = mode.make_game([player1,player2],[setup1,setup2]);

    battle = BattleInfo.new(@battle_id,game);
    @battles.push(battle);
    @battle_id+=1;

    return battle;
  end
  #Определяет участвует ли игрок с данным id в бою
  # Возвращает этот бой если да
  def check_player_in_battle(player_id)
    res = @battles.index{|battle| battle.game.players.any?{|player| player.name==player_id}};
    if(res.nil?) then
      return nil;
    else
      return @battles[res];
    end
  end

  def end_battle(id, winner_id)
    #Здесь можно сделать с базой все что нужно

    @battles.delete_if { |battle| battle.id == id};
  end

end
