class QueueChannel < ApplicationCable::Channel
  # Вызывается, когда потребитель успешно
  # стал подписчиком этого канала
  def subscribed
    stream_from "queue"
    stream_for current_user
    puts current_user.username;
  end

  def unsubscribed

  end

  def receive(data)
    act = data["act"];

    if(act == "get_status") then
      puts "atong get status";
      status = Matchmaker.instance.user_status(current_user.id);
      if(status=="none") then
        broadcast_to(current_user,{status: "waiting"});
        res = Matchmaker.instance.add_user(current_user.id,"Classic");
        if(res > -1)
          ActionCable.server.broadcast("queue",{status: "starting_battle", });
        end
      elsif status=="in_battle"
        broadcast_to(current_user,{status: "in_battle",
                                   battle_id: Matchmaker.instance.get_user_battle_id(current_user.id)});
      elsif status=="in_queue"
        broadcast_to(current_user,{status: "waiting"});

      end
    end

  end

end
