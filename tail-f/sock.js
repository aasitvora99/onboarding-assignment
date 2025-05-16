import { LogReader } from "./logreader.js";


export const initSocket = (server) => {
    const logReader = new LogReader();
    console.log('logReader initialized', logReader);

    server.on("connection", async (socket) => {
        console.log("socket initialized")

        const lastLines = await logReader.lastLines();
        socket.emit("lastLines", lastLines.join("\n"));

        logReader.streamUpdates((data) => {
            socket.emit("newLine", data);
        });
    });
}