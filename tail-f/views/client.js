const socket = io();
socket.on("connect", () => {
    console.log("Connected to WebSocket server");
});
const logContainer = document.getElementById("log-container");

socket.on("lastLines", (data) => {
    logContainer.innerText += "\n" + data;
});

socket.on("newLine", (data) => {
    console.log(data)
    logContainer.innerText += data ;
});
