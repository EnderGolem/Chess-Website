class Matchmaker
  include Singleton

  def initialize
    @queue = Array.new
    @battles = Hash.new
  end

  def add_user(user_id,user_mode)
    @queue.push([user_id,user_mode])
    if(@queue.count==2)
      @battles[@battles.count] = @queue.first(2);
      @queue.pop(2)
      return @battles.count - 1;
    else
      return -1;
    end
  end

  def user_status(user_id)
    puts "user id = #{user_id}";
    if(@queue.any?{|hs| hs[0]==user_id}) then
      return "in_queue";
    elsif(@battles.any?{|k,v| v.any?{|hs| hs[0]==user_id}})
      return "in_battle";
    else
      return "none";
    end
  end

  def get_user_battle_id(user_id)
    return @battles.select{|k,v| v.any?{|hs| hs[0]==user_id}}.first[0];
  end
end
