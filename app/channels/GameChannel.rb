
class GameChannel < ApplicationCable::Channel
  # Вызывается, когда потребитель успешно
  # стал подписчиком этого канала
  def subscribed
    stream_from "battle_#{params[:number]}"
    stream_for current_user
    #ActionCable.server.broadcast("battle_#{params[:number]}", positionToFen(game.position));
    #ActionCable.server.broadcast("battle_#{params[:number]}", positionToFen(game.position));
   end

  def receive(data)
    act = data["act"];
    battle = Battlecontroller.instance.check_player_in_battle(current_user.id);
    if(battle.nil?) then
      return;
    end
    if(act == "get_position") then
      broadcast_to(current_user, {status: "current_state",
                                  position: positionToFen(battle.game.position),
                                  orientation:
                                    color_to_string(battle.game.players.select{|player|
                                      player.name == current_user.id}.first.color),
                                  turn_color: color_to_string(battle.game.position.get_cur_color_player),
                                  opponent_name: User.find_by(id: battle.game.players.select{|player|
                                    player.name != current_user.id}.first.name).username});


      if(battle.game.is_ended?) then

        # broadcast_to(current_user, {status: "game_ended",
        #                         orientation:
        #                               color_to_string(battle.game.players.select{|player|
        #                                 player.name == current_user.id}.first.color),
        #                             winner_color: color_to_string(battle.game.get_result.winners.first.first),
        #                             reason: "Checkmate!"});

        ActionCable.server.broadcast("battle_#{params[:number]}",{status: "game_ended",
                                                                  winner_color: color_to_string(battle.game.get_result.winners.first.first),
                                                                  reason: "Checkmate!"});

        end_game(battle.game.players.select{|player| player.color==battle.game.get_result.winners.first.first}.first.name);
      end
    elsif(act=="move")
      mnot = battle.game.position.possible_moves.keys.select{
        |k| !(k.index(data["from"]).nil?) && !(k.index(data["to"]).nil?)};
      #Проверка на рокировку
      if(data["piece"] == "wk" && data["from"] == "e1") then
        if(data["to"] == "g1") then
          mnot = ["0-0"];
        elsif(data["to"] == "c1")
          mnot = ["0-0-0"];
        end
      elsif(data["piece"] == "bk" && data["from"] == "e8")
        if(data["to"] == "g8") then
          mnot = ["0-0"];
        elsif(data["to"] == "c8")
          mnot = ["0-0-0"];
        end
      end
     battle.game.step!(mnot.first);

      ActionCable.server.broadcast("battle_#{params[:number]}", {status:"state_changed"});
    elsif(act == "surrender")
      ActionCable.server.broadcast("battle_#{params[:number]}",{status: "game_ended",
                                   winner_color: color_to_string(battle.game.players.select{|player|
                                     player.name != current_user.id}.first.color),
                                   reason: "Surrender!"});
      end_game(battle.game.players.select{|player|
        player.name != current_user.id}.first.name);
    end

  end

  private
  def positionToFen(position)
    res="";

    position.board.matrix.reverse_each do |line|
      empty_count = 0
      line.each do |elem|
        if elem.class == Integer then empty_count+=1
        elsif elem.class == Piece then
          if(empty_count>0) then
            res+=empty_count.to_s;
            empty_count = 0;
          end

          piecechar =
            if elem.piece_description.name == "Pawn" then
              "p"
            elsif elem.piece_description.name == "Rook" then
              "r"
            elsif elem.piece_description.name == "Bishop" then
              "b"
            elsif elem.piece_description.name == "Knight" then
              "n"
            elsif elem.piece_description.name == "King" then
              "k"
            elsif elem.piece_description.name == "Queen" then
              "q"
            elsif elem.piece_description.name == "Dame" then
              "q"
            elsif elem.piece_description.name == "Man" then
              "p"
            end

          if(elem.player_color == :white) then
            piecechar.upcase!;
          end

          res+=piecechar
        end
      end
      if(empty_count>0) then
        res+=empty_count.to_s;
        empty_count = 0;
      end
      res+="/";
    end
    res.delete_suffix!("/");

    return res;
  end

  def color_to_string(color)
    if(color==:white) then
      return "white";
    elsif(color==:black)
      return "black";
    end
  end

  def end_game(winner_id)
    Battlecontroller.instance.end_battle(params[:number],winner_id);
  end

end
