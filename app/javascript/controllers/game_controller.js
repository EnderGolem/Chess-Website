import { Controller } from "@hotwired/stimulus"
import {Chessboard, INPUT_EVENT_TYPE, COLOR} from 'cm-chessboard'
import consumer from "../channels/consumer";
let queueChannel;
let gameChannel;
let board;
export default class extends Controller {
    connect() {

        queueChannel = consumer.subscriptions.create({channel: "QueueChannel"}, {
            connected() {
                console.log("Adding to queue...")
                queueChannel.send({act: "get_status"})
            },

            disconnected() {
                // Called when the subscription has been terminated by the server
            },

            received(data) {
                // Called when there's incoming data on the websocket for this channel
                console.log("receive ")
                console.log("status = " + data["status"])
                if(data["status"] == "waiting")
                {
                   let info_text = document.getElementById("infoContainer");
                   info_text.textContent = "Waiting for opponent...";
                }
                else if(data["status"] == "starting_battle")
                {
                    queueChannel.send({act: "get_status"})
                    let info_text = document.getElementById("infoContainer");
                    info_text.textContent = "Starting game!";
                }
                else if(data["status"] == "in_battle")
                {
                    console.log("battle id = " + data["battle_id"])
                    gameChannel = consumer.subscriptions.create({channel: "GameChannel", number: data["battle_id"]}, {
                        connected() {
                            console.log("subscription")
                            gameChannel.send({act: "get_position"})
                        },

                        disconnected() {
                            // Called when the subscription has been terminated by the server
                        },

                        received(data) {
                            // Called when there's incoming data on the websocket for this channel
                            console.log("set position!")
                            let surrender_button = document.getElementById("surrender_button");
                            surrender_button.hidden = false
                            if(data["status"] == "current_state") {
                                let opponent_info_text = document.getElementById("opponentInfoContainer");
                                opponent_info_text.hidden = false;
                                opponent_info_text.textContent = data["opponent_name"];
                                board.setPosition(data["position"]);
                                console.log("orientation" + data["orientation"])
                                console.log("turn color" + data["turn_color"])
                                if(data["orientation"] == "white")
                                {
                                    board.setOrientation(COLOR.white)
                                }
                                else
                                {
                                    board.setOrientation(COLOR.black)
                                }
                                let info_text = document.getElementById("infoContainer");
                                if(data["turn_color"] == "white")
                                {
                                    info_text.textContent = "White turn!";
                                }
                                else
                                {
                                    info_text.textContent = "Black turn!";
                                }

                                if(data["orientation"] != data["turn_color"])
                                {
                                    board.disableMoveInput();
                                }
                                else
                                {
                                    board.enableMoveInput(inputHandler,(data["turn_color"]=="white")?COLOR.white:COLOR.black)
                                    function inputHandler(event) {
                                        switch (event.type) {
                                            case INPUT_EVENT_TYPE.moveInputStarted:
                                                console.log(`moveInputStarted: ${event.square}`)
                                                return true
                                            case INPUT_EVENT_TYPE.validateMoveInput:
                                                console.log(`validateMoveInput: ${event.squareFrom}-${event.squareTo}`)
                                                gameChannel.send({sent_by: "Max", act: "move" ,from: event.squareFrom,
                                                    to: event.squareTo, piece: board.getPiece(event.squareFrom)});
                                                return true
                                            case INPUT_EVENT_TYPE.moveInputCanceled:
                                                console.log(`moveInputCanceled`)
                                        }
                                    }
                                }
                            }
                            else if(data["status"] == "state_changed")
                            {
                                gameChannel.send({act: "get_position"})
                            }
                            else if(data["status"] == "game_ended")
                            {
                                let info_text = document.getElementById("infoContainer");
                                console.log("orientation: "+data["orientation"])
                                console.log("winner: "+data["winner_color"])
                                info_text.textContent = data["winner_color"]+" win! Reason: "+data["reason"];

                                /*if(data["orientation"] != data["winner_color"])
                                {
                                    info_text.textContent = data["winner_color"]+" win! Reason: "+data["reason"];
                                }
                                else
                                {
                                    info_text.textContent = "You win! Reason: "+data["reason"];
                                }*/
                            }
                        }
                    });
                }
            }
        });
        console.log("connect board!")
        /*gameChannel = consumer.subscriptions.create({channel: "GameChannel", number: 1}, {
            connected() {
                console.log("subscription")

            },

            disconnected() {
                // Called when the subscription has been terminated by the server
            },

            received(data) {
                // Called when there's incoming data on the websocket for this channel
                console.log("set position!")
                board.setPosition(data);
            }
        });*/

    }

    initialize(){
        console.log("Initialize board!")
        let opponent_info_text = document.getElementById("opponentInfoContainer");
        opponent_info_text.hidden = true;

        let surrender_button = document.getElementById("surrender_button");
        surrender_button.hidden = true
        surrender_button.onclick = function() {
            gameChannel.send({act: "surrender"})
        }

        board = new Chessboard(document.getElementById("boardContainer"),
            {sprite: {url: "../chess/chessboard-sprite.svg"},
                position: "8/8/8/8/8/8/8/8 w KQkq - 0 1",
                responsive: true}
        )
    }
}