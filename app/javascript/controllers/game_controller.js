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
                if(data["status"] == "starting_battle")
                {
                    queueChannel.send({act: "get_status"})
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
                            if(data["status"] == "current_state") {
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
        board = new Chessboard(document.getElementById("boardContainer"),
            {sprite: {url: "../chess/chessboard-sprite.svg"},
                position: "8/8/8/8/8/8/8/8 w KQkq - 0 1",
                responsive: true}
        )
    }
}