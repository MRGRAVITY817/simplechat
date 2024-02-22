// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import "./user_socket";
import socket from "./user_socket";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// Message list code

const ul = document.getElementById("msg-list"); // list of messages.
const name = document.getElementById("name"); // name of message sender
const msg = document.getElementById("msg"); // message input field
const send = document.getElementById("send"); // send message button

const channel = socket.channel("room:lobby", {}); // connect to chat "room"
channel.join(); // join the channel.

// Listening to 'shout' events and displaying messages.
channel.on("shout", (payload) => {
  render_message(payload);
});

// Send message to the server on "shout" channel
function sendMessage() {
  channel.push("shout", {
    name: name.value || "guest",
    message: msg.value,
    inserted_at: new Date(),
  });

  msg.value = ""; // clear the message input field.
  window.scrollTo(0, document.body.scrollHeight); // scroll to the bottom.
}

function render_message(payload) {
  const li = document.createElement("li");

  // Message HTML with Tailwind CSS
  li.innerHTML = `
  <div class="flex flex-row w-[95%] mx-2 border-b-[1px] border-slate-300 py-2">
    <div class="text-left w-1/5 font-semibold text-slate-800 break-words">
      ${payload.name}
      <div class="text-xs mr-1">
        <span class="font-thin">${formatDate(payload.inserted_at)}</span>
        <span>${formatTime(payload.inserted_at)}</span>
      </div>
    </div>
    <div class="flex w-3/5 mx-1 grow">
      ${payload.message}
    </div>
  </div>
  `;

  // Append message to the message list.
  ul.appendChild(li);
}

// Listen to the enter key press event to send the message.
msg.addEventListener("keypress", (e) => {
  if (e.key === "Enter") {
    sendMessage();
  }
});

// Listen to the send button click event to send the message, if message length is not empty.
send.addEventListener("click", () => {
  if (msg.value.length > 0) {
    sendMessage();
  }
});

// Format date as "YYYY/MM/DD"
function formatDate(datetime) {
  const date = new Date(datetime);
  return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
}

// Format time as "HH:MM:SS"
function formatTime(datetime) {
  const date = new Date(datetime);
  return `${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`;
}
