import fs from "fs/promises";
import { watch } from "fs";

export class LogReader {
    constructor() {
        this.filePath = 'app.log';
        this.logfile = null;
        this.currentPosition = 0;
    }

    async openFile() {
        if (!this.logfile) {
            this.logfile = await fs.open(this.filePath, "r");
            const stats = await this.logfile.stat();
            this.currentPosition = stats.size;
        }
    }

    async lastLines(totalLines = 10) {
        await this.openFile();
        const size = (await this.logfile.stat()).size;
        if (size === 0) return [];

        const chunkSize = 4096;
        let position = size;
        let leftover = '';
        let lines = [];

        while (position > 0 && lines.length < totalLines + 1) {
            const readSize = Math.min(chunkSize, position);
            position -= readSize;
            const buffer = Buffer.alloc(readSize);
            await this.logfile.read(buffer, 0, readSize, position);
            const chunkLines = (buffer.toString() + leftover).split("\n");

            leftover = chunkLines.shift();
            lines = chunkLines.concat(lines);
        }
        if (leftover) {
            lines.unshift(leftover);
        }
        return lines.slice(-totalLines);
    }

    async streamUpdates(callback) {
        await this.openFile();

        watch(this.filePath, async (eventType) => {
            if (eventType === "change") {
                try {
                    const stats = await this.logfile.stat();
                    const newSize = stats.size;

                    if (newSize > this.currentPosition) {
                        const readSize = newSize - this.currentPosition;
                        const buffer = Buffer.alloc(readSize);
                        await this.logfile.read(buffer, 0, readSize, this.currentPosition);
                        this.currentPosition = newSize;
                        callback(buffer.toString());
                    }
                } catch (error) {
                    console.error("Error reading file updates:", error);
                }
            }
        });
    }
}