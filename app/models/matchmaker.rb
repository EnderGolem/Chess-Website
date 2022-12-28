class Matchmaker
  include Singleton

  def initialize
    @queue = Array.new
  end

  def add_user(user_id,user_setup)
    @queue.push([user_id,user_setup])
    if(@queue.count==2)
      battle = Battlecontroller.instance
                      .create_battle(Chess.instance.modes["Classic"],@queue[0][0],@queue[1][0],@queue[0][1],@queue[1][1]);
      @queue.pop(2)
      return battle.id;
    else
      return -1;
    end
  end

  def user_status(user_id)
    puts "user id = #{user_id}";
    if(@queue.any?{|hs| hs[0]==user_id}) then
      return "in_queue";
    elsif(!Battlecontroller.instance.check_player_in_battle(user_id).nil?)
      return "in_battle";
    else
      return "none";
    end
  end

  def get_user_battle_id(user_id)
    return Battlecontroller.instance.check_player_in_battle(user_id).id;
  end
end
