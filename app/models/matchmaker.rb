class Matchmaker
  include Singleton

  def initialize
    @queue_size = 0;
    @battle_num = 0;
  end

  def add_user
    @queue_size+=1;
    if(@queue_size==2)
      @queue_size=0;
      @battle_num+=1;
      return @battle_num;
    else
      return -1;
    end
  end
end
