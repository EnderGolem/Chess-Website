
class GameChannel < ApplicationCable::Channel
  # Вызывается, когда потребитель успешно
  # стал подписчиком этого канала
  def subscribed
    stream_from "battle_#{params[:number]}"

    mode = Chess.instance.modes["Classic"];
    player1 = Player.new("Player1",:white);
    player2 = Player.new("Player2",:black);
    setup1 = Chess.instance.setups["Mongols"];
    setup2 = Chess.instance.setups["Checkers"];
    game = mode.make_game([player1,player2],[setup1,setup2]);

    #ActionCable.server.broadcast("battle_#{params[:number]}", positionToFen(game.position));
    #ActionCable.server.broadcast("battle_#{params[:number]}", positionToFen(game.position));
   end

  def receive(data)
    mode = Chess.instance.modes["Classic"];
    player1 = Player.new("Player1",:white);
    player2 = Player.new("Player2",:black);
    setup1 = Chess.instance.setups["Mongols"];
    setup2 = Chess.instance.setups["Checkers"];
    game = mode.make_game([player1,player2],[setup1,setup2]);
    mnot = game.position.possible_moves.keys.select{
    |k| !(k.index(data["from"]).nil?) && !(k.index(data["to"]).nil?)};
    puts "mnot = #{mnot}";
    puts game.step!(mnot.first);

    ActionCable.server.broadcast("battle_#{params[:number]}", positionToFen(game.position));
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
end
