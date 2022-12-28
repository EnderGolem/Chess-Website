import { Controller } from "@hotwired/stimulus"
import {Chessboard, INPUT_EVENT_TYPE} from 'cm-chessboard'
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
                    gameChannel = consumer.subscriptions.create({channel: "GameChannel", number: 1}, {
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
                position: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
                responsive: true}
        )

        board.enableMoveInput(inputHandler)
        function inputHandler(event) {
            switch (event.type) {
                case INPUT_EVENT_TYPE.moveInputStarted:
                    console.log(`moveInputStarted: ${event.square}`)
                    return true
                case INPUT_EVENT_TYPE.validateMoveInput:
                    console.log(`validateMoveInput: ${event.squareFrom}-${event.squareTo}`)
                    gameChannel.send({sent_by: "Max", from: event.squareFrom,
                        to: event.squareTo, piece: board.getPiece(event.squareFrom)});
                    return true
                case INPUT_EVENT_TYPE.moveInputCanceled:
                    console.log(`moveInputCanceled`)
            }
        }
    }
}